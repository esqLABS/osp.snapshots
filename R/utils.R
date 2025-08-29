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

#' Validate that an object is a Snapshot
#'
#' @description
#' Check if an object is a Snapshot instance.
#' Throws an error if the object is not a Snapshot.
#'
#' @param snapshot Object to validate
#' @return TRUE if valid, throws an error if invalid
#' @export
validate_snapshot <- function(snapshot) {
  if (!inherits(snapshot, "Snapshot")) {
    cli::cli_abort(
      "Expected a Snapshot object, but got {.cls {class(snapshot)[1]}}"
    )
  }
  return(TRUE)
}

#' Convert ospsuite time units to lubridate-compatible units
#'
#' @description
#' Convert time units from ospsuite format to lubridate-compatible format.
#' This function handles the mapping of units like "day(s)" to "days", etc.
#'
#' @param unit The ospsuite time unit to convert
#' @return A lubridate-compatible time unit
#' @export
convert_ospsuite_time_unit_to_lubridate <- function(unit) {
  if (is.null(unit) || is.na(unit)) {
    return(unit)
  }
  
  # Define mapping from ospsuite units to lubridate units
  unit_mapping <- list(
    "s" = "seconds",
    "min" = "minutes", 
    "h" = "hours",
    "day(s)" = "days",
    "week(s)" = "weeks",
    "month(s)" = "months",
    "year(s)" = "years",
    "ks" = "seconds"  # kiloseconds - will need special handling for value
  )
  
  # Return mapped unit or original if not found
  lubridate_unit <- unit_mapping[[unit]]
  if (!is.null(lubridate_unit)) {
    return(lubridate_unit)
  } else {
    # For unknown units, try to return as is and let lubridate handle it
    cli::cli_warn("Unknown time unit '{unit}', passing through as-is")
    return(unit)
  }
}

#' Convert time value and unit to lubridate duration
#'
#' @description
#' Convert a time value and ospsuite unit to a lubridate duration object.
#' This function handles unit conversion and special cases like kiloseconds.
#'
#' @param value The time value
#' @param unit The ospsuite time unit
#' @return A lubridate duration object
#' @export
convert_ospsuite_time_to_duration <- function(value, unit) {
  if (is.null(value) || is.na(value)) {
    return(lubridate::duration(0))
  }
  
  if (is.null(unit) || is.na(unit)) {
    # Default to seconds if no unit provided
    return(lubridate::duration(value, units = "seconds"))
  }
  
  # Handle special case for kiloseconds
  if (unit == "ks") {
    # Convert kiloseconds to seconds
    return(lubridate::duration(value * 1000, units = "seconds"))
  }
  
  # Convert unit and create duration
  lubridate_unit <- convert_ospsuite_time_unit_to_lubridate(unit)
  return(lubridate::duration(value, units = lubridate_unit))
}
