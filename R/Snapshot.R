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
    #' @field path The path to the snapshot file
    path = NULL,

    #' @description
    #' Create a new Snapshot object from a JSON file
    #' @param path Path to the snapshot JSON file
    #' @return A new Snapshot object
    initialize = function(path) {
      cli::cli_alert_info("Reading snapshot from {.file {path}}")
      self$path <- path
      private$.original_data <- jsonlite::fromJSON(
        txt = path,
        simplifyDataFrame = FALSE
      )

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
          final_name <- paste0(name, "_", name_indices[[name]])
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
          final_name <- paste0(name, "_", name_indices[[name]])
        } else {
          final_name <- name
        }

        individuals_named[[final_name]] <- private$.individuals[[i]]
      }

      class(individuals_named) <- c("individual_collection", "list")
      private$.individuals_named <- individuals_named
    },

    # Store compound objects in an unnamed list
    .compounds = NULL,

    # Cache for the named compounds list with disambiguated names
    .compounds_named = NULL,

    # Store individual objects in an unnamed list
    .individuals = NULL,

    # Cache for the named individuals list with disambiguated names
    .individuals_named = NULL
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
#' @param temp_dir Character string. Path to a temporary directory for downloading files.
#'   Defaults to a subdirectory in the R session's temporary directory.
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
load_snapshot <- function(
  source
) {
  temp_dir = file.path(tempdir(), "osp_snapshots")

  if (is.null(source) || !is.character(source) || length(source) != 1) {
    cli::cli_abort("Source must be a single character string")
  }

  # Create the temp directory if it doesn't exist
  if (!dir.exists(temp_dir)) {
    dir.create(temp_dir, recursive = TRUE)
  }

  # Check if source is a local file
  if (file.exists(source) && grepl("\\.json$", source, ignore.case = TRUE)) {
    return(Snapshot$new(source))
  }

  # Check if source is a URL
  if (grepl("^https?://", source)) {
    temp_file <- file.path(temp_dir, basename(source))
    tryCatch(
      {
        cli::cli_alert_info("Downloading snapshot from URL: {.url {source}}")
        utils::download.file(source, temp_file, mode = "wb", quiet = TRUE)
        return(Snapshot$new(temp_file))
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

  temp_templates <- file.path(temp_dir, "templates.json")
  tryCatch(
    {
      utils::download.file(
        templates_url,
        temp_templates,
        mode = "wb",
        quiet = TRUE
      )
      templates <- jsonlite::fromJSON(temp_templates)

      # Find the template with matching name (case insensitive)
      template_idx <- which(
        tolower(templates$Templates$Name) == tolower(source)
      )

      if (length(template_idx) == 0) {
        cli::cli_abort("No template found with name: {source}")
      }

      template_url <- templates$Templates$Url[template_idx[1]]
      cli::cli_alert_info("Found template: {template_url}")

      # Download the template
      temp_file <- file.path(temp_dir, paste0(source, ".json"))
      utils::download.file(template_url, temp_file, mode = "wb", quiet = TRUE)
      return(Snapshot$new(temp_file))
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
#' snapshot <- add_individual_to_snapshot(snapshot, ind)
#' }
add_individual_to_snapshot <- function(snapshot, individual) {
  # Validate that the snapshot is a Snapshot object
  if (!inherits(snapshot, "Snapshot")) {
    cli::cli_abort(
      "Expected a Snapshot object, but got {.cls {class(snapshot)[1]}}"
    )
  }

  # Call the add_individual method of the Snapshot class
  snapshot$add_individual(individual)

  # Return the updated snapshot
  invisible(snapshot)
}
