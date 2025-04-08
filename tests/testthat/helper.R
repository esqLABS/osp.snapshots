test_snapshot_path <- test_path("data", "test_snapshot.json")
test_snapshot <- Snapshot$new(test_snapshot_path)

# Create a minimal snapshot data for tests that need a simple snapshot
minimal_snapshot_data <- list(
    Version = 80,
    Compounds = NULL,
    Individuals = NULL
)

# Create a reusable minimal snapshot object
minimal_snapshot <- Snapshot$new(minimal_snapshot_data)

# Helper function to skip tests when no internet connection is available
skip_if_offline <- function() {
    has_connection <- tryCatch(
        {
            con <- url("https://www.r-project.org")
            open(con)
            close(con)
            TRUE
        },
        error = function(e) FALSE
    )

    if (!has_connection) {
        testthat::skip("No internet connection available")
    }
}
