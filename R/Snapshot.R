# Minimum supported snapshot `Version`. PK-Sim v11.2 maps to numeric 79;
# anything below that uses pre-v11 conventions (notably `Applications|...`
# path segments instead of `Events|...`) that this package does not model.
SUPPORTED_VERSION_MIN <- 79L

# Default export adapter for a building-block section. Pairs with the
# per-section table `Snapshot$private$.export_adapters`; non-default sections
# (currently only ObservedData) supply their own adapter.
#
# Contract:
#   items     cache slot value: `NULL` (lazy cache untouched, replay original
#             verbatim), `list()` (cache touched and now empty), or a
#             non-empty list of R6 wrappers (extract each wrapper's `$data`).
#   original  the raw slice from `.original_data` (may be NULL).
#
# When `items` is `list()`, the cache could be empty either because the user
# removed every entry or because the lazy loader observed an absent/empty
# section. In the latter case `original` is also empty (`NULL` or `list()`),
# so falling through to `list()` faithfully represents the section as empty
# in both cases. The previously-buggy fallback to `original` re-introduced
# removed entries when the original slice was non-empty.
.default_export_adapter <- function(items, original) {
  if (is.null(items)) {
    return(original)
  }
  if (length(items) == 0) {
    # Preserve the historical NULL shape when the original slice was already
    # NULL or empty; only emit `list()` when the user actually cleared a
    # non-empty section.
    if (length(original) == 0) {
      return(original)
    }
    return(list())
  }
  lapply(items, function(item) item$data)
}

