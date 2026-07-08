#' Convert a snapshot collection to a tibble or list of tibbles
#'
#' @description
#' Unified bridge from a `Snapshot` to the tidyverse for any
#' building-block kind plus observed data. Replaces the nine
#' per-kind `get_*_dfs()` functions as the canonical entry point;
#' those remain available as thin wrappers. Omit `kind` to convert
#' every kind of a snapshot in a single call.
#'
#' @param snapshot A `Snapshot` object.
#' @param kind Character vector naming the collection(s) to convert,
#'   or `NULL` (the default) to convert every kind. Each element must
#'   be one of `"compounds"`, `"individuals"`, `"formulations"`,
#'   `"populations"`, `"events"`, `"expression_profiles"`,
#'   `"protocols"`, `"observer_sets"`, `"observed_data"`. A length-1
#'   `kind` returns that kind's native shape directly (a tibble or a
#'   named list of tibbles); a length-2-or-more `kind` returns a named
#'   list keyed by the requested kinds, in request order; `NULL`
#'   returns a named list of all nine kinds in the order above.
#'
#' @return When `kind` names a single collection, a tibble or a named
#'   list of tibbles for that collection (see below). When `kind` names
#'   several collections, or is `NULL` (all nine kinds), a named list
#'   keyed by the requested kinds, each entry the native shape of that
#'   kind:
#' \itemize{
#'   \item `"compounds"`: a list with `properties` and `processes`
#'     tibbles. `properties` carries one row per (compound,
#'     physicochemical property) pair (plus folded process rows
#'     for backwards compatibility); `processes` is the long-form,
#'     one row per (compound, process, parameter) triple.
#'   \item `"protocols"`, `"observed_data"`: a single tibble.
#'   \item `"observer_sets"`: a list with `observer_sets` (one row per
#'     `ObserverSet`) and `observers` (one row per `Observer`, joinable
#'     to its parent via `observer_set_id` / `observer_set_name`).
#'   \item `"individuals"`: a list with `individuals`,
#'     `individuals_parameters`, `individuals_expressions`.
#'   \item `"formulations"`: a list with `formulations`,
#'     `formulations_parameters`.
#'   \item `"populations"`: a list with `populations`,
#'     `populations_parameters`.
#'   \item `"events"`: a list with `events`, `events_parameters`.
#'   \item `"expression_profiles"`: a list with `expression_profiles`,
#'     `expression_profiles_parameters`.
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("Midazolam")
#'
#' # List of tibbles (compounds returns properties + processes)
#' compounds <- as_tibbles(snapshot, "compounds")
#' compounds$properties
#' compounds$processes
#'
#' # List of tibbles
#' individuals <- as_tibbles(snapshot, "individuals")
#' individuals$individuals_parameters
#'
#' # Omit `kind` to convert every kind at once, keyed by kind name
#' all_kinds <- as_tibbles(snapshot)
#' names(all_kinds)
#' }
as_tibbles <- function(snapshot, kind = NULL) {
  validate_snapshot(snapshot)

  builders <- list(
    compounds = as_tibbles_compounds,
    individuals = as_tibbles_individuals,
    formulations = as_tibbles_formulations,
    populations = as_tibbles_populations,
    events = as_tibbles_events,
    expression_profiles = as_tibbles_expression_profiles,
    protocols = as_tibbles_protocols,
    observer_sets = as_tibbles_observer_sets,
    observed_data = as_tibbles_observed_data
  )

  if (is.null(kind)) {
    kind <- names(builders)
  }

  if (!is.character(kind)) {
    cli::cli_abort(
      "{.arg kind} must be `NULL` or a character vector, not \\
      {.obj_type_friendly {kind}}."
    )
  }

  if (length(kind) == 0L) {
    cli::cli_abort("{.arg kind} must name at least one collection.")
  }

  unknown <- kind[!kind %in% names(builders)]
  if (length(unknown) > 0L) {
    cli::cli_abort(c(
      "Unknown {.arg kind} {.val {unknown}}.",
      i = "Must be one of {.val {names(builders)}}."
    ))
  }

  if (length(kind) == 1L) {
    return(builders[[kind]](snapshot))
  }

  stats::setNames(lapply(kind, \(k) builders[[k]](snapshot)), kind)
}

