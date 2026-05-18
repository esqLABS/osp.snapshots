#' Observer class for OSP snapshot observer sets
#'
#' @description
#' An R6 class that represents a single observer inside an [ObserverSet].
#' An observer is a simulation-time formula that computes a derived
#' quantity from the underlying model (for example an amount observer or
#' a container observer), used to expose values that are not natural
#' model outputs.
#'
#' In an OSP snapshot, each observer is one entry of the `Observers`
#' array nested inside an `ObserverSets` building block. An observer is
#' not itself a building block; it lives inside an `ObserverSet`.
#'
#' @importFrom R6 R6Class
#'
#' @export
#' @examples
#' observer <- Observer$new(list(
#'   Name = "brain_plasma_conc",
#'   Type = "Container",
#'   Dimension = "Concentration (molar)",
#'   Formula = list(Formula = "Conc_Br")
#' ))
#' observer$name
#' observer$type
#' observer$dimension
Observer <- R6::R6Class(
  classname = "Observer",
  public = list(
    #' @description
    #' Create a new Observer object.
    #' @param data Raw `Observer` list from a snapshot. May be `NULL` or
    #'   an empty list, both of which create an empty observer.
    #' @return A new Observer object
    initialize = function(data = list()) {
      if (is.null(data)) {
        data <- list()
      }
      private$.data <- data
    },

    #' @description
    #' Print a short summary of the observer.
    #' @param ... Additional arguments (unused).
    #' @return Invisibly returns the Observer object.
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h3("Observer: {self$name %||% '(unnamed)'}")
        if (!is.null(self$type)) {
          cli::cli_li("Type: {self$type}")
        }
        if (!is.null(self$dimension)) {
          cli::cli_li("Dimension: {self$dimension}")
        }
        if (!is.null(self$formula)) {
          cli::cli_li("Formula: {self$formula}")
        }
        if (!is.null(self$container_tags)) {
          cli::cli_li("Container tags: {self$container_tags}")
        }
      })
      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert the observer to a single-row tibble suitable for the
    #' tibble-layer exporter. Columns are `name`, `type`, `dimension`,
    #' `formula`, and `container_tags`.
    #' @return A tibble with one row.
    to_df = function() {
      tibble::tibble(
        name = self$name %||% NA_character_,
        type = self$type %||% NA_character_,
        dimension = self$dimension %||% NA_character_,
        formula = self$formula %||% NA_character_,
        container_tags = self$container_tags %||% NA_character_
      )
    }
  ),
  active = list(
    #' @field data The raw `Observer` list as it appears in the snapshot
    #'   JSON (read-only).
    data = function(value) {
      if (!missing(value)) {
        cli::cli_abort("data is read-only")
      }
      private$.data
    },

    #' @field name The name of the observer.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field type The observer type. PK-Sim recognises `"Amount"`
    #'   (an `AmountObserverBuilder`) and `"Container"` (a
    #'   `ContainerObserverBuilder`).
    type = function(value) {
      if (missing(value)) {
        return(private$.data$Type)
      }
      private$.data$Type <- value
    },

    #' @field dimension The dimension of the observed quantity, resolved
    #'   in PK-Sim via `IDimensionRepository.DimensionByName()`.
    dimension = function(value) {
      if (missing(value)) {
        return(private$.data$Dimension)
      }
      private$.data$Dimension <- value
    },

    #' @field formula The formula expression string. Read from the inner
    #'   `Formula$Formula` field of the underlying `ExplicitFormula`
    #'   object; this binding does not expose `References` or `Dimension`.
    #'   Setting this field writes back to `Formula$Formula` only. To
    #'   access the full `ExplicitFormula`, use `observer$data$Formula`.
    formula = function(value) {
      if (missing(value)) {
        return(private$.data$Formula$Formula)
      }
      if (is.null(private$.data$Formula)) {
        private$.data$Formula <- list()
      }
      private$.data$Formula$Formula <- value
    },

    #' @field container_tags The `Tag` values from the observer's
    #'   `ContainerCriteria`, joined with `|`. There is no `ContainerPath`
    #'   field in the snapshot JSON; this binding is synthesized from the
    #'   tags found in `ContainerCriteria`. `NULL` when the observer
    #'   carries no container criteria.
    container_tags = function(value) {
      if (!missing(value)) {
        cli::cli_abort("container_tags is read-only")
      }
      criteria <- private$.data$ContainerCriteria
      if (is.null(criteria) || length(criteria) == 0) {
        return(NULL)
      }
      tags <- vapply(
        criteria,
        function(c) c$Tag %||% NA_character_,
        character(1)
      )
      tags <- tags[!is.na(tags)]
      if (length(tags) == 0) {
        return(NULL)
      }
      paste(tags, collapse = "|")
    }
  ),
  private = list(
    .data = NULL
  )
)

# Internal: build a flat named list of `Observer` objects from a raw
# `Observer[]` list. Duplicate names are disambiguated with the standard
# `_{n}` suffix used elsewhere in the package.
build_observers_from_raw <- function(raw_observers) {
  raw_observers <- raw_observers %||% list()
  if (length(raw_observers) == 0) {
    return(list())
  }

  observers <- lapply(raw_observers, function(d) Observer$new(d))

  keys <- vapply(
    observers,
    function(o) o$name %||% "Observer",
    character(1)
  )

  names(observers) <- disambiguate_names(keys)
  observers
}