#' Snapshot class for OSP snapshots
#'
#' @description
#' An R6 class that represents an OSP snapshot file. This class provides
#' methods to access different components of the snapshot and visualize its
#' structure.
#'
#' # Supported snapshot versions
#'
#' `Snapshot` only accepts PK-Sim v11+ snapshots, i.e. integer `Version`
#' values of `79` or greater (see `osp.snapshots:::SUPPORTED_VERSION_MIN`).
#' Earlier snapshots use different conventions (notably `Applications|...`
#' instead of `Events|...` in parameter paths) and are not modelled by this
#' package; `Snapshot$new()` aborts on them rather than silently rewriting
#' fields. Hand-rolled list input must supply `Version` for the same reason.
#'
#' @importFrom R6 R6Class
#' @importFrom fs path_rel
#'
#' @export
Snapshot <- R6::R6Class(
  classname = "Snapshot",
  public = list(
    #' @description
    #' Create a new Snapshot object from a JSON file or a list
    #' @param input Path to the snapshot JSON file, URL, template name, or a
    #'   list containing snapshot data. The parsed data must contain an
    #'   integer `Version` field of `79` (v11.2) or greater; older or missing
    #'   versions abort.
    #' @return A new Snapshot object
    initialize = function(input) {
      if (is.character(input)) {
        cli::cli_alert_info("Reading snapshot from {.file {input}}")
        # Store as absolute path
        if (file.exists(input)) {
          private$.abs_path <- normalizePath(input, mustWork = TRUE)
        } else {
          private$.abs_path <- input # Keep URLs as is
        }
        private$.original_data <- jsonlite::fromJSON(
          txt = input,
          simplifyDataFrame = FALSE,
          simplifyVector = FALSE
        )
      } else if (is.list(input)) {
        cli::cli_alert_info("Creating snapshot from list data")
        private$.original_data <- input
      } else {
        cli::cli_abort("Input must be either a path to a JSON file or a list")
      }

      private$.validate_version()

      # Building-block collections are constructed lazily on first access via
      # their active bindings; all `private$.<kind>` caches stay NULL here.

      cli::cli_alert_success("Snapshot loaded successfully")
    },
    #' @description
    #' Print a summary of the snapshot
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the snapshot object
    print = function(...) {
      # Use cli_format_method for beautiful CLI formatting
      output <- cli::cli_format_method({
        cli::cli_h1("PKSIM Snapshot")

        # Version information
        raw_version <- private$.original_data$Version
        pksim_version <- self$pksim_version
        cli::cli_alert_info("Version: {raw_version} (PKSIM {pksim_version})")

        # Display path if available
        if (!is.null(private$.abs_path)) {
          cli::cli_alert_info("Path: {.file {self$path}}")
        }

        # Get all sections dynamically from the data
        # We'll exclude Version as it's already displayed
        sections <- names(self$data)[names(self$data) != "Version"]

        # Display counts for each section in alphabetical order
        if (length(sections) > 0) {
          for (section in sort(sections)) {
            # Only display sections that are lists (collections)
            if (is.list(self$data[[section]])) {
              items <- self$data[[section]]
              count <- length(items)
              cli::cli_li("{section}: {count}")
            }
          }
        }
      })

      # Use cat for consistent output with other print methods
      cat(output, sep = "\n")

      # Return invisibly for method chaining
      invisible(self)
    },

    #' @description
    #' Export the snapshot to a JSON file
    #' @param path Path to save the JSON file
    #' @return Invisibly returns the object
    export = function(path) {
      # Convert to absolute path
      abs_path <- normalizePath(path, mustWork = FALSE)

      jsonlite::write_json(
        self$data,
        abs_path,
        auto_unbox = TRUE,
        pretty = TRUE,
        digits = NA
      )

      # Store the absolute path
      private$.abs_path <- abs_path

      cli::cli_alert_success("Snapshot exported to {.file {self$path}}")
      invisible(self)
    },

    #' @description
    #' Add an Individual object to the snapshot
    #' @param individual An Individual object created with create_individual()
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Create a new individual
    #' ind <- create_individual(name = "New Patient", age = 35, weight = 70)
    #'
    #' # Add the individual to a snapshot
    #' snapshot$add_individual(ind)
    #' }
    add_individual = function(individual) {
      private$.add_block(
        obj = individual,
        expected_class = "Individual",
        class_article = "an",
        slot = ".individuals",
        named_slot = ".individuals_named",
        ensure = private$.ensure_individuals,
        collection_class = "individual_collection",
        label = "individual"
      )
    },

    #' @description
    #' Remove an individual from the snapshot by name
    #' @param individual_name Character vector of individual name(s) to remove
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Remove an individual from the snapshot
    #' snapshot$remove_individual("Subject_001")
    #' }
    remove_individual = function(individual_name) {
      private$.remove_block(
        input_keys = individual_name,
        slot = ".individuals",
        named_slot = ".individuals_named",
        ensure = private$.ensure_individuals,
        collection_class = "individual_collection",
        label_singular_title = "Individual",
        label_plural = "individuals",
        label_count = "individual(s)"
      )
    },

    #' @description
    #' Add a Formulation object to the snapshot
    #' @param formulation A Formulation object created with create_formulation()
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Create a new formulation
    #' form <- create_formulation(name = "Tablet", type = "Weibull")
    #'
    #' # Add the formulation to a snapshot
    #' snapshot$add_formulation(form)
    #' }
    add_formulation = function(formulation) {
      private$.add_block(
        obj = formulation,
        expected_class = "Formulation",
        class_article = "a",
        slot = ".formulations",
        named_slot = ".formulations_named",
        ensure = private$.ensure_formulations,
        collection_class = "formulation_collection",
        label = "formulation"
      )
    },

    #' @description
    #' Remove a formulation from the snapshot by name
    #' @param formulation_name Character vector of formulation name(s) to remove
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Remove a formulation from the snapshot
    #' snapshot$remove_formulation("Tablet")
    #' }
    remove_formulation = function(formulation_name) {
      private$.remove_block(
        input_keys = formulation_name,
        slot = ".formulations",
        named_slot = ".formulations_named",
        ensure = private$.ensure_formulations,
        collection_class = "formulation_collection",
        label_singular_title = "Formulation",
        label_plural = "formulations",
        label_count = "formulation(s)"
      )
    },

    #' @description
    #' Remove a population from the snapshot by name
    #' @param population_name Character vector of population name(s) to remove
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Remove a population from the snapshot
    #' snapshot$remove_population("pop_1")
    #' }
    remove_population = function(population_name) {
      private$.remove_block(
        input_keys = population_name,
        slot = ".populations",
        named_slot = ".populations_named",
        ensure = private$.ensure_populations,
        collection_class = "population_collection",
        label_singular_title = "Population",
        label_plural = "populations",
        label_count = "population(s)"
      )
    },

    #' @description
    #' Add an ExpressionProfile object to the snapshot
    #' @param expression_profile An ExpressionProfile object
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Create a new expression profile
    #' profile_data <- list(
    #'   Type = "Enzyme",
    #'   Species = "Human",
    #'   Molecule = "CYP3A4",
    #'   Category = "Healthy",
    #'   Parameters = list()
    #' )
    #' profile <- ExpressionProfile$new(profile_data)
    #'
    #' # Add the expression profile to a snapshot
    #' snapshot$add_expression_profile(profile)
    #' }
    add_expression_profile = function(expression_profile) {
      private$.add_block(
        obj = expression_profile,
        expected_class = "ExpressionProfile",
        class_article = "an",
        slot = ".expression_profiles",
        named_slot = ".expression_profiles_named",
        ensure = private$.ensure_expression_profiles,
        collection_class = "expression_profile_collection",
        key_fn = \(x) x$id,
        label = "expression profile",
        display_fn = \(x) x$molecule
      )
    },

    #' @description
    #' Remove expression profiles from the snapshot by ID
    #' @param profile_id Character vector of expression profile IDs to remove
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Remove an expression profile from the snapshot
    #' snapshot$remove_expression_profile("CYP3A4_Human_Healthy")
    #' }
    remove_expression_profile = function(profile_id) {
      private$.remove_block(
        input_keys = profile_id,
        slot = ".expression_profiles",
        named_slot = ".expression_profiles_named",
        ensure = private$.ensure_expression_profiles,
        collection_class = "expression_profile_collection",
        key_fn = \(x) x$id,
        label_singular_title = "Expression profile",
        label_plural = "expression profiles",
        label_count = "expression profile(s)"
      )
    },

    add_observer_set = function(observer_set) {
      private$.add_block(
        obj = observer_set,
        expected_class = "ObserverSet",
        class_article = "an",
        slot = ".observer_sets",
        named_slot = ".observer_sets_named",
        ensure = private$.ensure_observer_sets,
        collection_class = "observer_set_collection",
        label = "observer set"
      )
    },

    remove_observer_set = function(observer_set_name) {
      private$.remove_block(
        input_keys = observer_set_name,
        slot = ".observer_sets",
        named_slot = ".observer_sets_named",
        ensure = private$.ensure_observer_sets,
        collection_class = "observer_set_collection",
        label_singular_title = "Observer set",
        label_plural = "observer sets",
        label_count = "observer set(s)"
      )
    },

    #' @description
    #' Add a DataSet object (observed data) to the snapshot
    #' @param observed_data A DataSet object created from snapshot observed data
    #' @return Invisibly returns the object
    add_observed_data = function(observed_data) {
      private$.add_block(
        obj = observed_data,
        expected_class = "DataSet",
        class_article = "a",
        slot = ".observed_data",
        named_slot = ".observed_data_named",
        ensure = private$.ensure_observed_data,
        collection_class = "observed_data_collection",
        label = "observed data",
        pre_add = function(obj) {
          # Warn once at add time if the new DataSet has no backing JSON slice
          # in `.original_data`; `ospsuite::DataSet` does not round-trip back
          # to the snapshot list shape, so such entries are dropped on export.
          # Warning here (rather than inside the export adapter) keeps
          # `print()` and other `$data` accesses quiet.
          original <- private$.original_data$ObservedData
          original_names <- if (is.null(original)) {
            character()
          } else {
            vapply(
              original,
              function(od) od$Name %||% od$name,
              character(1)
            )
          }
          if (!(obj$name %in% original_names)) {
            cli::cli_warn(c(
              "Observed data {.val {obj$name}} cannot be serialized on export.",
              i = "{.cls DataSet} objects have no {.code $data} accessor; only entries present in the original snapshot are exported."
            ))
          }
        }
      )
    },

    #' @description
    #' Remove observed data from the snapshot by name
    #' @param observed_data_name Character vector of observed data names to remove
    #' @return Invisibly returns the object
    remove_observed_data = function(observed_data_name) {
      private$.remove_block(
        input_keys = observed_data_name,
        slot = ".observed_data",
        named_slot = ".observed_data_named",
        ensure = private$.ensure_observed_data,
        collection_class = "observed_data_collection",
        label_singular_title = "Observed data",
        label_plural = "observed data",
        label_count = "observed data item(s)"
      )
    },

    add_compound = function(compound) {
      private$.add_block(
        obj = compound,
        expected_class = "Compound",
        class_article = "a",
        slot = ".compounds",
        named_slot = ".compounds_named",
        ensure = private$.ensure_compounds,
        collection_class = "compound_collection",
        label = "compound"
      )
    },

    remove_compound = function(compound_name) {
      private$.remove_block(
        input_keys = compound_name,
        slot = ".compounds",
        named_slot = ".compounds_named",
        ensure = private$.ensure_compounds,
        collection_class = "compound_collection",
        label_singular_title = "Compound",
        label_plural = "compounds",
        label_count = "compound(s)"
      )
    },

    add_population = function(population) {
      private$.add_block(
        obj = population,
        expected_class = "Population",
        class_article = "a",
        slot = ".populations",
        named_slot = ".populations_named",
        ensure = private$.ensure_populations,
        collection_class = "population_collection",
        label = "population"
      )
    },

    add_protocol = function(protocol) {
      private$.add_block(
        obj = protocol,
        expected_class = "Protocol",
        class_article = "a",
        slot = ".protocols",
        named_slot = ".protocols_named",
        ensure = private$.ensure_protocols,
        collection_class = "protocol_collection",
        label = "protocol"
      )
    },

    remove_protocol = function(protocol_name) {
      private$.remove_block(
        input_keys = protocol_name,
        slot = ".protocols",
        named_slot = ".protocols_named",
        ensure = private$.ensure_protocols,
        collection_class = "protocol_collection",
        label_singular_title = "Protocol",
        label_plural = "protocols",
        label_count = "protocol(s)"
      )
    },

    add_event = function(event) {
      private$.add_block(
        obj = event,
        expected_class = "Event",
        class_article = "an",
        slot = ".events",
        named_slot = ".events_named",
        ensure = private$.ensure_events,
        collection_class = "event_collection",
        label = "event"
      )
    },

    remove_event = function(event_name) {
      private$.remove_block(
        input_keys = event_name,
        slot = ".events",
        named_slot = ".events_named",
        ensure = private$.ensure_events,
        collection_class = "event_collection",
        label_singular_title = "Event",
        label_plural = "events",
        label_count = "event(s)"
      )
    }
  ),
  active = list(
    #' @field data The aggregated data of the snapshot from all components
    data = function() {
      result <- private$.original_data
      for (section in names(private$.export_adapters)) {
        spec <- private$.export_adapters[[section]]
        result[[section]] <- spec$adapter(
          private[[spec$cache]],
          private$.original_data[[section]]
        )
      }
      result
    },

    #' @field pksim_version The human-readable PKSIM version corresponding to the snapshot version
    pksim_version = function() {
      if (is.null(private$.pksim_version)) {
        private$.pksim_version <- private$.get_pksim_version()
      } else {
        private$.pksim_version
      }
    },

    #' @field path The path to the snapshot file relative to the working directory
    path = function() {
      if (is.null(private$.abs_path)) {
        return(NULL)
      }

      # If it's a URL, return as is
      if (grepl("^https?://", private$.abs_path)) {
        return(private$.abs_path)
      }

      # Use fs::path_rel to get the relative path
      return(fs::path_rel(private$.abs_path, start = getwd()))
    },

    #' @field compounds List of Compound objects in the snapshot
    compounds = function(value = NULL) {
      if (!is.null(value)) {
        private$.compounds <- value
        private$.compounds_named <- NULL
      }
      private$.ensure_compounds()
      if (is.null(private$.compounds_named)) {
        private$.compounds_named <- private$.build_named_list(
          private$.compounds,
          "compound_collection"
        )
      }
      private$.compounds_named
    },

    #' @field expression_profiles List of ExpressionProfile objects in the snapshot
    expression_profiles = function(value = NULL) {
      if (!is.null(value)) {
        private$.expression_profiles <- value
        private$.expression_profiles_named <- NULL
      }
      private$.ensure_expression_profiles()
      if (is.null(private$.expression_profiles_named)) {
        private$.expression_profiles_named <- private$.build_named_list(
          private$.expression_profiles,
          "expression_profile_collection",
          key_fn = \(x) x$id
        )
      }
      private$.expression_profiles_named
    },

    #' @field individuals List of Individual objects in the snapshot
    individuals = function(value = NULL) {
      if (!is.null(value)) {
        private$.individuals <- value
        private$.individuals_named <- NULL
      }
      private$.ensure_individuals()
      if (is.null(private$.individuals_named)) {
        private$.individuals_named <- private$.build_named_list(
          private$.individuals,
          "individual_collection"
        )
      }
      private$.individuals_named
    },

    #' @field formulations List of Formulation objects in the snapshot
    formulations = function(value = NULL) {
      if (!is.null(value)) {
        private$.formulations <- value
        private$.formulations_named <- NULL
      }
      private$.ensure_formulations()
      if (is.null(private$.formulations_named)) {
        private$.formulations_named <- private$.build_named_list(
          private$.formulations,
          "formulation_collection"
        )
      }
      private$.formulations_named
    },

    #' @field populations List of Population objects in the snapshot
    populations = function(value = NULL) {
      if (!is.null(value)) {
        private$.populations <- value
        private$.populations_named <- NULL
      }
      private$.ensure_populations()
      if (is.null(private$.populations_named)) {
        private$.populations_named <- private$.build_named_list(
          private$.populations,
          "population_collection"
        )
      }
      private$.populations_named
    },

    #' @field events List of Event objects in the snapshot
    events = function(value = NULL) {
      if (!is.null(value)) {
        private$.events <- value
        private$.events_named <- NULL
      }
      private$.ensure_events()
      if (is.null(private$.events_named)) {
        private$.events_named <- private$.build_named_list(
          private$.events,
          "event_collection"
        )
      }
      private$.events_named
    },

    #' @field observer_sets List of ObserverSet objects in the snapshot
    observer_sets = function(value = NULL) {
      if (!is.null(value)) {
        private$.observer_sets <- value
        private$.observer_sets_named <- NULL
      }
      private$.ensure_observer_sets()
      if (is.null(private$.observer_sets_named)) {
        private$.observer_sets_named <- private$.build_named_list(
          private$.observer_sets,
          "observer_set_collection"
        )
      }
      private$.observer_sets_named
    },

    #' @field protocols List of Protocol objects in the snapshot
    protocols = function(value = NULL) {
      if (!is.null(value)) {
        private$.protocols <- value
        private$.protocols_named <- NULL
      }
      private$.ensure_protocols()
      if (is.null(private$.protocols_named)) {
        private$.protocols_named <- private$.build_named_list(
          private$.protocols,
          "protocol_collection"
        )
      }
      private$.protocols_named
    },

    #' @field observed_data List of DataSet objects (observed data) in the snapshot
    observed_data = function(value = NULL) {
      if (!is.null(value)) {
        private$.observed_data <- value
        private$.observed_data_named <- NULL
      }
      private$.ensure_observed_data()
      if (is.null(private$.observed_data_named)) {
        private$.observed_data_named <- private$.build_named_list(
          private$.observed_data,
          "observed_data_collection"
        )
      }
      private$.observed_data_named
    }
  ),
  private = list(
    .original_data = NULL,
    .pksim_version = NULL,
    .abs_path = NULL,

    # Abort when the parsed snapshot is missing `Version` or sits below the
    # supported v11+ floor. Below v11, snapshots use `Applications|...` in
    # localized parameter paths and other older conventions this package does
    # not model; refusing them is preferable to silently rewriting fields.
    .validate_version = function() {
      raw <- private$.original_data$Version
      # `unlist()` guards against list-wrapped values (jsonlite is configured
      # with `simplifyVector = FALSE`, so scalars can arrive as length-1 lists).
      version_num <- suppressWarnings(as.integer(unlist(raw)))
      if (
        is.null(raw) ||
          length(version_num) != 1 ||
          is.na(version_num)
      ) {
        cli::cli_abort(c(
          "Snapshot is missing an integer {.field Version} field.",
          i = "{.pkg osp.snapshots} requires PK-Sim v11+ snapshots ({.field Version} >= {SUPPORTED_VERSION_MIN})."
        ))
      }
      if (version_num < SUPPORTED_VERSION_MIN) {
        cli::cli_abort(c(
          "Unsupported snapshot {.field Version} {version_num}.",
          i = "{.pkg osp.snapshots} requires PK-Sim v11+ snapshots ({.field Version} >= {SUPPORTED_VERSION_MIN})."
        ))
      }
    },

    # Per-section export adapter table used by `$data` to rebuild the export
    # payload. Each entry pairs a private cache slot with an adapter function
    # `adapter(items, original)` that turns the lazy cache + the raw slice
    # from `.original_data` into the value to write back. Most sections use
    # the default building-block adapter; ObservedData has its own carve-out
    # co-located with `R/ObservedData.R` (see `.observed_data_export_adapter`).
    .export_adapters = list(
      Compounds = list(
        cache = ".compounds",
        adapter = .default_export_adapter
      ),
      ExpressionProfiles = list(
        cache = ".expression_profiles",
        adapter = .default_export_adapter
      ),
      Individuals = list(
        cache = ".individuals",
        adapter = .default_export_adapter
      ),
      Formulations = list(
        cache = ".formulations",
        adapter = .default_export_adapter
      ),
      Populations = list(
        cache = ".populations",
        adapter = .default_export_adapter
      ),
      Events = list(
        cache = ".events",
        adapter = .default_export_adapter
      ),
      Protocols = list(
        cache = ".protocols",
        adapter = .default_export_adapter
      ),
      ObserverSets = list(
        cache = ".observer_sets",
        adapter = .default_export_adapter
      ),
      ObservedData = list(
        cache = ".observed_data",
        adapter = .observed_data_export_adapter
      )
    ),

    # Convert the raw version number to a human-readable PKSIM version
    # Returns a string with the human-readable PKSIM version
    .get_pksim_version = function() {
      version_num <- as.integer(unlist(private$.original_data$Version))

      pksim_version <- switch(
        as.character(version_num),
        "80" = "12.0",
        "79" = "11.2",
        "Unknown"
      )

      return(pksim_version)
    },

    # Lazily build the unnamed object list for a building-block collection.
    # On first call, walks the matching section of `private$.original_data`
    # and wraps each item with `ctor`; the cache slot stays an empty list
    # when the section is absent or empty. Idempotent on the cache.
    .ensure_collection = function(cache_name, section_name, ctor) {
      if (!is.null(private[[cache_name]])) {
        return(invisible(NULL))
      }
      section <- private$.original_data[[section_name]]
      if (is.null(section)) {
        private[[cache_name]] <- list()
      } else {
        private[[cache_name]] <- lapply(section, ctor)
      }
      invisible(NULL)
    },

    .ensure_compounds = function() {
      private$.ensure_collection(
        ".compounds",
        "Compounds",
        function(d) Compound$new(d)
      )
    },

    .ensure_expression_profiles = function() {
      private$.ensure_collection(
        ".expression_profiles",
        "ExpressionProfiles",
        function(d) ExpressionProfile$new(d)
      )
    },

    .ensure_individuals = function() {
      private$.ensure_collection(
        ".individuals",
        "Individuals",
        function(d) Individual$new(d)
      )
    },

    .ensure_formulations = function() {
      private$.ensure_collection(
        ".formulations",
        "Formulations",
        function(d) Formulation$new(d)
      )
    },

    .ensure_populations = function() {
      private$.ensure_collection(
        ".populations",
        "Populations",
        function(d) Population$new(d)
      )
    },

    .ensure_events = function() {
      private$.ensure_collection(
        ".events",
        "Events",
        function(d) Event$new(d)
      )
    },

    .ensure_protocols = function() {
      private$.ensure_collection(
        ".protocols",
        "Protocols",
        function(d) Protocol$new(d)
      )
    },

    .ensure_observer_sets = function() {
      private$.ensure_collection(
        ".observer_sets",
        "ObserverSets",
        function(d) ObserverSet$new(d)
      )
    },

    .ensure_observed_data = function() {
      private$.ensure_collection(
        ".observed_data",
        "ObservedData",
        function(d) loadDataSetFromSnapshot(d)
      )
    },

    # Store compound objects in an unnamed list
    .compounds = NULL,

    # Cache for the named compounds list with disambiguated names
    .compounds_named = NULL,

    # Store expression profile objects in an unnamed list
    .expression_profiles = NULL,

    # Cache for the named expression profiles list with disambiguated names
    .expression_profiles_named = NULL,

    # Store individual objects in an unnamed list
    .individuals = NULL,

    # Cache for the named individuals list with disambiguated names
    .individuals_named = NULL,

    # Store formulation objects in an unnamed list
    .formulations = NULL,

    # Cache for the named formulations list with disambiguated names
    .formulations_named = NULL,

    # Store population objects in an unnamed list
    .populations = NULL,

    # Cache for the named populations list with disambiguated names
    .populations_named = NULL,

    # Store event objects in an unnamed list
    .events = NULL,

    # Cache for the named events list with disambiguated names
    .events_named = NULL,

    # Store protocol objects in an unnamed list
    .protocols = NULL,

    # Cache for the named protocols list with disambiguated names
    .protocols_named = NULL,

    # Store observer set objects in an unnamed list
    .observer_sets = NULL,

    # Cache for the named observer sets list with disambiguated names
    .observer_sets_named = NULL,

    # Store observed data objects in an unnamed list.
    # Tri-state sentinel used by the export path in `$data`:
    #   NULL          = lazy cache untouched, export from `.original_data`.
    #   list()        = cleared by the user, drop ObservedData from export.
    #   non-empty     = filter `.original_data` down to surviving names.
    # Only the first and third states are reachable from the public API today;
    # the cleared state is reachable via `remove_observed_data()` removing all
    # entries.
    .observed_data = NULL,

    # Cache for the named observed data list with disambiguated names
    .observed_data_named = NULL,

    # Shared append routine for `add_<kind>` methods. Validates `obj` against
    # `expected_class`, forces lazy construction of the cache via `ensure()`,
    # appends the new object to the unnamed cache slot, rebuilds the named
    # cache via `.build_named_list`, and emits a success message. `pre_add`,
    # when supplied, is run after the class check but before mutation; it is
    # used by `add_observed_data` to warn about un-serializable DataSets.
    .add_block = function(
      obj,
      expected_class,
      slot,
      named_slot,
      ensure,
      collection_class,
      label,
      key_fn = \(x) x$name,
      display_fn = \(x) x$name,
      class_article = "a",
      pre_add = NULL
    ) {
      if (!inherits(obj, expected_class)) {
        cli::cli_abort(
          "Expected {class_article} {expected_class} object, but got {.cls {class(obj)[1]}}",
          call = rlang::caller_env()
        )
      }

      if (!is.null(pre_add)) {
        pre_add(obj)
      }

      ensure()

      private[[slot]] <- c(private[[slot]], list(obj))

      private[[named_slot]] <- private$.build_named_list(
        private[[slot]],
        collection_class,
        key_fn = key_fn
      )

      cli::cli_alert_success(
        "Added {label} '{display_fn(obj)}' to the snapshot"
      )
      invisible(self)
    },

    # Shared filter routine for `remove_<kind>` methods. Forces lazy
    # construction, warns and bails when the collection is empty, warns once
    # per missing key, filters by `key_fn`, rebuilds the named cache, and
    # emits a success count message. Empty-after-removal leaves the cache
    # slot as `list()`, never `NULL`; for `.observed_data` this preserves
    # the tri-state sentinel that `$data` reads for export gating.
    .remove_block = function(
      input_keys,
      slot,
      named_slot,
      ensure,
      collection_class,
      label_singular_title,
      label_plural,
      label_count,
      key_fn = \(x) x$name
    ) {
      ensure()

      if (length(private[[slot]]) == 0) {
        cli::cli_warn("No {label_plural} to remove")
        return(invisible(self))
      }

      current_keys <- vapply(private[[slot]], key_fn, character(1))

      for (key in unique(input_keys)) {
        if (!(key %in% current_keys)) {
          cli::cli_warn(
            "{label_singular_title} '{key}' not found in snapshot"
          )
        }
      }

      keep_indices <- which(!(current_keys %in% input_keys))
      num_removed <- length(current_keys) - length(keep_indices)
      private[[slot]] <- private[[slot]][keep_indices]

      private[[named_slot]] <- private$.build_named_list(
        private[[slot]],
        collection_class,
        key_fn = key_fn
      )

      cli::cli_alert_success(
        "Removed {num_removed} {label_count}"
      )
      invisible(self)
    },

    # Build a named list from a building-block collection, disambiguating
    # duplicate keys by appending "_{n}" suffixes. `key_fn` extracts the
    # lookup key from each item (typically the building-block's `$name`
    # field, but ExpressionProfile uses the composite
    # `Molecule|Species|Category` id).
    .build_named_list = function(
      items,
      collection_class,
      key_fn = \(x) x$name
    ) {
      if (length(items) == 0) {
        return(as_snapshot_collection(list(), collection_class))
      }

      keys <- vapply(items, key_fn, character(1))
      names(items) <- disambiguate_names(keys)
      as_snapshot_collection(items, collection_class)
    }
  )
)

