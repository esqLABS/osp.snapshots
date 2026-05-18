# Internal helpers shared by the `create_*` factory functions.

# Internal: assert that `value` is a non-empty scalar character.
# Used by the create_* factories to validate required string arguments.
check_required_string <- function(value, arg_name) {
  if (
    missing(value) ||
      is.null(value) ||
      !is.character(value) ||
      length(value) != 1 ||
      is.na(value) ||
      !nzchar(value)
  ) {
    cli::cli_abort(
      "{.arg {arg_name}} must be a non-empty string",
      call = parent.frame()
    )
  }
  invisible(value)
}

# Internal: validate that every entry of `items` is either an R6 instance of
# `r6_class` or a raw list, then return a list of raw shapes (`x$data` for
# R6 entries, `x` as-is for lists). Outer names are dropped so the JSON
# shape stays an array when a caller supplies a named list.
to_raw_r6_or_list <- function(
  items,
  r6_class,
  arg_name,
  call = parent.frame()
) {
  valid <- vapply(
    items,
    function(item) inherits(item, r6_class) || is.list(item),
    logical(1)
  )
  if (!all(valid)) {
    cli::cli_abort(
      "Every entry of {.arg {arg_name}} must be a {.cls {r6_class}} or a raw list",
      call = call
    )
  }
  unname(lapply(items, function(item) {
    if (inherits(item, r6_class)) item$data else item
  }))
}

# Internal: convert a list of Parameter R6 objects (or raw parameter lists)
# into the raw list-of-lists shape used in snapshot JSON.
# `name_key` must be supplied explicitly and selects which field the target
# JSON shape keys on:
#   - `"Path"` (used by ExpressionProfile, Individual, Simulation parameter
#     arrays): the result carries `Path`, copying from `Name` when the
#     incoming parameter only has `Name` (because `create_parameter()`
#     without a `path` argument returns a plain `Parameter` keyed by Name).
#     The original `Name` is dropped.
#   - `"Name"` (used by Compound, Event, Protocol, Formulation parameter
#     arrays): the result carries `Name`, copying from `Path` when the
#     incoming parameter only has `Path`. The original `Path` is dropped.
to_raw_parameters <- function(parameters, name_key) {
  if (!is.list(parameters)) {
    cli::cli_abort(
      "{.arg parameters} must be a list",
      call = parent.frame()
    )
  }
  name_key <- match.arg(name_key, c("Path", "Name"))
  lapply(parameters, function(param) {
    raw <- if (inherits(param, "Parameter")) param$data else param
    if (identical(name_key, "Name")) {
      if (is.null(raw$Name) && !is.null(raw$Path)) {
        raw$Name <- raw$Path
      }
      raw$Path <- NULL
    } else {
      if (is.null(raw$Path) && !is.null(raw$Name)) {
        raw$Path <- raw$Name
      }
      raw$Name <- NULL
    }
    raw
  })
}