as_tibbles_compounds <- function(snapshot) {
  compounds <- snapshot$compounds

  result <- list(
    properties = empty_compound_property_tibble(),
    processes = empty_processes_tibble()
  )

  if (length(compounds) == 0) {
    return(result)
  }

  property_dfs <- lapply(compounds, \(compound) compound$to_df())
  result$properties <- dplyr::bind_rows(property_dfs)
  result$properties <- result$properties[order(result$properties$compound), ]

  process_dfs <- lapply(compounds, \(compound) {
    compound_processes_to_long_df(compound$name, compound$data$Processes)
  })
  result$processes <- dplyr::bind_rows(process_dfs)
  if (nrow(result$processes) > 0) {
    result$processes <- result$processes[order(result$processes$compound), ]
  }

  result
}

as_tibbles_individuals <- function(snapshot) {
  individuals <- snapshot$individuals

  result <- list(
    individuals = tibble::tibble(
      individual_id = character(0),
      name = character(0),
      description = character(0),
      seed = integer(0),
      species = character(0),
      population = character(0),
      gender = character(0),
      age = numeric(0),
      age_unit = character(0),
      gestational_age = numeric(0),
      gestational_age_unit = character(0),
      weight = numeric(0),
      weight_unit = character(0),
      height = numeric(0),
      height_unit = character(0),
      disease_state = character(0),
      calculation_methods = character(0),
      disease_state_parameters = character(0)
    ),
    individuals_parameters = tibble::tibble(
      individual_id = character(0),
      path = character(0),
      value = numeric(0),
      unit = character(0),
      source = character(0),
      description = character(0),
      source_id = integer(0)
    ),
    individuals_expressions = tibble::tibble(
      individual_id = character(0),
      profile = character(0)
    )
  )

  if (length(individuals) == 0) {
    return(result)
  }

  ind_dfs <- lapply(individuals, \(individual) individual$to_df())

  for (slot in names(result)) {
    parts <- lapply(ind_dfs, \(df) df[[slot]])
    parts <- parts[!vapply(parts, is.null, logical(1))]
    if (length(parts) > 0) {
      result[[slot]] <- dplyr::bind_rows(parts)
    }
  }

  result
}

as_tibbles_formulations <- function(snapshot) {
  formulations <- snapshot$formulations

  result <- list(
    formulations = tibble::tibble(
      formulation_id = character(0),
      name = character(0),
      formulation = character(0),
      formulation_type = character(0)
    ),
    formulations_parameters = tibble::tibble(
      formulation_id = character(0),
      name = character(0),
      value = numeric(0),
      unit = character(0),
      is_table_point = logical(0),
      x_value = numeric(0),
      y_value = numeric(0),
      table_name = character(0)
    )
  )

  if (length(formulations) == 0) {
    return(result)
  }

  form_dfs <- lapply(formulations, \(formulation) formulation$to_df())

  for (slot in names(result)) {
    parts <- lapply(form_dfs, \(df) df[[slot]])
    parts <- parts[!vapply(parts, is.null, logical(1))]
    if (length(parts) > 0) {
      result[[slot]] <- dplyr::bind_rows(parts)
    }
  }

  result
}

as_tibbles_populations <- function(snapshot) {
  populations <- snapshot$populations

  result <- list(
    populations = tibble::tibble(
      population_id = character(0),
      name = character(0),
      seed = integer(0),
      number_of_individuals = integer(0),
      proportion_of_females = numeric(0),
      source_population = character(0),
      individual_name = character(0),
      age_min = numeric(0),
      age_max = numeric(0),
      age_unit = character(0),
      weight_min = numeric(0),
      weight_max = numeric(0),
      weight_unit = character(0),
      height_min = numeric(0),
      height_max = numeric(0),
      height_unit = character(0),
      bmi_min = numeric(0),
      bmi_max = numeric(0),
      bmi_unit = character(0),
      egfr_min = numeric(0),
      egfr_max = numeric(0),
      egfr_unit = character(0)
    ),
    populations_parameters = tibble::tibble(
      population_id = character(0),
      parameter = character(0),
      seed = integer(0),
      distribution_type = character(0),
      statistic = character(0),
      value = numeric(0),
      unit = character(0),
      source = character(0),
      description = character(0)
    )
  )

  if (length(populations) == 0) {
    return(result)
  }

  for (pop in populations) {
    pop_dfs <- pop$to_df()
    result$populations <- dplyr::bind_rows(
      result$populations,
      pop_dfs$characteristics
    )
    result$populations_parameters <- dplyr::bind_rows(
      result$populations_parameters,
      pop_dfs$parameters
    )
  }

  result
}

