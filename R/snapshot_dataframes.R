#' Get all compounds in a snapshot as data frames
#'
#' @description
#' This function extracts all compounds from a snapshot and converts them to
#' data frames for easier analysis and visualization, following the same format
#' as the legacy compound dataframe functions.
#'
#' @param snapshot A Snapshot object
#' @return A data frame with compound parameter data including:
#' \itemize{
#'   \item compound: Compound name
#'   \item category: Broad parameter category - "physicochemical_property" for basic properties,
#'         or descriptive categories like "protein_binding_partners", "metabolizing_enzymes",
#'         "hepatic_clearance", "transporter_proteins", "renal_clearance", "biliary_clearance",
#'         "inhibition", "induction" for process-related data
#'   \item type: Specific type within category - for physicochemical properties: property type
#'         (e.g., "lipophilicity", "fraction_unbound", "molecular_weight"); for processes:
#'         the InternalName from process data (e.g., "SpecificBinding", "Metabolization", "ActiveTransport")
#'   \item parameter: Specific parameter details (e.g., parameter names, molecule names)
#'   \item value: Parameter value (raw values from data)
#'   \item unit: Parameter unit
#'   \item data_source: Data source information from the snapshot
#'   \item source: Original source information
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all compound data as a data frame
#' compounds_df <- get_compounds_dfs(snapshot)
#'
#' }
get_compounds_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all compounds from the snapshot
  compounds <- snapshot$compounds

  # Initialize empty result dataframe
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

  # If there are no compounds, return the empty tibble
  if (length(compounds) == 0) {
    return(result)
  }

  # Get data frames for each compound and combine them
  compound_dfs <- lapply(compounds, function(compound) {
    compound$to_df()
  })

  # Combine all compound data frames
  if (length(compound_dfs) > 0) {
    result <- dplyr::bind_rows(compound_dfs)
  }

  # Sort compounds by compound name
  result <- result[order(result$compound), ]
  return(result)
}

#' Get all individuals in a snapshot as data frames
#'
#' @description
#' This function extracts all individuals from a snapshot and converts them to
#' data frames for easier analysis and visualization.
#'
#' @param snapshot A Snapshot object
#'
#' @return A list containing three data frames:
#' \itemize{
#'   \item individuals: Basic information about each individual
#'   \item individuals_parameters: All parameters for all individuals
#'   \item individuals_expressions: Expression profiles for all individuals
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all individual data as data frames
#' dfs <- get_individuals_dfs(snapshot)
#'
#' # Access specific data frames
#' individuals_df <- dfs$individuals
#' individuals_parameters_df <- dfs$individuals_parameters
#' individuals_expressions_df <- dfs$individuals_expressions
#' }
get_individuals_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all individuals from the snapshot
  individuals <- snapshot$individuals

  # Initialize empty result list with tibbles for each data type
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

  # If there are no individuals, return the empty tibbles
  if (length(individuals) == 0) {
    return(result)
  }

  # Get data frames for each individual and combine them
  ind_dfs <- lapply(individuals, function(individual) {
    individual$to_df()
  })

  # Combine all individuals data frames
  if (length(ind_dfs) > 0) {
    individuals_dfs <- lapply(ind_dfs, function(df) df$individuals)
    result$individuals <- dplyr::bind_rows(individuals_dfs)
    param_dfs <- lapply(ind_dfs, function(df) df$individuals_parameters)
    result$individuals_parameters <- dplyr::bind_rows(param_dfs)
    expr_dfs <- lapply(ind_dfs, function(df) df$individuals_expressions)
    result$individuals_expressions <- dplyr::bind_rows(expr_dfs)
  }

  return(result)
}


#' Get all formulations in a snapshot as data frames
#'
#' @description
#' This function extracts all formulations from a snapshot and converts them to
#' data frames for easier analysis and visualization.
#'
#' @param snapshot A Snapshot object
#'
#' @return A list containing two data frames:
#' \itemize{
#'   \item formulations: Basic information about each formulation
#'   \item formulations_parameters: All parameters for all formulations, including
#'         table parameter points. Table parameter points have is_table_point=TRUE
#'         and include x_value, y_value, and table_name values.
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all formulation data as data frames
#' dfs <- get_formulations_dfs(snapshot)
#'
#' # Access specific data frames
#' formulations_df <- dfs$formulations
#' formulations_parameters_df <- dfs$formulations_parameters
#'
#' # Filter to get only table points
#' table_points <- formulations_parameters_df[formulations_parameters_df$is_table_point, ]
#' }
get_formulations_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all formulations from the snapshot
  formulations <- snapshot$formulations

  # Initialize empty result list with tibbles for each data type
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

  # If there are no formulations, return the empty tibbles
  if (length(formulations) == 0) {
    return(result)
  }

  # Get data frames for each formulation and combine them
  form_dfs <- lapply(formulations, function(formulation) {
    formulation$to_df()
  })

  # Combine all main data frames
  if (length(form_dfs) > 0) {
    formulations_dfs <- lapply(form_dfs, function(df) df$formulations)
    result$formulations <- dplyr::bind_rows(formulations_dfs)
    param_dfs <- lapply(form_dfs, function(df) df$formulations_parameters)
    result$formulations_parameters <- dplyr::bind_rows(param_dfs)
  }

  return(result)
}

