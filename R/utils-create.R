# Internal helpers shared by the `create_*` factory functions.

# Internal: return an empty *named* list. jsonlite serialises an unnamed
# empty list (`list()`) as the JSON array `[]`, and a named-empty list as
# the JSON object `{}`. Some PK-Sim snapshot fields (notably `Solver`)
# must be objects, never arrays, or the snapshot mapper rejects the
# enclosing simulation silently.
empty_named_list <- function() {
  stats::setNames(list(), character(0))
}

# Internal: the non-empty-scalar-character shape check, factored out so the
# several setters and factories that require it share one definition. Returns
# `TRUE` only when `value` is a length-one character vector that is neither
# `NA` nor the empty string. It carries no abort message on purpose: each
# call site keeps its own distinct, snapshot-asserted wording.
is_non_empty_scalar_string <- function(value) {
  is.character(value) &&
    length(value) == 1 &&
    !is.na(value) &&
    nzchar(value)
}

# Internal: assert that `value` is a non-empty scalar character.
# Used by the create_* factories to validate required string arguments.
check_required_string <- function(value, arg_name, call = parent.frame()) {
  if (missing(value) || is.null(value) || !is_non_empty_scalar_string(value)) {
    cli::cli_abort(
      "{.arg {arg_name}} must be a non-empty string",
      call = call
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

# Internal: the accepted dose-family units, the single source of truth shared
# by `resolve_input_dose_parameter()`'s membership test and its error message.
# PK-Sim's "Input dose" dose family is NOT a resolvable ospsuite dimension
# (neither `ospsuite::getUnitsForDimension("Input dose")` nor
# `ospsuite::ospUnits[["Input dose"]]` returns it), so the accepted set is the
# union of the four real ospsuite dimensions the family maps onto: plain doses
# (`Mass`, `Amount`), doses per body weight (`Dose per body weight`), and doses
# per body surface area (`Dose per body surface area`). Each dimension is
# resolved with the same tolerant lookup `validate_unit()` uses so behaviour
# stays consistent with the rest of the package.
dose_family_units <- function() {
  dimensions <- c(
    "Mass",
    "Amount",
    "Dose per body weight",
    "Dose per body surface area"
  )
  units <- unlist(lapply(dimensions, function(dim) {
    tryCatch(
      ospsuite::getUnitsForDimension(dim),
      error = function(e) unlist(ospsuite::ospUnits[[dim]], use.names = FALSE)
    )
  }))
  unique(units)
}

# Internal: resolve the canonical name of a single parameter entry, handling
# both accepted shapes (a `Parameter` R6 object or a raw list) exactly as
# `to_raw_parameters()` reconciles Name/Path. Falls back to `Path` when only
# `Path` is present, and to `NA_character_` when neither resolves, so a caller
# scanning entry names with `vapply(..., character(1))` stays character-typed
# and a malformed entry simply never matches a target name.
resolve_parameter_name <- function(entry) {
  raw <- if (inherits(entry, "Parameter")) entry$data else entry
  raw$Name %||% raw$Path %||% NA_character_
}

# Internal: resolve a promoted dose value and unit into the single raw
# `InputDose` parameter shape. Validates `unit` against the accepted
# dose-family units (see `dose_family_units()`), aborting with `call` so the
# error is attributed to the calling factory rather than this helper. Does NOT
# validate the numeric `dose` value; the calling factory owns the finite-scalar
# check. Always returns a parameter named `InputDose` (never `Dose`,
# `DosePerBodyWeight`, or `DosePerBodySurfaceArea`); the unit alone carries the
# dose family. Designed for reuse: it holds no schema-item-specific state, so
# `create_protocol()` can adopt it for the Simple-protocol dose.
resolve_input_dose_parameter <- function(dose, unit, call = parent.frame()) {
  valid_units <- dose_family_units()
  if (!(unit %in% valid_units)) {
    cli::cli_abort(
      c(
        "Invalid dose unit: {unit}",
        "i" = "Valid dose units are: {toString(valid_units)}"
      ),
      call = call
    )
  }
  list(Name = "InputDose", Value = dose, Unit = unit)
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
  name <- if (is.list(disease)) disease$name else NULL
  if (
    !is.list(disease) ||
      is.object(disease) ||
      is.null(name) ||
      !is_non_empty_scalar_string(name)
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