#' Load a snapshot from various sources
#'
#' @description
#' Conveniently load an OSP snapshot from a local file, URL, or predefined template name.
#'
#' @param source Character string. Can be:
#'
#'   - Path to a local file (.json)
#'   - URL to a remote snapshot file
#'   - Name of a template from the OSPSuite.BuildingBlockTemplates repository
#'
#' @details
#' Available templates can be listed with `osp_models()`.
#'
#' @return A Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load from local file
#' snapshot <- load_snapshot("path/to/local/snapshot.json")
#'
#' # Load from URL
#' snapshot <- load_snapshot("https://example.com/snapshot.json")
#'
#' # Load a predefined template by name
#' snapshot <- load_snapshot("Midazolam")
#' }
load_snapshot <- function(source) {
  if (is.null(source) || !is.character(source) || length(source) != 1) {
    cli::cli_abort("Source must be a single character string")
  }

  # Check if source is a local file
  if (file.exists(source) && grepl("\\.json$", source, ignore.case = TRUE)) {
    return(Snapshot$new(source))
  }

  # Check if source is a URL
  if (grepl("^https?://", source)) {
    cli::cli_alert_info("Downloading snapshot from URL: {.url {source}}")
    tryCatch(
      {
        # Download and parse JSON directly without saving to file
        json_data <- jsonlite::fromJSON(
          source,
          simplifyDataFrame = FALSE,
          simplifyVector = FALSE
        )
        return(Snapshot$new(json_data))
      },
      error = function(e) {
        cli::cli_abort(
          "Failed to download snapshot from URL: {source}\nError: {e$message}"
        )
      }
    )
  }

  # If not a file or URL, try to find it in the templates list
  cli::cli_alert_info("Looking for template: {source}")

  tryCatch(
    {
      # Use helper function to get templates data
      templates_df <- .get_templates_data()

      # Find the template with matching name (case insensitive)
      template_idx <- which(
        tolower(templates_df$Name) == tolower(source)
      )

      if (length(template_idx) == 0) {
        # Provide helpful error message with available templates
        cli::cli_abort(c(
          "No template found with name: {source}",
          "i" = "Use osp_models() to see all available templates"
        ))
      }

      template_url <- templates_df$Url[template_idx[1]]
      cli::cli_alert_info("Found template: {template_url}")

      # Download and parse template JSON directly
      json_data <- jsonlite::fromJSON(
        template_url,
        simplifyDataFrame = FALSE,
        simplifyVector = FALSE
      )
      return(Snapshot$new(json_data))
    },
    error = function(e) {
      cli::cli_abort(
        "Failed to find or download template: {source}\nError: {e$message}"
      )
    }
  )
}

