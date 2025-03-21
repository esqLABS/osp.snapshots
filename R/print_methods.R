#' S3 print method for compound collections
#'
#' @param x A compound collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the compound collection
#' @export
print.compound_collection <- function(x, ...) {
  cli::cli_h1("Compounds ({length(x)})")

  if (length(x) > 0) {
    # Create a simple bullet point list with just the names
    for (name in names(x)) {
      cli::cli_li("{name}")
    }
  } else {
    cli::cli_alert_info("No compounds found")
  }
  invisible(x)
}
