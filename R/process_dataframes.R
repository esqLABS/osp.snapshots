# Tibble-layer helpers for compound processes.
#
# Two output shapes coexist:
#
#   1. The **legacy wide form** used by the deprecated category-keyed
#      tibbles (`protein_binding_partners`, `metabolizing_enzymes`,
#      `hepatic_clearance`, `transporter_proteins`, `renal_clearance`,
#      `biliary_clearance`, `inhibition`, `induction`). Each category
#      formats the `parameter` column slightly differently (some include
#      molecule names, metabolite names, etc.) for backwards compatibility.
#      Used by `Compound$to_df()` (which folds those rows into the legacy
#      combined tibble) and by the eight `Compound$<category>` active
#      bindings.
#
#   2. The **new long form** described in ADR-0002: one row per
#      (process, parameter) pair, with `compound`, `category`,
#      `process_name`, `parameter`, `value`, `unit`, `data_source`,
#      `source`, plus the optional `molecule`, `metabolite`, `species`
#      columns. Used by `get_compounds_dfs()`'s `processes` element.
#
# Both shapes share the same source data (`compound$data$Processes`,
# the raw `CompoundProcess[]` list) and the same value-origin handling
# (`compound_value_origin_source`, defined in `R/Compound.R`).

# ---------------------------------------------------------------------------
# Long form (preferred): one row per (process, parameter) pair.
# ---------------------------------------------------------------------------

# Public-facing empty tibble shape for the long-form processes table.
empty_processes_tibble <- function() {
  tibble::tibble(
    compound = character(0),
    category = character(0),
    process_name = character(0),
    parameter = character(0),
    value = character(0),
    unit = character(0),
    data_source = character(0),
    source = character(0),
    molecule = character(0),
    metabolite = character(0),
    species = character(0)
  )
}

# Walk every Process in a compound and emit one row per parameter.
compound_processes_to_long_df <- function(compound_name, raw_processes) {
  if (is.null(raw_processes) || length(raw_processes) == 0) {
    return(empty_processes_tibble())
  }

  rows <- purrr::map(raw_processes, function(p) {
    parameters <- p$Parameters %||% list()
    if (length(parameters) == 0) {
      return(NULL)
    }

    cat <- process_category(p$InternalName)

    purrr::map(parameters, function(param) {
      tibble::tibble(
        compound = compound_name,
        category = cat %||% NA_character_,
        process_name = p$InternalName %||% NA_character_,
        parameter = param$Name %||% NA_character_,
        value = format_process_value(param$Value),
        unit = param$Unit %||% NA_character_,
        data_source = p$DataSource %||% NA_character_,
        source = compound_value_origin_source(param$ValueOrigin),
        molecule = p$Molecule %||% NA_character_,
        metabolite = p$Metabolite %||% NA_character_,
        species = p$Species %||% NA_character_
      )
    }) |>
      purrr::list_rbind()
  })

  rows <- purrr::compact(rows)
  if (length(rows) == 0) {
    return(empty_processes_tibble())
  }
  dplyr::bind_rows(rows)
}

format_process_value <- function(x) {
  if (is.null(x)) {
    return(NA_character_)
  }
  if (is.character(x)) {
    return(x)
  }
  as.character(x)
}

# Strip the deprecation classing from a `legacy_category_named_list()`
# result. Used by the internal tibble emitter where the named list is
# walked, not displayed.
unclassed_legacy_named_list <- function(raw_processes, category) {
  result <- legacy_category_named_list(raw_processes, category)
  if (is.null(result)) {
    return(NULL)
  }
  class(result) <- "list"
  result
}

# ---------------------------------------------------------------------------
# Legacy wide form: per-category tibble shape used by `Compound$to_df()` and
# the deprecated `Compound$<category>` accessors. These exist to preserve
# the existing row formatting (metabolite suffixes, "param, molecule" joins,
# IrreversibleInhibition Ki imputation, etc.).
# ---------------------------------------------------------------------------

empty_compound_processes_legacy_tibble <- function() {
  tibble::tibble(
    compound = character(0),
    category = character(0),
    type = character(0),
    parameter = character(0),
    value = character(0),
    unit = character(0),
    data_source = character(0),
    source = character(0)
  )
}

# Build the legacy `<category>` named-list shape (the historical
# `private$.protein_binding_partners` etc. structure) for one category.
# Used only by the deprecated `Compound$<category>` accessors.
legacy_category_named_list <- function(raw_processes, category) {
  matching <- purrr::keep(
    raw_processes %||% list(),
    function(p) identical(process_category(p$InternalName), category)
  )
  if (length(matching) == 0) {
    return(NULL)
  }

  datasource_names <- unique(purrr::list_c(purrr::map(matching, "DataSource")))
  result <- list()

  for (ds in datasource_names) {
    entries <- purrr::keep(matching, ~ identical(.x$DataSource, ds))
    result[[ds]] <- purrr::map(entries, function(p) {
      build_legacy_process_entry(p, category)
    })
  }

  class(result) <- c(category, "list")
  result
}

