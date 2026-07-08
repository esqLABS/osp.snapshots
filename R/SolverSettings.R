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

    #' @field abs_tol Absolute solver tolerance. Writable: a single numeric
    #'   value, or `NULL` to clear.
    abs_tol = function(value) {
      if (missing(value)) {
        return(private$.data$AbsTol)
      }
      if (!is.null(value)) {
        check_single_numeric(value, "abs_tol")
      }
      private$.data$AbsTol <- value
    },

    #' @field rel_tol Relative solver tolerance. Writable: a single numeric
    #'   value, or `NULL` to clear.
    rel_tol = function(value) {
      if (missing(value)) {
        return(private$.data$RelTol)
      }
      if (!is.null(value)) {
        check_single_numeric(value, "rel_tol")
      }
      private$.data$RelTol <- value
    },

    #' @field use_jacobian Whether to use the Jacobian during integration.
    #'   Writable: a single logical value, or `NULL` to clear.
    use_jacobian = function(value) {
      if (missing(value)) {
        return(private$.data$UseJacobian)
      }
      if (!is.null(value)) {
        check_single_logical(value, "use_jacobian")
      }
      private$.data$UseJacobian <- value
    },

    #' @field h0 Initial step size. Writable: a single numeric value, or
    #'   `NULL` to clear.
    h0 = function(value) {
      if (missing(value)) {
        return(private$.data$H0)
      }
      if (!is.null(value)) {
        check_single_numeric(value, "h0")
      }
      private$.data$H0 <- value
    },

    #' @field h_min Minimum step size. Writable: a single numeric value, or
    #'   `NULL` to clear.
    h_min = function(value) {
      if (missing(value)) {
        return(private$.data$HMin)
      }
      if (!is.null(value)) {
        check_single_numeric(value, "h_min")
      }
      private$.data$HMin <- value
    },

    #' @field h_max Maximum step size. Writable: a single numeric value, or
    #'   `NULL` to clear.
    h_max = function(value) {
      if (missing(value)) {
        return(private$.data$HMax)
      }
      if (!is.null(value)) {
        check_single_numeric(value, "h_max")
      }
      private$.data$HMax <- value
    },

    #' @field mx_step Maximum number of internal solver steps. Writable: a
    #'   single positive whole number (stored as an integer), or `NULL` to
    #'   clear.
    mx_step = function(value) {
      if (missing(value)) {
        return(private$.data$MxStep)
      }
      if (!is.null(value)) {
        check_positive_whole_number(value, "mx_step")
        value <- as.integer(value)
      }
      private$.data$MxStep <- value
    }
  ),
  private = list(
    .data = NULL
  )
)

# Internal guards shared by the SolverSettings setters and
# `create_solver_settings()`, colocated here since only this class and its
# factory use them.

check_single_numeric <- function(value, arg, call = parent.frame()) {
  if (!is.numeric(value) || length(value) != 1) {
    cli::cli_abort("{.arg {arg}} must be a single numeric value", call = call)
  }
  invisible(value)
}

check_single_logical <- function(value, arg, call = parent.frame()) {
  if (!is.logical(value) || length(value) != 1) {
    cli::cli_abort("{.arg {arg}} must be a single logical value", call = call)
  }
  invisible(value)
}

check_positive_whole_number <- function(value, arg, call = parent.frame()) {
  if (
    !is.numeric(value) ||
      length(value) != 1 ||
      !is.finite(value) ||
      value != as.integer(value) ||
      value < 1
  ) {
    cli::cli_abort(
      "{.arg {arg}} must be a single positive whole number",
      call = call
    )
  }
  invisible(value)
}
