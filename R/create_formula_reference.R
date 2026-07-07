#' Create a formula reference for an observer
#'
#' @description
#' Build a single `FormulaUsablePath` entry for the `References` of an
#' observer's `ExplicitFormula`. A formula reference binds an alias used
#' in the formula expression to a model path. This is a small builder that
#' returns the raw named list; assemble several of them into a list for
#' [create_observer()] or `observer$formula_references`.
#'
#' @param alias Character. The alias used in the formula expression
#'   (required).
#' @param path Character. The model path the alias resolves to (required).
#' @param dimension Character. The dimension of the referenced quantity.
#'   Omitted when `NULL`.
#'
#' @return A named list with `Alias`, `Path`, and, when supplied,
#'   `Dimension`.
#' @export
#'
#' @examples
#' create_formula_reference(
#'   "Conc_Br",
#'   "Organism|Brain|Plasma|Drug|Concentration"
#' )
#'
#' # With an explicit dimension
#' create_formula_reference(
#'   "Conc_Br",
#'   "Organism|Brain|Plasma|Drug|Concentration",
#'   "Concentration (molar)"
#' )
create_formula_reference <- function(alias, path, dimension = NULL) {
  check_required_string(alias, "alias")
  check_required_string(path, "path")

  data <- list(Alias = alias, Path = path)

  if (!is.null(dimension)) {
    check_required_string(dimension, "dimension")
    data$Dimension <- dimension
  }

  data
}
