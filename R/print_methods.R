#' S3 print method for compound collections
#'
#' @param x A compound collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the compound collection
#' @export
print.compound_collection <- function(x, ...) {
  output <- cli::cli_format_method({
    cli::cli_h1("Compounds ({length(x)})")

    if (length(x) > 0) {
      # Create a simple bullet point list with just the names
      for (name in names(x)) {
        cli::cli_li("{name}")
      }
    } else {
      cli::cli_alert_info("No compounds found")
    }
  })

  cat(output, sep = "\n")
  invisible(x)
}

#' S3 print method for individual collections
#'
#' @param x An individual collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the individual collection
#' @export
print.individual_collection <- function(x, ...) {
  output <- cli::cli_format_method({
    cli::cli_h1("Individuals ({length(x)})")

    if (length(x) > 0) {
      # Create a simple bullet point list with just the names
      for (name in names(x)) {
        cli::cli_li("{name}")
      }
    } else {
      cli::cli_alert_info("No individuals found")
    }
  })

  cat(output, sep = "\n")
  invisible(x)
}

#' S3 print method for population collections
#'
#' @param x A population collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the population collection
#' @export
print.population_collection <- function(x, ...) {
  output <- cli::cli_format_method({
    cli::cli_h1("Populations ({length(x)})")

    if (length(x) > 0) {
      # Create a simple bullet point list with name and number of individuals
      for (name in names(x)) {
        n_individuals <- x[[name]]$number_of_individuals
        source_text <- if (!is.null(x[[name]]$source_population)) {
          glue::glue(" [Source: {x[[name]]$source_population}]")
        } else {
          ""
        }
        cli::cli_li("{name}{source_text} ({n_individuals} individuals)")
      }
    } else {
      cli::cli_alert_info("No populations found")
    }
  })

  cat(output, sep = "\n")
  invisible(x)
}

#' S3 print method for formulation collections
#'
#' @param x A formulation collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the formulation collection
#' @export
print.formulation_collection <- function(x, ...) {
  output <- cli::cli_format_method({
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
  })

  cat(output, sep = "\n")
  invisible(x)
}

#' S3 print method for event collections
#'
#' @param x An event collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the event collection
#' @export
print.event_collection <- function(x, ...) {
  output <- cli::cli_format_method({
    cli::cli_h1("Events ({length(x)})")

    if (length(x) > 0) {
      # Create a bullet point list with names, templates, and parameter counts
      for (name in names(x)) {
        event <- x[[name]]
        template <- event$template
        param_count <- length(event$parameters)

        if (param_count > 0) {
          cli::cli_li("{name} ({template}) - {param_count} parameter{?s}")
        } else {
          cli::cli_li("{name} ({template})")
        }
      }
    } else {
      cli::cli_alert_info("No events found")
    }
  })

  cat(output, sep = "\n")
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
      if (!is.null(param$table_formula)) {
        "Table"
      } else {
        format(param$value, digits = 4)
      },
      unit_display
    ))
  }

  invisible(x)
}

#' S3 print method for expression profile collections
#'
#' @param x An expression profile collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the expression profile collection
#' @export
print.expression_profile_collection <- function(x, ...) {
  output <- cli::cli_format_method({
    cli::cli_h1("Expression Profiles ({length(x)})")

    if (length(x) > 0) {
      # Create a bullet point list with molecule, type and species
      for (name in names(x)) {
        profile <- x[[name]]
        type <- profile$type
        species <- profile$species
        molecule <- profile$molecule
        category <- if (!is.null(profile$category)) profile$category else "N/A"

        cli::cli_li("{molecule} ({type}, {species}, {category})")
      }
    } else {
      cli::cli_alert_info("No expression profiles found")
    }
  })

  cat(output, sep = "\n")
  invisible(x)
}

