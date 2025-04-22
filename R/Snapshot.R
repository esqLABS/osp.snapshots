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
    #' @field path The path to the snapshot file if loaded from file, NULL otherwise
    path = NULL,

    #' @description
    #' Create a new Snapshot object from a JSON file or a list
    #' @param input Path to the snapshot JSON file, URL, template name, or a list containing snapshot data
    #' @return A new Snapshot object
    initialize = function(input) {
      if (is.character(input)) {
        cli::cli_alert_info("Reading snapshot from {.file {input}}")
        self$path <- input
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

      cli::cli_alert_success("Snapshot loaded successfully")
    },
    #' @description
    #' Print a summary of the snapshot
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      cli::cli_h1("PKSIM Snapshot")

      # Version information
      raw_version <- private$.original_data$Version
      pksim_version <- self$pksim_version
      cli::cli_alert_info("Version: {raw_version} (PKSIM {pksim_version})")

      # Get all sections dynamically from the data
      # We'll exclude Version as it's already displayed
      sections <- names(self$data)[names(self$data) != "Version"]

      # Display counts for each section in alphabetical order
      for (section in sort(sections)) {
        # Only display sections that are lists (collections)
        if (is.list(self$data[[section]])) {
          items <- self$data[[section]]
          count <- length(items)
          cli::cli_li("{section}: {count}")
        }
      }

      # Return the object invisibly
      invisible(self)
    },

    #' @description
    #' Export the snapshot to a JSON file
    #' @param path Path to save the JSON file
    #' @return Invisibly returns the object
    export = function(path) {
      jsonlite::write_json(
        self$data,
        path,
        auto_unbox = TRUE,
        pretty = TRUE,
        digits = NA
      )
      cli::cli_alert_success("Snapshot exported to {.file {path}}")
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

      # Additional components could be added here in the future

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
    }
  ),
  private = list(
    .original_data = NULL,
    .pksim_version = NULL,
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

    # Store compound objects in an unnamed list
    .compounds = NULL,

    # Cache for the named compounds list with disambiguated names
    .compounds_named = NULL,

    # Store individual objects in an unnamed list
    .individuals = NULL,

    # Cache for the named individuals list with disambiguated names
    .individuals_named = NULL,

    # Store formulation objects in an unnamed list
    .formulations = NULL,

    # Cache for the named formulations list with disambiguated names
    .formulations_named = NULL
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
