# Shared helper for constructing `Parameter` objects inside building blocks.
#
# Each building block stores its raw parameter dicts in a different sub-key of
# its snapshot slice (typically `private$.data$Parameters`). The construction
# loop, the optional keying by path, and the `parameter_collection` class tag
# used for custom printing are identical across blocks. This helper centralises
# those steps; per-block sub-structure extraction (e.g. Compound processes,
# Formulation's projection of the raw `Parameter` dict onto the fields the
# `Parameter` class actually consumes) stays on the owning class.
#
# Arguments:
#   raw_params: a list of raw parameter dicts (or NULL / empty).
#   key_by: how to name the returned list. "none" returns an unnamed list,
#     "path" uses each Parameter's `path` (falling back to "Unknown"), and
#     "name" uses each Parameter's `name` (also falling back to "Unknown").
#   name_as_path: when TRUE, run `ensure_path_from_name` on every raw dict
#     before constructing the `Parameter` objects. Used by blocks (Protocol,
#     Event, Formulation) whose snapshot parameters carry `Name` rather than
#     `Path`.
#
# Returns a list of `Parameter` objects, always tagged with the
# `parameter_collection` class for custom printing. When `raw_params` is empty
# the result is an empty list with that class still applied.
build_parameters_from_raw <- function(
  raw_params,
  key_by = c("none", "path", "name"),
  name_as_path = FALSE
) {
  key_by <- match.arg(key_by)

  raw_params <- raw_params %||% list()
  if (name_as_path) {
    raw_params <- lapply(raw_params, ensure_path_from_name)
  }

  result <- lapply(
    raw_params,
    \(param_data) Parameter$new(param_data)
  )

  if (length(result) > 0) {
    if (key_by == "path") {
      names(result) <- vapply(
        result,
        \(p) p$path %||% "Unknown",
        character(1)
      )
    } else if (key_by == "name") {
      names(result) <- vapply(
        result,
        \(p) p$name %||% "Unknown",
        character(1)
      )
    }
  }

  class(result) <- c("parameter_collection", "list")

  result
}

# Copy `Name` to `Path` on a raw parameter dict when `Path` is missing. Used by
# blocks (Protocol, Event, Formulation) whose snapshot parameters carry a
# `Name` field instead of a `Path` field but whose `Parameter` accessors expect
# `Path` to be populated.
ensure_path_from_name <- function(param_data) {
  if (!is.null(param_data$Name) && is.null(param_data$Path)) {
    param_data$Path <- param_data$Name
  }
  param_data
}
