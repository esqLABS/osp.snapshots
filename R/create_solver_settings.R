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
    check_single_numeric(abs_tol, "abs_tol")
    data$AbsTol <- abs_tol
  }
  if (!is.null(rel_tol)) {
    check_single_numeric(rel_tol, "rel_tol")
    data$RelTol <- rel_tol
  }
  if (!is.null(use_jacobian)) {
    check_single_logical(use_jacobian, "use_jacobian")
    data$UseJacobian <- use_jacobian
  }
  if (!is.null(h0)) {
    check_single_numeric(h0, "h0")
    data$H0 <- h0
  }
  if (!is.null(h_min)) {
    check_single_numeric(h_min, "h_min")
    data$HMin <- h_min
  }
  if (!is.null(h_max)) {
    check_single_numeric(h_max, "h_max")
    data$HMax <- h_max
  }
  if (!is.null(mx_step)) {
    check_positive_whole_number(mx_step, "mx_step")
    data$MxStep <- as.integer(mx_step)
  }
  SolverSettings$new(data)
}
