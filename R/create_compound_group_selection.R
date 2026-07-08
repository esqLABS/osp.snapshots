#' Create a compound alternative group selection
#'
#' @description
#' Build a [CompoundGroupSelection] entry, used inside a
#' [CompoundProperties] to record which alternative is selected within an
#' alternative group. Internal machinery only: the friendly `alternatives`
#' selection in [add_simulation()]'s `compounds` argument is the
#' user-facing way to select an alternative; this constructor and the
#' `COMPOUND_*` group constants it takes are not part of the public API.
#'
#' @param group_name Character. Name of the alternative group (required),
#'   for example `"COMPOUND_SOLUBILITY"`.
#' @param alternative_name Character. Name of the selected alternative
#'   within the group (required).
#'
#' @return A [CompoundGroupSelection] object.
#' @keywords internal
create_compound_group_selection <- function(group_name, alternative_name) {
  check_required_string(group_name, "group_name")
  check_required_string(alternative_name, "alternative_name")
  CompoundGroupSelection$new(list(
    GroupName = group_name,
    AlternativeName = alternative_name
  ))
}
