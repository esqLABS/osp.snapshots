#' Create an event selection for a simulation
#'
#' @description
#' Build an [EventSelection] entry that references an [Event] building
#' block by name and supplies a numeric start time (in hours) for the
#' event inside the simulation.
#'
#' @param name Character. Name of the event building block (required).
#' @param start_time Numeric. Start time, in hours, when the event fires
#'   in the simulation (required).
#'
#' @return An [EventSelection] object.
#' @export
#'
#' @examples
#' create_event_selection(name = "GB emptying", start_time = 12)
create_event_selection <- function(name, start_time) {
  check_required_string(name, "name")
  if (
    missing(start_time) ||
      !is.numeric(start_time) ||
      length(start_time) != 1
  ) {
    cli::cli_abort("{.arg start_time} must be a single numeric value")
  }

  EventSelection$new(list(
    Name = name,
    StartTime = list(Value = start_time, Unit = "h")
  ))
}
