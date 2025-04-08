#' Get data frames from all individuals in a snapshot
#'
#' @description
#' Extract data from all individuals in a snapshot and combine them into data frames
#' by type (origin, parameters, expressions).
#'
#' @param snapshot A snapshot object
#'
#' @return A list of data frames containing combined data from all individuals:
#' \itemize{
#'   \item origin: General information about individuals
#'   \item parameters: Parameter values for all individuals
#'   \item expressions: Expression profile data for all individuals
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot from a file
#' snapshot <- read_snapshot("path/to/snapshot.json")
#'
#' # Get all individual data as data frames
#' dfs <- get_individuals_df(snapshot)
#'
#' # Access specific data frames
#' origin_df <- dfs$origin
#' parameters_df <- dfs$parameters
#' expressions_df <- dfs$expressions
#' }
get_individuals_df <- function(snapshot) {
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
    get_individuals_df(snapshot)$origin
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
    get_individuals_df(snapshot)$parameters
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
    get_individuals_df(snapshot)$expressions
}
