# Helper functions for test fixtures
# Following best practices from: https://testthat.r-lib.org/articles/test-fixtures.html

#' Create a temporary snapshot file from data
#'
#' Creates a temporary file with snapshot data that will be automatically cleaned up
#' when the test or function finishes.
#'
#' @param data A list representing the snapshot data
#' @param env The environment in which to register the cleanup, defaults to parent.frame()
#' @return Path to the temporary file
local_snapshot_file <- function(data, env = parent.frame()) {
    # Create temp file with automatic cleanup using withr
    temp_file <- withr::local_tempfile(fileext = ".json", .local_envir = env)

    # Convert data to JSON and write to file
    json_data <- jsonlite::toJSON(data, auto_unbox = TRUE, pretty = TRUE)
    writeLines(json_data, temp_file)

    # Return the path to the temp file
    return(temp_file)
}

#' Create a temporary snapshot with specific data
#'
#' Creates a Snapshot object from provided data that will be automatically
#' cleaned up when the test or function finishes.
#'
#' @param data A list representing the snapshot data
#' @param env The environment in which to register the cleanup, defaults to parent.frame()
#' @return A Snapshot object
local_snapshot <- function(data = list(Version = 80), env = parent.frame()) {
    # Create a snapshot from the provided data
    snapshot <- Snapshot$new(data)

    # Return the snapshot (no cleanup needed for in-memory objects)
    return(snapshot)
}

#' Enhanced version of skip_if_offline that uses withr
#'
#' Skips a test if there is no internet connection available.
#' This version properly handles connection cleanup using withr.
#'
#' @param host The host to check, defaults to "www.r-project.org"
#' @return Invisible NULL if connection is available, otherwise skips the test
skip_if_offline <- function(host = "www.r-project.org") {
    has_connection <- tryCatch(
        {
            # Use withr to ensure connection is properly closed even on error
            withr::with_connection(
                con <- url(glue::glue("https://{host}")),
                {
                    open(con)
                    TRUE
                }
            )
        },
        error = function(e) FALSE
    )

    if (!has_connection) {
        testthat::skip("No internet connection available")
    }

    invisible(NULL)
}
