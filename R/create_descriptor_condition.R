#' Create a container criterion for an observer
#'
#' @description
#' Build a single `DescriptorCondition` entry for an [Observer]'s
#' `ContainerCriteria`. A container criterion matches the containers an
#' observer applies to by a `Tag` and an optional match `Type`. This is a
#' small builder that returns the raw named list; assemble several of them
#' into a list for [create_observer()] or `observer$container_criteria`.
#'
#' @param tag Character. The container tag to match (required).
#' @param type Character. The match type. This is an open string, not a
#'   closed enum: PK-Sim writes values such as `"InContainer"`,
#'   `"NotInContainer"`, `"InParent"`, or `"MatchTag"`, and any of these
#'   (or another string PK-Sim emits) is preserved verbatim. Omitted when
#'   `NULL`.
#'
#' @return A named list with `Tag` and, when supplied, `Type`.
#' @export
#'
#' @examples
#' create_descriptor_condition("Brain", "InContainer")
#'
#' # The match type is optional
#' create_descriptor_condition("Brain")
create_descriptor_condition <- function(tag, type = NULL) {
  check_required_string(tag, "tag")

  data <- list(Tag = tag)

  if (!is.null(type)) {
    check_required_string(type, "type")
    data$Type <- type
  }

  data
}
