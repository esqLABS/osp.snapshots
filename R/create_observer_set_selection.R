#' Create an observer-set selection for a simulation
#'
#' @description
#' Build an [ObserverSetSelection] entry that references an [ObserverSet]
#' building block by name inside a [Simulation].
#'
#' @param name Character. Name of the observer-set building block (required).
#'
#' @return An [ObserverSetSelection] object.
#' @export
#'
#' @examples
#' create_observer_set_selection(name = "BrainPlasmaConcentration")
create_observer_set_selection <- function(name) {
  check_required_string(name, "name")
  ObserverSetSelection$new(list(Name = name))
}
