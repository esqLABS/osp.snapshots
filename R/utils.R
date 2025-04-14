#' Validate that a unit is valid for a given dimension
#'
#' @description
#' Check if a unit is valid for a given dimension using ospsuite units.
#' Throws an error if the unit is invalid.
#'
#' @param unit Unit to validate
#' @param dimension Dimension the unit should belong to
#' @return TRUE if valid, throws an error if invalid
#' @export
validate_unit <- function(unit, dimension) {
  valid_units <- ospsuite::ospUnits[[dimension]]
  if (!(unit %in% valid_units)) {
    cli::cli_abort(
      c(
        "Invalid unit: {unit}",
        "i" = "Valid units for {dimension} are: {toString(valid_units)}"
      )
    )
  }
  return(TRUE)
}

#' Validate that a species is valid
#'
#' @description
#' Check if a species is valid using ospsuite Species enum.
#' Throws an error if the species is invalid.
#'
#' @param species Species value to validate
#' @return TRUE if valid, throws an error if invalid
#' @export
validate_species <- function(species) {
  valid_species <- ospsuite::Species
  if (!species %in% valid_species) {
    cli::cli_abort(
      c(
        "Invalid species: {species}",
        "i" = "Valid species are: {toString(valid_species)}"
      )
    )
  }
  return(TRUE)
}

#' Validate that a population is valid
#'
#' @description
#' Check if a population is valid using ospsuite HumanPopulation enum.
#' Throws an error if the population is invalid.
#'
#' @param population Population value to validate
#' @return TRUE if valid, throws an error if invalid
#' @export
validate_population <- function(population) {
  valid_populations <- ospsuite::HumanPopulation
  if (!population %in% valid_populations) {
    cli::cli_abort(
      c(
        "Invalid population: {population}",
        "i" = "Valid populations are: {toString(valid_populations)}"
      )
    )
  }
  return(TRUE)
}

#' Validate that a gender is valid
#'
#' @description
#' Check if a gender is valid using ospsuite Gender enum.
#' Throws an error if the gender is invalid.
#'
#' @param gender Gender value to validate
#' @return TRUE if valid, throws an error if invalid
#' @export
validate_gender <- function(gender) {
  valid_genders <- ospsuite::Gender
  if (!gender %in% valid_genders) {
    cli::cli_abort(
      c(
        "Invalid gender: {gender}",
        "i" = "Valid genders are: {toString(valid_genders)}"
      )
    )
  }
  return(TRUE)
}
