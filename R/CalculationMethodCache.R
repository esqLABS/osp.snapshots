#' CalculationMethodCache class for OSP snapshots
#'
#' @description
#' An R6 class that wraps the set of calculation methods PK-Sim uses to derive
#' compound quantities (e.g. partition coefficient method, cellular
#' permeability method, body surface area method). In an OSP snapshot, the
#' calculation method cache is serialised as an array of method name strings.
#' It appears in two places: directly on a [Compound] and inside an
#' [OriginData] of an [Individual].
#'
#' @importFrom R6 R6Class
#'
#' @export
CalculationMethodCache <- R6::R6Class(
  classname = "CalculationMethodCache",
  public = list(
    #' @description
    #' Create a new CalculationMethodCache object
    #' @param methods Character vector of method names. May be `NULL` or an
    #'   empty vector, both of which result in an empty cache.
    #' @return A new CalculationMethodCache object
    initialize = function(methods = character()) {
      private$.methods <- private$.coerce(methods)
    },

    #' @description
    #' Print a summary of the calculation method cache
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the CalculationMethodCache object
    print = function(...) {
      output <- cli::cli_format_method({
        if (length(private$.methods) == 0) {
          cli::cli_text("CalculationMethodCache: (empty)")
        } else {
          cli::cli_text(
            "CalculationMethodCache ({length(private$.methods)} method{?s})"
          )
          for (method in private$.methods) {
            cli::cli_li("{method}")
          }
        }
      })
      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Add a method name to the cache. Duplicates are kept to mirror the
    #' snapshot's raw representation.
    #' @param method Character. Name of the calculation method to add.
    #' @return Invisibly returns the CalculationMethodCache object
    add = function(method) {
      if (!is.character(method) || length(method) != 1 || is.na(method)) {
        cli::cli_abort("`method` must be a single non-missing character string")
      }
      private$.methods <- c(private$.methods, method)
      invisible(self)
    },

    #' @description
    #' Remove a method name from the cache. If `method` is not present, the
    #' cache is unchanged. Note the asymmetry with `$add()`: `$add()` keeps
    #' duplicates to mirror the snapshot's raw representation, whereas
    #' `$remove()` deletes every occurrence of `method` in a single call.
    #' @param method Character. Name of the calculation method to remove.
    #' @return Invisibly returns the CalculationMethodCache object
    remove = function(method) {
      if (!is.character(method) || length(method) != 1 || is.na(method)) {
        cli::cli_abort("`method` must be a single non-missing character string")
      }
      private$.methods <- private$.methods[private$.methods != method]
      invisible(self)
    },

    #' @description
    #' Convert the cache back to its raw snapshot representation: a list of
    #' method-name strings, or `NULL` when the cache is empty. A list is used
    #' (rather than a character vector) so that single-method caches round-trip
    #' as JSON arrays.
    #' @return A list of method-name strings, or `NULL` when empty.
    to_list = function() {
      if (length(private$.methods) == 0) {
        return(NULL)
      }
      as.list(private$.methods)
    }
  ),
  active = list(
    #' @field methods Character vector of method names in the cache.
    methods = function(value) {
      if (missing(value)) {
        return(private$.methods)
      }
      private$.methods <- private$.coerce(value)
    },

    #' @field length Number of methods currently in the cache (read-only).
    length = function() {
      length(private$.methods)
    }
  ),
  private = list(
    .methods = character(),
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
length.CalculationMethodCache <- function(x) {
  x$length
}
