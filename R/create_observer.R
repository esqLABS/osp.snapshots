# Valid observer types recognised by PK-Sim.
VALID_OBSERVER_TYPES <- c("Amount", "Container")

#' Create a new observer
#'
#' @description
#' Create a single [Observer] from named arguments. This is a thin factory
#' around `Observer$new()` that builds the raw list shape for you and
#' composes with [create_observer_set()] via
#' `create_observer_set(observers = list(...))`.
#'
#' An observer is a simulation-time formula that computes a derived
#' quantity from the underlying model (for example an amount observer or a
#' container observer). It is not itself a building block; it lives inside
#' an [ObserverSet].
#'
#' @param name Character. Name of the observer (required).
#' @param type Character. The observer type, one of `"Amount"` (an
#'   `AmountObserverBuilder`) or `"Container"` (a
#'   `ContainerObserverBuilder`). Any other value aborts (required).
#' @param dimension Character. The dimension of the observed quantity.
#'   Omitted when `NULL`.
#' @param formula The observer's formula. Either a bare expression string
#'   (which becomes the inner `Formula$Formula`), or a full
#'   `ExplicitFormula` raw list used as the whole `Formula`. Omitted when
#'   `NULL`.
#' @param formula_references List of formula references, each a
#'   [create_formula_reference()] output or an equivalent raw
#'   `{Alias, Path, Dimension}` list. Written to the formula's
#'   `References`; supplying these without `formula` yields a `Formula`
#'   carrying only `References`. Omitted when `NULL`.
#' @param container_criteria List of container criteria, each a
#'   [create_descriptor_condition()] output or an equivalent raw
#'   `{Tag, Type}` list. Written to `ContainerCriteria`. Omitted when
#'   `NULL`.
#' @param molecule_list A [create_molecule_list()] output or an equivalent
#'   raw list. Written to `MoleculeList`. Omitted when `NULL`.
#'
#' @return An [Observer] object.
#' @export
#'
#' @examples
#' # Minimal amount observer
#' create_observer(name = "drug_amount", type = "Amount")
#'
#' # Container observer with all sub-properties
#' obs <- create_observer(
#'   name = "brain_plasma_conc",
#'   type = "Container",
#'   dimension = "Concentration (molar)",
#'   formula = "Conc_Br",
#'   formula_references = list(
#'     create_formula_reference(
#'       "Conc_Br",
#'       "Organism|Brain|Plasma|Drug|Concentration"
#'     )
#'   ),
#'   container_criteria = list(
#'     create_descriptor_condition("Brain", "InContainer")
#'   ),
#'   molecule_list = create_molecule_list(for_all = FALSE, include = "Drug")
#' )
#'
#' # Compose into an observer set
#' create_observer_set(name = "BrainPlasmaConcentration", observers = list(obs))
create_observer <- function(
  name,
  type,
  dimension = NULL,
  formula = NULL,
  formula_references = NULL,
  container_criteria = NULL,
  molecule_list = NULL
) {
  check_required_string(name, "name")
  data <- list(Name = name)

  if (
    missing(type) || !is.character(type) || !(type %in% VALID_OBSERVER_TYPES)
  ) {
    cli::cli_abort(
      "{.arg type} must be one of {.val {VALID_OBSERVER_TYPES}}"
    )
  }
  data$Type <- type

  if (!is.null(dimension)) {
    check_required_string(dimension, "dimension")
    data$Dimension <- dimension
  }

  if (!is.null(formula)) {
    if (is.character(formula) && length(formula) == 1) {
      data$Formula <- list(Formula = formula)
    } else if (is.list(formula) && !is.object(formula)) {
      data$Formula <- formula
    } else {
      cli::cli_abort(
        "{.arg formula} must be a string or a raw list"
      )
    }
  }

  if (!is.null(formula_references)) {
    formula_references <- to_raw_list_entries(
      formula_references,
      "formula_references"
    )
    if (is.null(data$Formula)) {
      data$Formula <- list()
    }
    data$Formula$References <- formula_references
  }

  if (!is.null(container_criteria)) {
    data$ContainerCriteria <- to_raw_list_entries(
      container_criteria,
      "container_criteria"
    )
  }

  if (!is.null(molecule_list)) {
    if (!is.list(molecule_list) || is.object(molecule_list)) {
      cli::cli_abort("{.arg molecule_list} must be a list")
    }
    data$MoleculeList <- molecule_list
  }

  Observer$new(data)
}