as_tibbles_events <- function(snapshot) {
  events <- snapshot$events

  result <- list(
    events = tibble::tibble(
      event_id = character(0),
      name = character(0),
      template = character(0)
    ),
    events_parameters = tibble::tibble(
      event_id = character(0),
      parameter = character(0),
      value = numeric(0),
      unit = character(0)
    )
  )

  if (length(events) == 0) {
    return(result)
  }

  basic_list <- list()
  params_list <- list()

  for (event_name in names(events)) {
    event <- events[[event_name]]
    event_df <- event$to_dataframe()

    if (!is.null(event_df$events)) {
      basic_list[[length(basic_list) + 1]] <- dplyr::bind_cols(
        tibble::tibble(event_id = event_name),
        event_df$events
      )
    }

    if (
      !is.null(event_df$events_parameters) &&
        nrow(event_df$events_parameters) > 0
    ) {
      params_list[[length(params_list) + 1]] <- dplyr::bind_cols(
        tibble::tibble(
          event_id = rep(event_name, nrow(event_df$events_parameters))
        ),
        event_df$events_parameters
      ) |>
        dplyr::rename(
          "parameter" = "param_name",
          "value" = "param_value",
          "unit" = "param_unit"
        )
    }
  }

  if (length(basic_list) > 0) {
    result$events <- dplyr::bind_rows(basic_list)
  }
  if (length(params_list) > 0) {
    result$events_parameters <- dplyr::bind_rows(params_list)
  }

  result
}

as_tibbles_expression_profiles <- function(snapshot) {
  expression_profiles <- snapshot$expression_profiles

  result <- list(
    expression_profiles = tibble::tibble(
      expression_id = character(0),
      molecule = character(0),
      type = character(0),
      species = character(0),
      category = character(0),
      localization = character(0),
      ontogeny = character(0)
    ),
    expression_profiles_parameters = tibble::tibble(
      expression_id = character(0),
      parameter = character(0),
      value = numeric(0),
      unit = character(0),
      source = character(0),
      description = character(0)
    )
  )

  if (length(expression_profiles) == 0) {
    return(result)
  }

  profile_dfs <- lapply(expression_profiles, \(profile) profile$to_df())

  for (slot in names(result)) {
    parts <- lapply(profile_dfs, \(df) df[[slot]])
    parts <- parts[!vapply(parts, is.null, logical(1))]
    if (length(parts) > 0) {
      result[[slot]] <- dplyr::bind_rows(parts)
    }
  }

  result
}

as_tibbles_protocols <- function(snapshot) {
  protocols <- snapshot$protocols

  # Reuse the same empty-tibble helper Protocol$to_df() falls back to so the
  # empty-state and populated shapes cannot diverge (#56).
  if (length(protocols) == 0) {
    return(empty_protocol_tibble())
  }

  protocol_dfs <- lapply(protocols, \(protocol) protocol$to_df())
  dplyr::bind_rows(protocol_dfs)
}

as_tibbles_observer_sets <- function(snapshot) {
  observer_sets <- snapshot$observer_sets

  result <- list(
    observer_sets = empty_observer_sets_tibble(),
    observers = empty_observers_tibble()
  )

  if (length(observer_sets) == 0) {
    return(result)
  }

  set_rows <- lapply(names(observer_sets), function(id) {
    os <- observer_sets[[id]]
    tibble::tibble(
      observer_set_id = id,
      name = os$name %||% NA_character_,
      n_observers = length(os$observers)
    )
  })
  result$observer_sets <- dplyr::bind_rows(set_rows)

  observer_rows <- lapply(names(observer_sets), function(id) {
    os <- observer_sets[[id]]
    if (length(os$observers) == 0) {
      return(NULL)
    }
    obs_df <- dplyr::bind_rows(lapply(os$observers, function(o) o$to_df()))
    dplyr::bind_cols(
      tibble::tibble(
        observer_set_id = rep(id, nrow(obs_df)),
        observer_set_name = rep(os$name %||% NA_character_, nrow(obs_df))
      ),
      obs_df
    )
  })
  observer_rows <- observer_rows[!vapply(observer_rows, is.null, logical(1))]
  if (length(observer_rows) > 0) {
    result$observers <- dplyr::bind_rows(observer_rows)
  }

  result
}

# Shared empty tibble for the observer_sets element returned by
# as_tibbles_observer_sets().
empty_observer_sets_tibble <- function() {
  tibble::tibble(
    observer_set_id = character(0),
    name = character(0),
    n_observers = integer(0)
  )
}

# Shared empty tibble for the observers element returned by
# as_tibbles_observer_sets().
empty_observers_tibble <- function() {
  tibble::tibble(
    observer_set_id = character(0),
    observer_set_name = character(0),
    name = character(0),
    type = character(0),
    dimension = character(0),
    formula_expression = character(0),
    formula_dimension = character(0),
    formula_references = character(0),
    container_tags = character(0)
  )
}

