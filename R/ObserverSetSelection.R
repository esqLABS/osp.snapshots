#' ObserverSetSelection class for Simulation observer-set references
#'
#' @description
#' An R6 class representing one entry in a [Simulation]'s `ObserverSets`
#' array. Resolves to an [ObserverSet] building block by name.
#'
#' @importFrom R6 R6Class
#' @export
ObserverSetSelection <- R6::R6Class(
  classname = "ObserverSetSelection",
  public = list(
    #' @description
    #' Create a new ObserverSetSelection object.
    #' @param data Raw `ObserverSetSelection` data from a snapshot.
    #' @return A new ObserverSetSelection object.
    initialize = function(data) {
      private$.data <- data
    }
  ),
  active = list(
    #' @field data The raw data of the selection (read-only).
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the observer-set building block.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