#' Get all populations in a snapshot as data frames
#'
#' @description
#' This function extracts all populations from a snapshot and converts them to
#' data frames for easier analysis and visualization.
#'
#' @param snapshot A Snapshot object
#'
#' @return A list containing two data frames:
#' \itemize{
#'   \item populations: Basic information about each population including ranges
#'   \item populations_parameters: All parameters for all populations
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all population data as data frames
#' dfs <- get_populations_dfs(snapshot)
#'
#' # Access specific data frames
#' populations_df <- dfs$populations
#' populations_parameters_df <- dfs$populations_parameters
#' }
get_populations_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all populations from the snapshot
  populations <- snapshot$populations

  # Initialize empty result list with tibbles for each data type
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

  # If there are no populations, return the empty tibbles
  if (length(populations) == 0) {
    return(result)
  }

  # Process each population
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

  return(result)
}

#' Get all events in a snapshot as data frames
#'
#' @description
#' This function extracts all events from a snapshot and converts them to
#' data frames for easier analysis and visualization.
#'
#' @param snapshot A Snapshot object
#'
#' @return A list containing two data frames:
#' \itemize{
#'   \item events: Basic information about each event
#'   \item events_parameters: All parameters for all events
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all event data as data frames
#' dfs <- get_events_dfs(snapshot)
#'
#' # Access specific data frames
#' events_df <- dfs$events
#' events_parameters_df <- dfs$events_parameters
#' }
get_events_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all events from the snapshot
  events <- snapshot$events

  # Initialize empty result list with tibbles for each data type
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

  # If there are no events, return the empty tibbles
  if (length(events) == 0) {
    return(result)
  }

  # Process each event
  basic_list <- list()
  params_list <- list()

  for (event_name in names(events)) {
    event <- events[[event_name]]

    # Use the to_dataframe method to get consistent data structure
    event_df <- event$to_dataframe()

    # Add event_id to the main data
    if (!is.null(event_df$events)) {
      events_df <- dplyr::bind_cols(
        tibble::tibble(event_id = event_name),
        event_df$events
      )
      basic_list[[length(basic_list) + 1]] <- events_df
    }

    # Add event_id to the parameters data if available
    if (
      !is.null(event_df$events_parameters) &&
        nrow(event_df$events_parameters) > 0
    ) {
      # Add event_id and rename columns to match expected structure
      param_df <- dplyr::bind_cols(
        tibble::tibble(
          event_id = rep(event_name, nrow(event_df$events_parameters))
        ),
        event_df$events_parameters
      ) %>%
        dplyr::rename(
          parameter = param_name,
          value = param_value,
          unit = param_unit
        )

      params_list[[length(params_list) + 1]] <- param_df
    }
  }

  # Combine all data frames
  if (length(basic_list) > 0) {
    result$events <- dplyr::bind_rows(basic_list)
  }

  if (length(params_list) > 0) {
    result$events_parameters <- dplyr::bind_rows(params_list)
  }

  return(result)
}

#' Get all expression profiles in a snapshot as data frames
#'
#' @description
#' This function extracts all expression profiles from a snapshot and converts them to
#' data frames for easier analysis and visualization.
#'
#' @param snapshot A Snapshot object
#'
#' @return A list containing two data frames:
#' \itemize{
#'   \item expression_profiles: Basic information about each expression profile
#'   \item expression_profiles_parameters: All parameters for all expression profiles
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all expression profile data as data frames
#' dfs <- get_expression_profiles_dfs(snapshot)
#'
#' # Access specific data frames
#' expression_profiles_df <- dfs$expression_profiles
#' expression_profiles_parameters_df <- dfs$expression_profiles_parameters
#' }
get_expression_profiles_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all expression profiles from the snapshot
  expression_profiles <- snapshot$expression_profiles

  # Initialize empty result list with tibbles for each data type
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

  # If there are no expression profiles, return the empty tibbles
  if (length(expression_profiles) == 0) {
    return(result)
  }

  # Get data frames for each expression profile and combine them
  profile_dfs <- lapply(expression_profiles, function(profile) {
    profile$to_df()
  })

  # Combine all main data frames
  if (length(profile_dfs) > 0) {
    expression_profiles_dfs <- lapply(
      profile_dfs,
      function(df) df$expression_profiles
    )
    result$expression_profiles <- dplyr::bind_rows(expression_profiles_dfs)
    param_dfs <- lapply(
      profile_dfs,
      function(df) df$expression_profiles_parameters
    )
    param_dfs <- param_dfs[!sapply(param_dfs, is.null)]
    if (length(param_dfs) > 0) {
      result$expression_profiles_parameters <- dplyr::bind_rows(param_dfs)
    }
  }

  return(result)
}

