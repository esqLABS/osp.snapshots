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
#'   Protocol. Optional; when supplied it must be one of the canonical
#'   PK-Sim application types: `"Oral"`, `"IntravenousBolus"`,
#'   `"IntravenousInfusion"`, `"Intramuscular"`, `"Subcutaneous"`,
#'   `"Dermal"`, `"Rectal"`, `"Inhalation"`, or `"Intraperitoneal"`.
#'   Mutually exclusive with `schemas`.
#' @param dosing_interval Character. Dosing interval identifier for a
#'   Simple Protocol. Optional; when supplied it must be one of the fixed
#'   PK-Sim `DosingIntervalId` values: `"Single"`, `"DI_6_6_6_6"`,
#'   `"DI_6_6_12"`, `"DI_8_8_8"`, `"DI_12_12"`, or `"DI_24"`.
#' @param target_organ Character. Target organ for the dose.
#' @param target_compartment Character. Target compartment for the
#'   dose.
#' @param dose Numeric scalar. Optional dose for a Simple Protocol. When
#'   supplied it is emitted as a single `InputDose` parameter carrying
#'   `dose` and `dose_unit`. Mutually exclusive with `schemas`, and with
#'   an `InputDose` entry in `parameters`.
#' @param dose_unit Character. Display unit for `dose`, default `"mg"`.
#'   Validated as a dose-family unit: the unit must belong to one of the
#'   mass, amount, dose per body weight, or dose per body surface area
#'   dimensions, and the unit alone selects the family (the emitted
#'   parameter is always a single `InputDose`). There is no single
#'   `ospsuite::ospUnits$Dose` member, so the accepted units are the union
#'   of `ospsuite::ospUnits$Mass`, `ospsuite::ospUnits$Amount`,
#'   `ospsuite::ospUnits[["Dose per body weight"]]`, and
#'   `ospsuite::ospUnits[["Dose per body surface area"]]`. Only consulted
#'   when `dose` is supplied.
#' @param start_time Numeric scalar. Optional start time for a Simple
#'   Protocol. When supplied it is emitted as a `Start time` parameter.
#'   Mutually exclusive with `schemas`, and with a `Start time` entry in
#'   `parameters`.
#' @param start_time_unit Character. Display unit for `start_time`,
#'   default `"h"`, validated against dimension `"Time"`; valid units are
#'   those in `ospsuite::ospUnits$Time`. Only consulted when `start_time`
#'   is supplied.
#' @param end_time Numeric scalar. Optional end time for a Simple
#'   Protocol. When supplied it is emitted as an `End time` parameter. Its
#'   display unit is taken from `time_unit`, falling back to `"h"` when
#'   `time_unit` is unset; there is no separate end-time unit argument.
#'   Mutually exclusive with `schemas`, and with an `End time` entry in
#'   `parameters`.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists. This is the free-form
#'   escape hatch for any Simple-Protocol parameter that has no dedicated
#'   argument. Dose, start time, and end time have the dedicated `dose`,
#'   `start_time`, and `end_time` arguments; supplying one of those
#'   settings both here and via its dedicated argument is an error.
#' @param schemas List of schemas for an Advanced Protocol. Entries may
#'   be [Schema] objects (created with [create_schema()]) or raw schema
#'   lists with `Name`, `Parameters`, and `SchemaItems`. If provided,
#'   the protocol is created as an Advanced Protocol.
#' @param time_unit Character. Display time unit for the protocol, validated
#'   against dimension `"Time"`; valid units are those in
#'   `ospsuite::ospUnits$Time`.
#'
#' @return A [Protocol] object.
#' @export
#'
#' @examples
#' # Create a simple oral protocol with one dose via promoted arguments
#' protocol <- create_protocol(
#'   name = "Single dose 10mg",
#'   application_type = "Oral",
#'   dosing_interval = "Single",
#'   dose = 10,
#'   dose_unit = "mg",
#'   start_time = 0
#' )
#'
#' # The same protocol via the free-form `parameters` escape hatch
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
#'
#' # Create an Advanced Protocol from Schema objects
#' protocol <- create_protocol(
#'   name = "Advanced",
#'   schemas = list(
#'     create_schema(
#'       name = "Schema 1",
#'       parameters = list(
#'         create_parameter(name = "NumberOfRepetitions", value = 1)
#'       ),
#'       items = list(
#'         create_schema_item(
#'           name = "Item 1",
#'           application_type = "Oral",
#'           parameters = list(
#'             create_parameter(name = "InputDose", value = 5, unit = "mg")
#'           )
#'         )
#'       )
#'     )
#'   ),
#'   time_unit = "h"
#' )
create_protocol <- function(
  name,
  application_type = NULL,
  dosing_interval = NULL,
  target_organ = NULL,
  target_compartment = NULL,
  parameters = NULL,
  schemas = NULL,
  time_unit = NULL,
  dose = NULL,
  dose_unit = "mg",
  start_time = NULL,
  start_time_unit = "h",
  end_time = NULL
) {
  check_required_string(name, "name")
  if (!is.null(schemas)) {
    simple_fields <- list(
      application_type = application_type,
      dosing_interval = dosing_interval,
      target_organ = target_organ,
      target_compartment = target_compartment,
      dose = dose,
      start_time = start_time,
      end_time = end_time,
      parameters = parameters
    )
    conflicting <- names(simple_fields)[
      !vapply(simple_fields, is.null, logical(1))
    ]
    if (length(conflicting) > 0) {
      cli::cli_abort(c(
        "{.arg schemas} is mutually exclusive with Simple Protocol fields.",
        "i" = "A protocol is either Simple (use {.arg application_type}, {.arg dosing_interval}, {.arg target_organ}, {.arg target_compartment}, {.arg dose}, {.arg start_time}, {.arg end_time}, {.arg parameters}) or Advanced (use {.arg schemas}).",
        "x" = "Conflicting argument{?s}: {.arg {conflicting}}."
      ))
    }
  }
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("{.arg parameters} must be a list")
  }
  if (!is.null(time_unit)) {
    validate_unit(time_unit, "Time")
  }

  data <- list(Name = name)

  if (!is.null(schemas)) {
    data$Schemas <- to_raw_r6_or_list(schemas, "Schema", "schemas")
  } else {
    if (
      !is.null(application_type) &&
        !application_type %in% schema_item_application_types()
    ) {
      cli::cli_abort(c(
        "{.arg application_type} must be one of the canonical PK-Sim application types.",
        "x" = "Got {.val {application_type}}.",
        "i" = "Valid values: {.val {schema_item_application_types()}}."
      ))
    }
    if (!is.null(application_type)) {
      data$ApplicationType <- application_type
    }
    if (
      !is.null(dosing_interval) &&
        !dosing_interval %in% schema_item_dosing_intervals()
    ) {
      cli::cli_abort(c(
        "{.arg dosing_interval} must be one of the fixed PK-Sim dosing intervals.",
        "x" = "Got {.val {dosing_interval}}.",
        "i" = "Valid values: {.val {schema_item_dosing_intervals()}}."
      ))
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

    if (
      !is.null(dose) &&
        (!is.numeric(dose) || length(dose) != 1 || !is.finite(dose))
    ) {
      cli::cli_abort("{.arg dose} must be a single finite numeric value")
    }
    if (
      !is.null(start_time) &&
        (!is.numeric(start_time) ||
          length(start_time) != 1 ||
          !is.finite(start_time))
    ) {
      cli::cli_abort("{.arg start_time} must be a single finite numeric value")
    }
    if (
      !is.null(end_time) &&
        (!is.numeric(end_time) ||
          length(end_time) != 1 ||
          !is.finite(end_time))
    ) {
      cli::cli_abort("{.arg end_time} must be a single finite numeric value")
    }

    # The `End time` parameter's display unit derives from `time_unit`,
    # falling back to PK-Sim's default `"h"` when `time_unit` is unset. This
    # does not set `data$TimeUnit`; that remains driven solely by `time_unit`.
    end_time_unit <- if (is.null(time_unit)) "h" else time_unit

    # Build the auto entries for supplied promoted values, in a deterministic
    # order (dose, start time, end time). Each is the raw
    # `list(Name=, Value=, Unit=)` shape used in the Simple-Protocol JSON.
    auto_parameters <- list()
    if (!is.null(dose)) {
      auto_parameters <- c(
        auto_parameters,
        list(resolve_input_dose_parameter(dose, dose_unit))
      )
    }
    if (!is.null(start_time)) {
      validate_unit(start_time_unit, "Time")
      auto_parameters <- c(
        auto_parameters,
        list(list(
          Name = "Start time",
          Value = start_time,
          Unit = start_time_unit
        ))
      )
    }
    if (!is.null(end_time)) {
      auto_parameters <- c(
        auto_parameters,
        list(list(Name = "End time", Value = end_time, Unit = end_time_unit))
      )
    }

    # Reject supplying a dosing setting both as a promoted argument and as the
    # same-named entry in `parameters`. Compare against the `Name`-normalised
    # identifier so both `create_parameter(name=)` and `create_parameter(path=)`
    # (Path-keyed) entries are caught.
    if (!is.null(parameters)) {
      existing_names <- vapply(
        to_raw_parameters(parameters, "Name"),
        function(param) param$Name %||% NA_character_,
        character(1)
      )
      if (!is.null(dose) && "InputDose" %in% existing_names) {
        cli::cli_abort(c(
          "{.arg dose} conflicts with an {.val InputDose} entry in {.arg parameters}.",
          "i" = "Supply the dose either as the {.arg dose} argument or as an {.val InputDose} entry in {.arg parameters}, not both."
        ))
      }
      if (!is.null(start_time) && "Start time" %in% existing_names) {
        cli::cli_abort(c(
          "{.arg start_time} conflicts with a {.val Start time} entry in {.arg parameters}.",
          "i" = "Supply the start time either as the {.arg start_time} argument or as a {.val Start time} entry in {.arg parameters}, not both."
        ))
      }
      if (!is.null(end_time) && "End time" %in% existing_names) {
        cli::cli_abort(c(
          "{.arg end_time} conflicts with an {.val End time} entry in {.arg parameters}.",
          "i" = "Supply the end time either as the {.arg end_time} argument or as an {.val End time} entry in {.arg parameters}, not both."
        ))
      }
    }

    # Combine the auto entries (already raw) with the user parameters
    # (normalised to Name), auto entries first. Only set `data$Parameters` when
    # the combined list is non-empty, so a call with no promoted arguments and
    # no `parameters` produces byte-identical output to before this change.
    user_parameters <- if (!is.null(parameters)) {
      to_raw_parameters(parameters, "Name")
    } else {
      list()
    }
    combined <- c(auto_parameters, user_parameters)
    if (length(combined) > 0) {
      # Simple Protocol parameters use Name (not Path) in the JSON shape.
      data$Parameters <- combined
    }
  }

  if (!is.null(time_unit)) {
    data$TimeUnit <- time_unit
  }

  Protocol$new(data)
}
