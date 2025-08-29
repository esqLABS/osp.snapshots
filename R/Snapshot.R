#' Snapshot class for OSP snapshots
#'
#' @description
#' An R6 class that represents an OSP snapshot file. This class provides
#' methods to access different components of the snapshot and visualize its structure.
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
          simplifyDataFrame = FALSE
        )
      } else if (is.list(input)) {
        cli::cli_alert_info("Creating snapshot from list data")
        private$.original_data <- input
      } else {
        cli::cli_abort("Input must be either a path to a JSON file or a list")
      }

      # Initialize compounds list during snapshot initialization
      if (is.null(private$.original_data$Compounds)) {
        private$.compounds <- list()
      } else {
        # Create compound objects and store in an unnamed list
        private$.compounds <- lapply(
          private$.original_data$Compounds,
          function(compound_data) {
            Compound$new(compound_data)
          }
        )
      }

      # Initialize expression profiles list during snapshot initialization
      if (is.null(private$.original_data$ExpressionProfiles)) {
        private$.expression_profiles <- list()
      } else {
        # Create expression profile objects and store in an unnamed list
        private$.expression_profiles <- lapply(
          private$.original_data$ExpressionProfiles,
          function(expression_profile_data) {
            ExpressionProfile$new(expression_profile_data)
          }
        )
      }

      # Initialize individuals list during snapshot initialization
      if (is.null(private$.original_data$Individuals)) {
        private$.individuals <- list()
      } else {
        # Create individual objects and store in an unnamed list
        private$.individuals <- lapply(
          private$.original_data$Individuals,
          function(individual_data) {
            Individual$new(individual_data)
          }
        )
      }

      # Initialize formulations list during snapshot initialization
      if (is.null(private$.original_data$Formulations)) {
        private$.formulations <- list()
      } else {
        # Create formulation objects and store in an unnamed list
        private$.formulations <- lapply(
          private$.original_data$Formulations,
          function(formulation_data) {
            Formulation$new(formulation_data)
          }
        )
      }

      # Initialize populations list during snapshot initialization
      if (is.null(private$.original_data$Populations)) {
        private$.populations <- list()
      } else {
        # Create population objects and store in an unnamed list
        private$.populations <- lapply(
          private$.original_data$Populations,
          function(population_data) {
            Population$new(population_data)
          }
        )
      }

      # Initialize events list during snapshot initialization
      if (is.null(private$.original_data$Events)) {
        private$.events <- list()
      } else {
        # Create event objects and store in an unnamed list
        private$.events <- lapply(
          private$.original_data$Events,
          function(event_data) {
            Event$new(event_data)
          }
        )
      }

      # Initialize protocols list during snapshot initialization
      if (is.null(private$.original_data$Protocols)) {
        private$.protocols <- list()
      } else {
        # Create protocol objects and store in an unnamed list
        private$.protocols <- lapply(
          private$.original_data$Protocols,
          function(protocol_data) {
            Protocol$new(protocol_data)
          }
        )
      }

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

      # Add the individual to the list
      private$.individuals <- c(private$.individuals, list(individual))

      # Reset the named list to include the new individual
      private$.individuals_named <- NULL
      private$.build_individuals_named_list()

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
      private$.individuals_named <- NULL
      private$.build_individuals_named_list()

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

      # Add the formulation to the list
      private$.formulations <- c(private$.formulations, list(formulation))

      # Reset the named list to include the new formulation
      private$.formulations_named <- NULL
      private$.build_formulations_named_list()

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
      private$.formulations_named <- NULL
      private$.build_formulations_named_list()

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
      private$.populations_named <- NULL
      private$.build_populations_named_list()

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

      # Add the expression profile to the list
      private$.expression_profiles <- c(
        private$.expression_profiles,
        list(expression_profile)
      )

      # Reset the named list to include the new expression profile
      private$.expression_profiles_named <- NULL
      private$.build_expression_profiles_named_list()

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
    #' snapshot$remove_expression_profile("CYP3A4|Human|Healthy")
    #' }
    remove_expression_profile = function(profile_id) {
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
      private$.expression_profiles_named <- NULL
      private$.build_expression_profiles_named_list()

      cli::cli_alert_success(
        "Removed {length(profile_id)} expression profile(s)"
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
      # Build the named list if it doesn't exist yet
      if (is.null(private$.compounds_named)) {
        private$.build_compounds_named_list()
      }

      if (is.null(value)) {
        return(private$.compounds_named)
      } else {
        private$.compounds <- value
        private$.build_compounds_named_list()
        return(private$.compounds_named)
      }
    },

    #' @field expression_profiles List of ExpressionProfile objects in the snapshot
    expression_profiles = function(value = NULL) {
      # Build the named list if it doesn't exist yet
      if (is.null(private$.expression_profiles_named)) {
        private$.build_expression_profiles_named_list()
      }

      if (is.null(value)) {
        return(private$.expression_profiles_named)
      } else {
        private$.expression_profiles <- value
        private$.build_expression_profiles_named_list()
        return(private$.expression_profiles_named)
      }
    },

    #' @field individuals List of Individual objects in the snapshot
    individuals = function(value = NULL) {
      # Build the named list
      private$.build_individuals_named_list()

      if (is.null(value)) {
        return(private$.individuals_named)
      } else {
        private$.individuals <- value
        private$.build_individuals_named_list()
        return(private$.individuals_named)
      }
    },

    #' @field formulations List of Formulation objects in the snapshot
    formulations = function(value = NULL) {
      # Build the named list
      private$.build_formulations_named_list()

      if (is.null(value)) {
        return(private$.formulations_named)
      } else {
        private$.formulations <- value
        private$.build_formulations_named_list()
        return(private$.formulations_named)
      }
    },

    #' @field populations List of Population objects in the snapshot
    populations = function(value = NULL) {
      # Build the named list
      private$.build_populations_named_list()

      if (is.null(value)) {
        return(private$.populations_named)
      } else {
        private$.populations <- value
        private$.build_populations_named_list()
        return(private$.populations_named)
      }
    },

    #' @field events List of Event objects in the snapshot
    events = function(value = NULL) {
      # Build the named list if it doesn't exist yet
      private$.build_events_named_list()

      if (is.null(value)) {
        return(private$.events_named)
      } else {
        private$.events <- value
        private$.build_events_named_list()
        return(private$.events_named)
      }
    },

    #' @field protocols List of Protocol objects in the snapshot
    protocols = function(value = NULL) {
      # Build the named list if it doesn't exist yet
      private$.build_protocols_named_list()

      if (is.null(value)) {
        return(private$.protocols_named)
      } else {
        private$.protocols <- value
        private$.build_protocols_named_list()
        return(private$.protocols_named)
      }
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
    # Build the named list of compounds with disambiguated names
    .build_compounds_named_list = function() {
      # Create a named list with compound names, handling duplicates
      compounds_named <- list()

      # Handle empty compound list
      if (length(private$.compounds) == 0) {
        class(compounds_named) <- c("compound_collection", "list")
        private$.compounds_named <- compounds_named
        return()
      }

      compound_names <- sapply(private$.compounds, function(x) x$name)

      # Track name occurrences to handle duplicates
      name_counts <- table(compound_names)
      name_indices <- list()

      for (i in seq_along(private$.compounds)) {
        name <- compound_names[i]

        # Initialize counter for this name if not already done
        if (is.null(name_indices[[name]])) {
          name_indices[[name]] <- 0
        }

        # Increment counter
        name_indices[[name]] <- name_indices[[name]] + 1

        # Construct the final name (with suffix if needed)
        if (name_counts[name] > 1) {
          final_name <- glue::glue("{name}_{name_indices[[name]]}")
        } else {
          final_name <- name
        }

        compounds_named[[final_name]] <- private$.compounds[[i]]
      }

      class(compounds_named) <- c("compound_collection", "list")
      private$.compounds_named <- compounds_named
    },

    # Build the named list of individuals with disambiguated names
    .build_individuals_named_list = function() {
      # Create a named list with individual names, handling duplicates
      individuals_named <- list()

      # Handle empty individuals list
      if (length(private$.individuals) == 0) {
        class(individuals_named) <- c("individual_collection", "list")
        private$.individuals_named <- individuals_named
        return()
      }

      individual_names <- sapply(private$.individuals, function(x) x$name)

      # Track name occurrences to handle duplicates
      name_counts <- table(individual_names)
      name_indices <- list()

      for (i in seq_along(private$.individuals)) {
        name <- individual_names[i]

        # Initialize counter for this name if not already done
        if (is.null(name_indices[[name]])) {
          name_indices[[name]] <- 0
        }

        # Increment counter
        name_indices[[name]] <- name_indices[[name]] + 1

        # Construct the final name (with suffix if needed)
        if (name_counts[name] > 1) {
          final_name <- glue::glue("{name}_{name_indices[[name]]}")
        } else {
          final_name <- name
        }

        individuals_named[[final_name]] <- private$.individuals[[i]]
      }

      class(individuals_named) <- c("individual_collection", "list")
      private$.individuals_named <- individuals_named
    },

    # Build the named list of formulations with disambiguated names
    .build_formulations_named_list = function() {
      # Create a named list with formulation names, handling duplicates
      formulations_named <- list()

      # Handle empty formulations list
      if (length(private$.formulations) == 0) {
        class(formulations_named) <- c("formulation_collection", "list")
        private$.formulations_named <- formulations_named
        return()
      }

      formulation_names <- sapply(private$.formulations, function(x) x$name)

      # Track name occurrences to handle duplicates
      name_counts <- table(formulation_names)
      name_indices <- list()

      for (i in seq_along(private$.formulations)) {
        name <- formulation_names[i]

        # Initialize counter for this name if not already done
        if (is.null(name_indices[[name]])) {
          name_indices[[name]] <- 0
        }

        # Increment counter
        name_indices[[name]] <- name_indices[[name]] + 1

        # Construct the final name (with suffix if needed)
        if (name_counts[name] > 1) {
          final_name <- glue::glue("{name}_{name_indices[[name]]}")
        } else {
          final_name <- name
        }

        formulations_named[[final_name]] <- private$.formulations[[i]]
      }

      class(formulations_named) <- c("formulation_collection", "list")
      private$.formulations_named <- formulations_named
    },

    # Build the named list of populations with disambiguated names
    .build_populations_named_list = function() {
      # Create a named list with population names, handling duplicates
      populations_named <- list()

      # Handle empty populations list
      if (length(private$.populations) == 0) {
        class(populations_named) <- c("population_collection", "list")
        private$.populations_named <- populations_named
        return()
      }

      population_names <- sapply(private$.populations, function(x) x$name)

      # Track name occurrences to handle duplicates
      name_counts <- table(population_names)
      name_indices <- list()

      for (i in seq_along(private$.populations)) {
        name <- population_names[i]

        # Initialize counter for this name if not already done
        if (is.null(name_indices[[name]])) {
          name_indices[[name]] <- 0
        }

        # Increment counter
        name_indices[[name]] <- name_indices[[name]] + 1

        # Construct the final name (with suffix if needed)
        if (name_counts[name] > 1) {
          final_name <- glue::glue("{name}_{name_indices[[name]]}")
        } else {
          final_name <- name
        }

        populations_named[[final_name]] <- private$.populations[[i]]
      }

      class(populations_named) <- c("population_collection", "list")
      private$.populations_named <- populations_named
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

    # Build the named list of events with disambiguated names
    .build_events_named_list = function() {
      # Create a named list with event names, handling duplicates
      events_named <- list()

      # Handle empty events list
      if (length(private$.events) == 0) {
        class(events_named) <- c("event_collection", "list")
        private$.events_named <- events_named
        return()
      }

      event_names <- sapply(private$.events, function(x) x$name)

      # Track name occurrences to handle duplicates
      name_counts <- table(event_names)
      name_indices <- list()

      for (i in seq_along(private$.events)) {
        name <- event_names[i]

        # Initialize counter for this name if not already done
        if (is.null(name_indices[[name]])) {
          name_indices[[name]] <- 0
        }

        # Increment counter
        name_indices[[name]] <- name_indices[[name]] + 1

        # Construct the final name (with suffix if needed)
        if (name_counts[name] > 1) {
          final_name <- glue::glue("{name}_{name_indices[[name]]}")
        } else {
          final_name <- name
        }

        events_named[[final_name]] <- private$.events[[i]]
      }

      class(events_named) <- c("event_collection", "list")
      private$.events_named <- events_named
    },

    # Build the named list of expression profiles with disambiguated names
    .build_expression_profiles_named_list = function() {
      # Create a named list with expression profile names, handling duplicates
      expression_profiles_named <- list()

      # Handle empty expression profiles list
      if (length(private$.expression_profiles) == 0) {
        class(expression_profiles_named) <- c(
          "expression_profile_collection",
          "list"
        )
        private$.expression_profiles_named <- expression_profiles_named
        return()
      }

      # Create profile IDs in the format "Molecule|Species|Category"
      profile_ids <- sapply(private$.expression_profiles, function(x) x$id)

      # Track name occurrences to handle duplicates
      name_counts <- table(profile_ids)
      name_indices <- list()

      for (i in seq_along(private$.expression_profiles)) {
        profile_id <- profile_ids[i]

        # Initialize counter for this name if not already done
        if (is.null(name_indices[[profile_id]])) {
          name_indices[[profile_id]] <- 0
        }

        # Increment counter
        name_indices[[profile_id]] <- name_indices[[profile_id]] + 1

        # Construct the final name (with suffix if needed)
        if (name_counts[profile_id] > 1) {
          final_name <- glue::glue("{profile_id}_{name_indices[[profile_id]]}")
        } else {
          final_name <- profile_id
        }

        expression_profiles_named[[
          final_name
        ]] <- private$.expression_profiles[[i]]
      }

      class(expression_profiles_named) <- c(
        "expression_profile_collection",
        "list"
      )
      private$.expression_profiles_named <- expression_profiles_named
    },

    # Build the named list of protocols with disambiguated names
    .build_protocols_named_list = function() {
      # Create a named list with protocol names, handling duplicates
      protocols_named <- list()

      # Handle empty protocol list
      if (length(private$.protocols) == 0) {
        class(protocols_named) <- c("protocol_collection", "list")
        private$.protocols_named <- protocols_named
        return()
      }

      protocol_names <- sapply(private$.protocols, function(x) x$name)

      # Track name occurrences to handle duplicates
      name_counts <- table(protocol_names)
      name_indices <- list()

      for (i in seq_along(private$.protocols)) {
        name <- protocol_names[i]

        # Initialize counter for this name if not already done
        if (is.null(name_indices[[name]])) {
          name_indices[[name]] <- 0
        }

        # Increment counter
        name_indices[[name]] <- name_indices[[name]] + 1

        # Construct the final name (with suffix if needed)
        if (name_counts[name] > 1) {
          final_name <- glue::glue("{name}_{name_indices[[name]]}")
        } else {
          final_name <- name
        }

        protocols_named[[final_name]] <- private$.protocols[[i]]
      }

      class(protocols_named) <- c("protocol_collection", "list")
      private$.protocols_named <- protocols_named
    }
  )
)

#' Load a snapshot from various sources
#'
#' @description
#' Conveniently load an OSP snapshot from a local file, URL, or predefined template name.
#'
#' @param source Character string. Can be:
#'   - Path to a local file (.json)
#'   - URL to a remote snapshot file
#'   - Name of a template from the OSPSuite.BuildingBlockTemplates repository
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
        json_data <- jsonlite::fromJSON(source, simplifyDataFrame = FALSE)
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
  templates_url <- "https://raw.githubusercontent.com/Open-Systems-Pharmacology/OSPSuite.BuildingBlockTemplates/refs/heads/develop/templates.json"

  tryCatch(
    {
      # Download and parse templates JSON directly
      templates <- jsonlite::fromJSON(templates_url)

      # Find the template with matching name (case insensitive)
      template_idx <- which(
        tolower(templates$Templates$Name) == tolower(source)
      )

      if (length(template_idx) == 0) {
        cli::cli_abort("No template found with name: {source}")
      }

      template_url <- templates$Templates$Url[template_idx[1]]
      cli::cli_alert_info("Found template: {template_url}")

      # Download and parse template JSON directly
      json_data <- jsonlite::fromJSON(template_url, simplifyDataFrame = FALSE)
      return(Snapshot$new(json_data))
    },
    error = function(e) {
      cli::cli_abort(
        "Failed to find or download template: {source}\nError: {e$message}"
      )
    }
  )
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
