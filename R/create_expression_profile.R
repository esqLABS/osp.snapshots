#' Create a new expression profile
#'
#' @description
#' Create an [ExpressionProfile] building block from named arguments.
#' This is a thin factory around `ExpressionProfile$new()` that builds
#' the raw list shape for you.
#'
#' An [ExpressionProfile]'s identity is the composite
#' `Molecule|Species|Category`, so all three of `molecule`, `species`,
#' and `category` are required.
#'
#' The `reference_concentration`, `half_life_liver`, and
#' `half_life_intestine` arguments promote the three fixed global
#' molecule-properties scalars as a convenience over hand-authoring them
#' through `parameters`. A promoted argument and the equivalent
#' `parameters` entry produce identical snapshot JSON.
#'
#' @param molecule Character. Name of the molecule (for example
#'   `"CYP3A4"`). Required.
#' @param species Character. Species (for example `"Human"`). Required.
#' @param category Character. Category disambiguator (for example
#'   `"Healthy"` or `"Variability"`). Required.
#' @param type Character. Molecule type, typically one of `"Enzyme"`,
#'   `"Transporter"`, or `"OtherProtein"`. Required.
#' @param localization Character. Expression localization for proteins.
#' @param transport_type Character. Transporter type (for transporter
#'   profiles), for example `"Efflux"` or `"Influx"`.
#' @param ontogeny Character or list. Ontogeny name, or a raw ontogeny
#'   list. If a string is supplied it is wrapped as
#'   `list(Name = ontogeny)`.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists describing relative
#'   expression and other per-organ values.
#' @param expression Per-organ relative expression, written to the
#'   snapshot's `Expression` array. Supply a data frame (or tibble), one
#'   row per organ/compartment, with a required `name` column
#'   (organ/container name, for example `"Liver"`) and the optional
#'   columns `value` (relative expression), `compartment` (for example
#'   `"Intracellular"`), and `transport_direction` (for transporter
#'   profiles). Missing (`NA`) or absent optional cells emit no key, so a
#'   row with only `name` and `value` produces a container with just those
#'   two fields. Row order is preserved and duplicate names are kept.
#'   Alternatively supply a raw list of container lists (each a named list
#'   with any of `Name`, `Value`, `CompartmentName`, `TransportDirection`)
#'   to pass through verbatim. `NULL` or an empty input writes nothing.
#' @param disease Disease state, written to the snapshot's `Disease`
#'   object. Supply a named list with `name` (required, the
#'   `DiseaseState` name) and an optional `parameters` list of [Parameter]
#'   objects or raw parameter lists. `NULL` writes nothing.
#' @param description Character. Free-text description of the profile.
#' @param reference_concentration Numeric or `NULL`. Global molecule
#'   reference concentration, written to the `Path`
#'   `"{molecule}|Reference concentration"`. Validated as a single finite
#'   numeric. `NULL` (default) emits nothing. Dimension
#'   `"Concentration (molar)"`.
#' @param reference_concentration_unit Character. Unit for
#'   `reference_concentration`, validated against the
#'   `"Concentration (molar)"` dimension. Default `"µmol/l"`.
#'   Consulted only when `reference_concentration` is supplied.
#' @param half_life_liver Numeric or `NULL`. Global molecule liver
#'   half-life, written to the `Path` `"{molecule}|t1/2 (liver)"`.
#'   Validated as a single finite numeric. `NULL` (default) emits nothing.
#'   Dimension `"Time"`.
#' @param half_life_liver_unit Character. Unit for `half_life_liver`,
#'   validated against the `"Time"` dimension. Default `"h"`. Consulted
#'   only when `half_life_liver` is supplied.
#' @param half_life_intestine Numeric or `NULL`. Global molecule intestine
#'   half-life, written to the `Path` `"{molecule}|t1/2 (intestine)"`.
#'   Validated as a single finite numeric. `NULL` (default) emits nothing.
#'   Dimension `"Time"`.
#' @param half_life_intestine_unit Character. Unit for
#'   `half_life_intestine`, validated against the `"Time"` dimension.
#'   Default `"h"`. Consulted only when `half_life_intestine` is supplied.
#'
#' @return An [ExpressionProfile] object.
#' @export
#'
#' @examples
#' # Create a minimal enzyme expression profile
#' profile <- create_expression_profile(
#'   molecule = "CYP3A4",
#'   species = "Human",
#'   category = "Healthy",
#'   type = "Enzyme"
#' )
#'
#' # Create a transporter expression profile with ontogeny
#' profile <- create_expression_profile(
#'   molecule = "P-gp",
#'   species = "Human",
#'   category = "Healthy",
#'   type = "Transporter",
#'   transport_type = "Efflux",
#'   ontogeny = "P-gp"
#' )
#'
#' # Create an enzyme profile with per-organ relative expression
#' profile <- create_expression_profile(
#'   molecule = "CYP3A4",
#'   species = "Human",
#'   category = "Healthy",
#'   type = "Enzyme",
#'   expression = data.frame(
#'     name = c("Liver", "Kidney"),
#'     value = c(1, 0.5)
#'   )
#' )
#'
#' # Set the global reference concentration directly
#' profile <- create_expression_profile(
#'   molecule = "CYP3A4",
#'   species = "Human",
#'   category = "Healthy",
#'   type = "Enzyme",
#'   reference_concentration = 4.32
#' )
create_expression_profile <- function(
  molecule,
  species,
  category,
  type,
  localization = NULL,
  transport_type = NULL,
  ontogeny = NULL,
  parameters = NULL,
  expression = NULL,
  disease = NULL,
  description = NULL,
  reference_concentration = NULL,
  reference_concentration_unit = "µmol/l",
  half_life_liver = NULL,
  half_life_liver_unit = "h",
  half_life_intestine = NULL,
  half_life_intestine_unit = "h"
) {
  check_required_string(molecule, "molecule")
  check_required_string(species, "species")
  check_required_string(category, "category")
  check_required_string(type, "type")

  data <- list(
    Type = type,
    Species = species,
    Molecule = molecule,
    Category = category
  )

  if (!is.null(description)) {
    data$Description <- description
  }
  if (!is.null(localization)) {
    data$Localization <- localization
  }
  if (!is.null(transport_type)) {
    data$TransportType <- transport_type
  }
  if (!is.null(ontogeny)) {
    if (is.character(ontogeny) && length(ontogeny) == 1) {
      data$Ontogeny <- list(Name = ontogeny)
    } else if (is.list(ontogeny)) {
      data$Ontogeny <- ontogeny
    } else {
      cli::cli_abort("{.arg ontogeny} must be a scalar character or a list")
    }
  }
  parameters_supplied <- !is.null(parameters)
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("{.arg parameters} must be a list")
  }
  raw_params <- if (is.null(parameters)) {
    list()
  } else {
    to_raw_parameters(parameters, "Path")
  }
  existing_paths <- vapply(
    raw_params,
    function(p) if (is.null(p$Path)) NA_character_ else p$Path,
    character(1)
  )
  promoted <- build_promoted_molecule_parameters(
    molecule = molecule,
    specs = list(
      list(
        arg = "reference_concentration",
        value = reference_concentration,
        unit = reference_concentration_unit,
        dimension = "Concentration (molar)",
        leaf = "Reference concentration"
      ),
      list(
        arg = "half_life_liver",
        value = half_life_liver,
        unit = half_life_liver_unit,
        dimension = "Time",
        leaf = "t1/2 (liver)"
      ),
      list(
        arg = "half_life_intestine",
        value = half_life_intestine,
        unit = half_life_intestine_unit,
        dimension = "Time",
        leaf = "t1/2 (intestine)"
      )
    ),
    existing_paths = existing_paths
  )
  combined <- c(promoted, raw_params)
  if (parameters_supplied || length(combined) > 0) {
    data$Parameters <- combined
  }

  containers <- build_expression_containers(expression)
  if (!is.null(containers)) {
    data$Expression <- containers
  }

  disease_state <- build_disease_state(disease)
  if (!is.null(disease_state)) {
    data$Disease <- disease_state
  }

  ExpressionProfile$new(data)
}
