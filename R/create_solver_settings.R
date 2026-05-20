#' Create a solver settings object for a simulation
#'
#' @description
#' Build a [SolverSettings] object, used inside a [Simulation]. All
#' arguments are optional; absent fields fall back to PK-Sim solver
#' defaults at load time.
#'
#' @param abs_tol Numeric. Absolute solver tolerance.
#' @param rel_tol Numeric. Relative solver tolerance.
#' @param use_jacobian Logical. Whether to use the Jacobian during
#'   integration.
#' @param h0 Numeric. Initial step size.
#' @param h_min Numeric. Minimum step size.
#' @param h_max Numeric. Maximum step size.
#' @param mx_step Integer. Maximum number of internal solver steps.
#'
#' @return A [SolverSettings] object.
#' @export
#'
#' @examples
#' create_solver_settings()
#'
#' create_solver_settings(abs_tol = 1e-9, rel_tol = 1e-9, mx_step = 100000)
create_solver_settings <- function(
  abs_tol = NULL,
  rel_tol = NULL,
  use_jacobian = NULL,
  h0 = NULL,
  h_min = NULL,
  h_max = NULL,
  mx_step = NULL
) {
  data <- list()
  if (!is.null(abs_tol)) {
    if (!is.numeric(abs_tol) || length(abs_tol) != 1) {
      cli::cli_abort("{.arg abs_tol} must be a single numeric value")
    }
    data$AbsTol <- abs_tol
  }
  if (!is.null(rel_tol)) {
    if (!is.numeric(rel_tol) || length(rel_tol) != 1) {
      cli::cli_abort("{.arg rel_tol} must be a single numeric value")
    }
    data$RelTol <- rel_tol
  }
  if (!is.null(use_jacobian)) {
    if (!is.logical(use_jacobian) || length(use_jacobian) != 1) {
      cli::cli_abort("{.arg use_jacobian} must be a single logical value")
    }
    data$UseJacobian <- use_jacobian
  }
  if (!is.null(h0)) {
    if (!is.numeric(h0) || length(h0) != 1) {
      cli::cli_abort("{.arg h0} must be a single numeric value")
    }
    data$H0 <- h0
  }
  if (!is.null(h_min)) {
    if (!is.numeric(h_min) || length(h_min) != 1) {
      cli::cli_abort("{.arg h_min} must be a single numeric value")
    }
    data$HMin <- h_min
  }
  if (!is.null(h_max)) {
    if (!is.numeric(h_max) || length(h_max) != 1) {
      cli::cli_abort("{.arg h_max} must be a single numeric value")
    }
    data$HMax <- h_max
  }
  if (!is.null(mx_step)) {
    if (!is.numeric(mx_step) || length(mx_step) != 1) {
      cli::cli_abort("{.arg mx_step} must be a single numeric value")
    }
    data$MxStep <- mx_step
  }
  SolverSettings$new(data)
}
