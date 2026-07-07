#' Create a new compound
#'
#' @description
#' Create a [Compound] building block from named arguments. This is a thin
#' factory around `Compound$new()` that builds the raw list shape for you,
#' including the physicochemical properties, pKa, and processes.
#'
#' Each of lipophilicity, fraction unbound, solubility (including reference
#' pH, gain per charge, and table solubility), intestinal permeability,
#' permeability, and pKa must be set through its dedicated argument (or by
#' mutating the matching writable [Compound] field). The `parameters`
#' argument is for additional/loose compound parameters only; it cannot set
#' these physicochemical properties, because each lives in its own
#' top-level alternative array or typed list rather than in `Parameters`.
#'
#' @param name Character. Name of the compound (required).
#' @param description Character. Free-text description of the compound.
#' @param is_small_molecule Logical. Whether the compound is a small
#'   molecule. Defaults to `TRUE` in PK-Sim when omitted.
#' @param plasma_protein_binding_partner Character. Name of the plasma
#'   protein binding partner (for example `"Albumin"`).
#' @param molecular_weight Numeric. Molecular weight value.
#' @param molecular_weight_unit Character. Unit for molecular weight.
#'   Defaults to `"g/mol"`.
#' @param calculation_methods Character vector. Calculation method names
#'   that PK-Sim uses to derive compound quantities.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists to attach as additional
#'   compound parameters. This does not set physicochemical properties;
#'   use the dedicated arguments below for those.
#' @param lipophilicity Numeric scalar. Lipophilicity value. When supplied,
#'   one default `Lipophilicity` alternative is created.
#' @param lipophilicity_unit Character. Unit for the lipophilicity
#'   parameter, validated against dimension `"Log Units"`. Defaults to
#'   `"Log Units"`.
#' @param lipophilicity_name Character. `Name` of the created lipophilicity
#'   alternative. Defaults to `"User defined"`.
#' @param fraction_unbound Numeric scalar. Fraction unbound value. When
#'   supplied, one default `FractionUnbound` alternative is created. The
#'   fraction-unbound parameter carries no unit.
#' @param fraction_unbound_name Character. `Name` of the created
#'   fraction-unbound alternative. Defaults to `"User defined"`.
#' @param solubility Numeric scalar. Solubility-at-reference-pH value. When
#'   supplied, one scalar-based `Solubility` alternative is created.
#'   Mutually exclusive with `solubility_table`.
#' @param solubility_unit Character. Unit for the solubility parameter,
#'   validated against dimension `"Concentration (mass)"`. Reused as the
#'   table Y unit. Defaults to `"mg/l"`.
#' @param reference_pH Numeric scalar. Reference pH added to the same
#'   scalar `Solubility` alternative as `solubility`. Not a standalone
#'   property: it is ignored unless `solubility` is supplied, and it does
#'   not apply to the table path.
#' @param solubility_gain_per_charge Numeric scalar. Optional
#'   `Solubility gain per charge` parameter added to the same scalar
#'   `Solubility` alternative as `solubility`. Not a standalone property:
#'   it is ignored unless `solubility` is supplied.
#' @param solubility_table Two-column data frame giving table-based
#'   solubility: the first column is pH and the second is the solubility
#'   value. When supplied, one `Solubility` alternative with a
#'   `Solubility table` parameter carrying a `TableFormula` is created
#'   instead of a scalar solubility. Mutually exclusive with `solubility`.
#'   Note: on import PK-Sim runs a table-solubility preparation step that
#'   this package does not perform; the package emits the faithful raw
#'   `Solubility table` + `TableFormula` shape that round-trips through
#'   load/export at the JSON level.
#' @param solubility_name Character. `Name` of the created solubility
#'   alternative (scalar or table). Defaults to `"User defined"`.
#' @param intestinal_permeability Numeric scalar. Intestinal permeability
#'   value. When supplied, one default `IntestinalPermeability` alternative
#'   is created.
#' @param intestinal_permeability_unit Character. Unit for the
#'   intestinal-permeability parameter, validated against dimension
#'   `"Velocity"`. Defaults to `"cm/min"`.
#' @param intestinal_permeability_name Character. `Name` of the created
#'   intestinal-permeability alternative. Defaults to `"User defined"`.
#' @param permeability Numeric scalar. Permeability value. When supplied,
#'   one default `Permeability` alternative is created.
#' @param permeability_unit Character. Unit for the permeability parameter,
#'   validated against dimension `"Velocity"`. Defaults to `"cm/min"`.
#' @param permeability_name Character. `Name` of the created permeability
#'   alternative. Defaults to `"User defined"`.
#' @param pKa List of typed pKa entries, each a list with a `type`
#'   (one of `"Acid"`, `"Base"`, `"Neutral"`) and a numeric `value`, for
#'   example `list(list(type = "Base", value = 10.02))`. Order is
#'   preserved. An empty `list()` clears the pKa types; `NULL` leaves them
#'   unset.
#' @param processes List of [Process] objects (created with
#'   [create_process()]) or raw process lists to attach to the compound.
#'
#' @return A [Compound] object.
#' @export
#'
#' @examples
#' # Create a minimal compound
#' compound <- create_compound(name = "Drug X")
#'
#' # Create a small molecule with molecular weight and binding partner
#' compound <- create_compound(
#'   name = "Drug X",
#'   is_small_molecule = TRUE,
#'   molecular_weight = 250.3,
#'   plasma_protein_binding_partner = "Albumin"
#' )
#'
#' # Set the single-parameter physicochemical properties
#' compound <- create_compound(
#'   name = "Drug X",
#'   lipophilicity = 2.5,
#'   fraction_unbound = 0.1,
#'   intestinal_permeability = 1.14e-05,
#'   permeability = 0.0069
#' )
#'
#' # Solubility with reference pH and gain per charge
#' compound <- create_compound(
#'   name = "Drug X",
#'   solubility = 9999,
#'   reference_pH = 7,
#'   solubility_gain_per_charge = 1000
#' )
#'
#' # Table-based solubility (first column pH, second column value)
#' compound <- create_compound(
#'   name = "Drug X",
#'   solubility_table = data.frame(
#'     pH = c(3, 6, 6.8),
#'     value = c(5000, 3000, 90)
#'   )
#' )
#'
#' # Multiple pKa entries
#' compound <- create_compound(
#'   name = "Drug X",
#'   pKa = list(
#'     list(type = "Base", value = 10.02),
#'     list(type = "Acid", value = 1.7)
#'   )
#' )
#'
#' # Attach a process
#' compound <- create_compound(
#'   name = "Drug X",
#'   processes = list(
#'     create_process(
#'       internal_name = "GlomerularFiltration",
#'       data_source = "Publication X"
#'     )
#'   )
#' )
#'
#' # Additional/loose parameters (not physicochemical properties)
#' compound <- create_compound(
#'   name = "Drug X",
#'   parameters = list(
#'     create_parameter(name = "Cl_spec", value = 5, unit = "ml/min/kg")
#'   )
#' )
create_compound <- function(
  name,
  description = NULL,
  is_small_molecule = NULL,
  plasma_protein_binding_partner = NULL,
  molecular_weight = NULL,
  molecular_weight_unit = "g/mol",
  calculation_methods = NULL,
  parameters = NULL,
  lipophilicity = NULL,
  lipophilicity_unit = "Log Units",
  lipophilicity_name = "User defined",
  fraction_unbound = NULL,
  fraction_unbound_name = "User defined",
  solubility = NULL,
  solubility_unit = "mg/l",
  reference_pH = NULL,
  solubility_gain_per_charge = NULL,
  solubility_table = NULL,
  solubility_name = "User defined",
  intestinal_permeability = NULL,
  intestinal_permeability_unit = "cm/min",
  intestinal_permeability_name = "User defined",
  permeability = NULL,
  permeability_unit = "cm/min",
  permeability_name = "User defined",
  pKa = NULL,
  processes = NULL
) {
  check_required_string(name, "name")
  if (!is.null(is_small_molecule) && !is.logical(is_small_molecule)) {
    cli::cli_abort("{.arg is_small_molecule} must be a logical value")
  }
  if (!is.null(molecular_weight) && !is.numeric(molecular_weight)) {
    cli::cli_abort("{.arg molecular_weight} must be a numeric value")
  }
  if (!is.null(molecular_weight)) {
    validate_unit(molecular_weight_unit, "Molecular weight")
  }

  # Numeric-scalar guards for the physicochemical property values.
  for (arg in c(
    "lipophilicity",
    "fraction_unbound",
    "solubility",
    "reference_pH",
    "solubility_gain_per_charge",
    "intestinal_permeability",
    "permeability"
  )) {
    val <- get(arg)
    if (!is.null(val) && (!is.numeric(val) || length(val) != 1)) {
      cli::cli_abort("{.arg {arg}} must be a numeric value")
    }
  }

  if (!is.null(solubility) && !is.null(solubility_table)) {
    cli::cli_abort(c(
      "Solubility is set either by a single value or by a table, not both.",
      "i" = "Supply {.arg solubility} or {.arg solubility_table}, not both."
    ))
  }
  if (!is.null(solubility_table)) {
    if (!is.data.frame(solubility_table) || ncol(solubility_table) != 2) {
      cli::cli_abort(
        "{.arg solubility_table} must be a data frame with two columns (pH, value)"
      )
    }
  }

  if (!is.null(lipophilicity)) {
    validate_unit(lipophilicity_unit, "Log Units")
  }
  if (!is.null(solubility) || !is.null(solubility_table)) {
    validate_unit(solubility_unit, "Concentration (mass)")
  }
  if (!is.null(intestinal_permeability)) {
    validate_unit(intestinal_permeability_unit, "Velocity")
  }
  if (!is.null(permeability)) {
    validate_unit(permeability_unit, "Velocity")
  }
  if (!is.null(pKa)) {
    validate_pka(pKa)
  }

  data <- list(Name = name)

  if (!is.null(description)) {
    data$Description <- description
  }
  if (!is.null(is_small_molecule)) {
    data$IsSmallMolecule <- is_small_molecule
  }
  if (!is.null(plasma_protein_binding_partner)) {
    data$PlasmaProteinBindingPartner <- plasma_protein_binding_partner
  }
  if (!is.null(calculation_methods)) {
    data$CalculationMethods <- as.list(calculation_methods)
  }

  parameter_list <- list()
  if (!is.null(molecular_weight)) {
    parameter_list <- c(
      parameter_list,
      list(list(
        Name = "Molecular weight",
        Value = molecular_weight,
        Unit = molecular_weight_unit
      ))
    )
  }
  if (!is.null(parameters)) {
    if (!is.list(parameters)) {
      cli::cli_abort("{.arg parameters} must be a list")
    }
    # Compound parameters use Name (not Path) in the JSON shape.
    parameter_list <- c(parameter_list, to_raw_parameters(parameters, "Name"))
  }
  if (length(parameter_list) > 0) {
    data$Parameters <- parameter_list
  }

  if (!is.null(lipophilicity)) {
    data$Lipophilicity <- build_single_param_alternative(
      lipophilicity_name,
      "Lipophilicity",
      lipophilicity,
      lipophilicity_unit
    )
  }
  if (!is.null(fraction_unbound)) {
    data$FractionUnbound <- build_single_param_alternative(
      fraction_unbound_name,
      "Fraction unbound (plasma, reference value)",
      fraction_unbound,
      unit = NULL
    )
  }
  if (!is.null(solubility)) {
    data$Solubility <- build_solubility_alternative(
      solubility_name,
      solubility,
      solubility_unit,
      reference_pH,
      solubility_gain_per_charge
    )
  } else if (!is.null(solubility_table)) {
    data$Solubility <- build_solubility_table_alternative(
      solubility_name,
      solubility_table,
      solubility_unit
    )
  }
  if (!is.null(intestinal_permeability)) {
    data$IntestinalPermeability <- build_single_param_alternative(
      intestinal_permeability_name,
      "Specific intestinal permeability (transcellular)",
      intestinal_permeability,
      intestinal_permeability_unit
    )
  }
  if (!is.null(permeability)) {
    data$Permeability <- build_single_param_alternative(
      permeability_name,
      "Permeability",
      permeability,
      permeability_unit
    )
  }
  if (!is.null(pKa) && length(pKa) > 0) {
    data$PkaTypes <- build_pka_types(pKa)
  }
  if (!is.null(processes)) {
    data$Processes <- to_raw_r6_or_list(processes, "Process", "processes")
  }

  Compound$new(data)
}

