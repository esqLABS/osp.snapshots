#' OutputSchema class for Simulation output schedules
#'
#' @description
#' An R6 class representing the `OutputSchema` field of a [Simulation], a
#' collection of [OutputInterval]s. The raw JSON shape is a bare array of
#' intervals (no enclosing object); the `intervals` active binding
#' exposes the wrapped list directly.
#'
#' @importFrom R6 R6Class
#' @export
OutputSchema <- R6::R6Class(
  classname = "OutputSchema",
  public = list(
    #' @description
    #' Create a new OutputSchema object.
    #' @param data Raw `OutputSchema` data from a snapshot. May be a bare
    #'   list of interval named lists or `NULL` for an empty schema.
    #' @return A new OutputSchema object.
    initialize = function(data) {
      raw <- data %||% list()
      private$.intervals <- lapply(raw, function(d) OutputInterval$new(d))
    }
  ),
  active = list(
    #' @field data The raw data of the schema (read-only). Rebuilt from
    #'   the cached [OutputInterval] list so that mutations flow back to
    #'   the export payload. Returns a bare list of interval named lists.
    data = function(value) {
      if (missing(value)) {
        intervals <- lapply(private$.intervals, function(i) i$data)
        names(intervals) <- NULL
        return(intervals)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field intervals List of [OutputInterval] objects.
    intervals = function(value) {
      if (missing(value)) {
        return(private$.intervals)
      }
      if (is.null(value)) {
        private$.intervals <- list()
      } else if (is.list(value)) {
        private$.intervals <- value
      } else {
        cli::cli_abort("{.field intervals} must be a list")
      }
    }
  ),
  private = list(
    .intervals = NULL,
    deep_clone = function(name, value) {
      if (name == ".intervals" && is.list(value)) {
        return(lapply(value, function(i) {
          if (inherits(i, "R6")) i$clone(deep = TRUE) else i
        }))
      }
      value
    }
  )
)
