#' Value-object helpers for the `create_*` factories
#'
#' @description
#' Small constructors that bundle a value, its unit (where applicable), an
#' alternative label (where applicable), and any field-specific extras into a
#' single object. Pass the result straight into the matching
#' [create_compound()], [create_individual()], or [create_observed_data()]
#' argument, for example `lipophilicity = lipophilicity(2.5)`.
#'
#' Each helper owns the correct default unit for its field and validates a
#' supplied unit against that field's `ospsuite` dimension with
#' [validate_unit()]. The object it returns is meant to be consumed
#' immediately by a factory (or assigned to the matching writable field of a
#' [Compound] or [Individual]); it carries the raw values the factory needs
#' and is not intended to be inspected or mutated directly.
#'
#' @name value_specs
#' @seealso [create_compound()], [create_individual()],
#'   [create_observed_data()]
#' @keywords internal
NULL

# Compound physicochemical-property helpers ------------------------------

#' Lipophilicity value object
#'
#' @description
#' Build a lipophilicity value object for [create_compound()]'s
#' `lipophilicity` argument (or the writable `Compound$lipophilicity`
#' field). Produces one default `Lipophilicity` alternative with parameter
#' `"Lipophilicity"`.
#'
#' @param value Numeric scalar. Lipophilicity value.
#' @param unit Character. Unit for the lipophilicity parameter, validated
#'   against dimension `"Log Units"`. Defaults to `"Log Units"`.
#' @param name Character. `Name` of the created alternative. Defaults to
#'   `"User defined"`.
#' @param default Logical. Whether this alternative is the group's default
#'   when it appears in a list of alternatives passed to the matching
#'   [create_compound()] argument or `Compound` field. Defaults to `FALSE`.
#'   Ignored for a single (non-list) value object, which is always the
#'   default. When a list has no element marked `default = TRUE`, the first
#'   element is the default (unchanged behaviour); marking two or more
#'   elements `default = TRUE` in the same list is an error.
#'
#' @return A `lipophilicity_spec` object to pass to [create_compound()].
#' @family value-object helpers
#' @seealso [create_compound()]
#' @export
#'
#' @examples
#' lipophilicity(2.5)
#' create_compound(name = "Drug X", lipophilicity = lipophilicity(2.5))
#'
#' # Several alternatives, the second marked as the default
#' create_compound(
#'   name = "Drug X",
#'   lipophilicity = list(
#'     lipophilicity(2.5, name = "Measured"),
#'     lipophilicity(3.1, name = "Predicted", default = TRUE)
#'   )
#' )
lipophilicity <- function(
  value,
  unit = "Log Units",
  name = "User defined",
  default = FALSE
) {
  check_numeric_scalar(value, "value")
  validate_unit(unit, "Log Units")
  check_required_string(name, "name")
  check_default_flag(default, "default")
  new_value_spec(
    "lipophilicity_spec",
    list(
      value = value,
      unit = unit,
      name = name,
      default = default
    )
  )
}

#' Fraction unbound value object
#'
#' @description
#' Build a fraction-unbound value object for [create_compound()]'s
#' `fraction_unbound` argument (or the writable `Compound$fraction_unbound`
#' field). Produces one default `FractionUnbound` alternative with parameter
#' `"Fraction unbound (plasma, reference value)"`. Fraction unbound stores a
#' bare value with no unit, so this helper takes no `unit` argument.
#'
#' @param value Numeric scalar. Fraction-unbound value.
#' @param name Character. `Name` of the created alternative. Defaults to
#'   `"User defined"`.
#' @param default Logical. Whether this alternative is the group's default
#'   when it appears in a list of alternatives passed to the matching
#'   [create_compound()] argument or `Compound` field. Defaults to `FALSE`.
#'   Ignored for a single (non-list) value object, which is always the
#'   default. When a list has no element marked `default = TRUE`, the first
#'   element is the default (unchanged behaviour); marking two or more
#'   elements `default = TRUE` in the same list is an error.
#'
#' @return A `fraction_unbound_spec` object to pass to [create_compound()].
#' @family value-object helpers
#' @seealso [create_compound()]
#' @export
#'
#' @examples
#' fraction_unbound(0.1)
#' create_compound(name = "Drug X", fraction_unbound = fraction_unbound(0.1))
#'
#' # Several alternatives, the second marked as the default
#' create_compound(
#'   name = "Drug X",
#'   fraction_unbound = list(
#'     fraction_unbound(0.1, name = "Plasma"),
#'     fraction_unbound(0.2, name = "Microsomal", default = TRUE)
#'   )
#' )
fraction_unbound <- function(value, name = "User defined", default = FALSE) {
  check_numeric_scalar(value, "value")
  check_required_string(name, "name")
  check_default_flag(default, "default")
  new_value_spec(
    "fraction_unbound_spec",
    list(
      value = value,
      name = name,
      default = default
    )
  )
}

