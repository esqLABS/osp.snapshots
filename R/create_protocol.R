#' Create a new protocol
#'
#' @description
#' Create a [Protocol] building block from named arguments. This is a
#' thin factory around `Protocol$new()` that builds the raw list shape
#' for you.
#'
#' By default this creates a Simple Protocol with a single application
#' type and dosing interval. To create an Advanced Protocol pass a list
#' of schemas via `schemas` instead of `application_type` and
#' `dosing_interval`.
#'
#' @param name Character. Name of the protocol (required).
#' @param application_type Character. Application type for a Simple
#'   Protocol (for example `"Oral"`, `"IntravenousBolus"`, or
#'   `"IntravenousInfusion"`). Mutually exclusive with `schemas`.
#' @param dosing_interval Character. Dosing interval identifier for a
#'   Simple Protocol (for example `"Single"`, `"DI_12_12"`,
#'   `"DI_8_8_8"`, or `"DI_24"`).
#' @param target_organ Character. Target organ for the dose.
#' @param target_compartment Character. Target compartment for the
#'   dose.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists for Simple Protocol
#'   parameters such as start time, end time, and dose.
#' @param schemas List of schema lists for an Advanced Protocol. Each
#'   schema is a list with `Name`, `Parameters`, and `SchemaItems`. If
#'   provided, the protocol is created as an Advanced Protocol.
#' @param time_unit Character. Display time unit for the protocol.
#'
#' @return A [Protocol] object.
#' @export
#'
#' @examples
#' # Create a simple oral protocol with one dose
#' protocol <- create_protocol(
#'   name = "Single dose 10mg",
#'   application_type = "Oral",
#'   dosing_interval = "Single",
#'   parameters = list(
#'     create_parameter(name = "Start time", value = 0, unit = "h"),
#'     create_parameter(name = "InputDose", value = 10, unit = "mg")
#'   )
#' )
#'
#' # Create a twice-daily intravenous protocol
#' protocol <- create_protocol(
#'   name = "BID IV",
#'   application_type = "IntravenousBolus",
#'   dosing_interval = "DI_12_12",
#'   parameters = list(
#'     create_parameter(name = "InputDose", value = 5, unit = "mg")
#'   )
#' )
create_protocol <- function(
  name,
  application_type = NULL,
  dosing_interval = NULL,
  target_organ = NULL,
  target_compartment = NULL,
  parameters = NULL,
  schemas = NULL,
  time_unit = NULL
) {
  check_required_string(name, "name")
  if (!is.null(schemas) && !is.null(application_type)) {
    cli::cli_abort(c(
      "{.arg schemas} and {.arg application_type} are mutually exclusive",
      "i" = "A protocol is either Simple (use {.arg application_type}) or Advanced (use {.arg schemas})."
    ))
  }
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("{.arg parameters} must be a list")
  }
  if (!is.null(schemas) && !is.list(schemas)) {
    cli::cli_abort("{.arg schemas} must be a list")
  }

  data <- list(Name = name)

  if (!is.null(schemas)) {
    data$Schemas <- schemas
  } else {
    if (!is.null(application_type)) {
      data$ApplicationType <- application_type
    }
    if (!is.null(dosing_interval)) {
      data$DosingInterval <- dosing_interval
    }
    if (!is.null(target_organ)) {
      data$TargetOrgan <- target_organ
    }
    if (!is.null(target_compartment)) {
      data$TargetCompartment <- target_compartment
    }
    if (!is.null(parameters)) {
      # Simple Protocol parameters use Name (not Path) in the JSON shape.
      data$Parameters <- to_raw_parameters(parameters, "Name")
    }
  }

  if (!is.null(time_unit)) {
    data$TimeUnit <- time_unit
  }

  Protocol$new(data)
}
