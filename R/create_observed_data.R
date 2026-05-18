#' Create a new observed data set
#'
#' @description
#' Create an `ospsuite::DataSet` from named arguments. This is a thin
#' factory around [loadDataSetFromSnapshot()] that builds the raw
#' snapshot observed-data shape for you and converts it into a
#' `DataSet`.
#'
#' An observed data entry is the time + value (+ optional error) series
#' attached to a snapshot. It is referenced by name from a [Snapshot]'s
#' simulations.
#'
#' @param name Character. Name of the observed data set (required).
#' @param time Numeric vector. Time grid x-values (required).
#' @param values Numeric vector. Measurement y-values, same length as
#'   `time` (required).
#' @param time_unit Character. Unit for `time` (for example `"h"`,
#'   `"min"`, `"day"`). Defaults to `"h"`.
#' @param value_unit Character. Unit for `values` (for example
#'   `"mg/l"`).
#' @param value_dimension Character. Dimension for `values` (for
#'   example `"Concentration (mass)"`).
#' @param error Numeric vector. Optional error y-values, same length as
#'   `values`.
#' @param error_type Character. Auxiliary type for `error`, typically
#'   one of `"ArithmeticStdDev"`, `"GeometricStdDev"`, or
#'   `"ArithmeticStdErr"`. Defaults to `"ArithmeticStdDev"` when `error`
#'   is provided.
#' @param error_unit Character. Unit for `error`. Defaults to
#'   `value_unit`.
#' @param molecular_weight Numeric. Molecular weight to attach to the
#'   data set, in g/mol.
#' @param lloq Numeric. Lower limit of quantification.
#' @param metadata Named list. Extended properties (key/value pairs)
#'   stored alongside the data set.
#'
#' @return An `ospsuite::DataSet` object.
#' @export
#'
#' @examples
#' # Create a minimal observed data set
#' obs <- create_observed_data(
#'   name = "Subject 001",
#'   time = c(0, 1, 2, 4, 8),
#'   values = c(0, 12, 18, 11, 5)
#' )
#'
#' # Create observed data with units and error
#' obs <- create_observed_data(
#'   name = "Subject 001",
#'   time = c(0, 1, 2, 4, 8),
#'   values = c(0, 12, 18, 11, 5),
#'   time_unit = "h",
#'   value_unit = "mg/l",
#'   value_dimension = "Concentration (mass)",
#'   error = c(0, 1.2, 1.5, 1.1, 0.6),
#'   error_type = "ArithmeticStdDev"
#' )
create_observed_data <- function(
  name,
  time,
  values,
  time_unit = "h",
  value_unit = NULL,
  value_dimension = NULL,
  error = NULL,
  error_type = NULL,
  error_unit = NULL,
  molecular_weight = NULL,
  lloq = NULL,
  metadata = NULL
) {
  check_required_string(name, "name")
  if (missing(time) || !is.numeric(time) || length(time) == 0) {
    cli::cli_abort("{.arg time} must be a non-empty numeric vector")
  }
  if (missing(values) || !is.numeric(values) || length(values) == 0) {
    cli::cli_abort("{.arg values} must be a non-empty numeric vector")
  }
  if (length(time) != length(values)) {
    cli::cli_abort(
      "{.arg time} and {.arg values} must have the same length, got {length(time)} and {length(values)}"
    )
  }
  if (!is.null(error)) {
    if (!is.numeric(error) || length(error) != length(values)) {
      cli::cli_abort(
        "{.arg error} must be a numeric vector of the same length as {.arg values}"
      )
    }
  }
  if (!is.null(metadata) && (!is.list(metadata) || is.null(names(metadata)))) {
    cli::cli_abort("{.arg metadata} must be a named list")
  }

  data_info <- list()
  if (!is.null(molecular_weight)) {
    data_info$MolWeight <- molecular_weight
  }
  if (!is.null(lloq)) {
    data_info$LLOQ <- lloq
  }

  column <- list(
    Values = as.list(values),
    Dimension = value_dimension %||% "Concentration (mass)"
  )
  if (!is.null(value_unit)) {
    column$Unit <- value_unit
  }
  if (length(data_info) > 0) {
    column$DataInfo <- data_info
  }

  if (!is.null(error)) {
    related <- list(
      Values = as.list(error),
      Unit = error_unit %||% value_unit,
      DataInfo = list(AuxiliaryType = error_type %||% "ArithmeticStdDev")
    )
    column$RelatedColumns <- list(related)
  }

  data <- list(
    Name = name,
    BaseGrid = list(Values = as.list(time), Unit = time_unit),
    Columns = list(column)
  )

  if (!is.null(metadata)) {
    data$ExtendedProperties <- lapply(
      names(metadata),
      function(key) list(Name = key, Value = metadata[[key]])
    )
  }

  loadDataSetFromSnapshot(data)
}
