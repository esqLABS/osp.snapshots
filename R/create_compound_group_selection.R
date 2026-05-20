#' Create a compound alternative group selection
#'
#' @description
#' Build a [CompoundGroupSelection] entry, used inside a
#' [CompoundProperties] to record which alternative is selected within an
#' alternative group.
#'
#' @param group_name Character. Name of the alternative group (required),
#'   for example `"COMPOUND_SOLUBILITY"`.
#' @param alternative_name Character. Name of the selected alternative
#'   within the group (required).
#'
#' @return A [CompoundGroupSelection] object.
#' @export
#'
#' @examples
#' create_compound_group_selection(
#'   group_name = "COMPOUND_SOLUBILITY",
#'   alternative_name = "Aqueous"
#' )
create_compound_group_selection <- function(group_name, alternative_name) {
  check_required_string(group_name, "group_name")
  check_required_string(alternative_name, "alternative_name")
  CompoundGroupSelection$new(list(
    GroupName = group_name,
    AlternativeName = alternative_name
  ))
}