#' Solubility value object
#'
#' @description
#' Build a solubility value object for [create_compound()]'s `solubility`
#' argument (or the writable `Compound$solubility` field). Expresses either
#' the scalar form (a single solubility value at a reference pH, optionally
#' with a solubility gain per charge) or the mutually exclusive table form (a
#' pH/value table).
#'
#' The scalar-form arguments (`value`, `reference_pH`, `gain_per_charge`) and
#' `table` are mutually exclusive: supplying `table` together with any of them
#' is an error. Unlike the previous `create_compound()` behaviour, where
#' `reference_pH` / `gain_per_charge` were silently ignored on the table path,
#' this helper rejects the combination so the intent is unambiguous.
#'
#' @param value Numeric scalar. Solubility-at-reference-pH value for the
#'   scalar form. Leave `NULL` for the table form.
#' @param unit Character. Unit for the solubility value (scalar form) and for
#'   the table Y values, validated against dimension
#'   `"Concentration (mass)"`. Defaults to `"mg/l"`.
#' @param reference_pH Numeric scalar. Reference pH added to the scalar
#'   `Solubility` alternative. Scalar form only.
#' @param gain_per_charge Numeric scalar. Optional
#'   `Solubility gain per charge` parameter added to the scalar `Solubility`
#'   alternative. Scalar form only.
#' @param table Two-column data frame giving table-based solubility: the first
#'   column is pH and the second is the solubility value. When supplied, the
#'   table form is built and the scalar-form arguments must be left unset.
#' @param name Character. `Name` of the created alternative (scalar or table).
#'   Defaults to `"User defined"`.
#' @param default Logical. Whether this alternative is the group's default
#'   when it appears in a list of alternatives passed to the matching
#'   [create_compound()] argument or `Compound` field. Defaults to `FALSE`.
#'   Ignored for a single (non-list) value object, which is always the
#'   default. When a list has no element marked `default = TRUE`, the first
#'   element is the default (unchanged behaviour); marking two or more
#'   elements `default = TRUE` in the same list is an error.
#'
#' @return A `solubility_spec` object to pass to [create_compound()].
#' @family value-object helpers
#' @seealso [create_compound()]
#' @export
#'
#' @examples
#' # Scalar form with reference pH and gain per charge
#' solubility(9999, reference_pH = 7, gain_per_charge = 1000)
#'
#' # Table form (first column pH, second column value)
#' solubility(table = data.frame(pH = c(3, 6, 6.8), value = c(5000, 3000, 90)))
#'
#' # Several alternatives, the second marked as the default
#' create_compound(
#'   name = "Drug X",
#'   solubility = list(
#'     solubility(9999, name = "Aqueous"),
#'     solubility(200, name = "FaSSIF", default = TRUE)
#'   )
#' )
solubility <- function(
  value = NULL,
  unit = "mg/l",
  reference_pH = NULL,
  gain_per_charge = NULL,
  table = NULL,
  name = "User defined",
  default = FALSE
) {
  check_required_string(name, "name")
  check_default_flag(default, "default")

  is_table <- !is.null(table)
  scalar_supplied <- !is.null(value) ||
    !is.null(reference_pH) ||
    !is.null(gain_per_charge)

  if (is_table && scalar_supplied) {
    cli::cli_abort(c(
      "Solubility is set either by a single value or by a table, not both.",
      "i" = "Supply the scalar form ({.arg value}, {.arg reference_pH}, \\
      {.arg gain_per_charge}) or {.arg table}, not both."
    ))
  }

  if (is_table) {
    validate_solubility_table(table)
    validate_unit(unit, "Concentration (mass)")
    return(new_value_spec(
      "solubility_spec",
      list(
        value = NULL,
        unit = unit,
        reference_pH = NULL,
        gain_per_charge = NULL,
        table = table,
        name = name,
        form = "table",
        default = default
      )
    ))
  }

  if (is.null(value)) {
    cli::cli_abort(c(
      "{.arg value} or {.arg table} must be supplied to {.fn solubility}.",
      "i" = "Use {.arg value} for a single solubility, or {.arg table} for a \\
      pH/value table."
    ))
  }
  check_numeric_scalar(value, "value")
  if (!is.null(reference_pH)) {
    check_numeric_scalar(reference_pH, "reference_pH")
  }
  if (!is.null(gain_per_charge)) {
    check_numeric_scalar(gain_per_charge, "gain_per_charge")
  }
  validate_unit(unit, "Concentration (mass)")
  new_value_spec(
    "solubility_spec",
    list(
      value = value,
      unit = unit,
      reference_pH = reference_pH,
      gain_per_charge = gain_per_charge,
      table = NULL,
      name = name,
      form = "scalar",
      default = default
    )
  )
}

