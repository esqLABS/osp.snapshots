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
#' @param time A [time()] object giving the time grid x-values and their
#'   unit (required).
#' @param values A [values()] object giving the measurement y-values, their
#'   dimension, and an optional unit (required), same length as `time`. The
#'   dimension is supplied to [values()] and is required there.
#' @param error A [error()] object giving the optional error y-values, an
#'   optional unit (defaulting to the values unit), and the auxiliary type.
#'   Same length as the values series. `NULL` for no error series.
#' @param molecular_weight Numeric. Molecular weight to attach to the
#'   data set, in g/mol.
#' @param lloq Numeric. Lower limit of quantification.
#' @param metadata Named list. Extended properties (key/value pairs)
#'   stored alongside the data set.
#'
#' @return An `ospsuite::DataSet` object.
#' @seealso [time()], [values()], [error()] for the series value-object
#'   helpers.
#' @export
#'
#' @examples
#' # Create a minimal observed data set
#' obs <- create_observed_data(
#'   name = "Subject 001",
#'   time = time(c(0, 1, 2, 4, 8)),
#'   values = values(c(0, 12, 18, 11, 5), dimension = "Concentration (mass)")
#' )
#'
#' # Create observed data with units and error
#' obs <- create_observed_data(
#'   name = "Subject 001",
#'   time = time(c(0, 1, 2, 4, 8), unit = "h"),
#'   values = values(
#'     c(0, 12, 18, 11, 5),
#'     unit = "mg/l",
#'     dimension = "Concentration (mass)"
#'   ),
#'   error = error(c(0, 1.2, 1.5, 1.1, 0.6), type = "ArithmeticStdDev")
#' )
create_observed_data <- function(
  name,
  time,
  values,
  error = NULL,
  molecular_weight = NULL,
  lloq = NULL,
  metadata = NULL
) {
  check_required_string(name, "name")
  # `time` and `values` are required and must be built with their helpers.
  # The values dimension (required) is enforced by `values()` itself, so by
  # the time the factory runs, `values$dimension` is guaranteed present.
  require_value_spec(
    time,
    "time_spec",
    "time",
    example = "time = time(c(0, 1, 2))"
  )
  if (is.null(time)) {
    cli::cli_abort(c(
      "{.arg time} must be built with {.fn time}.",
      "i" = "For example {.code time = time(c(0, 1, 2))}."
    ))
  }
  require_value_spec(
    values,
    "values_spec",
    "values",
    example = "values = values(c(0, 12), dimension = \"Concentration (mass)\")"
  )
  if (is.null(values)) {
    cli::cli_abort(c(
      "{.arg values} must be built with {.fn values}.",
      "i" = "For example {.code values = values(c(0, 12), dimension = \\
      \"Concentration (mass)\")}."
    ))
  }
  require_value_spec(
    error,
    "error_spec",
    "error",
    example = "error = error(c(0, 1))"
  )

  if (length(time$value) != length(values$value)) {
    cli::cli_abort(
      "{.arg time} and {.arg values} must have the same length, got {length(time$value)} and {length(values$value)}"
    )
  }
  if (!is.null(error) && length(error$value) != length(values$value)) {
    cli::cli_abort(
      "{.arg error} must be a numeric vector of the same length as {.arg values}"
    )
  }
  # The error dimension is the values-series dimension; validate the error
  # unit against it when the error carries its own unit.
  if (!is.null(error) && !is.null(error$unit)) {
    validate_unit(error$unit, values$dimension)
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
    Values = as.list(values$value),
    Dimension = values$dimension
  )
  if (!is.null(values$unit)) {
    column$Unit <- values$unit
  }
  if (length(data_info) > 0) {
    column$DataInfo <- data_info
  }

  if (!is.null(error)) {
    related <- list(
      Values = as.list(error$value),
      Unit = error$unit %||% values$unit,
      DataInfo = list(AuxiliaryType = error$type %||% "ArithmeticStdDev")
    )
    column$RelatedColumns <- list(related)
  }

  data <- list(
    Name = name,
    BaseGrid = list(Values = as.list(time$value), Unit = time$unit),
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
