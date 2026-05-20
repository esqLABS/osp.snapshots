#' Create an output interval for a simulation output schema
#'
#' @description
#' Build an [OutputInterval] entry, used inside an [OutputSchema] to
#' record one time window of output reporting (start time, end time,
#' resolution). All three time parameters are required; PK-Sim's default
#' units (`"h"` for times and `"pts/h"` for resolution) are used.
#'
#' @param name Character. Optional interval name.
#' @param start_time Numeric. Interval start time, in hours (required).
#' @param end_time Numeric. Interval end time, in hours (required).
#' @param resolution Numeric. Reporting resolution, in points per hour
#'   (required).
#'
#' @return An [OutputInterval] object.
#' @export
#'
#' @examples
#' create_output_interval(start_time = 0, end_time = 24, resolution = 20)
create_output_interval <- function(
  name = NULL,
  start_time,
  end_time,
  resolution
) {
  if (!is.null(name)) {
    check_required_string(name, "name")
  }
  if (
    missing(start_time) ||
      !is.numeric(start_time) ||
      length(start_time) != 1 ||
      !is.finite(start_time)
  ) {
    cli::cli_abort("{.arg start_time} must be a single finite numeric value")
  }
  if (
    missing(end_time) ||
      !is.numeric(end_time) ||
      length(end_time) != 1 ||
      !is.finite(end_time)
  ) {
    cli::cli_abort("{.arg end_time} must be a single finite numeric value")
  }
  if (
    missing(resolution) ||
      !is.numeric(resolution) ||
      length(resolution) != 1 ||
      !is.finite(resolution) ||
      resolution <= 0
  ) {
    cli::cli_abort(
      "{.arg resolution} must be a single finite positive numeric value"
    )
  }
  if (end_time <= start_time) {
    cli::cli_abort(
      "{.arg end_time} ({end_time}) must be greater than {.arg start_time} ({start_time})"
    )
  }

  data <- list()
  if (!is.null(name)) {
    data$Name <- name
  }
  data$Parameters <- list(
    list(Name = "Start time", Value = start_time, Unit = "h"),
    list(Name = "End time", Value = end_time, Unit = "h"),
    list(Name = "Resolution", Value = resolution, Unit = "pts/h")
  )

  OutputInterval$new(data)
}
