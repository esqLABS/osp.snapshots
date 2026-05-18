#' Convert a snapshot collection to a tibble or list of tibbles
#'
#' @description
#' Unified bridge from a `Snapshot` to the tidyverse for any
#' building-block kind plus observed data. Replaces the eight
#' per-kind `get_*_dfs()` functions as the canonical entry point;
#' those remain available as thin wrappers.
#'
#' @param snapshot A `Snapshot` object.
#' @param kind Character scalar naming the collection to convert.
#'   One of `"compounds"`, `"individuals"`, `"formulations"`,
#'   `"populations"`, `"events"`, `"expression_profiles"`,
#'   `"protocols"`, `"observed_data"`.
#'
#' @return A tibble or a named list of tibbles, depending on `kind`:
#' \itemize{
#'   \item `"compounds"`, `"protocols"`, `"observed_data"`: a single
#'     tibble.
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
#' # Single tibble
#' compounds <- as_tibbles(snapshot, "compounds")
#'
#' # List of tibbles
#' individuals <- as_tibbles(snapshot, "individuals")
#' individuals$individuals_parameters
#' }
as_tibbles <- function(snapshot, kind) {
  validate_snapshot(snapshot)

  builders <- list(
    compounds = as_tibbles_compounds,
    individuals = as_tibbles_individuals,
    formulations = as_tibbles_formulations,
    populations = as_tibbles_populations,
    events = as_tibbles_events,
    expression_profiles = as_tibbles_expression_profiles,
    protocols = as_tibbles_protocols,
    observed_data = as_tibbles_observed_data
  )

  if (!is.character(kind) || length(kind) != 1L || is.na(kind)) {
    cli::cli_abort(
      "{.arg kind} must be a single string, not {.obj_type_friendly {kind}}."
    )
  }

  if (!kind %in% names(builders)) {
    cli::cli_abort(c(
      "Unknown {.arg kind} {.val {kind}}.",
      i = "Must be one of {.val {names(builders)}}."
    ))
  }

  builders[[kind]](snapshot)
}

as_tibbles_compounds <- function(snapshot) {
  compounds <- snapshot$compounds

  result <- tibble::tibble(
    compound = character(0),
    category = character(0),
    type = character(0),
    parameter = character(0),
    value = character(0),
    unit = character(0),
    data_source = character(0),
    source = character(0)
  )

  if (length(compounds) == 0) {
    return(result)
  }

  compound_dfs <- lapply(compounds, \(compound) compound$to_df())
  result <- dplyr::bind_rows(compound_dfs)
  result[order(result$compound), ]
}

as_tibbles_individuals <- function(snapshot) {
  individuals <- snapshot$individuals

  result <- list(
    individuals = tibble::tibble(
      individual_id = character(0),
      name = character(0),
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

  if (length(protocols) == 0) {
    return(tibble::tibble(
      protocol_id = character(0),
      protocol_name = character(0),
      is_advanced = logical(0),
      protocol_application_type = character(0),
      protocol_dosing_interval = character(0),
      protocol_time_unit = character(0),
      schema_id = character(0),
      schema_name = character(0),
      schema_item_id = character(0),
      schema_item_name = character(0),
      schema_item_application_type = character(0),
      schema_item_formulation_key = character(0),
      parameter_name = character(0),
      parameter_value = numeric(0),
      parameter_unit = character(0),
      parameter_source = character(0),
      parameter_description = character(0),
      parameter_source_id = integer(0)
    ))
  }

  protocol_dfs <- lapply(protocols, \(protocol) protocol$to_df())
  dplyr::bind_rows(protocol_dfs)
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
#' @return A tibble with one row per compound parameter; see
#'   [as_tibbles()] for the column contract.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' compounds_df <- get_compounds_dfs(snapshot)
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
