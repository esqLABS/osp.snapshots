# Valid Scalings enum values, shared by the `scaling` active binding and
# `create_output_mapping()`.
OUTPUT_MAPPING_SCALINGS <- c("Linear", "Log")

#' OutputMapping class for simulation output-to-observed-data mappings
#'
#' @description
#' An R6 class representing one entry in a [Simulation]'s
#' `OutputMappings` array. Each entry maps a simulation output quantity
#' path to an observed-data repository name and records the scaling and
#' weight(s) used when comparing the two.
#'
#' @importFrom R6 R6Class
#' @export
OutputMapping <- R6::R6Class(
  classname = "OutputMapping",
  public = list(
    #' @description
    #' Create a new OutputMapping object.
    #' @param data Raw `OutputMapping` data from a snapshot.
    #' @return A new OutputMapping object.
    initialize = function(data) {
      private$.data <- data
    }
  ),
  active = list(
    #' @field data The raw data of the mapping (read-only).
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field path The simulation output quantity path. Writable: must be a
    #'   non-empty scalar string, or `NULL` to clear.
    path = function(value) {
      if (missing(value)) {
        return(private$.data$Path)
      }
      if (!is.null(value)) {
        check_required_string(value, "path")
      }
      private$.data$Path <- value
    },

    #' @field observed_data The observed-data repository name. Writable:
    #'   must be a non-empty scalar string, or `NULL` to clear.
    observed_data = function(value) {
      if (missing(value)) {
        return(private$.data$ObservedData)
      }
      if (!is.null(value)) {
        check_required_string(value, "observed_data")
      }
      private$.data$ObservedData <- value
    },

    #' @field scaling The scaling used for the mapping. Writable: one of
    #'   `"Linear"`, `"Log"`, or `NULL` to clear.
    scaling = function(value) {
      if (missing(value)) {
        return(private$.data$Scaling)
      }
      if (!is.null(value) && !(value %in% OUTPUT_MAPPING_SCALINGS)) {
        cli::cli_abort(
          "{.arg scaling} must be one of {.val {OUTPUT_MAPPING_SCALINGS}}"
        )
      }
      private$.data$Scaling <- value
    },

    #' @field weight A single weight applied to all points of the mapping.
    #'   Writable: a single numeric value, or `NULL` to clear.
    weight = function(value) {
      if (missing(value)) {
        # [[ ]] (not $) so that an absent `Weight` does not partial-match
        # `Weights`.
        return(private$.data[["Weight"]])
      }
      if (!is.null(value) && (!is.numeric(value) || length(value) != 1)) {
        cli::cli_abort("{.arg weight} must be a single numeric value")
      }
      private$.data[["Weight"]] <- value
    },

    #' @field weights A per-point weight vector. Writable: a numeric vector,
    #'   or `NULL` to clear.
    weights = function(value) {
      if (missing(value)) {
        return(private$.data[["Weights"]])
      }
      if (!is.null(value) && !is.numeric(value)) {
        cli::cli_abort("{.arg weights} must be a numeric vector")
      }
      private$.data[["Weights"]] <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
