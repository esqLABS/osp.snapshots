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

#' S3 print method for population collections
#'
#' @param x A population collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the population collection
#' @export
print.population_collection <- function(x, ...) {
  cli::cli_h1("Populations ({length(x)})")

  if (length(x) > 0) {
    # Create a simple bullet point list with name and number of individuals
    for (name in names(x)) {
      n_individuals <- x[[name]]$number_of_individuals
      source_text <- if (!is.null(x[[name]]$source_population))
        glue::glue(" [Source: {x[[name]]$source_population}]") else ""
      cli::cli_li("{name}{source_text} ({n_individuals} individuals)")
    }
  } else {
    cli::cli_alert_info("No populations found")
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
    glue::glue_collapse(rep("-", 40)),
    glue::glue_collapse(rep("-", 15)),
    glue::glue_collapse(rep("-", 15))
  ))

  for (param in x) {
    # Truncate long paths for display
    disp_name <- param$name
    if (nchar(disp_name) > 40) {
      disp_name <- glue::glue(
        "...{substr(disp_name, nchar(disp_name) - 36, nchar(disp_name))}"
      )
    }

    # Handle NULL units
    unit_display <- if (is.null(param$unit)) "" else param$unit

    cat(sprintf(
      "%-40s | %-15s | %s\n",
      disp_name,
      if (!is.null(param$table_formula)) "Table" else
        format(param$value, digits = 4),
      unit_display
    ))
  }

  invisible(x)
}
