#' Create a formulation selection for a simulation compound
#'
#' @description
#' Build a [FormulationSelection] entry, used inside a
#' [ProtocolSelection] to bind a formulation building block to one of the
#' protocol's application slots.
#'
#' @param name Character. Name of the formulation building block (required).
#' @param key Character. Formulation key identifying which application in
#'   the protocol uses this formulation (required).
#'
#' @return A [FormulationSelection] object.
#' @export
#'
#' @examples
#' create_formulation_selection(name = "Oral solution", key = "Formulation")
create_formulation_selection <- function(name, key) {
  check_required_string(name, "name")
  check_required_string(key, "key")
  FormulationSelection$new(list(Name = name, Key = key))
}
