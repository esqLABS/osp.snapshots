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

#' S3 print method for formulation collections
#'
#' @param x A formulation collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the formulation collection
#' @export
print.formulation_collection <- function(x, ...) {
  cli::cli_h1("Formulations ({length(x)})")

  if (length(x) > 0) {
    # Create a bullet point list with names and formulation types
    for (name in names(x)) {
      formulation_type_human <- x[[name]]$get_human_formulation_type()
      cli::cli_li("{name} ({formulation_type_human})")
    }
  } else {
    cli::cli_alert_info("No formulations found")
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
  cat(sprintf("%-40s | %-15s | %s\n", "Name", "Value", "Unit"))
  cat(sprintf(
    "%-40s-|-%-15s-|-%s\n",
    paste(rep("-", 40), collapse = ""),
    paste(rep("-", 15), collapse = ""),
    paste(rep("-", 15), collapse = "")
  ))

  for (param in x) {
    # Truncate long paths for display
    disp_name <- param$name
    if (nchar(disp_name) > 40) {
      disp_name <- paste0(
        "...",
        substr(disp_name, nchar(disp_name) - 36, nchar(disp_name))
      )
    }

    # Handle NULL units
    unit_display <- if (is.null(param$unit)) "" else param$unit

    cat(sprintf(
      "%-40s | %-15s | %s\n",
      disp_name,
      format(param$value, digits = 4),
      unit_display
    ))
  }

  invisible(x)
}

#' Print method for formulation parameter collections
#'
#' @param x A formulation_parameter_collection object
#' @param ... Additional arguments passed to print methods
#'
#' @return Invisibly returns the object
#'
#' @export
print.formulation_parameter_collection <- function(x, ...) {
  if (length(x) == 0) {
    cat("Empty Formulation Parameter Collection\n")
    return(invisible(x))
  }

  cat(
    "Formulation Parameter Collection with",
    length(x),
    "parameters:\n"
  )

  # Create a summary table
  cat(sprintf("%-40s | %-15s | %s\n", "Name", "Value", "Unit"))
  cat(sprintf(
    "%-40s-|-%-15s-|-%s\n",
    paste(rep("-", 40), collapse = ""),
    paste(rep("-", 15), collapse = ""),
    paste(rep("-", 15), collapse = "")
  ))

  for (param in x) {
    # Truncate long names for display
    disp_name <- param$Name
    if (nchar(disp_name) > 40) {
      disp_name <- paste0(
        "...",
        substr(disp_name, nchar(disp_name) - 36, nchar(disp_name))
      )
    }

    # Handle NULL units
    unit_display <- if (is.null(param$Unit)) "" else param$Unit

    cat(sprintf(
      "%-40s | %-15s | %s\n",
      disp_name,
      format(param$Value, digits = 4),
      unit_display
    ))
  }

  invisible(x)
}
