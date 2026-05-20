#' Create a compound process selection
#'
#' @description
#' Build a [CompoundProcessSelection] entry, used inside a
#' [CompoundProperties] to record which compound processes are selected
#' for the simulation.
#'
#' All arguments are optional and serialized only when supplied. PK-Sim
#' resolves the right process placeholder from whichever combination of
#' fields is set.
#'
#' @param name Character. Process name.
#' @param molecule_name Character. Molecule involved in the process.
#' @param metabolite_name Character. Metabolite produced by the process.
#' @param compound_name Character. Other compound involved in the process.
#' @param systemic_process_type Character. Systemic process type (e.g.
#'   `"Hepatic"`, `"Renal"`, `"Biliary"`).
#'
#' @return A [CompoundProcessSelection] object.
#' @export
#'
#' @examples
#' create_compound_process_selection(
#'   name = "P-gp-Collett 2004",
#'   molecule_name = "P-gp"
#' )
#'
#' create_compound_process_selection(systemic_process_type = "Hepatic")
create_compound_process_selection <- function(
  name = NULL,
  molecule_name = NULL,
  metabolite_name = NULL,
  compound_name = NULL,
  systemic_process_type = NULL
) {
  data <- list()
  if (!is.null(name)) {
    check_required_string(name, "name")
    data$Name <- name
  }
  if (!is.null(molecule_name)) {
    check_required_string(molecule_name, "molecule_name")
    data$MoleculeName <- molecule_name
  }
  if (!is.null(metabolite_name)) {
    check_required_string(metabolite_name, "metabolite_name")
    data$MetaboliteName <- metabolite_name
  }
  if (!is.null(compound_name)) {
    check_required_string(compound_name, "compound_name")
    data$CompoundName <- compound_name
  }
  if (!is.null(systemic_process_type)) {
    check_required_string(systemic_process_type, "systemic_process_type")
    data$SystemicProcessType <- systemic_process_type
  }
  CompoundProcessSelection$new(data)
}
