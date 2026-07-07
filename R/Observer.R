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
#'   Formula = list(
#'     Name = "brain_plasma_conc_formula",
#'     Formula = "Conc_Br",
#'     Dimension = "Concentration (molar)",
#'     References = list(list(
#'       Alias = "Conc_Br",
#'       Path = "Organism|Brain|Plasma|Drug|Concentration",
#'       Dimension = "Concentration (molar)"
#'     ))
#'   )
#' ))
#' observer$name
#' observer$type
#' observer$formula_expression
#' observer$formula_dimension
#' observer$formula_references
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
        if (!is.null(self$formula_expression)) {
          cli::cli_li("Formula expression: {self$formula_expression}")
        }
        if (!is.null(self$formula_dimension)) {
          cli::cli_li("Formula dimension: {self$formula_dimension}")
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
    #' `formula_expression`, `formula_dimension`, `formula_references`,
    #' and `container_tags`. `formula_references` collapses each
    #' `FormulaUsablePath` entry (`Alias`, `Path`, `Dimension`) to
    #' `"alias=path"` and joins entries with `|`; `NA` when the observer
    #' carries no references.
    #' @return A tibble with one row.
    to_df = function() {
      tibble::tibble(
        name = self$name %||% NA_character_,
        type = self$type %||% NA_character_,
        dimension = self$dimension %||% NA_character_,
        formula_expression = self$formula_expression %||% NA_character_,
        formula_dimension = self$formula_dimension %||% NA_character_,
        formula_references = format_formula_references(
          self$formula_references
        ),
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
    #'   `ContainerObserverBuilder`). On assignment, a non-`NULL` value is
    #'   validated against these two; assigning `NULL` removes the type.
    type = function(value) {
      if (missing(value)) {
        return(private$.data$Type)
      }
      if (!is.null(value) && !(value %in% VALID_OBSERVER_TYPES)) {
        cli::cli_abort(
          "{.arg type} must be one of {.val {VALID_OBSERVER_TYPES}}"
        )
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

    #' @field formula The full `ExplicitFormula` object backing the
    #'   observer, as a list with `Name`, `Formula` (the expression
    #'   string), `Dimension`, and `References` (a list of
    #'   `FormulaUsablePath` entries, each with `Alias`, `Path`, and
    #'   `Dimension`). `NULL` when the observer carries no formula.
    #'   Setting this field replaces the whole structure; pass `NULL` to
    #'   drop it. For the inner expression string or dimension only, use
    #'   `formula_expression` or `formula_dimension`.
    formula = function(value) {
      if (missing(value)) {
        return(private$.data$Formula)
      }
      private$.data$Formula <- value
    },

    #' @field formula_expression The expression string of the underlying
    #'   `ExplicitFormula` (`Formula$Formula` in the snapshot JSON).
    #'   Setting writes back to the inner `Formula$Formula` field and
    #'   preserves the sibling `Name`, `Dimension`, and `References`
    #'   entries. To build a complete `ExplicitFormula` (including
    #'   `Name` and `References`), assign to `formula` instead.
    formula_expression = function(value) {
      if (missing(value)) {
        return(private$.data$Formula$Formula)
      }
      if (is.null(private$.data$Formula)) {
        private$.data$Formula <- list()
      }
      private$.data$Formula$Formula <- value
    },

    #' @field formula_dimension The output dimension of the underlying
    #'   `ExplicitFormula` (`Formula$Dimension` in the snapshot JSON),
    #'   resolved in PK-Sim via `IDimensionRepository.DimensionByName()`.
    #'   Setting writes back to the inner `Formula$Dimension` field.
    formula_dimension = function(value) {
      if (missing(value)) {
        return(private$.data$Formula$Dimension)
      }
      if (is.null(private$.data$Formula)) {
        private$.data$Formula <- list()
      }
      private$.data$Formula$Dimension <- value
    },

    #' @field formula_references The `References` list of the underlying
    #'   `ExplicitFormula`, where each entry is a named list with
    #'   `Alias`, `Path`, and `Dimension`. Assign a list of
    #'   `create_formula_reference()` outputs (or raw `{Alias, Path,
    #'   Dimension}` lists) to replace it, preserving the sibling
    #'   `Formula$Name`, `Formula$Formula`, and `Formula$Dimension`
    #'   (the `Formula` is created if absent). Assign `NULL` to remove the
    #'   references; when no `Formula` exists this is a no-op that does not
    #'   create an empty `Formula`.
    formula_references = function(value) {
      if (missing(value)) {
        return(private$.data$Formula$References)
      }
      if (is.null(value)) {
        if (!is.null(private$.data$Formula)) {
          private$.data$Formula$References <- NULL
        }
        return(invisible(self))
      }
      # Validate/convert before mutating so a failed assignment is a
      # no-op (atomic), mirroring `container_criteria`/`molecule_list`.
      references <- to_raw_list_entries(value, "formula_references")
      if (is.null(private$.data$Formula)) {
        private$.data$Formula <- list()
      }
      private$.data$Formula$References <- references
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
    },

    #' @field container_criteria The full `ContainerCriteria` list, each
    #'   entry a named list with `Tag` and (optionally) `Type`. Unlike
    #'   `container_tags`, this preserves each condition's `Type` verbatim
    #'   (including non-enum values such as `"MatchTag"`). Assign a list of
    #'   `create_descriptor_condition()` outputs (or raw `{Tag, Type}`
    #'   lists) to replace it; assign `NULL` to remove it.
    container_criteria = function(value) {
      if (missing(value)) {
        return(private$.data$ContainerCriteria)
      }
      if (is.null(value)) {
        private$.data$ContainerCriteria <- NULL
        return(invisible(self))
      }
      private$.data$ContainerCriteria <- to_raw_list_entries(
        value,
        "container_criteria"
      )
    },

    #' @field molecule_list The full `MoleculeList` object (`ForAll`,
    #'   `MoleculeNamesToInclude`, `MoleculeNamesToExclude`) or `NULL`.
    #'   Assign a `create_molecule_list()` output (or an equivalent raw
    #'   list) to replace it; assign `NULL` to remove it.
    molecule_list = function(value) {
      if (missing(value)) {
        return(private$.data$MoleculeList)
      }
      if (is.null(value)) {
        private$.data$MoleculeList <- NULL
        return(invisible(self))
      }
      if (!is.list(value) || is.object(value)) {
        cli::cli_abort("{.arg molecule_list} must be a list")
      }
      private$.data$MoleculeList <- value
    }
  ),
  private = list(
    .data = NULL
  )
)

# Internal: collapse a `References` list (each entry an `Alias`/`Path`
# /`Dimension` triple) into a single string of `"alias=path"` pairs joined
# with `|`. Returns `NA_character_` for empty or `NULL` input so the
# Observer tibble layer can use it as a column value.
format_formula_references <- function(references) {
  if (is.null(references) || length(references) == 0) {
    return(NA_character_)
  }
  parts <- vapply(
    references,
    function(ref) {
      alias <- ref$Alias %||% ""
      path <- ref$Path %||% ""
      paste0(alias, "=", path)
    },
    character(1)
  )
  paste(parts, collapse = "|")
}

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
