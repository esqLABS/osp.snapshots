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
  description = NULL
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
  if (!is.null(parameters)) {
    if (!is.list(parameters)) {
      cli::cli_abort("{.arg parameters} must be a list")
    }
    data$Parameters <- to_raw_parameters(parameters, "Path")
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
