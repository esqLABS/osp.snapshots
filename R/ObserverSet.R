#' ObserverSet class for OSP snapshot observer sets
#'
#' @description
#' An R6 class that represents an `ObserverSet` building block in an OSP
#' snapshot. An `ObserverSet` is a named bundle of [Observer] objects
#' that simulations can reference by name.
#'
#' @importFrom R6 R6Class
#'
#' @export
ObserverSet <- R6::R6Class(
  classname = "ObserverSet",
  public = list(
    #' @description
    #' Create a new ObserverSet object
    #' @param data Raw observer set data from a snapshot
    #' @return A new ObserverSet object
    initialize = function(data) {
      private$.data <- data
      private$initialize_observers()
    },

    #' @description
    #' Print a summary of the observer set
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h1("ObserverSet: {self$name}")
        n_observers <- length(self$observers)
        plural <- if (n_observers == 1) "observer" else "observers"
        cli::cli_li("{n_observers} {plural}")
      })

      cat(output, sep = "\n")
      invisible(self)
    }
  ),
  active = list(
    #' @field data The raw data of the observer set, refreshed from the
    #'   wrapped [Observer] objects so mutations through the R6 surface
    #'   flow back into the snapshot payload (read-only).
    data = function(value) {
      if (!missing(value)) {
        cli::cli_abort("data is read-only")
      }
      result <- private$.data
      if (length(private$.observers) > 0) {
        result$Observers <- unname(lapply(
          private$.observers,
          function(observer) observer$data
        ))
      } else if (is.null(private$.data$Observers)) {
        result$Observers <- NULL
      } else {
        result$Observers <- list()
      }
      result
    },

    #' @field name The name of the observer set. Writable: must be a
    #'   non-empty scalar string.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      check_required_string(value, "name")
      private$.data$Name <- value
    },

    #' @field observers A named list of [Observer] objects keyed by
    #'   each observer's `$name`. Duplicate names are disambiguated with
    #'   `_{n}` suffixes. Assigning accepts either a list of [Observer]
    #'   objects or a list of raw observer dicts; both are normalised to
    #'   [Observer] objects and the underlying raw data is kept in sync.
    observers = function(value) {
      if (missing(value)) {
        return(private$.observers)
      }
      if (is.null(value)) {
        private$.observers <- list()
        private$.data$Observers <- list()
        return(invisible(private$.observers))
      }
      if (!is.list(value)) {
        cli::cli_abort(
          "{.field observers} must be a list of Observer objects or raw lists"
        )
      }
      observers <- lapply(value, function(v) {
        if (inherits(v, "Observer")) {
          v
        } else if (is.list(v)) {
          Observer$new(v)
        } else {
          cli::cli_abort(
            "Every entry of {.field observers} must be an {.cls Observer} or a list"
          )
        }
      })
      raw <- lapply(observers, function(o) o$data)
      private$.data$Observers <- raw
      private$initialize_observers()
      invisible(private$.observers)
    }
  ),
  private = list(
    .data = NULL,
    .observers = list(),
    deep_clone = function(name, value) {
      if (name == ".observers" && is.list(value)) {
        return(lapply(value, function(obs) {
          if (inherits(obs, "R6")) obs$clone(deep = TRUE) else obs
        }))
      }
      value
    },
    initialize_observers = function() {
      private$.observers <- build_observers_from_raw(
        private$.data$Observers
      )
    }
  )
)