#' Intestinal permeability value object
#'
#' @description
#' Build an intestinal-permeability value object for [create_compound()]'s
#' `intestinal_permeability` argument (or the writable
#' `Compound$intestinal_permeability` field). Produces one default
#' `IntestinalPermeability` alternative with parameter
#' `"Specific intestinal permeability (transcellular)"`.
#'
#' @param value Numeric scalar. Intestinal-permeability value.
#' @param unit Character. Unit for the parameter, validated against dimension
#'   `"Velocity"`. Defaults to `"cm/min"`.
#' @param name Character. `Name` of the created alternative. Defaults to
#'   `"User defined"`.
#' @param default Logical. Whether this alternative is the group's default
#'   when it appears in a list of alternatives passed to the matching
#'   [create_compound()] argument or `Compound` field. Defaults to `FALSE`.
#'   Ignored for a single (non-list) value object, which is always the
#'   default. When a list has no element marked `default = TRUE`, the first
#'   element is the default (unchanged behaviour); marking two or more
#'   elements `default = TRUE` in the same list is an error.
#'
#' @return An `intestinal_permeability_spec` object to pass to
#'   [create_compound()].
#' @family value-object helpers
#' @seealso [create_compound()]
#' @export
#'
#' @examples
#' intestinal_permeability(1.14e-05)
#' create_compound(
#'   name = "Drug X",
#'   intestinal_permeability = intestinal_permeability(1.14e-05)
#' )
#'
#' # Several alternatives, the second marked as the default
#' create_compound(
#'   name = "Drug X",
#'   intestinal_permeability = list(
#'     intestinal_permeability(1.14e-05, name = "Caco-2"),
#'     intestinal_permeability(2e-05, name = "PAMPA", default = TRUE)
#'   )
#' )
intestinal_permeability <- function(
  value,
  unit = "cm/min",
  name = "User defined",
  default = FALSE
) {
  check_numeric_scalar(value, "value")
  validate_unit(unit, "Velocity")
  check_required_string(name, "name")
  check_default_flag(default, "default")
  new_value_spec(
    "intestinal_permeability_spec",
    list(
      value = value,
      unit = unit,
      name = name,
      default = default
    )
  )
}

