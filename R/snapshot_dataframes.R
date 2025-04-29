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
#'   \item characteristics: Basic information about each individual
#'   \item parameters: All parameters for all individuals
#'   \item expressions: Expression profiles for all individuals
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
#' characteristics_df <- dfs$characteristics
#' parameters_df <- dfs$parameters
#' expressions_df <- dfs$expressions
#' }
get_individuals_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all individuals from the snapshot
  individuals <- snapshot$individuals

  # Initialize empty result list with tibbles for each data type
  result <- list(
    characteristics = tibble::tibble(
      individual_id = character(0),
      name = character(0),
      seed = integer(0),
      species = character(0),
      population = character(0),
      gender = character(0),
      age = numeric(0),
      age_unit = character(0),
      weight = numeric(0),
      weight_unit = character(0),
      height = numeric(0),
      height_unit = character(0),
      disease_state = character(0),
      calculation_methods = character(0)
    ),
    parameters = tibble::tibble(
      individual_id = character(0),
      name = character(0),
      value = numeric(0),
      unit = character(0)
    ),
    expressions = tibble::tibble(
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

  # Combine all characteristics data frames
  if (length(ind_dfs) > 0) {
    characteristics_dfs <- lapply(ind_dfs, function(df) df$characteristics)
    result$characteristics <- dplyr::bind_rows(characteristics_dfs)

    # Combine all parameter data frames
    param_dfs <- lapply(ind_dfs, function(df) df$parameters)
    result$parameters <- dplyr::bind_rows(param_dfs)

    # Combine all expression profile data frames
    expr_dfs <- lapply(ind_dfs, function(df) df$expressions)
    result$expressions <- dplyr::bind_rows(expr_dfs)
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
#'   \item basic: Basic information about each formulation
#'   \item parameters: All parameters for all formulations
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
#' basic_df <- dfs$basic
#' parameters_df <- dfs$parameters
#' }
get_formulations_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all formulations from the snapshot
  formulations <- snapshot$formulations

  # Initialize empty result list with tibbles for each data type
  result <- list(
    basic = tibble::tibble(
      formulation_id = character(0),
      name = character(0),
      type = character(0),
      application_type = character(0)
    ),
    parameters = tibble::tibble(
      formulation_id = character(0),
      parameter = character(0),
      value = numeric(0),
      unit = character(0)
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

  # Combine all basic data frames
  if (length(form_dfs) > 0) {
    basic_dfs <- lapply(form_dfs, function(df) df$basic)
    result$basic <- dplyr::bind_rows(basic_dfs)

    # Combine all parameter data frames
    param_dfs <- lapply(form_dfs, function(df) df$parameters)
    result$parameters <- dplyr::bind_rows(param_dfs)
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
#'   \item characteristics: Basic information about each population including ranges
#'   \item parameters: All parameters for all populations
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
#' characteristics_df <- dfs$characteristics
#' parameters_df <- dfs$parameters
#' }
get_populations_dfs <- function(snapshot) {
  # Check if input is a snapshot
  validate_snapshot(snapshot)

  # Get all populations from the snapshot
  populations <- snapshot$populations

  # Initialize empty result list with tibbles for each data type
  result <- list(
    characteristics = tibble::tibble(
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
    parameters = tibble::tibble(
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
  characteristics_list <- list()
  params_list <- list()

  for (pop in populations) {
    # Create characteristics data frame with all columns

    pop_dfs <- pop$to_df()

    result$characteristics <- dplyr::bind_rows(
      result$characteristics,
      pop_dfs$characteristics
    )

    result$parameters <- dplyr::bind_rows(
      result$parameters,
      pop_dfs$parameters
    )
  }

  return(result)
}
