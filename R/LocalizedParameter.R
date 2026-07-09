#' LocalizedParameter class for path-bearing OSP snapshot parameters
#'
#' @description
#' An R6 class that represents a Localized parameter in an OSP snapshot. A
#' Localized parameter is a [Parameter] identified by its full path within a
#' target's parameter tree (typically a Simulation or Individual). The path
#' locates where the override applies.
#'
#' `LocalizedParameter` inherits from [Parameter]; everything that works on a
#' `Parameter` also works on a `LocalizedParameter`. The only addition is a
#' required `path` field, populated from the `Path` element of the raw data.
#'
#' # Snapshot version assumption
#'
#' `osp.snapshots` only supports v11+ snapshots (numeric `Version` >= 79); the
#' check is enforced by `Snapshot$new()` at load time. In v11+ snapshots,
#' path segments named `Applications` are migrated to `Events`. The migration
#' runs in `initialize()`; for v11+ data it is a no-op because PK-Sim already
#' uses `Events`, and the constructor itself does not re-check the version.
#'
#' # Legacy `Name` fallback
#'
#' A v11+ snapshot's localized parameter always carries `Path`. As a
#' convenience for hand-rolled data, `initialize()` falls back to `data$Name`
#' when `data$Path` is missing and emits a deprecation warning so the
#' substitution is not silent; the resulting object stores the value in
#' `data$Path` and drops `data$Name`. Real snapshots never trigger this
#' branch.
#'
#' @importFrom R6 R6Class
#'
#' @export
LocalizedParameter <- R6::R6Class(
  classname = "LocalizedParameter",
  inherit = Parameter,
  public = list(
    #' @description
    #' Create a new LocalizedParameter object.
    #'
    #' Requires a non-empty path supplied through `data$Path`. If `data$Path`
    #' is missing but `data$Name` is present, the name is used as the path
    #' and a deprecation warning is emitted; `data$Name` is then cleared so
    #' the resulting raw shape is unambiguous. Path segments named
    #' `Applications` are rewritten to `Events` (legacy migration kept for
    #' robustness; no-op on v11+ data).
    #'
    #' @param data Raw parameter data from a snapshot. Must contain a `Path`.
    #' @return A new LocalizedParameter object.
    initialize = function(data) {
      path <- data$Path
      used_name_fallback <- FALSE
      if (is.null(path)) {
        path <- data$Name
        used_name_fallback <- !is.null(path)
      }
      # This shape check intentionally omits the character-class clause of
      # `is_non_empty_scalar_string()`: a non-character scalar that is
      # length-one, not `NA`, and passes `nzchar()` is accepted here, so it is
      # kept inlined rather than routed through the shared predicate.
      if (
        is.null(path) ||
          length(path) != 1 ||
          is.na(path) ||
          !nzchar(path)
      ) {
        cli::cli_abort(
          "{.cls LocalizedParameter} requires a single non-empty {.field path}."
        )
      }
      if (used_name_fallback) {
        cli::cli_warn(
          c(
            "Using {.field Name} as a path is deprecated for {.cls LocalizedParameter}.",
            i = "Supply {.field Path} instead. {.field Name} will be dropped from the data."
          ),
          .frequency = "regularly",
          .frequency_id = "localized_parameter_name_fallback"
        )
        data$Name <- NULL
      }
      data$Path <- migrate_applications_to_events(path)
      super$initialize(data)
    }
  )
)

# Rewrite `Applications` path segments to `Events`. Kept as a defensive
# normalisation: real v11+ snapshots already use `Events`, so the migration
# is a no-op there. Snapshot$new() refuses pre-v11 snapshots, so this only
# fires on hand-rolled data carrying legacy paths.
#
# Operates on the pipe-separated segments so we never touch substrings that
# merely contain the word "Applications". Uses `%in%` rather than `==` so that
# any unexpected NA segment is left untouched instead of silently corrupting
# the whole path (because `x[NA] <- value` assigns to every element in R).
migrate_applications_to_events <- function(path) {
  segments <- strsplit(path, "|", fixed = TRUE)[[1]]
  segments[segments %in% "Applications"] <- "Events"
  paste(segments, collapse = "|")
}
