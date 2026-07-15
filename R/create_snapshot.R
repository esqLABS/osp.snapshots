#' Create an empty snapshot
#'
#' @description
#' Create an in-memory [Snapshot] from scratch, carrying the current
#' supported PK-Sim version and no building blocks. This is the
#' snapshot-level constructor that pairs with [load_snapshot()] and
#' [export_snapshot()]: rather than loading an existing project, it starts
#' an empty one you can then populate.
#'
#' The result touches no files and has no path. Mutate it with the
#' `add_*()` verbs (for example [add_compound()]) and serialize it with
#' [export_snapshot()].
#'
#' @param name Character. Optional snapshot name. When supplied, it is
#'   written to the snapshot's `Name`; when `NULL`, no `Name` is set. An
#'   empty string `""` is written verbatim rather than treated as absent.
#' @param description Character. Optional snapshot description. Follows the
#'   same `NULL`-versus-supplied and empty-string semantics as `name`.
#'
#' @return A [Snapshot] object.
#' @seealso [load_snapshot()], [export_snapshot()]
#' @export
#'
#' @examples
#' # An empty snapshot
#' snapshot <- create_snapshot()
#'
#' # A named and described snapshot
#' snapshot <- create_snapshot(name = "My Project", description = "Notes")
#'
#' # Populate it with a building block
#' snapshot <- add_compound(create_snapshot(), create_compound(name = "Drug X"))
create_snapshot <- function(name = NULL, description = NULL) {
  if (
    !is.null(name) && (!is.character(name) || length(name) != 1 || is.na(name))
  ) {
    cli::cli_abort("{.arg name} must be a single string")
  }
  if (
    !is.null(description) &&
      (!is.character(description) ||
        length(description) != 1 ||
        is.na(description))
  ) {
    cli::cli_abort("{.arg description} must be a single string")
  }

  # Author at the highest supported version so a freshly created snapshot
  # matches the current PK-Sim format. At v81 the top-level `Name` precedes
  # `Version` in the serialized JSON, and `jsonlite::write_json()` preserves
  # list order, so build `Name` first when it is supplied.
  data <- if (!is.null(name)) {
    list(Name = name, Version = SUPPORTED_VERSION_MAX)
  } else {
    list(Version = SUPPORTED_VERSION_MAX)
  }

  if (!is.null(description)) {
    data$Description <- description
  }

  Snapshot$new(data)
}