build_legacy_process_entry <- function(p, category) {
  # A process can carry an empty `Parameters` list (PK-Sim exports e.g.
  # `GlomerularFiltration` with `"Parameters": []`). `purrr::set_names()`
  # cannot name a zero-length input, so start from an empty parameter list
  # and only build named entries when parameters are present.
  raw_parameters <- p$Parameters %||% list()
  if (length(raw_parameters) == 0) {
    params <- list()
  } else {
    parameter_names <- purrr::list_c(purrr::map(raw_parameters, "Name"))
    params <- purrr::map(
      purrr::set_names(raw_parameters, parameter_names),
      function(parameter) {
        list(
          Value = as.numeric(parameter$Value),
          Unit = parameter$Unit,
          Source = compound_value_origin_source(parameter$ValueOrigin)
        )
      }
    )
  }

  params$Process <- p$InternalName
  if (category != "hepatic_clearance" && category != "renal_clearance") {
    params$Molecule <- p$Molecule
  }
  if (category == "metabolizing_enzymes") {
    params$Metabolite <- p$Metabolite
  }
  params$DataSource <- p$DataSource

  # Preserve the IrreversibleInhibition Ki=K-kinact-half imputation that the
  # old `.extract_inhibition()` did.
  if (
    category == "inhibition" &&
      identical(p$InternalName, "IrreversibleInhibition") &&
      !("Ki" %in% names(params)) &&
      !is.null(params$K_kinact_half)
  ) {
    params$Ki <- params$K_kinact_half
    params$Ki$Source <- "Assumed Ki=K-kinact-half"
  }

  params
}

# Build the legacy combined tibble of process rows used by `Compound$to_df()`.
# The output mirrors what the old per-category `.<category>_to_table()`
# methods produced, in the same per-category order.
compound_processes_to_legacy_df <- function(compound_name, raw_processes) {
  if (is.null(raw_processes) || length(raw_processes) == 0) {
    return(empty_compound_processes_legacy_tibble())
  }

  category_order <- c(
    "protein_binding_partners",
    "metabolizing_enzymes",
    "hepatic_clearance",
    "transporter_proteins",
    "renal_clearance",
    "biliary_clearance",
    "inhibition",
    "induction"
  )

  rows <- purrr::map(category_order, function(cat) {
    by_ds <- unclassed_legacy_named_list(raw_processes, cat)
    if (length(by_ds) == 0) {
      return(NULL)
    }
    legacy_category_to_df(compound_name, cat, by_ds)
  })

  rows <- purrr::compact(rows)
  if (length(rows) == 0) {
    return(empty_compound_processes_legacy_tibble())
  }
  dplyr::bind_rows(rows)
}

# Per-category row emitters. Each one mirrors the formatting in the original
# `.<category>_to_table()` private methods so legacy callers see the same
# values.
legacy_category_to_df <- function(compound_name, category, by_ds) {
  rows <- purrr::imap(by_ds, function(entries, datasource_name) {
    purrr::map(entries, function(entry) {
      legacy_entry_to_df(compound_name, category, datasource_name, entry)
    }) |>
      purrr::list_rbind()
  })
  if (length(rows) == 0) {
    return(empty_compound_processes_legacy_tibble())
  }
  dplyr::bind_rows(rows)
}

legacy_entry_to_df <- function(
  compound_name,
  category,
  datasource_name,
  entry
) {
  metadata_keys <- c("Process", "Molecule", "Metabolite", "DataSource")
  metadata_keys <- intersect(names(entry), metadata_keys)
  params <- entry[setdiff(names(entry), metadata_keys)]
  process_internal <- entry$Process

  purrr::map(seq_along(params), function(i) {
    param <- params[[i]]
    param_name <- names(params)[i]

    parameter_string <- format_legacy_parameter_string(
      category,
      param_name,
      entry
    )

    tibble::tibble(
      compound = compound_name,
      category = category,
      type = process_internal,
      parameter = parameter_string,
      value = format_process_value(param$Value),
      unit = param$Unit %||% NA_character_,
      data_source = datasource_name,
      source = param$Source %||% NA_character_
    )
  }) |>
    purrr::list_rbind()
}

format_legacy_parameter_string <- function(category, param_name, entry) {
  if (category %in% c("hepatic_clearance", "renal_clearance")) {
    return(param_name)
  }
  if (
    category == "metabolizing_enzymes" &&
      !is.null(entry$Metabolite)
  ) {
    return(paste(
      paste(param_name, entry$Molecule, sep = ", "),
      entry$Metabolite,
      sep = "\n-"
    ))
  }
  paste(param_name, entry$Molecule, sep = ", ")
}
