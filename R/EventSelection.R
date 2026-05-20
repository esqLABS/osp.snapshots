#' EventSelection class for Simulation event references
#'
#' @description
#' An R6 class representing one entry in a [Simulation]'s `Events` array.
#' Resolves to an [Event] building block by name and carries the
#' simulation-local `StartTime` [Parameter] used by the event.
#'
#' @importFrom R6 R6Class
#' @export
EventSelection <- R6::R6Class(
  classname = "EventSelection",
  public = list(
    #' @description
    #' Create a new EventSelection object.
    #' @param data Raw `EventSelection` data from a snapshot.
    #' @return A new EventSelection object.
    initialize = function(data) {
      private$.data <- data
      if (!is.null(data$StartTime)) {
        private$.start_time <- Parameter$new(data$StartTime)
      }
    }
  ),
  active = list(
    #' @field data The raw data of the selection (read-only). Rebuilt from
    #'   the cached [Parameter] so that mutations on `$start_time` flow back
    #'   to the export payload.
    data = function(value) {
      if (missing(value)) {
        result <- private$.data
        if (!is.null(private$.start_time)) {
          result$StartTime <- private$.start_time$data
        }
        return(result)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the event building block.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field start_time The [Parameter] used as start time for the event.
    start_time = function(value) {
      if (missing(value)) {
        return(private$.start_time)
      }
      if (is.null(value)) {
        private$.start_time <- NULL
        private$.data$StartTime <- NULL
      } else if (inherits(value, "Parameter")) {
        private$.start_time <- value
      } else if (is.list(value)) {
        private$.start_time <- Parameter$new(value)
      } else {
        cli::cli_abort(
          "{.field start_time} must be a {.cls Parameter} or a raw list"
        )
      }
    }
  ),
  private = list(
    .data = NULL,
    .start_time = NULL,
    deep_clone = function(name, value) {
      if (name == ".start_time" && inherits(value, "R6")) {
        return(value$clone(deep = TRUE))
      }
      value
    }
  )
)
