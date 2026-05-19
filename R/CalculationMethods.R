#' CalculationMethods class for OSP snapshots
#'
#' @description
#' An R6 class that wraps the set of calculation methods PK-Sim uses to derive
#' compound quantities (e.g. partition coefficient method, cellular
#' permeability method, body surface area method). In an OSP snapshot, the
#' calculation methods are serialised as an array of method name strings. They
#' appear in two places: directly on a [Compound] and inside an [OriginData]
#' of an [Individual].
#'
#' @importFrom R6 R6Class
#'
#' @export
CalculationMethods <- R6::R6Class(
  classname = "CalculationMethods",
  public = list(
    #' @description
    #' Create a new CalculationMethods object
    #' @param names Character vector of method names. May be `NULL` or an
    #'   empty vector, both of which result in an empty set.
    #' @return A new CalculationMethods object
    initialize = function(names = character()) {
      private$.names <- private$.coerce(names)
    },

    #' @description
    #' Print a summary of the calculation methods
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the CalculationMethods object
    print = function(...) {
      output <- cli::cli_format_method({
        if (length(private$.names) == 0) {
          cli::cli_text("CalculationMethods: (empty)")
        } else {
          cli::cli_text(
            "CalculationMethods ({length(private$.names)} method{?s})"
          )
          for (name in private$.names) {
            cli::cli_li("{name}")
          }
        }
      })
      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Add a method name. Duplicates are kept to mirror the snapshot's raw
    #' representation.
    #' @param name Character. Name of the calculation method to add.
    #' @return Invisibly returns the CalculationMethods object
    add = function(name) {
      if (!is.character(name) || length(name) != 1 || is.na(name)) {
        cli::cli_abort("`name` must be a single non-missing character string")
      }
      private$.names <- c(private$.names, name)
      invisible(self)
    },

    #' @description
    #' Remove a method name. If `name` is not present, the set is unchanged.
    #' Note the asymmetry with `$add()`: `$add()` keeps duplicates to mirror
    #' the snapshot's raw representation, whereas `$remove()` deletes every
    #' occurrence of `name` in a single call.
    #' @param name Character. Name of the calculation method to remove.
    #' @return Invisibly returns the CalculationMethods object
    remove = function(name) {
      if (!is.character(name) || length(name) != 1 || is.na(name)) {
        cli::cli_abort("`name` must be a single non-missing character string")
      }
      private$.names <- private$.names[private$.names != name]
      invisible(self)
    },

    #' @description
    #' Convert back to the raw snapshot representation: a list of method-name
    #' strings, or `NULL` when empty. A list is used (rather than a character
    #' vector) so that single-method sets round-trip as JSON arrays.
    #' @return A list of method-name strings, or `NULL` when empty.
    to_list = function() {
      if (length(private$.names) == 0) {
        return(NULL)
      }
      as.list(private$.names)
    }
  ),
  active = list(
    #' @field names Character vector of method names.
    names = function(value) {
      if (missing(value)) {
        return(private$.names)
      }
      private$.names <- private$.coerce(value)
    },

    #' @field length Number of methods currently held (read-only).
    length = function() {
      length(private$.names)
    }
  ),
  private = list(
    .names = character(),
    .coerce = function(value) {
      if (is.null(value)) {
        return(character())
      }
      if (is.list(value)) {
        value <- unlist(value, use.names = FALSE)
      }
      if (length(value) == 0) {
        return(character())
      }
      if (!is.character(value)) {
        cli::cli_abort(
          "Method names must be a character vector, not {.cls {class(value)[1]}}"
        )
      }
      if (anyNA(value)) {
        cli::cli_abort("Method names must not be `NA`")
      }
      value
    }
  )
)

#' @export
length.CalculationMethods <- function(x) {
  x$length
}
