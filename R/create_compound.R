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
#'   protein binding partner: one of `"Unknown"`, `"Albumin"`,
#'   `"Glycoprotein"`.
#' @param molecular_weight Numeric. Molecular weight value.
#' @param molecular_weight_unit Character. Unit for molecular weight.
#'   Defaults to `"g/mol"`.
#' @param calculation_methods Character vector. Calculation method names
#'   that PK-Sim uses to derive compound quantities.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists to attach as additional
#'   compound parameters. This does not set physicochemical properties;
#'   use the dedicated arguments below for those.
#' @param lipophilicity A [lipophilicity()] object, or `NULL`. When
#'   supplied, one default `Lipophilicity` alternative is created.
#' @param fraction_unbound A [fraction_unbound()] object, or `NULL`. When
#'   supplied, one default `FractionUnbound` alternative is created.
#' @param solubility A [solubility()] object, or `NULL`. Expresses either
#'   the scalar form (value at a reference pH, with optional gain per
#'   charge) or the table form (a pH/value table). When supplied, one
#'   `Solubility` alternative is created. See [solubility()] for the scalar
#'   vs table forms and the mutual-exclusivity rule.
#' @param intestinal_permeability An [intestinal_permeability()] object, or
#'   `NULL`. When supplied, one default `IntestinalPermeability` alternative
#'   is created.
#' @param permeability A [permeability()] object, or `NULL`. When supplied,
#'   one default `Permeability` alternative is created.
#' @param pKa List of typed pKa entries, each a list with a `type`
#'   (one of `"Acid"`, `"Base"`, `"Neutral"`) and a numeric `value`, for
#'   example `list(list(type = "Base", value = 10.02))`. Order is
#'   preserved. Both `NULL` (the default) and an empty `list()` leave the
#'   created compound with no pKa types set. (The clearing semantics, where
#'   an empty `list()` removes existing values, apply to the writable
#'   `Compound$pka_types` field, not to construction.)
#' @param processes List of [Process] objects (created with
#'   [create_process()]) or raw process lists to attach to the compound.
#'
#' @return A [Compound] object.
#' @seealso [lipophilicity()], [fraction_unbound()], [solubility()],
#'   [intestinal_permeability()], [permeability()] for the physicochemical
#'   property helpers.
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
#'   lipophilicity = lipophilicity(2.5),
#'   fraction_unbound = fraction_unbound(0.1),
#'   intestinal_permeability = intestinal_permeability(1.14e-05),
#'   permeability = permeability(0.0069)
#' )
#'
#' # Solubility with reference pH and gain per charge
#' compound <- create_compound(
#'   name = "Drug X",
#'   solubility = solubility(9999, reference_pH = 7, gain_per_charge = 1000)
#' )
#'
#' # Table-based solubility (first column pH, second column value)
#' compound <- create_compound(
#'   name = "Drug X",
#'   solubility = solubility(
#'     table = data.frame(
#'       pH = c(3, 6, 6.8),
#'       value = c(5000, 3000, 90)
#'     )
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
  fraction_unbound = NULL,
  solubility = NULL,
  intestinal_permeability = NULL,
  permeability = NULL,
  pKa = NULL,
  processes = NULL
) {
  check_required_string(name, "name")
  if (!is.null(is_small_molecule) && !is.logical(is_small_molecule)) {
    cli::cli_abort("{.arg is_small_molecule} must be a logical value")
  }
  if (
    !is.null(plasma_protein_binding_partner) &&
      !(plasma_protein_binding_partner %in% PLASMA_PROTEIN_BINDING_PARTNERS)
  ) {
    cli::cli_abort(
      "{.arg plasma_protein_binding_partner} must be one of {.val {PLASMA_PROTEIN_BINDING_PARTNERS}}"
    )
  }
  if (!is.null(molecular_weight) && !is.numeric(molecular_weight)) {
    cli::cli_abort("{.arg molecular_weight} must be a numeric value")
  }
  if (!is.null(molecular_weight)) {
    validate_unit(molecular_weight_unit, "Molecular weight")
  }

  # Each physicochemical property must be built with its helper (the value,
  # unit, and validation now live in the helper). A bare scalar aborts with
  # guidance to the helper.
  require_value_spec(
    lipophilicity,
    "lipophilicity_spec",
    "lipophilicity",
    example = "lipophilicity = lipophilicity(2.5)"
  )
  require_value_spec(
    fraction_unbound,
    "fraction_unbound_spec",
    "fraction_unbound",
    example = "fraction_unbound = fraction_unbound(0.1)"
  )
  require_value_spec(
    solubility,
    "solubility_spec",
    "solubility",
    example = "solubility = solubility(9999)"
  )
  require_value_spec(
    intestinal_permeability,
    "intestinal_permeability_spec",
    "intestinal_permeability",
    example = "intestinal_permeability = intestinal_permeability(1.14e-05)"
  )
  require_value_spec(
    permeability,
    "permeability_spec",
    "permeability",
    example = "permeability = permeability(0.0069)"
  )
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
    data$Lipophilicity <- spec_to_single_param_alternative(
      lipophilicity,
      "Lipophilicity"
    )
  }
  if (!is.null(fraction_unbound)) {
    data$FractionUnbound <- spec_to_single_param_alternative(
      fraction_unbound,
      "Fraction unbound (plasma, reference value)"
    )
  }
  if (!is.null(solubility)) {
    data$Solubility <- spec_to_solubility_alternative(solubility)
  }
  if (!is.null(intestinal_permeability)) {
    data$IntestinalPermeability <- spec_to_single_param_alternative(
      intestinal_permeability,
      "Specific intestinal permeability (transcellular)"
    )
  }
  if (!is.null(permeability)) {
    data$Permeability <- spec_to_single_param_alternative(
      permeability,
      "Permeability"
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

# Internal: unwrap a single-value physicochemical-property value-spec into its
# alternative array via `build_single_param_alternative()`. Shared by the
# factory and the `Compound` writable-field setter so the unwrapping lives in
# one place. `spec$unit` is `NULL` for fraction unbound (no unit slot), which
# the builder treats as "omit unit".
spec_to_single_param_alternative <- function(spec, param_name) {
  build_single_param_alternative(
    spec$name,
    param_name,
    spec$value,
    spec$unit
  )
}

# Internal: unwrap a `solubility_spec` into its `Solubility` alternative,
# branching on the spec's `form` (scalar vs table) onto the matching builder.
# Shared by the factory and the `Compound$solubility` setter.
spec_to_solubility_alternative <- function(spec) {
  if (identical(spec$form, "table")) {
    build_solubility_table_alternative(spec$name, spec$table, spec$unit)
  } else {
    build_solubility_alternative(
      spec$name,
      spec$value,
      spec$unit,
      spec$reference_pH,
      spec$gain_per_charge
    )
  }
}

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
