#' OutputInterval class for Simulation output schemas
#'
#' @description
#' An R6 class representing one entry in an [OutputSchema]'s
#' `Intervals` array. Each interval carries optional name and the three
#' [Parameter]s `Start time`, `End time`, and `Resolution`.
#'
#' @importFrom R6 R6Class
#' @export
OutputInterval <- R6::R6Class(
  classname = "OutputInterval",
  public = list(
    #' @description
    #' Create a new OutputInterval object.
    #' @param data Raw `OutputInterval` data from a snapshot.
    #' @return A new OutputInterval object.
    initialize = function(data) {
      private$.data <- data
      private$.parameters <- build_parameters_from_raw(
        private$.data$Parameters,
        key_by = "name"
      )
    }
  ),
  active = list(
    #' @field data The raw data of the interval (read-only). Rebuilt from
    #'   the cached [Parameter] list so that mutations flow back to the
    #'   export payload.
    data = function(value) {
      if (missing(value)) {
        result <- private$.data
        if (length(private$.parameters) > 0) {
          params <- lapply(private$.parameters, function(p) p$data)
          names(params) <- NULL
          result$Parameters <- params
        } else if (!is.null(private$.data$Parameters)) {
          result$Parameters <- list()
        }
        return(result)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The interval name.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field parameters Named list of [Parameter] objects, keyed by name.
    parameters = function(value) {
      if (missing(value)) {
        return(private$.parameters)
      }
      if (is.null(value)) {
        private$.parameters <- build_parameters_from_raw(
          list(),
          key_by = "name"
        )
      } else if (is.list(value)) {
        private$.parameters <- value
        if (!inherits(private$.parameters, "parameter_collection")) {
          class(private$.parameters) <- c("parameter_collection", "list")
        }
      } else {
        cli::cli_abort("{.field parameters} must be a list")
      }
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL,
    deep_clone = function(name, value) {
      if (name == ".parameters" && is.list(value)) {
        return(lapply(value, function(p) {
          if (inherits(p, "R6")) p$clone(deep = TRUE) else p
        }))
      }
      value
    }
  )
)
