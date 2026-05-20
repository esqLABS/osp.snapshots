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

    #' @field path The simulation output quantity path.
    path = function(value) {
      if (missing(value)) {
        return(private$.data$Path)
      }
      private$.data$Path <- value
    },

    #' @field observed_data The observed-data repository name.
    observed_data = function(value) {
      if (missing(value)) {
        return(private$.data$ObservedData)
      }
      private$.data$ObservedData <- value
    },

    #' @field scaling The scaling used for the mapping.
    scaling = function(value) {
      if (missing(value)) {
        return(private$.data$Scaling)
      }
      private$.data$Scaling <- value
    },

    #' @field weight A single weight applied to all points of the mapping.
    weight = function(value) {
      if (missing(value)) {
        # [[ ]] (not $) so that an absent `Weight` does not partial-match
        # `Weights`.
        return(private$.data[["Weight"]])
      }
      private$.data[["Weight"]] <- value
    },

    #' @field weights A per-point weight vector.
    weights = function(value) {
      if (missing(value)) {
        return(private$.data[["Weights"]])
      }
      private$.data[["Weights"]] <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