as_tibbles_observed_data <- function(snapshot) {
  observed_data_items <- snapshot$observed_data

  result <- tibble::tibble(
    name = character(0),
    xValues = numeric(0),
    yValues = numeric(0),
    yErrorValues = numeric(0),
    xDimension = character(0),
    xUnit = character(0),
    yDimension = character(0),
    yUnit = character(0),
    yErrorType = character(0),
    yErrorUnit = character(0),
    molWeight = numeric(0),
    lloq = numeric(0)
  )

  if (length(observed_data_items) == 0) {
    return(result)
  }

  result <- ospsuite::dataSetToTibble(dataSets = unname(observed_data_items))
  result[order(result$name, result$xValues), ]
}

#' Get all compounds in a snapshot as data frames
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "compounds"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A list with `properties` and `processes` tibbles; see
#'   [as_tibbles()] for the column contract.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' dfs <- get_compounds_dfs(snapshot)
#' dfs$properties
#' dfs$processes
#' }
get_compounds_dfs <- function(snapshot) {
  as_tibbles(snapshot, "compounds")
}

#' Get all individuals in a snapshot as data frames
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "individuals"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A list with `individuals`, `individuals_parameters`, and
#'   `individuals_expressions` tibbles.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' dfs <- get_individuals_dfs(snapshot)
#' }
get_individuals_dfs <- function(snapshot) {
  as_tibbles(snapshot, "individuals")
}

#' Get all formulations in a snapshot as data frames
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "formulations"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A list with `formulations` and `formulations_parameters`
#'   tibbles. Table parameter points have `is_table_point = TRUE` and
#'   carry `x_value`, `y_value`, and `table_name`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' dfs <- get_formulations_dfs(snapshot)
#' }
get_formulations_dfs <- function(snapshot) {
  as_tibbles(snapshot, "formulations")
}

#' Get all populations in a snapshot as data frames
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "populations"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A list with `populations` and `populations_parameters`
#'   tibbles.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' dfs <- get_populations_dfs(snapshot)
#' }
get_populations_dfs <- function(snapshot) {
  as_tibbles(snapshot, "populations")
}

#' Get all events in a snapshot as data frames
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "events"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A list with `events` and `events_parameters` tibbles.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' dfs <- get_events_dfs(snapshot)
#' }
get_events_dfs <- function(snapshot) {
  as_tibbles(snapshot, "events")
}

#' Get all expression profiles in a snapshot as data frames
#'
#' @description
#' Thin wrapper around [as_tibbles()] with
#' `kind = "expression_profiles"`. Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A list with `expression_profiles` and
#'   `expression_profiles_parameters` tibbles.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' dfs <- get_expression_profiles_dfs(snapshot)
#' }
get_expression_profiles_dfs <- function(snapshot) {
  as_tibbles(snapshot, "expression_profiles")
}

#' Get all protocols in a snapshot as a single consolidated data frame
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "protocols"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A tibble with one row per protocol parameter (or per schema
#'   item parameter for advanced protocols).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' protocols_df <- get_protocols_dfs(snapshot)
#' }
get_protocols_dfs <- function(snapshot) {
  as_tibbles(snapshot, "protocols")
}

#' Get all observer sets in a snapshot as data frames
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "observer_sets"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A list with two tibbles. `observer_sets` has one row per
#'   `ObserverSet` with columns `observer_set_id`, `name`,
#'   `n_observers`. `observers` has one row per `Observer` with columns
#'   `observer_set_id`, `observer_set_name`, `name`, `type`,
#'   `dimension`, `formula_expression`, `formula_dimension`,
#'   `formula_references`, `container_tags`; rows join back to their
#'   parent `ObserverSet` by `observer_set_id` or `observer_set_name`.
#'   `formula_references` flattens the underlying `ExplicitFormula`
#'   references to `"alias=path"` pairs joined with `|`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' observer_sets_df <- get_observer_sets_dfs(snapshot)
#' }
get_observer_sets_dfs <- function(snapshot) {
  as_tibbles(snapshot, "observer_sets")
}

#' Get all observed data in a snapshot as a tibble
#'
#' @description
#' Thin wrapper around [as_tibbles()] with `kind = "observed_data"`.
#' Prefer [as_tibbles()] in new code.
#'
#' @inheritParams as_tibbles
#' @return A tibble in long format with columns `name`, `xValues`,
#'   `yValues`, `yErrorValues`, `xDimension`, `xUnit`, `yDimension`,
#'   `yUnit`, `yErrorType`, `yErrorUnit`, `molWeight`, `lloq`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' observed_data_df <- get_observed_data_dfs(snapshot)
#' }
get_observed_data_dfs <- function(snapshot) {
  as_tibbles(snapshot, "observed_data")
}
