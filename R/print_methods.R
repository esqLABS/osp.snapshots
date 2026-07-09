#' Generic print method for snapshot collections
#'
#' Shared S3 print method that renders any building-block collection: a
#' header with the kind and item count, one bullet per item with a
#' per-kind summary, and a friendly message when the collection is
#' empty. Per-item summary lines and per-kind labels are dispatched to
#' internal generics `collection_kind_info()` and
#' `collection_item_label()`, each with one method per collection class.
#'
#' @param x A snapshot collection (a `snapshot_collection` named list).
#' @param n Maximum number of items to display before truncating with
#'   "... and X more". Honoured only when the collection's
#'   `collection_kind_info()` method returns `truncate = TRUE`; the
#'   default is to show every item. Currently only the
#'   `observed_data_collection` opts in.
#' @param ... Additional arguments passed to print methods.
#' @return Invisibly returns the collection.
#' @export
print.snapshot_collection <- function(x, n = 5, ...) {
  info <- collection_kind_info(x)

  stopifnot(
    is.character(info$title),
    length(info$title) == 1L,
    is.character(info$empty_message),
    length(info$empty_message) == 1L
  )

  output <- cli::cli_format_method({
    cli::cli_h1("{info$title} ({length(x)})")

    if (length(x) == 0) {
      cli::cli_alert_info(info$empty_message)
    } else {
      names_to_show <- if (isTRUE(info$truncate)) {
        utils::head(names(x), n)
      } else {
        names(x)
      }
      for (name in names_to_show) {
        cli::cli_li(collection_item_label(x, item = x[[name]], name = name))
      }
      remaining <- length(x) - length(names_to_show)
      if (remaining > 0) {
        cli::cli_text("... and {remaining} more")
      }
    }
  })

  cat(output, sep = "\n")
  invisible(x)
}

#' Per-kind header info for a snapshot collection
#'
#' Internal S3 generic. Returns a list describing how
#' `print.snapshot_collection()` should label the collection.
#'
#' Required return shape:
#' * `title`: length-1 character. Header title (e.g. "Compounds").
#' * `empty_message`: length-1 character. Message shown when the
#'   collection has no items.
#' * `truncate` (optional): length-1 logical. When `TRUE`,
#'   `print.snapshot_collection()` truncates the listing at its `n`
#'   argument. Defaults to `FALSE` (show every item) when absent.
#'
#' @param x A snapshot collection. Used for dispatch only.
#' @return A list with `title`, `empty_message`, and optionally
#'   `truncate`.
#' @keywords internal
collection_kind_info <- function(x) {
  UseMethod("collection_kind_info")
}

#' @export
collection_kind_info.compound_collection <- function(x) {
  list(title = "Compounds", empty_message = "No compounds found")
}

#' @export
collection_kind_info.individual_collection <- function(x) {
  list(title = "Individuals", empty_message = "No individuals found")
}

#' @export
collection_kind_info.population_collection <- function(x) {
  list(title = "Populations", empty_message = "No populations found")
}

#' @export
collection_kind_info.formulation_collection <- function(x) {
  list(title = "Formulations", empty_message = "No formulations found")
}

#' @export
collection_kind_info.event_collection <- function(x) {
  list(title = "Events", empty_message = "No events found")
}

#' @export
collection_kind_info.expression_profile_collection <- function(x) {
  list(
    title = "Expression Profiles",
    empty_message = "No expression profiles found"
  )
}

#' @export
collection_kind_info.protocol_collection <- function(x) {
  list(title = "Protocols", empty_message = "No protocols found")
}

#' @export
collection_kind_info.observed_data_collection <- function(x) {
  list(
    title = "Observed Data",
    empty_message = "No observed data available",
    truncate = TRUE
  )
}

#' @export
collection_kind_info.observer_set_collection <- function(x) {
  list(title = "Observer Sets", empty_message = "No observer sets found")
}

#' Per-item bullet label for a snapshot collection
#'
#' Internal S3 generic. Returns the text used for the bullet of a single
#' item in `print.snapshot_collection()`.
#'
#' Required return shape: length-1 character or glue string.
#'
#' @param x The owning snapshot collection. Present so that dispatch
#'   reads the collection class via `UseMethod()`; methods typically
#'   ignore the value.
#' @param item The current entry, i.e. `x[[name]]`.
#' @param name The current entry's name in `x`.
#' @return A length-1 character (or glue) string.
#' @keywords internal
collection_item_label <- function(x, item, name) {
  UseMethod("collection_item_label")
}

