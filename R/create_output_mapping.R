#' Create an output-to-observed-data mapping for a simulation
#'
#' @description
#' Build an [OutputMapping] entry, used inside a [Simulation] to link a
#' simulation output quantity to an observed-data set for downstream
#' comparison and parameter identification.
#'
#' All arguments are optional and serialized only when supplied.
#'
#' @param path Character. Simulation output quantity path.
#' @param observed_data Character. Observed-data repository name.
#' @param scaling Character. Scaling used for the mapping: one of
#'   `"Linear"`, `"Log"`.
#' @param weight Numeric. Single weight applied to all points.
#' @param weights Numeric vector. Per-point weights.
#'
#' @return An [OutputMapping] object.
#' @export
#'
#' @examples
#' create_output_mapping(
#'   path = "Organism|PeripheralVenousBlood|Drug|Plasma",
#'   observed_data = "Study A",
#'   scaling = "Log",
#'   weight = 1
#' )
create_output_mapping <- function(
  path = NULL,
  observed_data = NULL,
  scaling = NULL,
  weight = NULL,
  weights = NULL
) {
  data <- list()
  if (!is.null(path)) {
    check_required_string(path, "path")
    data$Path <- path
  }
  if (!is.null(observed_data)) {
    check_required_string(observed_data, "observed_data")
    data$ObservedData <- observed_data
  }
  if (!is.null(scaling)) {
    if (!(scaling %in% OUTPUT_MAPPING_SCALINGS)) {
      cli::cli_abort(
        "{.arg scaling} must be one of {.val {OUTPUT_MAPPING_SCALINGS}}"
      )
    }
    data$Scaling <- scaling
  }
  if (!is.null(weight)) {
    if (!is.numeric(weight) || length(weight) != 1) {
      cli::cli_abort("{.arg weight} must be a single numeric value")
    }
    data$Weight <- weight
  }
  if (!is.null(weights)) {
    if (!is.numeric(weights)) {
      cli::cli_abort("{.arg weights} must be a numeric vector")
    }
    data$Weights <- as.list(weights)
  }
  OutputMapping$new(data)
}
