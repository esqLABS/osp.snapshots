#' ObserverSet class for OSP snapshot observer sets
#'
#' @description
#' An R6 class that represents an `ObserverSet` building block in an OSP
#' snapshot. An `ObserverSet` is a named bundle of observers that simulations
#' can reference by name. The class exposes the set's name and its raw
#' `Observers` list; richer wrapping of individual observers is deferred to
#' a follow-up.
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
    #' @field data The raw data of the observer set (read-only)
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the observer set
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field observers The raw list of observers in the set
    observers = function(value) {
      if (missing(value)) {
        return(private$.data$Observers %||% list())
      }
      private$.data$Observers <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