#' S3 print method for protocol collections
#'
#' @param x A protocol collection object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the protocol collection
#' @export
print.protocol_collection <- function(x, ...) {
  output <- cli::cli_format_method({
    cli::cli_h1("Protocols ({length(x)})")

    if (length(x) > 0) {
      # Create a bullet point list with protocol names and types
      for (name in names(x)) {
        protocol <- x[[name]]
        if (protocol$is_advanced) {
          schema_count <- length(protocol$schemas)
          cli::cli_li("{name} (Advanced - {schema_count} schema{?s})")
        } else {
          type_text <- if (!is.null(protocol$application_type)) {
            glue::glue(" - {protocol$get_human_application_type()}")
          } else {
            ""
          }
          interval_text <- if (!is.null(protocol$dosing_interval)) {
            glue::glue(" - {protocol$get_human_dosing_interval()}")
          } else {
            ""
          }
          cli::cli_li("{name} (Simple{type_text}{interval_text})")
        }
      }
    } else {
      cli::cli_alert_info("No protocols found")
    }
  })

  cat(output, sep = "\n")
  invisible(x)
}

#' S3 print method for physicochemical properties
#'
#' @param x A physicochemical_property object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the physicochemical property
#' @export
print.physicochemical_property <- function(x, ...) {
  # Get the property name from the attribute
  property_name <- attr(x, "property_name") %||% "Physicochemical Property"

  if (length(x) == 0) {
    cli::cli_li("{property_name}: No data available")
    return(invisible(x))
  }

  # Helper function to extract value and unit from parameters
  extract_value_unit <- function(entry) {
    if (!is.null(entry$Parameters) && length(entry$Parameters) > 0) {
      # Find the main parameter (usually matches the property name)
      main_param <- NULL
      for (param in entry$Parameters) {
        if (
          !is.null(param$Name) &&
            (grepl(property_name, param$Name, ignore.case = TRUE) ||
              grepl(
                gsub(" ", "", property_name),
                param$Name,
                ignore.case = TRUE
              ))
        ) {
          main_param <- param
          break
        }
      }

      # If no main parameter found, use the first one
      if (is.null(main_param) && length(entry$Parameters) > 0) {
        main_param <- entry$Parameters[[1]]
      }

      if (!is.null(main_param)) {
        value <- main_param$Value %||% "N/A"
        unit <- main_param$Unit %||% ""
        return(
          if (unit != "") glue::glue("{value} {unit}") else as.character(value)
        )
      }
    }
    return("N/A")
  }

  # Helper function to get source information
  get_source <- function(entry) {
    if (!is.null(entry$Parameters) && length(entry$Parameters) > 0) {
      param <- entry$Parameters[[1]]
      if (!is.null(param$ValueOrigin)) {
        source <- param$ValueOrigin$Source %||% "Unknown"
        method <- param$ValueOrigin$Method %||% ""
        description <- param$ValueOrigin$Description %||% ""

        source_parts <- c(source)
        if (method != "" && method != source) {
          source_parts <- c(source_parts, method)
        }
        if (description != "" && description != method) {
          source_parts <- c(source_parts, glue::glue("({description})"))
        }

        return(paste(source_parts, collapse = " - "))
      }
    }
    return("Unknown")
  }

  # Always show property name as main bullet point
  cli::cli_li("{property_name}:")
  cli::cli_ul(id = "prop_details")

  # Handle special cases for different property types
  for (i in seq_along(x)) {
    entry <- x[[i]]
    entry_name <- entry$Name %||% glue::glue("Entry {i}")

    if (property_name == "pKa Types") {
      # Special handling for pKa types - show both type and value
      pka_value <- entry$Pka %||% "Unknown"
      pka_type <- entry$Type %||% "Unknown"
      source_info <- if (!is.null(entry$ValueOrigin)) {
        source <- entry$ValueOrigin$Source %||% "Unknown"
        description <- entry$ValueOrigin$Description %||% ""
        if (description != "") {
          glue::glue("{source} - ({description})")
        } else {
          source
        }
      } else {
        "Unknown"
      }

      cli::cli_li("{pka_type}: {pka_value} [{source_info}]")
    } else if (property_name == "Solubility") {
      # Special handling for solubility (include pH info and table data)
      value_unit <- extract_value_unit(entry)

      # Get pH info if available
      ph_info <- ""
      if (!is.null(entry$Parameters)) {
        ref_ph_param <- purrr::keep(
          entry$Parameters,
          ~ .x$Name == "Reference pH"
        )
        if (length(ref_ph_param) > 0) {
          ph_info <- glue::glue(" (pH {ref_ph_param[[1]]$Value})")
        }
      }

      # Check if this is a table-based solubility entry
      table_info <- ""
      if (!is.null(entry$Parameters)) {
        table_param <- purrr::keep(
          entry$Parameters,
          ~ .x$Name == "Solubility table"
        )
        if (
          length(table_param) > 0 && !is.null(table_param[[1]]$TableFormula)
        ) {
          table_formula <- table_param[[1]]$TableFormula
          if (
            !is.null(table_formula$Points) && length(table_formula$Points) > 0
          ) {
            # Extract table points
            points_text <- sapply(table_formula$Points, function(point) {
              glue::glue("pH {point$X}→{point$Y} mg/l")
            })
            table_info <- glue::glue(
              " (Table: {paste(points_text, collapse=', ')})"
            )
          }
        }
      }

      source_info <- get_source(entry)
      if (length(x) > 1) {
        cli::cli_li(
          "{entry_name}: {value_unit}{ph_info}{table_info} [{source_info}]"
        )
      } else {
        cli::cli_li("{value_unit}{ph_info}{table_info} [{source_info}]")
      }
    } else {
      # General handling for other properties
      value_unit <- extract_value_unit(entry)
      source_info <- get_source(entry)

      if (length(x) > 1) {
        cli::cli_li("{entry_name}: {value_unit} [{source_info}]")
      } else {
        cli::cli_li("{value_unit} [{source_info}]")
      }
    }
  }

  # End nested list
  cli::cli_end(id = "prop_details")

  invisible(x)
}