# Helper function to get templates data
# This is used by both load_snapshot and osp_models
.get_templates_data <- function() {
  templates_url <- "https://raw.githubusercontent.com/Open-Systems-Pharmacology/OSPSuite.BuildingBlockTemplates/refs/heads/develop/templates.json"

  # Download and parse templates JSON directly
  templates <- jsonlite::fromJSON(templates_url)

  if (is.null(templates$Templates) || nrow(templates$Templates) == 0) {
    cli::cli_abort("No templates found in the repository")
  }

  return(templates$Templates)
}

#' Add an individual to a snapshot
#'
#' @description
#' Add an Individual object to a Snapshot. This is a convenience function
#' that calls the add_individual method of the Snapshot class.
#'
#' @param snapshot A Snapshot object
#' @param individual An Individual object created with create_individual()
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Create a new individual
#' ind <- create_individual(name = "New Patient", age = 35, weight = 70)
#'
#' # Add the individual to the snapshot
#' snapshot <- add_individual(snapshot, ind)
#' }
add_individual <- function(snapshot, individual) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Call the add_individual method of the Snapshot class
  snapshot$add_individual(individual)

  # Return the updated snapshot
  invisible(snapshot)
}

#' Remove individuals from a snapshot
#'
#' @description
#' Remove one or more individuals from a Snapshot by name.
#'
#' @param snapshot A Snapshot object
#' @param individual_name Character vector of individual names to remove
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Remove a single individual
#' snapshot <- remove_individual(snapshot, "Subject_001")
#'
#' # Remove multiple individuals
#' snapshot <- remove_individual(
#'   snapshot,
#'   c("Subject_001", "Subject_002")
#' )
#' }
remove_individual <- function(snapshot, individual_name) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Call the remove_individual method of the Snapshot class
  snapshot$remove_individual(individual_name)

  # Return the updated snapshot
  invisible(snapshot)
}