# Internal ----

# Internal: build a one-element (unnamed) alternative array holding a single
# default alternative with one parameter. Shared by the four single-parameter
# alternative groups (lipophilicity, fraction unbound, intestinal
# permeability, permeability). `unit = NULL` omits the parameter `Unit` field
# (fraction unbound stores a bare value).
build_single_param_alternative <- function(
  name,
  param_name,
  value,
  unit = NULL
) {
  param <- list(Name = param_name, Value = value)
  if (!is.null(unit)) {
    param$Unit <- unit
  }
  list(list(Name = name, IsDefault = TRUE, Parameters = list(param)))
}

# Internal: build a one-element (unnamed) scalar `Solubility` alternative
# bundling the reference pH and optional gain-per-charge into the same
# alternative. `Reference pH` and `Solubility gain per charge` are emitted
# only when supplied.
build_solubility_alternative <- function(
  name,
  value,
  unit,
  reference_pH = NULL,
  gain_per_charge = NULL
) {
  params <- list(
    list(Name = "Solubility at reference pH", Value = value, Unit = unit)
  )
  if (!is.null(reference_pH)) {
    params <- c(params, list(list(Name = "Reference pH", Value = reference_pH)))
  }
  if (!is.null(gain_per_charge)) {
    params <- c(
      params,
      list(list(Name = "Solubility gain per charge", Value = gain_per_charge))
    )
  }
  list(list(Name = name, IsDefault = TRUE, Parameters = params))
}