#' S3 print method for compound processes
#'
#' @param x A compound_processes object
#' @param ... Additional arguments passed to print methods
#' @return Invisibly returns the compound processes
#' @export
print.compound_processes <- function(x, ...) {
  if (length(x) == 0) {
    cli::cli_text("Processes: No processes available")
    return(invisible(x))
  }

  cli::cli_text("Processes ({length(x)} total):")
  cli::cli_ul(id = "processes_list")

  # Categorize processes (ordered by specificity - more specific patterns first)
  process_categories <- list(
    "Metabolism" = c("Metabolization", "rCYP"),
    "Transport" = c("ActiveTransport", "SpecificBinding"),
    "Clearance" = c(
      "^Glomerular",
      "^Tubular",
      "^Biliary",
      "^LiverClearance",
      "^Hepatocytes",
      "Clearance"
    ),
    "Inhibition" = c("Inhibition"),
    "Induction" = c("Induction")
  )

  # Helper function to extract parameters and create formatted string
  format_process <- function(p) {
    # Get process name with molecule if available
    process_name <- p$InternalName
    molecule_name <- p$Molecule %||% p$MoleculeName
    if (!is.null(molecule_name) && molecule_name != "") {
      process_name <- paste0(process_name, " (", molecule_name, ")")
    }

    # Add metabolite information if available (for metabolism processes)
    if (!is.null(p$Metabolite) && p$Metabolite != "") {
      process_name <- paste0(process_name, " → ", p$Metabolite)
    }

    # Extract all relevant parameters (more comprehensive)
    key_params <- c()
    if (!is.null(p$Parameters) && length(p$Parameters) > 0) {
      for (param in p$Parameters) {
        if (!is.null(param$Name)) {
          # Include most parameters, excluding very common/less informative ones
          exclude_params <- c(
            "Fraction unbound (experiment)",
            "Lipophilicity (experiment)",
            "Plasma clearance"
          )

          if (!param$Name %in% exclude_params) {
            value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
              paste0(param$Value, " ", param$Unit)
            } else {
              as.character(param$Value)
            }
            key_params <- c(key_params, paste0(param$Name, "=", value_unit))
          }
        }
      }
    }

    # Format parameters
    param_str <- if (length(key_params) > 0) {
      paste0(": ", paste(key_params, collapse = ", "))
    } else {
      ""
    }

    return(paste0(process_name, param_str))
  }

  categorized_processes <- character()

  # Process categories in order of priority (more specific first)
  for (category in names(process_categories)) {
    # Only consider processes that haven't been categorized yet
    available_processes <- purrr::keep(seq_along(x), function(i) {
      !x[[i]]$InternalName %in% categorized_processes
    })

    matching_processes <- purrr::keep(available_processes, function(i) {
      any(sapply(process_categories[[category]], function(pattern) {
        grepl(pattern, x[[i]]$InternalName)
      }))
    })

    if (length(matching_processes) > 0) {
      categorized_processes <- c(
        categorized_processes,
        sapply(matching_processes, function(i) x[[i]]$InternalName)
      )

      cli::cli_li("{category}:")
      cli::cli_ul(id = "proc_{category}")

      for (i in matching_processes) {
        formatted_process <- format_process(x[[i]])
        source_info <- if (
          !is.null(x[[i]]$DataSource) && x[[i]]$DataSource != ""
        ) {
          paste0(" [", x[[i]]$DataSource, "]")
        } else {
          ""
        }
        cli::cli_li("{formatted_process}{source_info}")
      }

      cli::cli_end(id = "proc_{category}")
    }
  }

  # Show uncategorized processes
  uncategorized <- purrr::keep(seq_along(x), function(i) {
    !x[[i]]$InternalName %in% categorized_processes
  })
  if (length(uncategorized) > 0) {
    cli::cli_li("Other:")
    cli::cli_ul(id = "proc_other")

    for (i in uncategorized) {
      formatted_process <- format_process(x[[i]])
      source_info <- if (
        !is.null(x[[i]]$DataSource) && x[[i]]$DataSource != ""
      ) {
        paste0(" [", x[[i]]$DataSource, "]")
      } else {
        ""
      }
      cli::cli_li("{formatted_process}{source_info}")
    }

    cli::cli_end(id = "proc_other")
  }

  cli::cli_end(id = "processes_list")

  invisible(x)
}