#' Permeability value object
#'
#' @description
#' Build a permeability value object for [create_compound()]'s `permeability`
#' argument (or the writable `Compound$permeability` field). Produces one
#' default `Permeability` alternative with parameter `"Permeability"`.
#'
#' @param value Numeric scalar. Permeability value.
#' @param unit Character. Unit for the parameter, validated against dimension
#'   `"Velocity"`. Defaults to `"cm/min"`.
#' @param name Character. `Name` of the created alternative. Defaults to
#'   `"User defined"`.
#' @param default Logical. Whether this alternative is the group's default
#'   when it appears in a list of alternatives passed to the matching
#'   [create_compound()] argument or `Compound` field. Defaults to `FALSE`.
#'   Ignored for a single (non-list) value object, which is always the
#'   default. When a list has no element marked `default = TRUE`, the first
#'   element is the default (unchanged behaviour); marking two or more
#'   elements `default = TRUE` in the same list is an error.
#'
#' @return A `permeability_spec` object to pass to [create_compound()].
#' @family value-object helpers
#' @seealso [create_compound()]
#' @export
#'
#' @examples
#' permeability(0.0069)
#' create_compound(name = "Drug X", permeability = permeability(0.0069))
#'
#' # Several alternatives, the second marked as the default
#' create_compound(
#'   name = "Drug X",
#'   permeability = list(
#'     permeability(0.0069, name = "Measured"),
#'     permeability(0.008, name = "Predicted", default = TRUE)
#'   )
#' )
permeability <- function(
  value,
  unit = "cm/min",
  name = "User defined",
  default = FALSE
) {
  check_numeric_scalar(value, "value")
  validate_unit(unit, "Velocity")
  check_required_string(name, "name")
  check_default_flag(default, "default")
  new_value_spec(
    "permeability_spec",
    list(
      value = value,
      unit = unit,
      name = name,
      default = default
    )
  )
}

# Individual demographic helpers -----------------------------------------

#' Age value object
#'
#' @description
#' Build an age value object for [create_individual()]'s `age` argument (or
#' the writable `Individual$age` / `OriginData$age` field). Fills the
#' `OriginData` `Age` characteristic (`list(Value =, Unit =)`).
#'
#' @param value Numeric scalar. Age value.
#' @param unit Character. Unit for age, validated against dimension
#'   `"Age in years"`. Defaults to `"year(s)"`.
#'
#' @return An `age_spec` object to pass to [create_individual()].
#' @family value-object helpers
#' @seealso [create_individual()]
#' @export
#'
#' @examples
#' age(30)
#' create_individual(name = "Subject", age = age(30))
age <- function(value, unit = "year(s)") {
  check_numeric_scalar(value, "value")
  validate_unit(unit, "Age in years")
  new_value_spec("age_spec", list(value = value, unit = unit))
}

#' Weight value object
#'
#' @description
#' Build a weight value object for [create_individual()]'s `weight` argument
#' (or the writable `Individual$weight` / `OriginData$weight` field). Fills
#' the `OriginData` `Weight` characteristic (`list(Value =, Unit =)`).
#'
#' @param value Numeric scalar. Weight value.
#' @param unit Character. Unit for weight, validated against dimension
#'   `"Mass"`. Defaults to `"kg"`.
#'
#' @return A `weight_spec` object to pass to [create_individual()].
#' @family value-object helpers
#' @seealso [create_individual()]
#' @export
#'
#' @examples
#' weight(70)
#' create_individual(name = "Subject", weight = weight(70))
weight <- function(value, unit = "kg") {
  check_numeric_scalar(value, "value")
  validate_unit(unit, "Mass")
  new_value_spec("weight_spec", list(value = value, unit = unit))
}

#' Height value object
#'
#' @description
#' Build a height value object for [create_individual()]'s `height` argument
#' (or the writable `Individual$height` / `OriginData$height` field). Fills
#' the `OriginData` `Height` characteristic (`list(Value =, Unit =)`).
#'
#' @param value Numeric scalar. Height value.
#' @param unit Character. Unit for height, validated against dimension
#'   `"Length"`. Defaults to `"cm"`.
#'
#' @return A `height_spec` object to pass to [create_individual()].
#' @family value-object helpers
#' @seealso [create_individual()]
#' @export
#'
#' @examples
#' height(175)
#' create_individual(name = "Subject", height = height(175))
height <- function(value, unit = "cm") {
  check_numeric_scalar(value, "value")
  validate_unit(unit, "Length")
  new_value_spec("height_spec", list(value = value, unit = unit))
}