# Internal: build a one-element (unnamed) table-based `Solubility`
# alternative whose single `Solubility table` parameter carries a
# `TableFormula`. The parameter `Value` is the first table Y value, matching
# observed PK-Sim exports.
build_solubility_table_alternative <- function(name, table, unit) {
  param <- list(
    Name = "Solubility table",
    Value = table[[2]][1],
    Unit = unit,
    TableFormula = build_solubility_table_formula(table, unit)
  )
  list(list(Name = name, IsDefault = TRUE, Parameters = list(param)))
}

# Internal: build the solubility `TableFormula` from a two-column table
# (col 1 pH, col 2 value). No `XUnit` field (matches the observed solubility
# table shape). Points are an unnamed list.
build_solubility_table_formula <- function(table, y_unit) {
  points <- lapply(seq_len(nrow(table)), function(i) {
    list(X = table[[1]][i], Y = table[[2]][i], RestartSolver = FALSE)
  })
  list(
    Name = "Solubility",
    XName = "pH",
    XDimension = "Dimensionless",
    YName = "Solubility",
    YDimension = "Concentration (mass)",
    YUnit = y_unit,
    UseDerivedValues = FALSE,
    Points = points
  )
}

# Internal: convert the `pKa` argument list to a `PkaType[]` (unnamed list of
# `list(Type =, Pka =)`). Validation lives in `validate_pka()`.
build_pka_types <- function(pKa) {
  unname(lapply(pKa, function(e) list(Type = e$type, Pka = e$value)))
}

