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
      jsonlite::write_json(self$data, path, auto_unbox = TRUE, pretty = TRUE)
      cli::cli_alert_success("Snapshot exported to {.file {path}}")
      invisible(self)
    }
  ),

  active = list(
    #' @field pksim_version The human-readable PKSIM version corresponding to the snapshot version
    pksim_version = function() {
      private$.get_pksim_version()
    },

    #' @field compounds List of Compound objects in the snapshot
    compounds = function(value = NULL) {
      if (is.null(private$.compounds)) {
        if (is.null(self$data$Compounds)) {
          private$.compounds <- list()
        } else {
          result <- lapply(self$data$Compounds, function(compound_data) {
            Compound$new(compound_data)
          })

          names(result) <- vapply(self$data$Compounds, function(x) x$Name, character(1))
          private$.compounds <- result
        }
      }
      if (is.null(value)) {
        class(private$.compounds) <- c("compound_collection", "list")
        return(private$.compounds)
      } else {
        return(private$.compounds[[value]])
      }
    }
  ),
  private = list(
    # Convert the raw version number to a human-readable PKSIM version
    # Returns a string with the human-readable PKSIM version
    .get_pksim_version = function() {
      version_num <- as.integer(self$data$Version)

      pksim_version <- switch(as.character(version_num),
                             "80" = "12.0",
                             "79" = "11.2",
                             "78" = "10.0",
                             "77" = "9.1",
                             "Unknown")

      return(pksim_version)
    },

    # Store compound objects
    .compounds = NULL
  )
)