#' Add a formulation to a snapshot
#'
#' @description
#' Add a Formulation object to a Snapshot. This is a convenience function
#' that calls the add_formulation method of the Snapshot class.
#'
#' @param snapshot A Snapshot object
#' @param formulation A Formulation object created with create_formulation()
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Create a new formulation
#' form <- create_formulation(name = "Tablet", type = "Weibull")
#'
#' # Add the formulation to the snapshot
#' snapshot <- add_formulation(snapshot, form)
#' }
add_formulation <- function(snapshot, formulation) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Call the add_formulation method of the Snapshot class
  snapshot$add_formulation(formulation)

  # Return the updated snapshot
  invisible(snapshot)
}

#' Remove formulations from a snapshot
#'
#' @description
#' Remove one or more formulations from a Snapshot by name.
#'
#' @param snapshot A Snapshot object
#' @param formulation_name Character vector of formulation names to remove
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Remove a single formulation
#' snapshot <- remove_formulation(snapshot, "Tablet")
#'
#' # Remove multiple formulations
#' snapshot <- remove_formulation(
#'   snapshot,
#'   c("Tablet", "Oral solution")
#' )
#' }
remove_formulation <- function(snapshot, formulation_name) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Call the remove_formulation method of the Snapshot class
  snapshot$remove_formulation(formulation_name)

  # Return the updated snapshot
  invisible(snapshot)
}

