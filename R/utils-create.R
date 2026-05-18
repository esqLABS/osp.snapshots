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

# Internal: convert a list of Parameter R6 objects (or raw parameter lists)
# into the raw list-of-lists shape used in snapshot JSON.
# `name_key` must be supplied explicitly:
#   - `"Path"` keeps parameter Path fields untouched (used where the JSON
#     shape keys on Path, for example ExpressionProfile parameters).
#   - `"Name"` renames any `Path` field to `Name`, dropping the original
#     `Path` (used by Compound, Event, and Protocol parameter arrays which
#     key on `Name`).
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
    }
    raw
  })
}