#' Print method for compound additional parameters
#'
#' @param x A compound_additional_parameters object
#' @param ... Additional arguments (unused)
#' @export
print.compound_additional_parameters <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    return(invisible(x))
  }

  # Extract and format parameters
  param_data <- purrr::map(x, function(param) {
    param_name <- param$Name %||% "Unknown"
    value <- param$Value %||% "N/A"
    unit <- param$Unit %||% ""
    value_origin <- param$ValueOrigin

    # Format value
    value_display <- if (is.numeric(value)) {
      formatC(value, format = "g", digits = 6)
    } else {
      as.character(value)
    }

    # Format unit
    unit_display <- if (unit != "") {
      glue::glue(" {unit}")
    } else {
      ""
    }

    # Format source information
    source_info <- "Unknown"
    if (!is.null(value_origin)) {
      source_parts <- character()
      if (!is.null(value_origin$Source)) {
        source_parts <- c(source_parts, value_origin$Source)
      }
      if (!is.null(value_origin$Method)) {
        source_parts <- c(source_parts, value_origin$Method)
      }
      if (!is.null(value_origin$Description)) {
        source_parts <- c(
          source_parts,
          glue::glue("({value_origin$Description})")
        )
      }
      if (length(source_parts) > 0) {
        source_info <- paste(source_parts, collapse = " - ")
      }
    }

    list(
      name = param_name,
      value = value_display,
      unit = unit_display,
      source = source_info
    )
  })

  # Display parameters
  cli::cli_text("• Additional Parameters ({length(param_data)} total):")
  cli::cli_ul()

  for (param in param_data) {
    cli::cli_li("{param$name}: {param$value}{param$unit} [{param$source}]")
  }

  cli::cli_end()

  invisible(x)
}

#' Print method for metabolizing enzymes
#'
#' @param x A metabolizing_enzymes object
#' @param ... Additional arguments (unused)
#' @export
print.metabolizing_enzymes <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Metabolizing Enzymes: No data available")
    return(invisible(x))
  }

  cli::cli_text("Metabolizing Enzymes:")
  cli::cli_ul(id = "met_enzymes")

  for (datasource in names(x)) {
    for (process in x[[datasource]]) {
      molecule <- process$Molecule %||% "Unknown"
      process_name <- process$Process %||% "Unknown"
      metabolite <- process$Metabolite

      # Format process name with metabolite if available
      process_display <- if (!is.null(metabolite) && metabolite != "") {
        paste0(process_name, " (", molecule, ") → ", metabolite)
      } else {
        paste0(process_name, " (", molecule, ")")
      }

      # Extract key parameters
      key_params <- c()
      param_data <- process[
        !names(process) %in%
          c("Process", "Molecule", "Metabolite", "DataSource")
      ]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (param_name %in% c("kcat", "Km", "Vmax", "Ki", "Kd")) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_display}{param_str} [{datasource}]")
    }
  }

  cli::cli_end(id = "met_enzymes")
  invisible(x)
}