#' Remove populations from a snapshot
#'
#' @description
#' Remove one or more populations from a Snapshot by name.
#'
#' @param snapshot A Snapshot object
#' @param population_name Character vector of population names to remove
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Remove a single population
#' snapshot <- remove_population(snapshot, "pop_1")
#'
#' # Remove multiple populations
#' snapshot <- remove_population(
#'   snapshot,
#'   c("pop_1", "pop_2")
#' )
#' }
remove_population <- function(snapshot, population_name) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Call the remove_population method of the Snapshot class
  snapshot$remove_population(population_name)

  # Return the updated snapshot
  invisible(snapshot)
}

#' Add an expression profile to a snapshot
#'
#' @description
#' Add an ExpressionProfile object to a Snapshot. This is a convenience function
#' that calls the add_expression_profile method of the Snapshot class.
#'
#' @param snapshot A Snapshot object
#' @param expression_profile An ExpressionProfile object
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Create a new expression profile
#' profile_data <- list(
#'   Type = "Enzyme",
#'   Species = "Human",
#'   Molecule = "CYP3A4",
#'   Category = "Healthy",
#'   Parameters = list()
#' )
#' profile <- ExpressionProfile$new(profile_data)
#'
#' # Add the expression profile to the snapshot
#' snapshot <- add_expression_profile(snapshot, profile)
#' }
add_expression_profile <- function(snapshot, expression_profile) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Call the add_expression_profile method of the Snapshot class
  snapshot$add_expression_profile(expression_profile)

  # Return the updated snapshot
  invisible(snapshot)
}

