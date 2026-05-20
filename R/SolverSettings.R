#' SolverSettings class for simulation solver configuration
#'
#' @description
#' An R6 class representing the `Solver` block of a [Simulation]. Each
#' field is optional and inherits the PK-Sim solver default when absent;
#' the underlying raw data list stays sparse so missing fields remain
#' absent on export.
#'
#' @importFrom R6 R6Class
#' @export
SolverSettings <- R6::R6Class(
  classname = "SolverSettings",
  public = list(
    #' @description
    #' Create a new SolverSettings object.
    #' @param data Raw `Solver` data from a snapshot (may be an empty list).
    #' @return A new SolverSettings object.
    initialize = function(data) {
      private$.data <- data %||% empty_named_list()
    }
  ),
  active = list(
    #' @field data The raw data of the solver settings (read-only). An
    #'   empty solver is always returned as a named-empty list so the JSON
    #'   serialiser writes it as `{}` (an object), not `[]` (an array).
    #'   PK-Sim's snapshot mapper requires the object shape.
    data = function(value) {
      if (missing(value)) {
        result <- private$.data
        if (length(result) == 0) {
          return(empty_named_list())
        }
        return(result)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field abs_tol Absolute solver tolerance.
    abs_tol = function(value) {
      if (missing(value)) {
        return(private$.data$AbsTol)
      }
      private$.data$AbsTol <- value
    },

    #' @field rel_tol Relative solver tolerance.
    rel_tol = function(value) {
      if (missing(value)) {
        return(private$.data$RelTol)
      }
      private$.data$RelTol <- value
    },

    #' @field use_jacobian Whether to use the Jacobian during integration.
    use_jacobian = function(value) {
      if (missing(value)) {
        return(private$.data$UseJacobian)
      }
      private$.data$UseJacobian <- value
    },

    #' @field h0 Initial step size.
    h0 = function(value) {
      if (missing(value)) {
        return(private$.data$H0)
      }
      private$.data$H0 <- value
    },

    #' @field h_min Minimum step size.
    h_min = function(value) {
      if (missing(value)) {
        return(private$.data$HMin)
      }
      private$.data$HMin <- value
    },

    #' @field h_max Maximum step size.
    h_max = function(value) {
      if (missing(value)) {
        return(private$.data$HMax)
      }
      private$.data$HMax <- value
    },

    #' @field mx_step Maximum number of internal solver steps.
    mx_step = function(value) {
      if (missing(value)) {
        return(private$.data$MxStep)
      }
      private$.data$MxStep <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
