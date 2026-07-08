#' CompoundGroupSelection class for compound alternative selections
#'
#' @description
#' An R6 class representing one entry in a [CompoundProperties]'s
#' `Alternatives` array. Each entry pairs an alternative group (e.g.
#' `"COMPOUND_SOLUBILITY"`) with the selected alternative within that
#' group.
#'
#' @importFrom R6 R6Class
#' @export
CompoundGroupSelection <- R6::R6Class(
  classname = "CompoundGroupSelection",
  public = list(
    #' @description
    #' Create a new CompoundGroupSelection object.
    #' @param data Raw `CompoundGroupSelection` data from a snapshot.
    #' @return A new CompoundGroupSelection object.
    initialize = function(data) {
      private$.data <- data
    }
  ),
  active = list(
    #' @field data The raw data of the selection (read-only).
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field group_name The alternative group name. Writable: must be a
    #'   non-empty scalar string.
    group_name = function(value) {
      if (missing(value)) {
        return(private$.data$GroupName)
      }
      check_required_string(value, "group_name")
      private$.data$GroupName <- value
    },

    #' @field alternative_name The selected alternative name in the group.
    #'   Writable: must be a non-empty scalar string.
    alternative_name = function(value) {
      if (missing(value)) {
        return(private$.data$AlternativeName)
      }
      check_required_string(value, "alternative_name")
      private$.data$AlternativeName <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
