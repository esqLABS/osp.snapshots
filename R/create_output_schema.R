#' Create an output schema for a simulation
#'
#' @description
#' Build an [OutputSchema] from a list of [OutputInterval] objects.
#'
#' @param intervals List of [OutputInterval] objects (created with
#'   [create_output_interval()]) or raw lists. Defaults to an empty list.
#'
#' @return An [OutputSchema] object.
#' @export
#'
#' @examples
#' create_output_schema(
#'   intervals = list(
#'     create_output_interval(start_time = 0, end_time = 2, resolution = 20),
#'     create_output_interval(start_time = 2, end_time = 24, resolution = 20)
#'   )
#' )
create_output_schema <- function(intervals = list()) {
  raw <- to_raw_r6_or_list(intervals, "OutputInterval", "intervals")
  OutputSchema$new(raw)
}
