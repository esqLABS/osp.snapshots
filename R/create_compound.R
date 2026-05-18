#' Create a new compound
#'
#' @description
#' Create a minimally populated [Compound] building block from named
#' arguments. This is a thin factory around `Compound$new()` that builds
#' the raw list shape for you.
#'
#' For richer compound structures (full lipophilicity alternatives,
#' processes, calculation methods, and so on), build the raw list directly
#' or load a template snapshot and mutate it.
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
#'   [create_parameter()]) or raw parameter lists to attach to the
#'   compound.
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
#' # Create a compound with additional parameters
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
  parameters = NULL
) {
  check_required_string(name, "name")
  if (!is.null(is_small_molecule) && !is.logical(is_small_molecule)) {
    cli::cli_abort("{.arg is_small_molecule} must be a logical value")
  }
  if (!is.null(molecular_weight) && !is.numeric(molecular_weight)) {
    cli::cli_abort("{.arg molecular_weight} must be a numeric value")
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

  Compound$new(data)
}