# Internal: validate the `pKa` argument (a list of `list(type =, value =)`
# entries). Aborts on a non-list, a non-list entry, a `type` outside
# Acid/Base/Neutral, or a non-numeric scalar `value`, naming the offending
# index.
validate_pka <- function(pKa, call = parent.frame()) {
  if (!is.list(pKa) || is.object(pKa)) {
    cli::cli_abort("{.arg pKa} must be a list", call = call)
  }
  valid_types <- c("Acid", "Base", "Neutral")
  for (i in seq_along(pKa)) {
    entry <- pKa[[i]]
    if (!is.list(entry) || is.object(entry)) {
      cli::cli_abort(
        "Entry {i} of {.arg pKa} must be a list with {.field type} and {.field value}",
        call = call
      )
    }
    if (
      is.null(entry$type) ||
        length(entry$type) != 1 ||
        !(entry$type %in% valid_types)
    ) {
      cli::cli_abort(
        c(
          "Entry {i} of {.arg pKa} has an invalid {.field type}.",
          "i" = "{.field type} must be one of {.val {valid_types}}."
        ),
        call = call
      )
    }
    if (!is.numeric(entry$value) || length(entry$value) != 1) {
      cli::cli_abort(
        "Entry {i} of {.arg pKa} must have a numeric {.field value}",
        call = call
      )
    }
  }
  invisible(pKa)
}
