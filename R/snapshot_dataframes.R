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
    if (!inherits(snapshot, "Snapshot")) {
        cli::cli_abort("Input must be a Snapshot object")
    }

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
            path = character(0),
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

#' Get origin data for all individuals in a snapshot
#'
#' @description
#' Extract origin data from all individuals in a snapshot and combine them into a single data frame.
#'
#' @param snapshot A snapshot object
#'
#' @return A tibble containing origin data for all individuals
#'
#' @export
get_origin_df <- function(snapshot) {
    get_individuals_dfs(snapshot)$origin
}

#' Get parameter data for all individuals in a snapshot
#'
#' @description
#' Extract parameter data from all individuals in a snapshot and combine them into a single data frame.
#'
#' @param snapshot A snapshot object
#'
#' @return A tibble containing parameter data for all individuals
#'
#' @export
get_parameters_df <- function(snapshot) {
    get_individuals_dfs(snapshot)$parameters
}

#' Get expression profile data for all individuals in a snapshot
#'
#' @description
#' Extract expression profile data from all individuals in a snapshot and combine them into a single data frame.
#'
#' @param snapshot A snapshot object
#'
#' @return A tibble containing expression profile data for all individuals
#'
#' @export
get_expressions_df <- function(snapshot) {
    get_individuals_dfs(snapshot)$expressions
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
    if (!inherits(snapshot, "Snapshot")) {
        cli::cli_abort("Input must be a Snapshot object")
    }

    # Get all formulations from the snapshot
    formulations <- snapshot$formulations

    # Initialize empty result list with tibbles for each data type
    result <- list(
        basic = tibble::tibble(
            formulation_id = character(0),
            name = character(0),
            formulation_type = character(0),
            formulation_type_human = character(0)
        ),
        parameters = tibble::tibble(
            formulation_id = character(0),
            name = character(0),
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

#' Get basic data for all formulations in a snapshot
#'
#' @description
#' Extract basic data from all formulations in a snapshot and combine them into a single data frame.
#'
#' @param snapshot A snapshot object
#'
#' @return A tibble containing basic data for all formulations
#'
#' @export
get_formulations_basic_df <- function(snapshot) {
    get_formulations_dfs(snapshot)$basic
}

#' Get parameter data for all formulations in a snapshot
#'
#' @description
#' Extract parameter data from all formulations in a snapshot and combine them into a single data frame.
#'
#' @param snapshot A snapshot object
#'
#' @return A tibble containing parameter data for all formulations
#'
#' @export
get_formulations_parameters_df <- function(snapshot) {
    get_formulations_dfs(snapshot)$parameters
}