#' Print method for transporter proteins
#'
#' @param x A transporter_proteins object
#' @param ... Additional arguments (unused)
#' @export
print.transporter_proteins <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Transporter Proteins: No data available")
    return(invisible(x))
  }

  cli::cli_text("Transporter Proteins:")
  cli::cli_ul(id = "transporters")

  for (datasource in names(x)) {
    for (process in x[[datasource]]) {
      molecule <- process$Molecule %||% "Unknown"
      process_name <- process$Process %||% "Unknown"

      process_display <- paste0(process_name, " (", molecule, ")")

      # Extract key parameters
      key_params <- c()
      param_data <- process[
        !names(process) %in% c("Process", "Molecule", "DataSource")
      ]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (
          param_name %in% c("kcat", "Km", "Vmax", "Ki", "Kd", "kon", "koff")
        ) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_display}{param_str} [{datasource}]")
    }
  }

  cli::cli_end(id = "transporters")
  invisible(x)
}

#' Print method for protein binding partners
#'
#' @param x A protein_binding_partners object
#' @param ... Additional arguments (unused)
#' @export
print.protein_binding_partners <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Protein Binding Partners: No data available")
    return(invisible(x))
  }

  cli::cli_text("Protein Binding Partners:")
  cli::cli_ul(id = "binding")

  for (datasource in names(x)) {
    for (process in x[[datasource]]) {
      molecule <- process$Molecule %||% "Unknown"
      process_name <- process$Process %||% "Unknown"

      process_display <- paste0(process_name, " (", molecule, ")")

      # Extract key parameters
      key_params <- c()
      param_data <- process[
        !names(process) %in% c("Process", "Molecule", "DataSource")
      ]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (param_name %in% c("koff", "Kd", "kon")) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_display}{param_str} [{datasource}]")
    }
  }

  cli::cli_end(id = "binding")
  invisible(x)
}

#' Print method for inhibition processes
#'
#' @param x An inhibition object
#' @param ... Additional arguments (unused)
#' @export
print.inhibition <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Inhibition: No data available")
    return(invisible(x))
  }

  cli::cli_text("Inhibition:")
  cli::cli_ul(id = "inhibition")

  for (datasource in names(x)) {
    for (process in x[[datasource]]) {
      molecule <- process$Molecule %||% "Unknown"
      process_name <- process$Process %||% "Unknown"

      process_display <- paste0(process_name, " (", molecule, ")")

      # Extract key parameters
      key_params <- c()
      param_data <- process[
        !names(process) %in% c("Process", "Molecule", "DataSource")
      ]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (param_name %in% c("Ki", "Kd", "kinact", "K_kinact_half", "Km")) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_display}{param_str} [{datasource}]")
    }
  }

  cli::cli_end(id = "inhibition")
  invisible(x)
}

#' Print method for induction processes
#'
#' @param x An induction object
#' @param ... Additional arguments (unused)
#' @export
print.induction <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Induction: No data available")
    return(invisible(x))
  }

  cli::cli_text("Induction:")
  cli::cli_ul(id = "induction")

  for (datasource in names(x)) {
    for (process in x[[datasource]]) {
      molecule <- process$Molecule %||% "Unknown"
      process_name <- process$Process %||% "Unknown"

      process_display <- paste0(process_name, " (", molecule, ")")

      # Extract key parameters
      key_params <- c()
      param_data <- process[
        !names(process) %in% c("Process", "Molecule", "DataSource")
      ]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (param_name %in% c("EC50", "Emax", "Km")) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_display}{param_str} [{datasource}]")
    }
  }

  cli::cli_end(id = "induction")
  invisible(x)
}

#' Print method for hepatic clearance processes
#'
#' @param x A hepatic_clearance object
#' @param ... Additional arguments (unused)
#' @export
print.hepatic_clearance <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Hepatic Clearance: No data available")
    return(invisible(x))
  }

  cli::cli_text("Hepatic Clearance:")
  cli::cli_ul(id = "hepatic")

  for (datasource in names(x)) {
    cli::cli_li("{datasource}:")
    cli::cli_ul(id = "datasource_{datasource}")

    for (process in x[[datasource]]) {
      process_name <- process$Process %||% "Unknown"

      # Extract key parameters
      key_params <- c()
      param_data <- process[!names(process) %in% c("Process", "DataSource")]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (
          param_name %in%
            c("Specific clearance", "Intrinsic clearance", "Vmax", "Km", "kcat")
        ) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_name}{param_str} [{datasource}]")
    }

    cli::cli_end(id = "datasource_{datasource}")
  }

  cli::cli_end(id = "hepatic")
  invisible(x)
}

