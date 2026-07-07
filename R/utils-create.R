# Internal helpers shared by the `create_*` factory functions.

# Internal: return an empty *named* list. jsonlite serialises an unnamed
# empty list (`list()`) as the JSON array `[]`, and a named-empty list as
# the JSON object `{}`. Some PK-Sim snapshot fields (notably `Solver`)
# must be objects, never arrays, or the snapshot mapper rejects the
# enclosing simulation silently.
empty_named_list <- function() {
  stats::setNames(list(), character(0))
}

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

# Internal: validate that `items` is a bare list whose every entry is
# either an R6 instance of `r6_class` or a raw list, then return a list
# of raw shapes (`x$data` for R6 entries, `x` as-is for lists). Outer
# names are dropped so the JSON shape stays an array when a caller
# supplies a named list. `is.object()` guards reject R6 objects and
# other classed lists (e.g. data frames) at both levels: a bare R6
# passed as the outer collection, and a wrong-class R6 (or a data
# frame) passed as an entry.
to_raw_r6_or_list <- function(
  items,
  r6_class,
  arg_name,
  call = parent.frame()
) {
  if (!is.list(items) || is.object(items)) {
    cli::cli_abort(
      "{.arg {arg_name}} must be a list",
      call = call
    )
  }
  valid <- vapply(
    items,
    function(item) {
      inherits(item, r6_class) || (is.list(item) && !is.object(item))
    },
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

# Internal: validate that `items` is a bare list whose every entry is a
# bare (unclassed) list, then return it unnamed. Used for observer leaf
# collections (container criteria, formula references) which are raw
# lists, not R6 objects, so `to_raw_r6_or_list()` does not fit.
to_raw_list_entries <- function(items, arg_name, call = parent.frame()) {
  if (!is.list(items) || is.object(items)) {
    cli::cli_abort("{.arg {arg_name}} must be a list", call = call)
  }
  valid <- vapply(items, function(x) is.list(x) && !is.object(x), logical(1))
  if (!all(valid)) {
    cli::cli_abort(
      "Every entry of {.arg {arg_name}} must be a raw list",
      call = call
    )
  }
  unname(items)
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

# Internal: map the `expression` argument of `create_expression_profile()`
# (and the `ExpressionProfile$expression` setter) to a raw
# `ExpressionContainer[]` list, or `NULL` when the input is empty. The
# result is an *unnamed* list so jsonlite serialises it as a JSON array
# (see the `empty_named_list` note above on array vs object shape).
#
# Accepts:
#   - a data frame / tibble, one row per ExpressionContainer, with a
#     required `name` column and optional `value`, `compartment`, and
#     `transport_direction` columns. Only non-missing cells become keys
#     (`Name`, `Value`, `CompartmentName`, `TransportDirection`), so a row
#     that omits `value` produces a container without a `Value` key. Row
#     order is preserved and duplicate names are kept as separate entries.
#   - a bare list of raw container lists (escape hatch), returned unnamed
#     and verbatim.
# The data-frame branch is tested before the bare-list branch because a
# data frame is also `is.list()` and `is.object()` TRUE.
build_expression_containers <- function(expression, call = parent.frame()) {
  if (is.null(expression)) {
    return(NULL)
  }
  if (is.data.frame(expression)) {
    if (nrow(expression) == 0) {
      return(NULL)
    }
    if (!("name" %in% names(expression))) {
      cli::cli_abort(
        "{.arg expression} data frame must have a {.field name} column",
        call = call
      )
    }
    names_col <- expression[["name"]]
    if (any(is.na(names_col) | !nzchar(as.character(names_col)))) {
      cli::cli_abort(
        "Every {.field name} in {.arg expression} must be a non-empty string",
        call = call
      )
    }
    containers <- lapply(seq_len(nrow(expression)), function(i) {
      container <- list(Name = as.character(names_col[[i]]))
      if (
        "value" %in% names(expression) && !is.na(expression[["value"]][[i]])
      ) {
        container$Value <- as.numeric(expression[["value"]][[i]])
      }
      if (
        "compartment" %in%
          names(expression) &&
          !is.na(expression[["compartment"]][[i]])
      ) {
        container$CompartmentName <- as.character(
          expression[["compartment"]][[i]]
        )
      }
      if (
        "transport_direction" %in%
          names(expression) &&
          !is.na(expression[["transport_direction"]][[i]])
      ) {
        container$TransportDirection <- as.character(
          expression[["transport_direction"]][[i]]
        )
      }
      container
    })
    return(unname(containers))
  }
  if (is.list(expression) && !is.object(expression)) {
    if (length(expression) == 0) {
      return(NULL)
    }
    return(unname(expression))
  }
  cli::cli_abort(
    "{.arg expression} must be a data frame or a list",
    call = call
  )
}

# Internal: map the `disease` argument of `create_expression_profile()`
# (and the `ExpressionProfile$disease` setter) to a raw `DiseaseState`
# named list (a JSON object), or `NULL` when unset. `parameters` is keyed
# on `Name` via `to_raw_parameters()`, matching the `DiseaseState`
# schema; the `Parameters` key is omitted when no parameters are given.
build_disease_state <- function(disease, call = parent.frame()) {
  if (is.null(disease)) {
    return(NULL)
  }
  name <- disease$name
  if (
    !is.list(disease) ||
      is.null(name) ||
      !is.character(name) ||
      length(name) != 1 ||
      is.na(name) ||
      !nzchar(name)
  ) {
    cli::cli_abort(
      "{.arg disease} must be a named list with a non-empty {.field name}",
      call = call
    )
  }
  result <- list(Name = name)
  if (!is.null(disease$parameters)) {
    result$Parameters <- to_raw_parameters(disease$parameters, "Name")
  }
  result
}
