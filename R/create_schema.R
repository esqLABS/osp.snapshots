#' Create a new schema
#'
#' @description
#' Create a [Schema] for an Advanced [Protocol] from named arguments.
#' This is a thin factory around `Schema$new()` that builds the raw list
#' shape for you.
#'
#' A schema is a repeatable block inside an Advanced [Protocol]: it has
#' a name, schema-level parameters (typically `NumberOfRepetitions`,
#' `TimeBetweenRepetitions`, and `Start time`), and an ordered list of
#' [SchemaItem] applications. The three repetition parameters are
#' available as the plain, unit-aware arguments `number_of_repetitions`,
#' `time_between_repetitions`, and `start_time`; anything else is supplied
#' through the `parameters` escape hatch.
#'
#' @param name Character. Name of the schema (required).
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists. This is the escape
#'   hatch for any schema-level parameter not promoted to a plain
#'   argument. Each promoted argument is mutually exclusive with a
#'   matching entry here (an entry named `"NumberOfRepetitions"`,
#'   `"TimeBetweenRepetitions"`, or `"Start time"`): supply a repetition
#'   parameter either as the plain argument or as a `parameters` entry,
#'   not both.
#' @param items List of [SchemaItem] objects (created with
#'   [create_schema_item()]) or raw schema item lists. These define the
#'   applications inside the schema.
#' @param number_of_repetitions Numeric. Optional count of schema
#'   repetitions (`NumberOfRepetitions`). A single finite whole number
#'   (dimensionless, no unit). Mutually exclusive with a
#'   `"NumberOfRepetitions"` entry in `parameters`.
#' @param time_between_repetitions Numeric. Optional time between
#'   repetitions (`TimeBetweenRepetitions`). A single finite numeric.
#'   Mutually exclusive with a `"TimeBetweenRepetitions"` entry in
#'   `parameters`.
#' @param time_between_repetitions_unit Character. Display unit for
#'   `time_between_repetitions`, default `"h"`, validated against the
#'   `"Time"` dimension.
#' @param start_time Numeric. Optional schema start time (`Start time`).
#'   A single finite numeric. Mutually exclusive with a `"Start time"`
#'   entry in `parameters`.
#' @param start_time_unit Character. Display unit for `start_time`,
#'   default `"h"`, validated against the `"Time"` dimension.
#'
#' @return A [Schema] object.
#' @export
#'
#' @examples
#' # A schema using the promoted repetition arguments
#' schema <- create_schema(
#'   name = "Schema 1",
#'   number_of_repetitions = 3,
#'   time_between_repetitions = 24,
#'   start_time = 0
#' )
#'
#' # A once-daily schema with a single oral application, using the
#' # `parameters` escape hatch for the schema-level parameters
#' schema <- create_schema(
#'   name = "Schema 1",
#'   parameters = list(
#'     create_parameter(name = "NumberOfRepetitions", value = 1),
#'     create_parameter(name = "TimeBetweenRepetitions", value = 0, unit = "h")
#'   ),
#'   items = list(
#'     create_schema_item(
#'       name = "Item 1",
#'       application_type = "Oral",
#'       parameters = list(
#'         create_parameter(name = "InputDose", value = 5, unit = "mg")
#'       )
#'     )
#'   )
#' )
create_schema <- function(
  name,
  parameters = NULL,
  items = NULL,
  number_of_repetitions = NULL,
  time_between_repetitions = NULL,
  time_between_repetitions_unit = "h",
  start_time = NULL,
  start_time_unit = "h"
) {
  check_required_string(name, "name")
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("{.arg parameters} must be a list")
  }

  # Validate the promoted scalar values and, for the time values, their
  # units. Build the promoted parameter entries in signature order.
  promoted <- list()
  if (!is.null(number_of_repetitions)) {
    check_finite_scalar(number_of_repetitions, "number_of_repetitions")
    if (
      abs(number_of_repetitions - round(number_of_repetitions)) >=
        .Machine$double.eps^0.5
    ) {
      cli::cli_abort(
        "{.arg number_of_repetitions} must be a single finite whole number"
      )
    }
    promoted <- c(
      promoted,
      list(create_parameter(
        name = "NumberOfRepetitions",
        value = number_of_repetitions
      ))
    )
  }
  if (!is.null(time_between_repetitions)) {
    check_finite_scalar(time_between_repetitions, "time_between_repetitions")
    validate_unit(time_between_repetitions_unit, "Time")
    promoted <- c(
      promoted,
      list(create_parameter(
        name = "TimeBetweenRepetitions",
        value = time_between_repetitions,
        unit = time_between_repetitions_unit
      ))
    )
  }
  if (!is.null(start_time)) {
    check_finite_scalar(start_time, "start_time")
    validate_unit(start_time_unit, "Time")
    promoted <- c(
      promoted,
      list(create_parameter(
        name = "Start time",
        value = start_time,
        unit = start_time_unit
      ))
    )
  }

  # Detect a value supplied both as a promoted argument and in
  # `parameters`, before merging. Resolve each `parameters` entry's name
  # from `Name`, falling back to `Path` (mirroring how
  # `to_raw_parameters(., "Name")` folds `Path` into `Name`).
  promoted_names <- c(
    if (!is.null(number_of_repetitions)) "NumberOfRepetitions",
    if (!is.null(time_between_repetitions)) "TimeBetweenRepetitions",
    if (!is.null(start_time)) "Start time"
  )
  if (!is.null(parameters) && length(promoted_names) > 0) {
    existing_names <- vapply(
      parameters,
      function(param) {
        raw <- if (inherits(param, "Parameter")) param$data else param
        (raw$Name %||% raw$Path) %||% NA_character_
      },
      character(1)
    )
    conflicting <- intersect(promoted_names, existing_names)
    if (length(conflicting) > 0) {
      cli::cli_abort(c(
        "A schema parameter was supplied both as a promoted argument and in {.arg parameters}.",
        "i" = "Supply each repetition parameter either as a plain argument ({.arg number_of_repetitions}, {.arg time_between_repetitions}, {.arg start_time}) or as an entry in {.arg parameters}, not both.",
        "x" = "Conflicting parameter{?s}: {.val {conflicting}}."
      ))
    }
  }

  data <- list(Name = name)

  # Merge the existing `parameters` entries (first) with the promoted
  # entries (after, in signature order). When neither is supplied,
  # `data$Parameters` is left unset (byte-identical to a bare schema).
  raw_parameters <- NULL
  if (!is.null(parameters)) {
    # Schema parameters use Name (not Path) in the JSON shape, mirroring the
    # simple-protocol path.
    raw_parameters <- to_raw_parameters(parameters, "Name")
  }
  if (length(promoted) > 0) {
    raw_parameters <- c(
      raw_parameters %||% list(),
      to_raw_parameters(promoted, "Name")
    )
  }
  if (!is.null(raw_parameters)) {
    data$Parameters <- raw_parameters
  }

  if (!is.null(items)) {
    data$SchemaItems <- to_raw_r6_or_list(items, "SchemaItem", "items")
  }

  Schema$new(data)
}

# Internal: assert a promoted schema scalar is a single finite numeric.
# `arg_name` drives the abort message; the call site handles the NULL
# "not supplied" guard and any extra checks (e.g. whole-number).
check_finite_scalar <- function(value, arg_name, call = parent.frame()) {
  if (!is.numeric(value) || length(value) != 1 || !is.finite(value)) {
    cli::cli_abort(
      "{.arg {arg_name}} must be a single finite numeric value",
      call = call
    )
  }
  invisible(value)
}
