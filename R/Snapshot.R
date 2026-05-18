#' Snapshot class for OSP snapshots
#'
#' @description
#' An R6 class that represents an OSP snapshot file. This class provides
#' methods to access different components of the snapshot and visualize its structure.
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
    #' @param input Path to the snapshot JSON file, URL, template name, or a list containing snapshot data
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
      # Validate that the input is an Individual object
      if (!inherits(individual, "Individual")) {
        cli::cli_abort(
          "Expected an Individual object, but got {.cls {class(individual)[1]}}"
        )
      }

      # Force lazy construction of any existing individuals before mutating
      private$.ensure_individuals()

      # Add the individual to the list
      private$.individuals <- c(private$.individuals, list(individual))

      # Reset the named list to include the new individual
      private$.individuals_named <- private$.build_named_list(
        private$.individuals,
        "individual_collection"
      )

      cli::cli_alert_success(
        "Added individual '{individual$name}' to the snapshot"
      )
      invisible(self)
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
      # Force lazy construction so we can inspect the current set
      private$.ensure_individuals()

      if (length(private$.individuals) == 0) {
        cli::cli_warn("No individuals to remove")
        return(invisible(self))
      }

      # Get current individual names
      current_names <- sapply(private$.individuals, function(i) i$name)

      # Check if requested individuals exist
      for (name in individual_name) {
        if (!(name %in% current_names)) {
          cli::cli_warn("Individual '{name}' not found in snapshot")
        }
      }

      # Remove the requested individuals
      keep_indices <- which(!(current_names %in% individual_name))

      if (length(keep_indices) == 0) {
        private$.individuals <- list()
      } else {
        private$.individuals <- private$.individuals[keep_indices]
      }

      # Reset the named list
      private$.individuals_named <- private$.build_named_list(
        private$.individuals,
        "individual_collection"
      )

      cli::cli_alert_success(
        "Removed {length(individual_name)} individual(s)"
      )
      invisible(self)
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
      # Validate that the input is a Formulation object
      if (!inherits(formulation, "Formulation")) {
        cli::cli_abort(
          "Expected a Formulation object, but got {.cls {class(formulation)[1]}}"
        )
      }

      # Force lazy construction of any existing formulations before mutating
      private$.ensure_formulations()

      # Add the formulation to the list
      private$.formulations <- c(private$.formulations, list(formulation))

      # Reset the named list to include the new formulation
      private$.formulations_named <- private$.build_named_list(
        private$.formulations,
        "formulation_collection"
      )

      cli::cli_alert_success(
        "Added formulation '{formulation$name}' to the snapshot"
      )
      invisible(self)
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
      # Force lazy construction so we can inspect the current set
      private$.ensure_formulations()

      if (length(private$.formulations) == 0) {
        cli::cli_warn("No formulations to remove")
        return(invisible(self))
      }

      # Get current formulation names
      current_names <- sapply(private$.formulations, function(f) f$name)

      # Check if requested formulations exist
      for (name in formulation_name) {
        if (!(name %in% current_names)) {
          cli::cli_warn("Formulation '{name}' not found in snapshot")
        }
      }

      # Remove the requested formulations
      keep_indices <- which(!(current_names %in% formulation_name))

      if (length(keep_indices) == 0) {
        private$.formulations <- list()
      } else {
        private$.formulations <- private$.formulations[keep_indices]
      }

      # Reset the named list
      private$.formulations_named <- private$.build_named_list(
        private$.formulations,
        "formulation_collection"
      )

      cli::cli_alert_success(
        "Removed {length(formulation_name)} formulation(s)"
      )
      invisible(self)
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
      # Force lazy construction so we can inspect the current set
      private$.ensure_populations()

      if (length(private$.populations) == 0) {
        cli::cli_warn("No populations to remove")
        return(invisible(self))
      }

      # Get current population names
      current_names <- sapply(private$.populations, function(p) p$name)

      # Check if requested populations exist
      for (name in population_name) {
        if (!(name %in% current_names)) {
          cli::cli_warn("Population '{name}' not found in snapshot")
        }
      }

      # Remove the requested populations
      keep_indices <- which(!(current_names %in% population_name))

      if (length(keep_indices) == 0) {
        private$.populations <- list()
      } else {
        private$.populations <- private$.populations[keep_indices]
      }

      # Reset the named list
      private$.populations_named <- private$.build_named_list(
        private$.populations,
        "population_collection"
      )

      cli::cli_alert_success(
        "Removed {length(population_name)} population(s)"
      )
      invisible(self)
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
      # Validate that the input is an ExpressionProfile object
      if (!inherits(expression_profile, "ExpressionProfile")) {
        cli::cli_abort(
          "Expected an ExpressionProfile object, but got {.cls {class(expression_profile)[1]}}"
        )
      }

      # Force lazy construction of any existing expression profiles before mutating
      private$.ensure_expression_profiles()

      # Add the expression profile to the list
      private$.expression_profiles <- c(
        private$.expression_profiles,
        list(expression_profile)
      )

      # Reset the named list to include the new expression profile
      private$.expression_profiles_named <- private$.build_named_list(
        private$.expression_profiles,
        "expression_profile_collection",
        key_fn = \(x) x$id
      )

      cli::cli_alert_success(
        "Added expression profile '{expression_profile$molecule}' to the snapshot"
      )
      invisible(self)
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
      # Force lazy construction so we can inspect the current set
      private$.ensure_expression_profiles()

      if (length(private$.expression_profiles) == 0) {
        cli::cli_warn("No expression profiles to remove")
        return(invisible(self))
      }

      # Get current expression profile IDs
      current_ids <- sapply(
        private$.expression_profiles,
        function(prof) prof$id
      )

      # Check if requested expression profiles exist
      for (id in profile_id) {
        if (!(id %in% current_ids)) {
          cli::cli_warn("Expression profile '{id}' not found in snapshot")
        }
      }

      # Remove the requested expression profiles
      keep_indices <- which(!(current_ids %in% profile_id))

      if (length(keep_indices) == 0) {
        private$.expression_profiles <- list()
      } else {
        private$.expression_profiles <- private$.expression_profiles[
          keep_indices
        ]
      }

      # Reset the named list
      private$.expression_profiles_named <- private$.build_named_list(
        private$.expression_profiles,
        "expression_profile_collection",
        key_fn = \(x) x$id
      )

      cli::cli_alert_success(
        "Removed {length(profile_id)} expression profile(s)"
      )
      invisible(self)
    },

    #' @description
    #' Add a DataSet object (observed data) to the snapshot
    #' @param observed_data A DataSet object created from snapshot observed data
    #' @return Invisibly returns the object
    add_observed_data = function(observed_data) {
      # Validate that the input is a DataSet object
      if (!inherits(observed_data, "DataSet")) {
        cli::cli_abort(
          "Expected a DataSet object, but got {.cls {class(observed_data)[1]}}"
        )
      }

      # Force lazy construction of any existing observed data before mutating
      private$.ensure_observed_data()

      # Add the observed data to the list
      private$.observed_data <- c(private$.observed_data, list(observed_data))

      # Reset the named list to include the new observed data
      private$.observed_data_named <- private$.build_named_list(
        private$.observed_data,
        "observed_data_collection"
      )

      cli::cli_alert_success(
        "Added observed data '{observed_data$name}' to the snapshot"
      )
      invisible(self)
    },

    #' @description
    #' Remove observed data from the snapshot by name
    #' @param observed_data_name Character vector of observed data names to remove
    #' @return Invisibly returns the object
    remove_observed_data = function(observed_data_name) {
      # Force lazy construction so we can inspect the current set
      private$.ensure_observed_data()

      if (length(private$.observed_data) == 0) {
        cli::cli_warn("No observed data to remove")
        return(invisible(self))
      }

      # Get current observed data names
      current_names <- sapply(private$.observed_data, function(od) od$name)

      # Check if requested observed data exist
      for (name in observed_data_name) {
        if (!(name %in% current_names)) {
          cli::cli_warn("Observed data '{name}' not found in snapshot")
        }
      }

      # Remove the requested observed data
      keep_indices <- which(!(current_names %in% observed_data_name))

      if (length(keep_indices) == 0) {
        private$.observed_data <- list()
      } else {
        private$.observed_data <- private$.observed_data[keep_indices]
      }

      # Reset the named list
      private$.observed_data_named <- private$.build_named_list(
        private$.observed_data,
        "observed_data_collection"
      )

      cli::cli_alert_success(
        "Removed {length(observed_data_name)} observed data item(s)"
      )
      invisible(self)
    }
  ),
  active = list(
    #' @field data The aggregated data of the snapshot from all components
    data = function() {
      # Start with a copy of the original data
      result <- private$.original_data

      # Update with current compound data
      if (length(private$.compounds) > 0) {
        # Extract raw data from each compound object
        compound_data <- lapply(private$.compounds, function(comp) comp$data)
        result$Compounds <- compound_data
      }

      # Update with current expression profile data
      if (length(private$.expression_profiles) > 0) {
        # Extract raw data from each expression profile object
        expression_profile_data <- lapply(
          private$.expression_profiles,
          function(profile) profile$data
        )
        result$ExpressionProfiles <- expression_profile_data
      }

      # Update with current individual data
      if (length(private$.individuals) > 0) {
        # Extract raw data from each individual object
        individual_data <- lapply(private$.individuals, function(ind) ind$data)
        result$Individuals <- individual_data
      }

      # Update with current formulation data
      if (length(private$.formulations) > 0) {
        # Extract raw data from each formulation object
        formulation_data <- lapply(
          private$.formulations,
          function(form) form$data
        )
        result$Formulations <- formulation_data
      }

      # Update with current population data
      if (length(private$.populations) > 0) {
        # Extract raw data from each population object
        population_data <- lapply(
          private$.populations,
          function(pop) pop$data
        )
        result$Populations <- population_data
      }

      # Update with current event data
      if (length(private$.events) > 0) {
        # Extract raw data from each event object
        event_data <- lapply(
          private$.events,
          function(evt) evt$data
        )
        result$Events <- event_data
      }

      # Update with current protocol data
      if (length(private$.protocols) > 0) {
        # Extract raw data from each protocol object
        protocol_data <- lapply(
          private$.protocols,
          function(protocol) protocol$data
        )
        result$Protocols <- protocol_data
      }

      # Update with current observed data
      # Note: DataSet objects have no $data accessor so the raw JSON entries in
      # `.original_data$ObservedData` are the source of truth on export. When
      # the lazy cache has been touched, filter the original entries down to
      # the names that still survive in the cache so removals and re-orderings
      # are honored. Items added at runtime (whose backing JSON is not in
      # `.original_data`) cannot be serialized here and are dropped with a
      # warning.
      if (!is.null(private$.observed_data)) {
        if (length(private$.observed_data) == 0) {
          result$ObservedData <- NULL
        } else {
          surviving_names <- vapply(
            private$.observed_data,
            function(od) od$name,
            character(1)
          )
          original <- private$.original_data$ObservedData
          original_names <- vapply(
            original,
            function(od) od$Name %||% od$name,
            character(1)
          )
          result$ObservedData <- original[original_names %in% surviving_names]
          if (length(private$.observed_data) > length(result$ObservedData)) {
            cli::cli_warn(c(
              "Some observed data added at runtime cannot be serialized.",
              i = "DataSet objects have no $data accessor; only original entries are exported."
            ))
          }
        }
      }

      return(result)
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

    # Convert the raw version number to a human-readable PKSIM version
    # Returns a string with the human-readable PKSIM version
    .get_pksim_version = function() {
      version_num <- as.integer(private$.original_data$Version)

      pksim_version <- switch(
        as.character(version_num),
        "80" = "12.0",
        "79" = "11.2",
        "78" = "10.0",
        "77" = "9.1",
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

      if (!anyDuplicated(keys)) {
        named <- items
        names(named) <- keys
        return(as_snapshot_collection(named, collection_class))
      }

      named <- list()
      key_counts <- table(keys)
      key_indices <- list()

      for (i in seq_along(items)) {
        key <- keys[i]

        if (is.null(key_indices[[key]])) {
          key_indices[[key]] <- 0
        }
        key_indices[[key]] <- key_indices[[key]] + 1

        if (key_counts[key] > 1) {
          final_name <- glue::glue("{key}_{key_indices[[key]]}")
        } else {
          final_name <- key
        }

        named[[final_name]] <- items[[i]]
      }

      as_snapshot_collection(named, collection_class)
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
