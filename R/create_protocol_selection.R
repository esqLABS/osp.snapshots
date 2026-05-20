#' Create a protocol selection for a simulation compound
#'
#' @description
#' Build a [ProtocolSelection] entry, used inside a [CompoundProperties]
#' to assign a [Protocol] building block to the compound and (optionally)
#' map each application slot to a [Formulation] via
#' [FormulationSelection].
#'
#' @param name Character. Name of the protocol building block (required).
#' @param formulations List of [FormulationSelection] objects (created
#'   with [create_formulation_selection()]) or raw lists.
#'
#' @return A [ProtocolSelection] object.
#' @export
#'
#' @examples
#' create_protocol_selection(
#'   name = "Yu 2004 - Rifampicin - 600 mg MD OD 10 days",
#'   formulations = list(
#'     create_formulation_selection(name = "Oral solution", key = "Formulation")
#'   )
#' )
create_protocol_selection <- function(name, formulations = NULL) {
  check_required_string(name, "name")

  data <- list(Name = name)
  if (!is.null(formulations)) {
    data$Formulations <- to_raw_r6_or_list(
      formulations,
      "FormulationSelection",
      "formulations"
    )
  }

  ProtocolSelection$new(data)
}
