#' Create compound properties for a simulation
#'
#' @description
#' Build a [CompoundProperties] entry, used inside a [Simulation] to
#' configure a [Compound] building block: which calculation methods to
#' apply, which alternatives, processes, and protocol to use. Internal
#' machinery only: [add_simulation()]'s inline `compounds` argument (a
#' friendly config list, with `alternatives` selected by property name and
#' label) is the user-facing way to configure a compound for a simulation;
#' this constructor is not part of the public API.
#'
#' @param name Character. Name of the compound building block (required).
#' @param calculation_methods Character vector. Calculation method names
#'   that override the compound's defaults for this simulation.
#' @param alternatives List of [CompoundGroupSelection] objects or raw
#'   lists.
#' @param processes List of [CompoundProcessSelection] objects or raw
#'   lists.
#' @param protocol A [ProtocolSelection] object or raw list.
#'
#' @return A [CompoundProperties] object.
#' @keywords internal
create_compound_properties <- function(
  name,
  calculation_methods = NULL,
  alternatives = NULL,
  processes = NULL,
  protocol = NULL
) {
  check_required_string(name, "name")

  data <- list(Name = name)

  if (!is.null(calculation_methods)) {
    if (!is.character(calculation_methods)) {
      cli::cli_abort(
        "{.arg calculation_methods} must be a character vector"
      )
    }
    data$CalculationMethods <- as.list(calculation_methods)
  }

  if (!is.null(alternatives)) {
    data$Alternatives <- to_raw_r6_or_list(
      alternatives,
      "CompoundGroupSelection",
      "alternatives"
    )
  }

  if (!is.null(processes)) {
    data$Processes <- to_raw_r6_or_list(
      processes,
      "CompoundProcessSelection",
      "processes"
    )
  }

  if (!is.null(protocol)) {
    if (inherits(protocol, "ProtocolSelection")) {
      data$Protocol <- protocol$data
    } else if (is.list(protocol) && !is.object(protocol)) {
      data$Protocol <- protocol
    } else {
      cli::cli_abort(
        "{.arg protocol} must be a {.cls ProtocolSelection} or a raw list"
      )
    }
  }

  CompoundProperties$new(data)
}