#' Remove expression profiles from a snapshot
#'
#' @description
#' Remove one or more expression profiles from a Snapshot by ID
#' (molecule|species|category).
#'
#' @param snapshot A Snapshot object
#' @param profile_id Character vector of expression profile IDs to remove
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Remove a single expression profile by ID
#' snapshot <- remove_expression_profile(snapshot, "CYP3A4|Human|Healthy")
#'
#' # Remove multiple expression profiles
#' snapshot <- remove_expression_profile(
#'   snapshot,
#'   c("CYP3A4|Human|Healthy", "P-gp|Human|Healthy")
#' )
#' }
remove_expression_profile <- function(snapshot, profile_id) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Call the remove_expression_profile method of the Snapshot class
  snapshot$remove_expression_profile(profile_id)

  # Return the updated snapshot
  invisible(snapshot)
}

#' Add an observer set to a snapshot
#'
#' @description
#' Add an `ObserverSet` building block to a `Snapshot`. The exported function
#' is the canonical, pipeable surface for the mutation; it validates the
#' snapshot before delegating to the underlying R6 method.
#'
#' @param snapshot A `Snapshot` object.
#' @param observer_set An `ObserverSet` object.
#'
#' @return The updated `Snapshot` object, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam")
#'
#' observer_set <- ObserverSet$new(list(
#'   Name = "BrainPlasmaConcentration",
#'   Observers = list()
#' ))
#'
#' snapshot |> add_observer_set(observer_set)
#' }
add_observer_set <- function(snapshot, observer_set) {
  validate_snapshot(snapshot)
  snapshot$add_observer_set(observer_set)
  invisible(snapshot)
}

#' Remove observer sets from a snapshot
#'
#' @description
#' Remove one or more `ObserverSet` building blocks from a `Snapshot` by name.
#' Names not present in the snapshot trigger a warning rather than an error so
#' callers can run idempotent cleanup pipelines.
#'
#' @param snapshot A `Snapshot` object.
#' @param observer_set_name Character vector of observer set names to remove.
#'
#' @return The updated `Snapshot` object, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam")
#'
#' snapshot |> remove_observer_set("BrainPlasmaConcentration")
#'
#' snapshot |>
#'   remove_observer_set(c("BrainPlasmaConcentration", "LiverObservers"))
#' }
remove_observer_set <- function(snapshot, observer_set_name) {
  validate_snapshot(snapshot)
  snapshot$remove_observer_set(observer_set_name)
  invisible(snapshot)
}

#' Browse available OSPSuite building block templates
#'
#' @description
#' Browse and display all available building block templates from the
#' OSPSuite.BuildingBlockTemplates repository. This function helps users
#' discover what templates are available for loading with `load_snapshot()`.
#'
#' @param pattern Character string. Optional pattern to filter template names
#'   (case insensitive). Uses regular expression matching.
#'
#' @return A data.frame with template information (invisibly), while also
#'   printing a formatted list to the console.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Browse all available templates
#' osp_models()
#'
#' # Filter templates containing "midazolam"
#' osp_models(pattern = "midazolam")
#'
#' # Get the data frame of templates for programmatic use
#' templates_df <- osp_models()
#' }
osp_models <- function(pattern = NULL) {
  cli::cli_alert_info("Fetching available templates...")

  tryCatch(
    {
      # Use helper function to get templates data
      templates_df <- .get_templates_data()

      # Filter by pattern if provided
      if (!is.null(pattern) && is.character(pattern) && length(pattern) == 1) {
        matching_indices <- grep(pattern, templates_df$Name, ignore.case = TRUE)
        if (length(matching_indices) == 0) {
          cli::cli_warn("No templates found matching pattern: {pattern}")
          return(invisible(data.frame()))
        }
        templates_df <- templates_df[matching_indices, , drop = FALSE]
      }

      # Display templates
      output <- cli::cli_format_method({
        cli::cli_h2("Available OSPSuite Building Block Templates")
        cli::cli_alert_info("Found {nrow(templates_df)} template{?s}")
        cli::cli_alert_info("Use any template name with load_snapshot()")
        cli::cli_text("")

        for (template_name in templates_df$Name) {
          cli::cli_li("{template_name}")
        }
      })

      cat(output, sep = "\n")

      return(invisible(templates_df))
    },
    error = function(e) {
      cli::cli_abort(
        "Failed to fetch templates from repository\nError: {e$message}"
      )
    }
  )
}