#' Gestational age value object
#'
#' @description
#' Build a gestational-age value object for [create_individual()]'s
#' `gestational_age` argument (or the writable `Individual$gestational_age` /
#' `OriginData$gestational_age` field). Fills the `OriginData`
#' `GestationalAge` characteristic (`list(Value =, Unit =)`).
#'
#' @param value Numeric scalar. Gestational-age value.
#' @param unit Character. Unit for gestational age, validated against
#'   dimension `"Time"`. Defaults to `"week(s)"`.
#'
#' @return A `gestational_age_spec` object to pass to [create_individual()].
#' @family value-object helpers
#' @seealso [create_individual()]
#' @export
#'
#' @examples
#' gestational_age(38)
#' create_individual(name = "Preterm", gestational_age = gestational_age(30))
gestational_age <- function(value, unit = "week(s)") {
  check_numeric_scalar(value, "value")
  validate_unit(unit, "Time")
  new_value_spec("gestational_age_spec", list(value = value, unit = unit))
}

# Observed-data series helpers -------------------------------------------

#' Time series value object
#'
#' @description
#' Build a time-series value object for [create_observed_data()]'s `time`
#' argument. Carries the time grid x-values and their unit.
#'
#' @param value Numeric vector. Time grid x-values.
#' @param unit Character. Unit for `value`, validated against dimension
#'   `"Time"`. Defaults to `"h"`.
#'
#' @return A `time_spec` object to pass to [create_observed_data()].
#' @family value-object helpers
#' @seealso [create_observed_data()]
#' @export
#'
#' @examples
#' time(c(0, 1, 2, 4, 8))
time <- function(value, unit = "h") {
  check_numeric_vector(value, "value")
  validate_unit(unit, "Time")
  new_value_spec("time_spec", list(value = value, unit = unit))
}

#' Measurement values series value object
#'
#' @description
#' Build a measurement-values value object for [create_observed_data()]'s
#' `values` argument. Carries the measurement y-values, their dimension, and
#' an optional unit.
#'
#' The `dimension` is required and has no default; it gates unit validation
#' and is written to the data-set column. When `unit` is supplied it is
#' validated against `dimension` via [validate_unit()].
#'
#' @param value Numeric vector. Measurement y-values.
#' @param unit Character. Optional unit for `value`. When supplied, validated
#'   against `dimension`.
#' @param dimension Character. Dimension for `value` (for example
#'   `"Concentration (mass)"`). Required: pass one of the names of
#'   `ospsuite::ospDimensions`.
#'
#' @return A `values_spec` object to pass to [create_observed_data()].
#' @family value-object helpers
#' @seealso [create_observed_data()]
#' @export
#'
#' @examples
#' values(c(0, 12, 18, 11, 5), unit = "mg/l", dimension = "Concentration (mass)")
values <- function(value, unit = NULL, dimension) {
  check_numeric_vector(value, "value")
  if (missing(dimension) || is.null(dimension)) {
    # Sort with radix to get deterministic, locale-independent order; the
    # native iteration order of `ospsuite::ospDimensions` differs across
    # platforms.
    valid_dims <- sort(names(ospsuite::ospDimensions), method = "radix")
    cli::cli_abort(c(
      "{.arg dimension} is required.",
      "i" = "Pass one of: {toString(valid_dims)}."
    ))
  }
  if (!is.null(unit)) {
    validate_unit(unit, dimension)
  }
  new_value_spec(
    "values_spec",
    list(
      value = value,
      unit = unit,
      dimension = dimension
    )
  )
}