#' @export
collection_item_label.compound_collection <- function(x, item, name) {
  name
}

#' @export
collection_item_label.individual_collection <- function(x, item, name) {
  name
}

#' @export
collection_item_label.population_collection <- function(x, item, name) {
  source_text <- if (!is.null(item$source_population)) {
    glue::glue(" [Source: {item$source_population}]")
  } else {
    ""
  }
  glue::glue("{name}{source_text} ({item$number_of_individuals} individuals)")
}

#' @export
collection_item_label.formulation_collection <- function(x, item, name) {
  glue::glue("{name} ({item$get_human_formulation_type()})")
}

#' @export
collection_item_label.event_collection <- function(x, item, name) {
  template <- item$template
  param_count <- length(item$parameters)
  if (param_count > 0) {
    plural <- if (param_count == 1) "parameter" else "parameters"
    glue::glue("{name} ({template}) - {param_count} {plural}")
  } else {
    glue::glue("{name} ({template})")
  }
}

#' @export
collection_item_label.expression_profile_collection <- function(x, item, name) {
  category <- if (!is.null(item$category)) item$category else "N/A"
  glue::glue("{item$molecule} ({item$type}, {item$species}, {category})")
}

#' @export
collection_item_label.protocol_collection <- function(x, item, name) {
  if (item$is_advanced) {
    schema_count <- length(item$schemas)
    plural <- if (schema_count == 1) "schema" else "schemas"
    glue::glue("{name} (Advanced - {schema_count} {plural})")
  } else {
    type_text <- if (!is.null(item$application_type)) {
      glue::glue(" - {item$get_human_application_type()}")
    } else {
      ""
    }
    interval_text <- if (!is.null(item$dosing_interval)) {
      glue::glue(" - {item$get_human_dosing_interval()}")
    } else {
      ""
    }
    glue::glue("{name} (Simple{type_text}{interval_text})")
  }
}

#' @export
collection_item_label.observed_data_collection <- function(x, item, name) {
  name
}

#' @export
collection_item_label.observer_set_collection <- function(x, item, name) {
  n_observers <- length(item$observers)
  plural <- if (n_observers == 1) "observer" else "observers"
  glue::glue("{name} ({n_observers} {plural})")
}

# Helper that tags a list with the snapshot_collection class triplet:
# (kind, "snapshot_collection", "list"). Class ordering matters: the
# kind-specific class must appear first so `collection_kind_info()` /
# `collection_item_label()` dispatch on the kind, with
# `print.snapshot_collection` as the shared method.
as_snapshot_collection <- function(x, kind) {
  class(x) <- c(kind, "snapshot_collection", "list")
  x
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

  # Name of the default alternative in this group, so it can be flagged
  # below. pKa Types are not an alternative group and carry no default.
  default_name <- if (property_name != "pKa Types") {
    get_default_alternative(x)
  } else {
    NULL
  }

  # Handle special cases for different property types
  for (i in seq_along(x)) {
    entry <- x[[i]]
    entry_name <- entry$Name %||% glue::glue("Entry {i}")
    default_suffix <- if (
      !is.null(default_name) && identical(entry$Name, default_name)
    ) {
      " (Default)"
    } else {
      ""
    }

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
              glue::glue("pH {point$X}\u2192{point$Y} mg/l")
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
          "{entry_name}{default_suffix}: {value_unit}{ph_info}{table_info} [{source_info}]"
        )
      } else {
        cli::cli_li("{value_unit}{ph_info}{table_info} [{source_info}]")
      }
    } else {
      # General handling for other properties
      value_unit <- extract_value_unit(entry)
      source_info <- get_source(entry)

      if (length(x) > 1) {
        cli::cli_li(
          "{entry_name}{default_suffix}: {value_unit} [{source_info}]"
        )
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
      process_name <- paste0(process_name, " \u2192 ", p$Metabolite)
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
  cli::cli_text("\u2022 Additional Parameters ({length(param_data)} total):")
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
        paste0(process_name, " (", molecule, ") \u2192 ", metabolite)
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
