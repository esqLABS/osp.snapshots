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
#' # Snapshot version normalization
#'
#' A loaded snapshot is upconverted to the current `Version = 80` (PK-Sim
#' v12) structure in memory at load time, so the whole in-memory model and
#' every export are one coherent current-format snapshot. Renal-clearance
#' parameter-container path segments (`GlomerularFiltration`,
#' `RenalClearance`) are qualified with their owning compound name, the
#' `Applications` to `Events` path rewrite is applied throughout, and every
#' export reports `Version = 80` regardless of the file's original declared
#' version. On a snapshot already at `Version = 80` this is a structural
#' no-op.
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

      # Upconvert the parsed data to the current `Version = 80` structure in
      # memory. Runs on `.original_data` before any lazy cache is built, so
      # both R6-wrapped sections and verbatim-passthrough sections
      # (`ParameterIdentifications`, `Version`) are normalized uniformly and no
      # mixed-version file can form. See `normalize_snapshot_to_current()`.
      private$.original_data <- normalize_snapshot_to_current(
        private$.original_data
      )

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
    #' Add one or more Individual objects to the snapshot. References to
    #' expression profiles not yet in the snapshot trigger one
    #' informational warning per individual; the add proceeds either way.
    #' @param individual An Individual object created with create_individual(),
    #'   or a list of such objects.
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Create a new individual
    #' ind <- create_individual(name = "New Patient", age = 35, weight = 70)
    #'
    #' # Add the individual to a snapshot
    #' snapshot$add_individual(ind)
    #'
    #' # Add several at once
    #' patients <- list(
    #'   create_individual("Patient_A", age = 25),
    #'   create_individual("Patient_B", age = 45)
    #' )
    #' snapshot$add_individual(patients)
    #' }
    add_individual = function(individual) {
      # Warn once per individual about unresolved expression-profile
      # references before `.add_block` mutates the cache. `.add_block`
      # repeats the type validation, so keep this loop tolerant: skip
      # entries that are not Individual objects (their errors surface in
      # `.add_block` immediately after).
      inds <- if (inherits(individual, "Individual")) {
        list(individual)
      } else if (is.list(individual)) {
        individual
      } else {
        list()
      }
      for (ind in inds) {
        if (inherits(ind, "Individual")) {
          private$.warn_unresolved_individual_refs(ind)
        }
      }

      private$.add_block(
        obj = individual,
        expected_class = "Individual",
        class_article = "an",
        slot = ".individuals",
        named_slot = ".individuals_named",
        ensure = private$.ensure_individuals,
        collection_class = "individual_collection",
        label_count = "individual(s)"
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
    #' Add one or more Formulation objects to the snapshot.
    #' @param formulation A Formulation object created with
    #'   create_formulation(), or a list of such objects.
    #' @return Invisibly returns the object
    #' @examples
    #' \dontrun{
    #' # Create a new formulation
    #' form <- create_formulation(name = "Tablet", type = "Weibull")
    #'
    #' # Add the formulation to a snapshot
    #' snapshot$add_formulation(form)
    #'
    #' # Add several at once
    #' forms <- list(
    #'   create_formulation("Tablet", type = "Weibull"),
    #'   create_formulation("Oral solution", type = "First Order")
    #' )
    #' snapshot$add_formulation(forms)
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
        label_count = "formulation(s)"
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
    #' Add one or more ExpressionProfile objects to the snapshot.
    #' @param expression_profile An ExpressionProfile object, or a list of
    #'   such objects.
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
    #'
    #' # Add several at once
    #' snapshot$add_expression_profile(list(profile, profile))
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
        label_count = "expression profile(s)"
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
        label_count = "observer set(s)"
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
    #' Add one or more DataSet objects (observed data) to the snapshot.
    #' @param observed_data A DataSet object created from snapshot observed
    #'   data, or a list of such objects.
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
        label_count = "observed data item(s)"
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
        label_count = "compound(s)"
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
        label_count = "population(s)"
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
        label_count = "protocol(s)"
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
        label_count = "event(s)"
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
    },

    #' @description
    #' Build a simulation from named arguments and attach it, or attach a
    #' pre-built simulation.
    #'
    #' The build mode is the entry point: with the snapshot in hand it
    #' resolves compound references and derives defaults (calculation
    #' methods, formulation key, alternatives) before attaching. Supply
    #' `name` plus exactly one of `individual` / `population` to build; each
    #' inline `compounds` entry is a config list
    #' (`list(name =, protocol =, formulation =, processes =,
    #' calculation_methods =, alternatives =)`). Alternatively supply a
    #' pre-built [Simulation] (or a list of them) through `simulation`.
    #' References to building blocks not yet in the snapshot trigger one
    #' informational warning per simulation; the add proceeds either way.
    #' @param simulation A pre-built [Simulation] object, or a list of such
    #'   objects. Leave `NULL` to build a simulation from the named
    #'   arguments instead.
    #' @param name Character. Simulation name (required in build mode).
    #' @param model Character. PK-Sim model name (defaults to `"4Comp"`).
    #' @param individual Character. Name of the individual building block.
    #'   Mutually exclusive with `population`.
    #' @param population Character. Name of the population building block.
    #'   Mutually exclusive with `individual`.
    #' @param compounds List of inline compound-config lists
    #'   (`list(name =, protocol =, formulation =, processes =,
    #'   calculation_methods =, alternatives =)`). `alternatives` is a
    #'   named character vector (or named list of length-one strings)
    #'   mapping a friendly property name (`lipophilicity`,
    #'   `fraction_unbound`, `solubility`, `intestinal_permeability`,
    #'   `permeability`) to the alternative label to select on that
    #'   compound, for example `alternatives = c(solubility = "FaSSIF")`;
    #'   it overrides the derived default for the named groups only, every
    #'   other group is still defaulted from the compound. `formulation`
    #'   accepts a single string (bound to the protocol's inferred first
    #'   slot key, unchanged) or a named character vector (or named list of
    #'   length-one strings) mapping application-slot key to formulation
    #'   name for a multi-slot protocol, for example
    #'   `formulation = c(Formulation = "Oral solution",
    #'   "Formulation 2" = "IV solution")`.
    #' @param events List of [EventSelection] objects or raw lists.
    #' @param observer_sets List of [ObserverSetSelection] objects or raw
    #'   lists.
    #' @param observed_data_names Character vector of observed-data names.
    #' @param solver A [SolverSettings] object or raw list. Defaults to
    #'   PK-Sim defaults.
    #' @param output_schema An [OutputSchema] object or raw list. Defaults
    #'   to an empty schema.
    #' @param output_selections Character vector of output quantity paths.
    #' @param output_mappings List of [OutputMapping] objects or raw lists.
    #' @param parameters List of [LocalizedParameter] objects (created with
    #'   `create_parameter(path = ..., ...)`) or raw parameter lists.
    #' @param advanced_parameters List of [AdvancedParameter] objects or raw
    #'   lists (population simulations only).
    #' @param description Character. Free-text description of the simulation.
    #' @param allow_aging Logical. Whether the simulation allows aging.
    #' @return Invisibly returns the object
    add_simulation = function(
      simulation = NULL,
      name = NULL,
      model = "4Comp",
      individual = NULL,
      population = NULL,
      compounds = NULL,
      events = NULL,
      observer_sets = NULL,
      observed_data_names = NULL,
      solver = NULL,
      output_schema = NULL,
      output_selections = NULL,
      output_mappings = NULL,
      parameters = NULL,
      advanced_parameters = NULL,
      description = NULL,
      allow_aging = NULL
    ) {
      # Build mode: no pre-built simulation, `name` supplied. Build,
      # resolving compounds and deriving defaults against this snapshot.
      if (is.null(simulation)) {
        if (is.null(name)) {
          cli::cli_abort(c(
            "Nothing to add.",
            i = "Supply a pre-built {.cls Simulation} via {.arg simulation}, \\
            or {.arg name} plus {.arg individual}/{.arg population} to build one."
          ))
        }
        simulation <- private$.build_simulation(
          name = name,
          model = model,
          individual = individual,
          population = population,
          compounds = compounds,
          events = events,
          observer_sets = observer_sets,
          observed_data_names = observed_data_names,
          solver = solver,
          output_schema = output_schema,
          output_selections = output_selections,
          output_mappings = output_mappings,
          parameters = parameters,
          advanced_parameters = advanced_parameters,
          description = description,
          allow_aging = allow_aging
        )
      }

      # Walk every simulation that looks valid, emit a missing-refs warning
      # per simulation before `.add_block` mutates the cache. `.add_block`
      # repeats the type validation so we keep this loop tolerant: we skip
      # entries that are not Simulation objects (those errors are surfaced
      # by `.add_block` immediately after).
      sims <- if (inherits(simulation, "Simulation")) {
        list(simulation)
      } else if (is.list(simulation)) {
        simulation
      } else {
        list()
      }
      for (s in sims) {
        if (inherits(s, "Simulation")) {
          private$.warn_unresolved_simulation_refs(s)
        }
      }

      private$.add_block(
        obj = simulation,
        expected_class = "Simulation",
        class_article = "a",
        slot = ".simulations",
        named_slot = ".simulations_named",
        ensure = private$.ensure_simulations,
        collection_class = "simulation_collection",
        label_count = "simulation(s)"
      )
    },

    #' @description
    #' Remove a simulation from the snapshot by name
    #' @param simulation_name Character vector of simulation name(s) to remove
    #' @return Invisibly returns the object
    remove_simulation = function(simulation_name) {
      private$.remove_block(
        input_keys = simulation_name,
        slot = ".simulations",
        named_slot = ".simulations_named",
        ensure = private$.ensure_simulations,
        collection_class = "simulation_collection",
        label_singular_title = "Simulation",
        label_plural = "simulations",
        label_count = "simulation(s)"
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
    },

    #' @field simulations List of Simulation objects in the snapshot
    simulations = function(value = NULL) {
      if (!is.null(value)) {
        private$.simulations <- value
        private$.simulations_named <- NULL
      }
      private$.ensure_simulations()
      if (is.null(private$.simulations_named)) {
        private$.simulations_named <- private$.build_named_list(
          private$.simulations,
          "simulation_collection"
        )
      }
      private$.simulations_named
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
      ),
      Simulations = list(
        cache = ".simulations",
        adapter = .default_export_adapter
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

    .ensure_simulations = function() {
      private$.ensure_collection(
        ".simulations",
        "Simulations",
        function(d) Simulation$new(d)
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

    # Store simulation objects in an unnamed list
    .simulations = NULL,

    # Cache for the named simulations list with disambiguated names
    .simulations_named = NULL,

    # Shared append routine for `add_<kind>` methods. Accepts either a single
    # building block of class `expected_class` or a list of such objects;
    # rejects mixed-type lists and empty lists. Forces lazy construction via
    # `ensure()`, appends the validated objects to the unnamed cache slot in
    # one shot, rebuilds the named cache via `.build_named_list`, and emits a
    # success message counting the entries added.
    .add_block = function(
      obj,
      expected_class,
      slot,
      named_slot,
      ensure,
      collection_class,
      label_count,
      key_fn = \(x) x$name,
      class_article = "a"
    ) {
      if (inherits(obj, expected_class)) {
        objs <- list(obj)
      } else if (is.list(obj)) {
        objs <- obj
        bad <- which(!vapply(objs, inherits, logical(1), expected_class))
        if (length(bad) > 0) {
          first <- bad[[1]]
          cli::cli_abort(
            c(
              "Every element must be {class_article} {.cls {expected_class}} object.",
              x = "Element {first} is {.cls {class(objs[[first]])[1]}}."
            ),
            call = rlang::caller_env()
          )
        }
      } else {
        cli::cli_abort(
          "Expected {class_article} {expected_class} object or a list of them, but got {.cls {class(obj)[1]}}",
          call = rlang::caller_env()
        )
      }

      if (length(objs) == 0) {
        cli::cli_abort(
          "Must supply at least one {.cls {expected_class}}.",
          call = rlang::caller_env()
        )
      }

      ensure()

      private[[slot]] <- c(private[[slot]], objs)

      private[[named_slot]] <- private$.build_named_list(
        private[[slot]],
        collection_class,
        key_fn = key_fn
      )

      cli::cli_alert_success(
        "Added {length(objs)} {label_count}"
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

    # Build a `Simulation` from named arguments, resolving compound
    # references and deriving defaults against this snapshot. Assembles the
    # raw simulation payload with the same validations, defaults, and error
    # messages as the standalone factory did, then wraps it in `Simulation`.
    # Compounds run through `resolve_compounds()` (inline configs resolved
    # against the snapshot).
    .build_simulation = function(
      name,
      model,
      individual,
      population,
      compounds,
      events,
      observer_sets,
      observed_data_names,
      solver,
      output_schema,
      output_selections,
      output_mappings,
      parameters,
      advanced_parameters,
      description,
      allow_aging,
      call = parent.frame()
    ) {
      check_required_string(name, "name", call = call)
      check_required_string(model, "model", call = call)

      has_individual <- !is.null(individual)
      has_population <- !is.null(population)
      if (has_individual == has_population) {
        cli::cli_abort(
          c(
            "Simulation must reference exactly one of {.arg individual} or {.arg population}.",
            i = "Supply one and leave the other {.code NULL}."
          ),
          call = call
        )
      }
      if (has_individual) {
        check_required_string(individual, "individual", call = call)
      } else {
        check_required_string(population, "population", call = call)
      }

      if (!is.null(allow_aging)) {
        if (!is.logical(allow_aging) || length(allow_aging) != 1) {
          cli::cli_abort(
            "{.arg allow_aging} must be a single logical value",
            call = call
          )
        }
      }
      if (!is.null(description)) {
        check_required_string(description, "description", call = call)
      }

      data <- list(Name = name, Model = model)

      if (!is.null(description)) {
        data$Description <- description
      }
      if (!is.null(allow_aging)) {
        data$AllowAging <- allow_aging
      }
      if (has_individual) {
        data$Individual <- individual
      }
      if (has_population) {
        data$Population <- population
      }

      resolved_compounds <- resolve_compounds(compounds, self, call = call)
      if (!is.null(resolved_compounds)) {
        data$Compounds <- resolved_compounds
      }
      if (!is.null(events)) {
        data$Events <- to_raw_r6_or_list(events, "EventSelection", "events")
      }
      if (!is.null(observer_sets)) {
        data$ObserverSets <- to_raw_r6_or_list(
          observer_sets,
          "ObserverSetSelection",
          "observer_sets"
        )
      }
      if (!is.null(observed_data_names)) {
        if (!is.character(observed_data_names)) {
          cli::cli_abort(
            "{.arg observed_data_names} must be a character vector",
            call = call
          )
        }
        data$ObservedData <- as.list(observed_data_names)
      }
      if (!is.null(output_selections)) {
        if (!is.character(output_selections)) {
          cli::cli_abort(
            "{.arg output_selections} must be a character vector",
            call = call
          )
        }
        data$OutputSelections <- as.list(output_selections)
      }
      if (!is.null(output_mappings)) {
        data$OutputMappings <- to_raw_r6_or_list(
          output_mappings,
          "OutputMapping",
          "output_mappings"
        )
      }
      if (!is.null(advanced_parameters)) {
        data$AdvancedParameters <- to_raw_r6_or_list(
          advanced_parameters,
          "AdvancedParameter",
          "advanced_parameters"
        )
      }

      # Solver: pre-resolve so the raw $data carries it.
      if (!is.null(solver)) {
        if (inherits(solver, "SolverSettings")) {
          data$Solver <- solver$data
        } else if (is.list(solver) && !is.object(solver)) {
          data$Solver <- solver
        } else {
          cli::cli_abort(
            "{.arg solver} must be a {.cls SolverSettings} or a raw list",
            call = call
          )
        }
      } else {
        # Empty *named* list so jsonlite writes `{}` (an object). An
        # unnamed `list()` serialises to `[]` (an array), which PK-Sim's
        # snapshot mapper rejects silently.
        data$Solver <- empty_named_list()
      }

      if (!is.null(output_schema)) {
        if (inherits(output_schema, "OutputSchema")) {
          data$OutputSchema <- output_schema$data
        } else if (is.list(output_schema) && !is.object(output_schema)) {
          data$OutputSchema <- output_schema
        } else {
          cli::cli_abort(
            "{.arg output_schema} must be an {.cls OutputSchema} or a raw list",
            call = call
          )
        }
      } else {
        data$OutputSchema <- list()
      }

      if (!is.null(parameters)) {
        data$Parameters <- to_raw_parameters(parameters, "Path")
      }

      Simulation$new(data)
    },

    # Pre-add hook for `add_individual()`. Warns once per individual when
    # any expression profile it references (by composite
    # `Molecule|Species|Category` id) does not resolve to an expression
    # profile currently in the snapshot. The add proceeds either way;
    # PK-Sim will surface unresolved references at load time.
    .warn_unresolved_individual_refs = function(individual) {
      refs <- individual$expression_profiles
      if (is.null(refs) || length(refs) == 0) {
        return()
      }

      known <- vapply(
        self$expression_profiles,
        function(profile) {
          category <- profile$category
          paste(
            profile$molecule %||% "",
            profile$species %||% "",
            category %||% "",
            sep = "|"
          )
        },
        character(1)
      )

      missing_ids <- setdiff(refs, known)
      if (length(missing_ids) == 0) {
        return()
      }

      ind_name <- individual$name %||% "<unnamed>"
      cli::cli_warn(c(
        "Individual {.val {ind_name}} references expression profiles that are not in the snapshot:",
        stats::setNames(
          paste0("ExpressionProfiles: ", paste(missing_ids, collapse = ", ")),
          "*"
        ),
        i = "PK-Sim will fail to resolve these at load time."
      ))
    },

    # Pre-add hook for `add_simulation()`. Warns once per simulation when
    # any name referenced by the simulation does not resolve to a
    # currently-known building block in the snapshot. The add proceeds
    # either way; PK-Sim will surface unresolved references at load time.
    .warn_unresolved_simulation_refs = function(sim) {
      collect_names <- function(items, accessor) {
        if (length(items) == 0) {
          return(character())
        }
        vapply(items, accessor, character(1))
      }

      known_individuals <- collect_names(
        self$individuals,
        function(x) x$name %||% ""
      )
      known_populations <- collect_names(
        self$populations,
        function(x) x$name %||% ""
      )
      known_compounds <- collect_names(
        self$compounds,
        function(x) x$name %||% ""
      )
      known_events <- collect_names(self$events, function(x) x$name %||% "")
      known_observer_sets <- collect_names(
        self$observer_sets,
        function(x) x$name %||% ""
      )
      known_observed_data <- collect_names(
        self$observed_data,
        function(x) x$name %||% ""
      )
      known_protocols <- collect_names(
        self$protocols,
        function(x) x$name %||% ""
      )
      known_formulations <- collect_names(
        self$formulations,
        function(x) x$name %||% ""
      )

      missing <- list()
      record <- function(kind, name) {
        if (is.null(name) || !nzchar(name)) {
          return()
        }
        missing[[kind]] <<- unique(c(missing[[kind]], name))
      }

      if (!is.null(sim$individual) && nzchar(sim$individual)) {
        if (!(sim$individual %in% known_individuals)) {
          record("Individuals", sim$individual)
        }
      }
      if (!is.null(sim$population) && nzchar(sim$population)) {
        if (!(sim$population %in% known_populations)) {
          record("Populations", sim$population)
        }
      }

      for (c in sim$compounds) {
        if (!is.null(c$name) && !(c$name %in% known_compounds)) {
          record("Compounds", c$name)
        }
        if (!is.null(c$protocol)) {
          p_name <- c$protocol$name
          if (!is.null(p_name) && !(p_name %in% known_protocols)) {
            record("Protocols", p_name)
          }
          for (f in c$protocol$formulations) {
            if (!is.null(f$name) && !(f$name %in% known_formulations)) {
              record("Formulations", f$name)
            }
          }
        }
      }

      for (e in sim$events) {
        if (!is.null(e$name) && !(e$name %in% known_events)) {
          record("Events", e$name)
        }
      }

      for (o in sim$observer_sets) {
        if (!is.null(o$name) && !(o$name %in% known_observer_sets)) {
          record("ObserverSets", o$name)
        }
      }

      od_names <- sim$observed_data_names
      if (!is.null(od_names)) {
        for (od in od_names) {
          od_name <- as.character(od)
          if (!(od_name %in% known_observed_data)) {
            record("ObservedData", od_name)
          }
        }
      }

      if (length(missing) == 0) {
        return()
      }

      lines <- vapply(
        names(missing),
        function(kind) {
          paste0(
            kind,
            ": ",
            paste(missing[[kind]], collapse = ", ")
          )
        },
        character(1)
      )
      sim_name <- sim$name %||% "<unnamed>"
      cli::cli_warn(c(
        "Simulation {.val {sim_name}} references building blocks that are not in the snapshot:",
        stats::setNames(lines, rep("*", length(lines))),
        i = "PK-Sim will fail to resolve these at load time."
      ))
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

#' Add one or more individuals to a snapshot
#'
#' @description
#' Add one or more [Individual] objects to a [Snapshot].
#'
#' @param snapshot A Snapshot object
#' @param individual An Individual object created with [create_individual()],
#'   or a list of such objects.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Add a single individual
#' ind <- create_individual(name = "New Patient", age = 35, weight = 70)
#' snapshot <- add_individual(snapshot, ind)
#'
#' # Add several at once
#' patients <- list(
#'   create_individual("Patient_A", age = 25),
#'   create_individual("Patient_B", age = 45)
#' )
#' snapshot <- add_individual(snapshot, patients)
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
#' @return The updated [Snapshot] object, returned invisibly.
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

#' Add one or more formulations to a snapshot
#'
#' @description
#' Add one or more [Formulation] objects to a [Snapshot].
#'
#' @param snapshot A Snapshot object
#' @param formulation A Formulation object created with
#'   [create_formulation()], or a list of such objects.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("Midazolam")
#'
#' # Add a single formulation
#' form <- create_formulation(name = "Tablet", type = "Weibull")
#' snapshot <- add_formulation(snapshot, form)
#'
#' # Add several at once
#' forms <- list(
#'   create_formulation("Tablet", type = "Weibull"),
#'   create_formulation("Oral solution", type = "First Order")
#' )
#' snapshot <- add_formulation(snapshot, forms)
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
#' @return The updated [Snapshot] object, returned invisibly.
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
#' @return The updated [Snapshot] object, returned invisibly.
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

#' Add one or more expression profiles to a snapshot
#'
#' @description
#' Add one or more [ExpressionProfile] objects to a [Snapshot].
#'
#' @param snapshot A Snapshot object
#' @param expression_profile An ExpressionProfile object, or a list of such
#'   objects.
#' @return The updated [Snapshot] object, returned invisibly.
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
#' # Add a single expression profile
#' snapshot <- add_expression_profile(snapshot, profile)
#'
#' # Add several at once
#' snapshot <- add_expression_profile(snapshot, list(profile, profile))
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
#' @return The updated [Snapshot] object, returned invisibly.
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

#' Add one or more observer sets to a snapshot
#'
#' @description
#' Add one or more `ObserverSet` building blocks to a `Snapshot`. The
#' exported function is the canonical, pipeable surface for the mutation; it
#' validates the snapshot before delegating to the underlying R6 method.
#'
#' @param snapshot A `Snapshot` object.
#' @param observer_set An `ObserverSet` object, or a list of such objects.
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
#'
#' snapshot |> add_observer_set(list(observer_set, observer_set))
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

#' Add one or more compounds to a snapshot
#'
#' @description
#' Add one or more [Compound] objects to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param compound A [Compound] object created with [create_compound()], or a
#'   list of such objects.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_compound(create_compound(name = "Drug X"))
#'
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_compound(list(
#'     create_compound(name = "Drug X"),
#'     create_compound(name = "Drug Y")
#'   ))
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

#' Add one or more populations to a snapshot
#'
#' @description
#' Add one or more [Population] objects to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param population A [Population] object created with [create_population()],
#'   or a list of such objects.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' pop <- create_population(name = "Adults", number_of_individuals = 100)
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_population(pop)
#'
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_population(list(
#'     create_population(name = "Adults", number_of_individuals = 100),
#'     create_population(name = "Children", number_of_individuals = 50)
#'   ))
#' }
add_population <- function(snapshot, population) {
  validate_snapshot(snapshot)
  snapshot$add_population(population)
  invisible(snapshot)
}

#' Add one or more protocols to a snapshot
#'
#' @description
#' Add one or more [Protocol] objects to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param protocol A [Protocol] object created with [create_protocol()], or a
#'   list of such objects.
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
#'
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_protocol(list(prot, prot))
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

#' Add one or more events to a snapshot
#'
#' @description
#' Add one or more [Event] objects to a [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param event An [Event] object created with [create_event()], or a list of
#'   such objects.
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
#'
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_event(list(evt, evt))
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

#' Add one or more observed-data entries to a snapshot
#'
#' @description
#' Add one or more `ospsuite::DataSet` (observed data) objects to a
#' [Snapshot].
#'
#' @param snapshot A [Snapshot] object.
#' @param observed_data A `DataSet` object, typically created with
#'   [create_observed_data()] or [loadDataSetFromSnapshot()], or a list of
#'   such objects.
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
#'
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_observed_data(list(dataset, dataset))
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

#' Build a simulation from a snapshot and attach it
#'
#' @description
#' Build a [Simulation] from named arguments and attach it to a
#' [Snapshot], or attach a pre-built [Simulation].
#'
#' A simulation is almost pure references into the snapshot, so the
#' snapshot is its entry point. In build mode, with the snapshot in hand,
#' `add_simulation()` resolves compound references and derives sensible
#' defaults (calculation methods, formulation key, alternatives) from the
#' referenced building blocks before attaching. Supply `name` plus exactly
#' one of `individual` / `population`, and configure each compound inline
#' through `compounds`, selecting a specific alternative by friendly
#' property name and label, or a multi-slot protocol's formulations, where
#' the derived defaults are not enough. References to building blocks not
#' yet in the snapshot trigger one informational warning per simulation;
#' the add proceeds either way.
#'
#' @param snapshot A [Snapshot] object.
#' @param simulation A pre-built [Simulation] object, or a list of such
#'   objects. Leave `NULL` to build a simulation from the named arguments.
#' @param name Character. Simulation name (required in build mode).
#' @param model Character. PK-Sim model name (defaults to `"4Comp"`).
#' @param individual Character. Name of the individual building block.
#'   Mutually exclusive with `population`.
#' @param population Character. Name of the population building block.
#'   Mutually exclusive with `individual`.
#' @param compounds List of inline compound-config lists
#'   (`list(name =, protocol =, formulation =, processes =,
#'   calculation_methods =, alternatives =)`). Each entry is resolved
#'   against the snapshot. `alternatives` is a named character vector (or
#'   named list of length-one strings) mapping a friendly property name
#'   (`lipophilicity`, `fraction_unbound`, `solubility`,
#'   `intestinal_permeability`, `permeability`) to the alternative label to
#'   select on that compound, for example
#'   `alternatives = c(solubility = "FaSSIF")`; it overrides the derived
#'   default for the named groups only, every other group is still
#'   defaulted from the compound. `formulation` accepts a single string
#'   (bound to the protocol's inferred first slot key, unchanged) or a
#'   named character vector (or named list of length-one strings) mapping
#'   application-slot key to formulation name for a multi-slot protocol,
#'   for example `formulation = c(Formulation = "Oral solution",
#'   "Formulation 2" = "IV solution")`.
#' @param events List of [EventSelection] objects or raw lists.
#' @param observer_sets List of [ObserverSetSelection] objects or raw
#'   lists.
#' @param observed_data_names Character vector of observed-data names.
#' @param solver A [SolverSettings] object or raw list. Defaults to
#'   PK-Sim defaults.
#' @param output_schema An [OutputSchema] object or raw list. Defaults to
#'   an empty schema.
#' @param output_selections Character vector of output quantity paths.
#' @param output_mappings List of [OutputMapping] objects or raw lists.
#' @param parameters List of [LocalizedParameter] objects (created with
#'   `create_parameter(path = ..., ...)`) or raw parameter lists.
#' @param advanced_parameters List of [AdvancedParameter] objects or raw
#'   lists (population simulations only).
#' @param description Character. Free-text description of the simulation.
#' @param allow_aging Logical. Whether the simulation allows aging.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   add_simulation(
#'     name = "Sim 1",
#'     individual = "Korean (Yu 2004 study)",
#'     compounds = list(list(
#'       name = "Rifampicin",
#'       protocol = "Yu 2004 - Rifampicin - 600 mg MD OD 10 days",
#'       formulation = "Oral solution",
#'       processes = c("Hepatic"),
#'       alternatives = c(solubility = "FaSSIF")
#'     ))
#'   )
#' }
add_simulation <- function(
  snapshot,
  simulation = NULL,
  name = NULL,
  model = "4Comp",
  individual = NULL,
  population = NULL,
  compounds = NULL,
  events = NULL,
  observer_sets = NULL,
  observed_data_names = NULL,
  solver = NULL,
  output_schema = NULL,
  output_selections = NULL,
  output_mappings = NULL,
  parameters = NULL,
  advanced_parameters = NULL,
  description = NULL,
  allow_aging = NULL
) {
  validate_snapshot(snapshot)
  snapshot$add_simulation(
    simulation = simulation,
    name = name,
    model = model,
    individual = individual,
    population = population,
    compounds = compounds,
    events = events,
    observer_sets = observer_sets,
    observed_data_names = observed_data_names,
    solver = solver,
    output_schema = output_schema,
    output_selections = output_selections,
    output_mappings = output_mappings,
    parameters = parameters,
    advanced_parameters = advanced_parameters,
    description = description,
    allow_aging = allow_aging
  )
  invisible(snapshot)
}

#' Remove simulations from a snapshot
#'
#' @description
#' Remove one or more simulations from a [Snapshot] by name.
#'
#' @param snapshot A [Snapshot] object.
#' @param simulation_name Character vector of simulation names to remove.
#' @return The updated [Snapshot] object, returned invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam") |>
#'   remove_simulation("simulation1")
#' }
remove_simulation <- function(snapshot, simulation_name) {
  validate_snapshot(snapshot)
  snapshot$remove_simulation(simulation_name)
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