#' Error series value object
#'
#' @description
#' Build an error-series value object for [create_observed_data()]'s `error`
#' argument. Carries the error y-values, an optional unit, and an auxiliary
#' type.
#'
#' The unit is not validated here: the error dimension is the values-series
#' dimension, which this helper does not see. [create_observed_data()]
#' validates the error unit against the values dimension when a unit is
#' present, and defaults the error unit to the values unit when `unit` is
#' `NULL`.
#'
#' @param value Numeric vector. Error y-values, same length as the values
#'   series.
#' @param unit Character. Optional unit for the error. Defaults (in the
#'   factory) to the values-series unit when `NULL`.
#' @param type Character. Auxiliary type for the error, one of the schema
#'   `AuxiliaryType` values: `"ArithmeticStdDev"` (the default),
#'   `"GeometricStdDev"`, `"ArithmeticMeanPop"`, or `"GeometricMeanPop"`.
#'
#' @return An `error_spec` object to pass to [create_observed_data()].
#' @family value-object helpers
#' @seealso [create_observed_data()]
#' @export
#'
#' @examples
#' error(c(0, 1.2, 1.5, 1.1, 0.6))
error <- function(value, unit = NULL, type = "ArithmeticStdDev") {
  check_numeric_vector(value, "value")
  if (!type %in% AUXILIARY_TYPES) {
    cli::cli_abort(c(
      "{.arg type} must be one of the schema {.field AuxiliaryType} values.",
      "x" = "Got {.val {type}}.",
      "i" = "Valid values: {.val {AUXILIARY_TYPES}}."
    ))
  }
  new_value_spec(
    "error_spec",
    list(
      value = value,
      unit = unit,
      type = type
    )
  )
}

# Internal ----

# Internal: the schema `AuxiliaryType` enum. The single source of truth for
# the error auxiliary types `error()` accepts; `Undefined` is the
# not-an-auxiliary sentinel and is enum-valid but not advertised as a user's
# error type.
AUXILIARY_TYPES <- c(
  "Undefined",
  "ArithmeticStdDev",
  "GeometricStdDev",
  "ArithmeticMeanPop",
  "GeometricMeanPop"
)

# Internal: construct a classed value-spec object. Every helper returns a
# plain tagged list carrying a subclass plus the shared `osp_value_spec`
# parent, so a factory can test "is this a helper?" generically and assert
# the *right* helper was passed to a given argument.
new_value_spec <- function(subclass, slots) {
  structure(slots, class = c(subclass, "osp_value_spec"))
}

# Internal: abort unless `value` is a non-missing numeric scalar. Wording
# mirrors the previous factory guards so error snapshots read the same.
check_numeric_scalar <- function(value, arg, call = parent.frame()) {
  if (!is.numeric(value) || length(value) != 1 || is.na(value)) {
    cli::cli_abort("{.arg {arg}} must be a numeric value", call = call)
  }
  invisible(value)
}

# Internal: abort unless `value` is a non-missing single logical. Used to
# validate the `default` flag on the compound physicochemical-property
# helpers.
check_default_flag <- function(value, arg, call = parent.frame()) {
  if (!is.logical(value) || length(value) != 1 || is.na(value)) {
    cli::cli_abort("{.arg {arg}} must be a single logical value", call = call)
  }
  invisible(value)
}

# Internal: abort unless `value` is a non-empty numeric vector free of missing
# values. Used by the observed-data series helpers.
check_numeric_vector <- function(value, arg, call = parent.frame()) {
  if (!is.numeric(value) || length(value) == 0 || anyNA(value)) {
    cli::cli_abort(
      "{.arg {arg}} must be a non-empty numeric vector",
      call = call
    )
  }
  invisible(value)
}

