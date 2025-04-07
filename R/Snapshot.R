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
    #' @field data The raw data of the snapshot
    data = NULL,

    #' @field path The path to the snapshot file
    path = NULL,

    #' @description
    #' Create a new Snapshot object from a JSON file
    #' @param path Path to the snapshot JSON file
    #' @return A new Snapshot object
    initialize = function(path) {
      cli::cli_alert_info("Reading snapshot from {.file {path}}")
      self$path <- path
      self$data <- jsonlite::fromJSON(txt = path, simplifyDataFrame = FALSE)

      # Initialize compounds list during snapshot initialization
      if (is.null(self$data$Compounds)) {
        private$.compounds <- list()
      } else {
        # Create compound objects and store in an unnamed list
        private$.compounds <- lapply(
          self$data$Compounds,
          function(compound_data) {
            Compound$new(compound_data)
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
      raw_version <- self$data$Version
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
    }
  ),
  active = list(
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
        return(private$.compounds_named[[value]])
      }
    }
  ),
  private = list(
    .pksim_version = NULL,
    # Convert the raw version number to a human-readable PKSIM version
    # Returns a string with the human-readable PKSIM version
    .get_pksim_version = function() {
      version_num <- as.integer(self$data$Version)

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

    # Method to modify compounds list and invalidate the named cache
    .set_compounds = function(new_compounds) {
      private$.compounds <- new_compounds
      # Invalidate the named list cache so it will be rebuilt on next access
      private$.compounds_named <- NULL
    },

    # Store compound objects in an unnamed list
    .compounds = NULL,

    # Cache for the named compounds list with disambiguated names
    .compounds_named = NULL
  )
)
