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

#' S3 print method for individual collections
#'
#' @param x An individual collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the individual collection
#' @export
print.individual_collection <- function(x, ...) {
  cli::cli_h1("Individuals ({length(x)})")

  if (length(x) > 0) {
    # Create a simple bullet point list with just the names
    for (name in names(x)) {
      cli::cli_li("{name}")
    }
  } else {
    cli::cli_alert_info("No individuals found")
  }
  invisible(x)
}

#' Print method for parameter collections
#'
#' @param x A parameter_collection object
#' @param ... Additional arguments passed to print methods
#'
#' @return Invisibly returns the object
#'
#' @export
print.parameter_collection <- function(x, ...) {
  if (length(x) == 0) {
    cat("Empty Parameter Collection\n")
    return(invisible(x))
  }

  cat(
    "Parameter Collection with",
    length(x),
    "parameters:\n"
  )

  # Create a summary table
  cat(sprintf("%-40s | %-15s | %s\n", "Path", "Value", "Unit"))
  cat(sprintf(
    "%-40s-|-%-15s-|-%s\n",
    paste(rep("-", 40), collapse = ""),
    paste(rep("-", 15), collapse = ""),
    paste(rep("-", 15), collapse = "")
  ))

  for (param in x) {
    # Truncate long paths for display
    disp_path <- param$path
    if (nchar(disp_path) > 40) {
      disp_path <- paste0(
        "...",
        substr(disp_path, nchar(disp_path) - 36, nchar(disp_path))
      )
    }

    # Handle NULL units
    unit_display <- if (is.null(param$unit)) "" else param$unit

    cat(sprintf(
      "%-40s | %-15s | %s\n",
      disp_path,
      format(param$value, digits = 4),
      unit_display
    ))
  }

  invisible(x)
}
