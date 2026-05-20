#' FormulationSelection class for Simulation compound formulations
#'
#' @description
#' An R6 class representing one entry in a [ProtocolSelection]'s
#' `Formulations` array. Each entry maps a formulation building-block name
#' to a formulation key used by an application within the protocol.
#'
#' @importFrom R6 R6Class
#' @export
FormulationSelection <- R6::R6Class(
  classname = "FormulationSelection",
  public = list(
    #' @description
    #' Create a new FormulationSelection object.
    #' @param data Raw `FormulationSelection` data from a snapshot.
    #' @return A new FormulationSelection object.
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

    #' @field name The name of the formulation building block.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field key The formulation key (application slot) inside the protocol.
    key = function(value) {
      if (missing(value)) {
        return(private$.data$Key)
      }
      private$.data$Key <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
