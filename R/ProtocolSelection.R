#' ProtocolSelection class for Simulation compound protocol assignments
#'
#' @description
#' An R6 class representing the `Protocol` field of a
#' [CompoundProperties]. References a [Protocol] building block by name
#' and lists per-application [FormulationSelection]s mapping formulation
#' keys to formulation building blocks.
#'
#' @importFrom R6 R6Class
#' @export
ProtocolSelection <- R6::R6Class(
  classname = "ProtocolSelection",
  public = list(
    #' @description
    #' Create a new ProtocolSelection object.
    #' @param data Raw `ProtocolSelection` data from a snapshot.
    #' @return A new ProtocolSelection object.
    initialize = function(data) {
      private$.data <- data
      if (!is.null(data$Formulations)) {
        private$.formulations <- lapply(
          data$Formulations,
          function(d) FormulationSelection$new(d)
        )
      } else {
        private$.formulations <- list()
      }
    }
  ),
  active = list(
    #' @field data The raw data of the selection (read-only). Rebuilt from
    #'   the cached [FormulationSelection] list so that mutations flow
    #'   back to the export payload.
    data = function(value) {
      if (missing(value)) {
        result <- private$.data
        if (length(private$.formulations) > 0) {
          formulations <- lapply(private$.formulations, function(f) f$data)
          names(formulations) <- NULL
          result$Formulations <- formulations
        } else if (!is.null(private$.data$Formulations)) {
          result$Formulations <- list()
        }
        return(result)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the protocol building block. Writable: must
    #'   be a non-empty scalar string.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      check_required_string(value, "name")
      private$.data$Name <- value
    },

    #' @field formulations List of [FormulationSelection] objects.
    formulations = function(value) {
      if (missing(value)) {
        return(private$.formulations)
      }
      if (is.null(value)) {
        private$.formulations <- list()
      } else if (is.list(value)) {
        private$.formulations <- value
      } else {
        cli::cli_abort("{.field formulations} must be a list")
      }
    }
  ),
  private = list(
    .data = NULL,
    .formulations = NULL,
    deep_clone = function(name, value) {
      if (name == ".formulations" && is.list(value)) {
        return(lapply(value, function(f) {
          if (inherits(f, "R6")) f$clone(deep = TRUE) else f
        }))
      }
      value
    }
  )
)