#' Get all protocols in a snapshot as a single consolidated data frame
#'
#' @description
#' This function extracts all protocols from a snapshot and converts them to
#' a single consolidated data frame containing all protocol information, including
#' simple protocol parameters and advanced protocol schema details.
#'
#' @param snapshot A Snapshot object
#'
#' @return A tibble containing all protocol data with the following columns:
#' \itemize{
#'   \item protocol_id: Protocol identifier
#'   \item protocol_name: Protocol name
#'   \item is_advanced: Whether the protocol is advanced (schema-based)
#'   \item protocol_application_type: Application type (for simple protocols)
#'   \item protocol_dosing_interval: Dosing interval (for simple protocols)
#'   \item protocol_time_unit: Time unit
#'   \item schema_id: Schema identifier (NA for simple protocols)
#'   \item schema_name: Schema name (NA for simple protocols)
#'   \item schema_item_id: Schema item identifier (NA for simple protocols)
#'   \item schema_item_name: Schema item name (NA for simple protocols)
#'   \item schema_item_application_type: Schema item application type (NA for simple protocols)
#'   \item schema_item_formulation_key: Schema item formulation key (NA for simple protocols)
#'   \item parameter_name: Parameter name (NA if no parameters)
#'   \item parameter_value: Parameter value (NA if no parameters)
#'   \item parameter_unit: Parameter unit (NA if no parameters)
#'   \item parameter_source: Parameter source (NA if no parameters)
#'   \item parameter_description: Parameter description (NA if no parameters)
#'   \item parameter_source_id: Parameter source ID (NA if no parameters)
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all protocol data as a single data frame
#' protocols_df <- get_protocols_dfs(snapshot)
#'
#' # Filter simple protocols
#' simple_protocols <- protocols_df[!protocols_df$is_advanced, ]
#'
#' # Filter advanced protocols
#' advanced_protocols <- protocols_df[protocols_df$is_advanced, ]
#' }
get_protocols_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all protocols from the snapshot
  protocols <- snapshot$protocols

  # If there are no protocols, return an empty tibble with correct structure
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

  # Get data frames for each protocol and combine them
  protocol_dfs <- lapply(protocols, function(protocol) {
    protocol$to_df()
  })

  # Combine all data frames
  result <- dplyr::bind_rows(protocol_dfs)

  return(result)
}

#' Get all observed data in a snapshot as data frames
#'
#' @description
#' This function extracts all observed data from a snapshot and converts them to
#' data frames for easier analysis and visualization.
#'
#' @param snapshot A Snapshot object
#'
#' @return A tibble containing all observed data in long format with columns:
#' \itemize{
#'   \item observed_data_name: Name of the observed data set
#'   \item time: Time values
#'   \item time_unit: Unit for time values
#'   \item column_name: Name of the measurement column
#'   \item value: Measured values
#'   \item unit: Unit for the measured values
#'   \item path: Full path of the measurement
#'   \item auxiliary_type: Type of auxiliary data (e.g., ArithmeticMean, ArithmeticStdDev)
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Get all observed data as data frames
#' observed_data_df <- get_observed_data_dfs(snapshot)
#' }
get_observed_data_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all observed data from the snapshot
  observed_data_items <- snapshot$observed_data

  # Initialize empty result dataframe with compatible structure
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

  # If there are no observed data items, return the empty tibble
  if (length(observed_data_items) == 0) {
    return(result)
  }

  # Convert DataSet objects to tibble using ospsuite function
  if (length(observed_data_items) > 0) {
    # Convert list of DataSet objects to a combined tibble
    result <- ospsuite::dataSetToTibble(dataSets = unname(observed_data_items))
  }

  # Sort by name and time
  result <- result[order(result$name, result$xValues), ]
  return(result)
}
