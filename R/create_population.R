#' Create a new population
#'
#' @description
#' Create a [Population] building block from named arguments. This is a
#' thin factory around `Population$new()` that builds the raw `Settings`
#' shape for you.
#'
#' A [Population] is a recipe for generating subjects: it owns the
#' settings PK-Sim uses to sample a cohort at simulation time. Subjects
#' themselves are not stored in the snapshot.
#'
#' @param name Character. Name of the population (required).
#' @param number_of_individuals Integer. Number of subjects to generate
#'   (required, must be a positive integer).
#' @param proportion_of_females Numeric. Percentage of females in the
#'   population, between 0 and 100. Defaults to `50`.
#' @param individual_name Character. Name of the base [Individual]
#'   building block the population samples from.
#' @param species Character. Species used for the base individual when
#'   `individual_name` is not provided.
#' @param source_population Character. Population name used for the base
#'   individual (for example `"European_ICRP_2002"`).
#' @param age_range A [Range] object describing the age bounds (see
#'   [range()]).
#' @param weight_range A [Range] object describing the weight bounds.
#' @param height_range A [Range] object describing the height bounds.
#' @param bmi_range A [Range] object describing the BMI bounds.
#' @param seed Integer. Random seed for population generation.
#' @param advanced_parameters List of [AdvancedParameter] objects or raw
#'   advanced-parameter lists that override default variability
#'   distributions.
#'
#' @return A [Population] object.
#' @export
#'
#' @examples
#' # Create a minimal population
#' pop <- create_population(
#'   name = "Adults",
#'   number_of_individuals = 100
#' )
#'
#' # Create a population with demographic ranges
#' pop <- create_population(
#'   name = "Healthy Adults",
#'   number_of_individuals = 50,
#'   proportion_of_females = 50,
#'   species = "Human",
#'   source_population = "European_ICRP_2002",
#'   age_range = range(20, 60, "year(s)"),
#'   weight_range = range(50, 90, "kg")
#' )
create_population <- function(
  name,
  number_of_individuals,
  proportion_of_females = 50,
  individual_name = NULL,
  species = NULL,
  source_population = NULL,
  age_range = NULL,
  weight_range = NULL,
  height_range = NULL,
  bmi_range = NULL,
  seed = NULL,
  advanced_parameters = NULL
) {
  check_required_string(name, "name")
  if (
    missing(number_of_individuals) ||
      !is.numeric(number_of_individuals) ||
      length(number_of_individuals) != 1 ||
      is.na(number_of_individuals) ||
      number_of_individuals < 1 ||
      number_of_individuals != round(number_of_individuals)
  ) {
    cli::cli_abort(
      "{.arg number_of_individuals} must be a positive integer"
    )
  }
  if (
    !is.numeric(proportion_of_females) ||
      length(proportion_of_females) != 1 ||
      is.na(proportion_of_females) ||
      proportion_of_females < 0 ||
      proportion_of_females > 100
  ) {
    cli::cli_abort(
      "{.arg proportion_of_females} must be a number between 0 and 100"
    )
  }
  if (!is.null(species)) {
    validate_species(species)
  }
  if (!is.null(source_population)) {
    validate_population(source_population)
  }

  range_to_list <- function(value, arg_name) {
    if (is.null(value)) {
      return(NULL)
    }
    if (!inherits(value, "Range")) {
      cli::cli_abort(c(
        "{.arg {arg_name}} must be a {.cls Range} object",
        "i" = "Use {.fn range} to create one."
      ))
    }
    list(Min = value$min, Max = value$max, Unit = value$unit)
  }

  settings <- list(NumberOfIndividuals = number_of_individuals)
  settings$ProportionOfFemales <- proportion_of_females

  individual_data <- list()
  if (!is.null(individual_name)) {
    individual_data$Name <- individual_name
  }
  origin_data <- list()
  if (!is.null(species)) {
    origin_data$Species <- species
  }
  if (!is.null(source_population)) {
    origin_data$Population <- source_population
  }
  if (length(origin_data) > 0) {
    individual_data$OriginData <- origin_data
  }
  if (length(individual_data) > 0) {
    settings$Individual <- individual_data
  }

  age <- range_to_list(age_range, "age_range")
  if (!is.null(age)) {
    settings$Age <- age
  }
  weight <- range_to_list(weight_range, "weight_range")
  if (!is.null(weight)) {
    settings$Weight <- weight
  }
  height <- range_to_list(height_range, "height_range")
  if (!is.null(height)) {
    settings$Height <- height
  }
  bmi <- range_to_list(bmi_range, "bmi_range")
  if (!is.null(bmi)) {
    settings$BMI <- bmi
  }

  data <- list(Name = name, Settings = settings)
  if (!is.null(seed)) {
    data$Seed <- seed
  }
  if (!is.null(advanced_parameters)) {
    if (!is.list(advanced_parameters)) {
      cli::cli_abort("{.arg advanced_parameters} must be a list")
    }
    data$AdvancedParameters <- lapply(advanced_parameters, function(param) {
      if (inherits(param, "AdvancedParameter")) {
        return(param$data)
      }
      param
    })
  }

  Population$new(data)
}