#' Add a compound to a snapshot
#'
#' @description
#' Add a [Compound] object to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param compound A [Compound] object created with [create_compound()].
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_compound(create_compound(name = "Drug X"))
#' }
add_compound <- function(snapshot, compound) {
  validate_snapshot(snapshot)
  snapshot$add_compound(compound)
  invisible(snapshot)
}

#' Remove compounds from a snapshot
#'
#' @description
#' Remove one or more compounds from a [Snapshot] by name.
#'
#' @param snapshot A [Snapshot] object.
#' @param compound_name Character vector of compound names to remove.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   remove_compound("Midazolam")
#' }
remove_compound <- function(snapshot, compound_name) {
  validate_snapshot(snapshot)
  snapshot$remove_compound(compound_name)
  invisible(snapshot)
}

#' Add a population to a snapshot
#'
#' @description
#' Add a [Population] object to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param population A [Population] object created with [create_population()].
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' pop <- create_population(name = "Adults", number_of_individuals = 100)
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_population(pop)
#' }
add_population <- function(snapshot, population) {
  validate_snapshot(snapshot)
  snapshot$add_population(population)
  invisible(snapshot)
}

#' Add a protocol to a snapshot
#'
#' @description
#' Add a [Protocol] object to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param protocol A [Protocol] object created with [create_protocol()].
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' prot <- create_protocol(
#'   name = "Single oral dose",
#'   application_type = "Oral",
#'   dosing_interval = "Single"
#' )
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_protocol(prot)
#' }
add_protocol <- function(snapshot, protocol) {
  validate_snapshot(snapshot)
  snapshot$add_protocol(protocol)
  invisible(snapshot)
}

#' Remove protocols from a snapshot
#'
#' @description
#' Remove one or more protocols from a [Snapshot] by name.
#'
#' @param snapshot A [Snapshot] object.
#' @param protocol_name Character vector of protocol names to remove.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   remove_protocol("IV bolus 1mg")
#' }
remove_protocol <- function(snapshot, protocol_name) {
  validate_snapshot(snapshot)
  snapshot$remove_protocol(protocol_name)
  invisible(snapshot)
}

#' Add an event to a snapshot
#'
#' @description
#' Add an [Event] object to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param event An [Event] object created with [create_event()].
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' evt <- create_event(
#'   name = "Breakfast",
#'   template = "Meal: Standard (Human)"
#' )
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_event(evt)
#' }
add_event <- function(snapshot, event) {
  validate_snapshot(snapshot)
  snapshot$add_event(event)
  invisible(snapshot)
}

#' Remove events from a snapshot
#'
#' @description
#' Remove one or more events from a [Snapshot] by name.
#'
#' @param snapshot A [Snapshot] object.
#' @param event_name Character vector of event names to remove.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   remove_event("Breakfast")
#' }
remove_event <- function(snapshot, event_name) {
  validate_snapshot(snapshot)
  snapshot$remove_event(event_name)
  invisible(snapshot)
}

#' Add observed data to a snapshot
#'
#' @description
#' Add an `ospsuite::DataSet` (observed data) to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param observed_data A `DataSet` object, typically created with
#'   [create_observed_data()] or [loadDataSetFromSnapshot()].
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' dataset <- create_observed_data(
#'   name = "Study A",
#'   time = c(0, 1, 2),
#'   values = c(0, 5, 8),
#'   value_dimension = "Concentration (mass)"
#' )
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_observed_data(dataset)
#' }
add_observed_data <- function(snapshot, observed_data) {
  validate_snapshot(snapshot)
  snapshot$add_observed_data(observed_data)
  invisible(snapshot)
}

#' Remove observed data from a snapshot
#'
#' @description
#' Remove one or more observed-data entries from a [Snapshot] by name.
#'
#' @param snapshot A [Snapshot] object.
#' @param observed_data_name Character vector of observed-data names to
#'   remove.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   remove_observed_data("Study A")
#' }
remove_observed_data <- function(snapshot, observed_data_name) {
  validate_snapshot(snapshot)
  snapshot$remove_observed_data(observed_data_name)
  invisible(snapshot)
}

#' Export a snapshot to a JSON file
#'
#' @description
#' Export a Snapshot object to a JSON file. This is a convenient wrapper
#' around the `$export()` method of the Snapshot class.
#'
#' @param snapshot A Snapshot object
#' @param path Character string. Path where to save the JSON file
#' @return Invisibly returns the snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Export to a new file
#' export_snapshot(snapshot, "path/to/exported_snapshot.json")
#' }
export_snapshot <- function(snapshot, path) {
  # Validate that the snapshot is a Snapshot object
  validate_snapshot(snapshot)

  # Validate that path is provided and is a character string
  if (
    missing(path) || is.null(path) || !is.character(path) || length(path) != 1
  ) {
    cli::cli_abort("Path must be a single character string")
  }

  # Call the export method of the Snapshot class
  snapshot$export(path)

  # Return the updated snapshot invisibly
  invisible(snapshot)
}
