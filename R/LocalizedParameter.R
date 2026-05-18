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
#' required `path` field, populated from the `Path` element of the raw data
#' (and falling back to `Name` when only a name is supplied, so a
#' `LocalizedParameter` can still be created from existing schema-style data).
#'
#' In v11+ snapshots, path segments named `Applications` are migrated to
#' `Events`. The migration runs in `initialize()`, so any path read back from
#' a `LocalizedParameter` is already normalized.
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
    #' Requires a non-empty path supplied either through `data$Path` or
    #' `data$Name`. Path segments named `Applications` are rewritten to
    #' `Events` (v11+ migration).
    #'
    #' @param data Raw parameter data from a snapshot. Must contain a `Path`
    #'   (or, for legacy data, a `Name` used as the path).
    #' @return A new LocalizedParameter object.
    initialize = function(data) {
      path <- data$Path %||% data$Name
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
      data$Path <- migrate_applications_to_events(path)
      super$initialize(data)
    }
  )
)

# Rewrite `Applications` path segments to `Events` for v11+ compatibility.
# Operates on the pipe-separated segments so we never touch substrings that
# merely contain the word "Applications". Uses `%in%` rather than `==` so that
# any unexpected NA segment is left untouched instead of silently corrupting
# the whole path (because `x[NA] <- value` assigns to every element in R).
migrate_applications_to_events <- function(path) {
  segments <- strsplit(path, "|", fixed = TRUE)[[1]]
  segments[segments %in% "Applications"] <- "Events"
  paste(segments, collapse = "|")
}