#' Print method for renal clearance processes
#'
#' @param x A renal_clearance object
#' @param ... Additional arguments (unused)
#' @export
print.renal_clearance <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Renal Clearance: No data available")
    return(invisible(x))
  }

  cli::cli_text("Renal Clearance:")
  cli::cli_ul(id = "renal")

  for (datasource in names(x)) {
    cli::cli_li("{datasource}:")
    cli::cli_ul(id = "datasource_{datasource}")

    for (process in x[[datasource]]) {
      process_name <- process$Process %||% "Unknown"

      # Extract key parameters
      key_params <- c()
      param_data <- process[!names(process) %in% c("Process", "DataSource")]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (
          param_name %in%
            c("Specific clearance", "Intrinsic clearance", "GFR fraction")
        ) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_name}{param_str} [{datasource}]")
    }

    cli::cli_end(id = "datasource_{datasource}")
  }

  cli::cli_end(id = "renal")
  invisible(x)
}

#' Print method for biliary clearance processes
#'
#' @param x A biliary_clearance object
#' @param ... Additional arguments (unused)
#' @export
print.biliary_clearance <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Biliary Clearance: No data available")
    return(invisible(x))
  }

  cli::cli_text("Biliary Clearance:")
  cli::cli_ul(id = "biliary")

  for (datasource in names(x)) {
    cli::cli_li("{datasource}:")
    cli::cli_ul(id = "datasource_{datasource}")

    for (process in x[[datasource]]) {
      process_name <- process$Process %||% "Unknown"

      # Extract key parameters
      key_params <- c()
      param_data <- process[!names(process) %in% c("Process", "DataSource")]

      for (param_name in names(param_data)) {
        param <- param_data[[param_name]]
        if (param_name %in% c("Specific clearance", "Plasma clearance")) {
          value_unit <- if (!is.null(param$Unit) && param$Unit != "") {
            paste0(param$Value, " ", param$Unit)
          } else {
            as.character(param$Value)
          }
          key_params <- c(key_params, paste0(param_name, "=", value_unit))
        }
      }

      param_str <- if (length(key_params) > 0) {
        paste0(": ", paste(key_params, collapse = ", "))
      } else {
        ""
      }

      cli::cli_li("{process_name}{param_str} [{datasource}]")
    }

    cli::cli_end(id = "datasource_{datasource}")
  }

  cli::cli_end(id = "biliary")
  invisible(x)
}

#' Print method for compound calculation methods
#'
#' @param x A compound_calculation_methods object
#' @param ... Additional arguments (unused)
#' @export
print.compound_calculation_methods <- function(x, ...) {
  if (is.null(x) || length(x) == 0) {
    cli::cli_text("Calculation Methods: No data available")
    return(invisible(x))
  }

  cli::cli_text("Calculation Methods:")
  cli::cli_ul(id = "calc_methods")

  # Display partition coefficient method
  if (!is.null(x$partition_coef)) {
    cli::cli_li("Partition Coefficient: {x$partition_coef}")
  }

  # Display permeability method
  if (!is.null(x$permeability)) {
    cli::cli_li("Permeability: {x$permeability}")
  }

  cli::cli_end(id = "calc_methods")
  invisible(x)
}

#' Print method for observed data collection
#'
#' @param x An observed_data_collection object (a named list of DataSet objects)
#' @param n Number of observed data names to display (default: 10)
#' @param ... Additional arguments (not used)
#' @return The input object x, invisibly
#' @export
print.observed_data_collection <- function(x, n = 5, ...) {
  output <- cli::cli_format_method({
    cli::cli_h1("Observed Data ({length(x)})")

    if (length(x) == 0) {
      cli::cli_alert_info("No observed data available")
    } else {
      # Show first n names
      names_to_show <- head(names(x), n)

      for (name in names_to_show) {
        cli::cli_li("{name}")
      }

      # Show "... and X more" if there are additional items
      remaining <- length(x) - length(names_to_show)
      if (remaining > 0) {
        cli::cli_text("... and {remaining} more")
      }
    }
  })

  cat(output, sep = "\n")
  invisible(x)
}
