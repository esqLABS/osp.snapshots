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
#'   \item origin: Basic information about each individual
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
#' origin_df <- dfs$origin
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
    origin = tibble::tibble(
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

  # Combine all origin data frames
  if (length(ind_dfs) > 0) {
    origin_dfs <- lapply(ind_dfs, function(df) df$origin)
    result$origin <- dplyr::bind_rows(origin_dfs)

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
#'   \item advanced_parameters: Advanced parameters information
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
#' advanced_parameters_df <- dfs$advanced_parameters
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
      bmi_unit = character(0)
    ),
    advanced_parameters = tibble::tibble(
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
  advanced_params_list <- list()

  for (pop in populations) {
    # Create characteristics data frame with all columns
    characteristics_df <- tibble::tibble(
      population_id = pop$name,
      name = pop$name,
      seed = pop$seed,
      number_of_individuals = pop$number_of_individuals,
      proportion_of_females = pop$proportion_of_females,
      source_population = NA_character_,
      age_min = NA_real_,
      age_max = NA_real_,
      age_unit = NA_character_,
      weight_min = NA_real_,
      weight_max = NA_real_,
      weight_unit = NA_character_,
      height_min = NA_real_,
      height_max = NA_real_,
      height_unit = NA_character_,
      bmi_min = NA_real_,
      bmi_max = NA_real_,
      bmi_unit = NA_character_
    )

    # Add source population if available
    if (!is.null(pop$source_population)) {
      characteristics_df$source_population <- pop$source_population
    }

    # Add age range
    if (!is.null(pop$age_range)) {
      characteristics_df$age_min <- pop$age_range$min
      characteristics_df$age_max <- pop$age_range$max
      characteristics_df$age_unit <- pop$age_range$unit
    }

    # Add weight range if available
    if (!is.null(pop$weight_range)) {
      characteristics_df$weight_min <- pop$weight_range$min
      characteristics_df$weight_max <- pop$weight_range$max
      characteristics_df$weight_unit <- pop$weight_range$unit
    }

    # Add height range if available
    if (!is.null(pop$height_range)) {
      characteristics_df$height_min <- pop$height_range$min
      characteristics_df$height_max <- pop$height_range$max
      characteristics_df$height_unit <- pop$height_range$unit
    }

    # Add BMI range if available
    if (!is.null(pop$bmi_range)) {
      characteristics_df$bmi_min <- pop$bmi_range$min
      characteristics_df$bmi_max <- pop$bmi_range$max
      characteristics_df$bmi_unit <- pop$bmi_range$unit
    }

    characteristics_list[[
      length(characteristics_list) + 1
    ]] <- characteristics_df

    # Process advanced parameters
    if (length(pop$advanced_parameters) > 0) {
      adv_params_df <- tibble::tibble()

      for (param in pop$advanced_parameters) {
        if (length(param$parameters) > 0) {
          for (stat in param$parameters) {
            # Get source and description if available
            source <- NA_character_
            description <- NA_character_

            if (!is.null(stat$ValueOrigin)) {
              source <- stat$ValueOrigin$Source
              if (!is.null(stat$ValueOrigin$Description)) {
                description <- stat$ValueOrigin$Description
              }
            }

            adv_params_df <- dplyr::bind_rows(
              adv_params_df,
              tibble::tibble(
                population_id = pop$name,
                parameter = param$name,
                seed = param$seed,
                distribution_type = param$distribution_type,
                statistic = stat$Name,
                value = stat$Value,
                unit = ifelse(is.null(stat$Unit), NA_character_, stat$Unit),
                source = source,
                description = description
              )
            )
          }
        } else {
          # If no parameters, add just the basic info
          adv_params_df <- dplyr::bind_rows(
            adv_params_df,
            tibble::tibble(
              population_id = pop$name,
              parameter = param$name,
              seed = param$seed,
              distribution_type = param$distribution_type,
              statistic = NA_character_,
              value = NA_real_,
              unit = NA_character_,
              source = NA_character_,
              description = NA_character_
            )
          )
        }
      }

      if (nrow(adv_params_df) > 0) {
        advanced_params_list[[
          length(advanced_params_list) + 1
        ]] <- adv_params_df
      }
    }
  }

  # Combine all data frames
  if (length(characteristics_list) > 0) {
    result$characteristics <- dplyr::bind_rows(characteristics_list)
  }

  if (length(advanced_params_list) > 0) {
    result$advanced_parameters <- dplyr::bind_rows(advanced_params_list)
  }

  return(result)
}
