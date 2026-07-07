#' Create a molecule list for an observer
#'
#' @description
#' Build a `MoleculeList` for an [Observer], selecting which molecules the
#' observer applies to. This is a small builder that returns the raw named
#' list for [create_observer()] or `observer$molecule_list`.
#'
#' @param for_all Logical (length 1). When `TRUE`, the observer applies to
#'   all molecules. Omitted when `NULL`.
#' @param include Character vector of molecule names to include. Always
#'   serialises as a JSON array, even for a single name. Omitted when
#'   `NULL`.
#' @param exclude Character vector of molecule names to exclude. Always
#'   serialises as a JSON array, even for a single name. Omitted when
#'   `NULL`.
#'
#' @return A named list with `ForAll`, `MoleculeNamesToInclude`, and
#'   `MoleculeNamesToExclude` for the arguments supplied (an empty named
#'   list when all are `NULL`).
#' @export
#'
#' @examples
#' create_molecule_list(for_all = FALSE, include = "Drug")
#'
#' # Multiple names and an exclusion
#' create_molecule_list(include = c("Drug", "Metabolite"), exclude = "Water")
create_molecule_list <- function(
  for_all = NULL,
  include = NULL,
  exclude = NULL
) {
  data <- empty_named_list()

  if (!is.null(for_all)) {
    if (!is.logical(for_all) || length(for_all) != 1 || is.na(for_all)) {
      cli::cli_abort("{.arg for_all} must be a single {.cls logical} value")
    }
    data$ForAll <- for_all
  }
  if (!is.null(include)) {
    if (!is.character(include)) {
      cli::cli_abort("{.arg include} must be a character vector")
    }
    data$MoleculeNamesToInclude <- as.list(include)
  }
  if (!is.null(exclude)) {
    if (!is.character(exclude)) {
      cli::cli_abort("{.arg exclude} must be a character vector")
    }
    data$MoleculeNamesToExclude <- as.list(exclude)
  }

  data
}