# Internal: the field-mismatch / plain-scalar guard. Returns invisibly when
# `value` is the expected `*_spec` object (or `NULL` when `required` is
# `FALSE`); otherwise aborts. When `required = TRUE`, a `NULL` value also
# aborts with the same helper-pointing message, so a factory need not add a
# separate null-check. Two message branches for a non-`NULL` mismatch:
# another value-spec (wrong helper for the argument), or anything else (a bare
# numeric, list, ...), which points the user at the helper. `helper` is the
# constructor name to suggest; `example` is a short usage hint.
#
# `value` may also be a bare list (not itself a value-spec object) whose
# every element must independently match `subclass`; each offending element
# is diagnosed by position with the same two message branches, so a list of
# alternatives gets the same guidance a single value object would. An
# empty list is valid and returned as-is: it means "no alternatives", which
# the caller (e.g. `create_compound()`) treats the same as `NULL`.
require_value_spec <- function(
  value,
  subclass,
  arg,
  helper = sub("_spec$", "", subclass),
  example = NULL,
  required = FALSE,
  call = parent.frame()
) {
  if (inherits(value, subclass)) {
    return(invisible(value))
  }
  if (is.null(value) && !required) {
    return(invisible(value))
  }
  if (is.list(value) && !is.object(value)) {
    return(require_value_spec_list(
      value,
      subclass,
      arg,
      helper = helper,
      example = example,
      call = call
    ))
  }
  hint <- example %||% sprintf("%s = %s(...)", arg, helper)
  if (inherits(value, "osp_value_spec")) {
    cli::cli_abort(
      c(
        "{.arg {arg}} was built with the wrong helper.",
        "i" = "Use {.fn {helper}} for {.arg {arg}}, e.g. {.code {hint}}."
      ),
      call = call
    )
  }
  cli::cli_abort(
    c(
      "{.arg {arg}} must be built with {.fn {helper}}.",
      "i" = "For example {.code {hint}}."
    ),
    call = call
  )
}

# Internal: is `value` a non-empty bare list of `osp_value_spec` objects
# (of any subclass)? Used by the `Compound` writable field setters to
# detect the list-of-specs shape ahead of the generic raw-list branch,
# which must keep storing an arbitrary raw list (e.g. a loaded alternative
# array) verbatim.
is_value_spec_list <- function(value) {
  is.list(value) &&
    !is.object(value) &&
    length(value) > 0 &&
    all(vapply(value, inherits, logical(1), "osp_value_spec"))
}

# Internal: validate every element of a bare list against `subclass`,
# identifying the offending element by position. Shared by
# `require_value_spec()` (the factory arguments) and the `Compound` writable
# field setters, so a list of alternatives is validated identically on both
# paths. An empty list passes through untouched.
require_value_spec_list <- function(
  value,
  subclass,
  arg,
  helper = sub("_spec$", "", subclass),
  example = NULL,
  call = parent.frame()
) {
  if (length(value) == 0) {
    return(invisible(value))
  }
  hint <- example %||% sprintf("%s = %s(...)", arg, helper)
  for (i in seq_along(value)) {
    element <- value[[i]]
    if (inherits(element, subclass)) {
      next
    }
    if (inherits(element, "osp_value_spec")) {
      cli::cli_abort(
        c(
          "Element {i} of {.arg {arg}} was built with the wrong helper.",
          "i" = "Use {.fn {helper}} for {.arg {arg}}, e.g. {.code {hint}}."
        ),
        call = call
      )
    }
    cli::cli_abort(
      c(
        "Element {i} of {.arg {arg}} must be built with {.fn {helper}}.",
        "i" = "For example {.code {hint}}."
      ),
      call = call
    )
  }
  invisible(value)
}

# Internal: validate the two-column solubility `table`, reusing the exact
# diagnostics the `create_compound()` factory used before the helper existed.
validate_solubility_table <- function(table, call = parent.frame()) {
  if (!is.data.frame(table) || ncol(table) != 2) {
    cli::cli_abort(
      "{.arg table} must be a data frame with two columns (pH, value)",
      call = call
    )
  }
  if (
    nrow(table) == 0 ||
      !is.numeric(table[[1]]) ||
      !is.numeric(table[[2]])
  ) {
    cli::cli_abort(
      "{.arg table} must have at least one row with numeric pH and value columns",
      call = call
    )
  }
  invisible(table)
}
