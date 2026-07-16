#' Create a new schema item
#'
#' @description
#' Create a [SchemaItem] for an Advanced [Protocol] from named arguments.
#' This is a thin factory around `SchemaItem$new()` that builds the raw
#' list shape for you.
#'
#' A schema item is one application inside a [Schema] of an Advanced
#' Protocol. It carries an application type, an optional formulation key,
#' target organ and compartment, and the application-level parameters
#' (dose, start time, ...).
#'
#' @param name Character. Name of the schema item (required).
#' @param application_type Character. Application type for the schema
#'   item (required). Must be one of the canonical PK-Sim application
#'   types: `"Oral"`, `"IntravenousBolus"`, `"IntravenousInfusion"`,
#'   `"Intramuscular"`, `"Subcutaneous"`, `"Dermal"`, `"Rectal"`,
#'   `"Inhalation"`, or `"Intraperitoneal"`.
#' @param dose Numeric scalar dose for the application, written as a
#'   single `InputDose` parameter. `NULL` (default) emits no dose
#'   parameter. The dose family (plain dose, per body weight, or per body
#'   surface area) is selected by `dose_unit`.
#' @param dose_unit Character. Unit for `dose`, default `"mg"`. Must be a
#'   dose-family unit (a Mass, Amount, dose-per-body-weight, or
#'   dose-per-body-surface-area unit, for example `"mg"`, `"mg/kg"`, or
#'   `"mg/m²"`). Consulted only when `dose` is supplied.
#' @param start_time Numeric scalar application start time, written as a
#'   `"Start time"` parameter. `NULL` (default) emits no start-time
#'   parameter. Zero and negative values are allowed.
#' @param start_time_unit Character. Unit for `start_time`, default `"h"`,
#'   validated against the `"Time"` dimension. Consulted only when
#'   `start_time` is supplied.
#' @param formulation_key Character. Formulation key linking the schema
#'   item to a formulation selection in the owning simulation.
#' @param target_organ Character. Target organ for the application.
#' @param target_compartment Character. Target compartment for the
#'   application.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists. These become the
#'   application-level parameters (dose, start time, ...). The promoted
#'   `dose` and `start_time` arguments flow into the same `"InputDose"`
#'   and `"Start time"` parameters, so supplying a setting both as a
#'   promoted argument and as the matching `parameters` entry is an error.
#'
#' @return A [SchemaItem] object.
#' @export
#'
#' @examples
#' # An oral schema item using the promoted dose and start-time arguments
#' item <- create_schema_item(
#'   name = "Item 1",
#'   application_type = "Oral",
#'   dose = 10,
#'   dose_unit = "mg",
#'   start_time = 0
#' )
#'
#' # The same, authored through the free-form `parameters` escape hatch
#' item <- create_schema_item(
#'   name = "Item 1",
#'   application_type = "Oral",
#'   parameters = list(
#'     create_parameter(name = "Start time", value = 0, unit = "h"),
#'     create_parameter(name = "InputDose", value = 10, unit = "mg")
#'   )
#' )
#'
#' # An intravenous bolus schema item targeting the venous blood
#' item <- create_schema_item(
#'   name = "IV bolus",
#'   application_type = "IntravenousBolus",
#'   target_organ = "VenousBlood",
#'   target_compartment = "Plasma",
#'   dose = 5
#' )
create_schema_item <- function(
  name,
  application_type,
  dose = NULL,
  dose_unit = "mg",
  start_time = NULL,
  start_time_unit = "h",
  formulation_key = NULL,
  target_organ = NULL,
  target_compartment = NULL,
  parameters = NULL
) {
  check_required_string(name, "name")
  check_required_string(application_type, "application_type")
  if (!application_type %in% schema_item_application_types()) {
    cli::cli_abort(c(
      "{.arg application_type} must be one of the canonical PK-Sim application types.",
      "x" = "Got {.val {application_type}}.",
      "i" = "Valid values: {.val {schema_item_application_types()}}."
    ))
  }
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("{.arg parameters} must be a list")
  }

  # Resolve the promoted dosing arguments into raw parameter entries. A unit
  # argument stays inert (no validation, no emitted parameter) while its paired
  # value is NULL.
  dose_param <- NULL
  if (!is.null(dose)) {
    if (!is.numeric(dose) || length(dose) != 1 || !is.finite(dose)) {
      cli::cli_abort("{.arg dose} must be a single finite numeric value")
    }
    dose_param <- resolve_input_dose_parameter(dose, dose_unit)
  }
  start_time_param <- NULL
  if (!is.null(start_time)) {
    if (
      !is.numeric(start_time) ||
        length(start_time) != 1 ||
        !is.finite(start_time)
    ) {
      cli::cli_abort("{.arg start_time} must be a single finite numeric value")
    }
    validate_unit(start_time_unit, "Time")
    start_time_param <- list(
      Name = "Start time",
      Value = start_time,
      Unit = start_time_unit
    )
  }

  # Reject supplying a setting both as a promoted argument and as the matching
  # `parameters` entry. Names are resolved from both accepted entry shapes (a
  # `Parameter` R6 object or a raw list) exactly as `to_raw_parameters()` does,
  # and compared case-sensitively against the canonical PK-Sim names. Every
  # offending promoted argument is collected and reported together in a single
  # error, keyed back to its R argument name.
  if (!is.null(parameters)) {
    existing_names <- vapply(parameters, resolve_parameter_name, character(1))
    promoted_pksim_names <- c(
      if (!is.null(dose)) c(dose = "InputDose"),
      if (!is.null(start_time)) c(start_time = "Start time")
    )
    conflicting_args <- names(
      promoted_pksim_names[promoted_pksim_names %in% existing_names]
    )
    if (length(conflicting_args) > 0) {
      cli::cli_abort(c(
        "{cli::qty(conflicting_args)}Promoted argument{?s} conflict with {.arg parameters} entr{?y/ies}.",
        "x" = "{.arg {conflicting_args}} {?is/are} also supplied in {.arg parameters}.",
        "i" = "Supply each setting either as its promoted argument or as an entry in {.arg parameters}, not both."
      ))
    }
  }

  data <- list(
    Name = name,
    ApplicationType = application_type
  )

  if (!is.null(formulation_key)) {
    data$FormulationKey <- formulation_key
  }
  if (!is.null(target_organ)) {
    data$TargetOrgan <- target_organ
  }
  if (!is.null(target_compartment)) {
    data$TargetCompartment <- target_compartment
  }

  # Assemble the parameter set: promoted entries first (dose, then start time)
  # for deterministic output, then the caller's `parameters` in given order.
  # PK-Sim matches parameters by Name, so ordering is not semantically
  # significant. Only set `data$Parameters` when the combined set is non-empty,
  # keeping the no-promoted-args, no-`parameters` path byte-identical to before.
  promoted <- c(list(dose_param), list(start_time_param))
  promoted <- promoted[!vapply(promoted, is.null, logical(1))]
  combined <- c(promoted, parameters)
  if (length(combined) > 0) {
    # Schema item parameters use Name (not Path) in the JSON shape, mirroring
    # the simple-protocol path.
    data$Parameters <- to_raw_parameters(combined, "Name")
  }

  SchemaItem$new(data)
}

# Canonical PK-Sim application types accepted by `create_schema_item()` and
# `Schema/SchemaItem` JSON. Reads from the single source of truth declared in
# `R/Protocol.R` so the validator, `Protocol$get_human_application_type()`,
# and the reverse lookup all stay in sync.
schema_item_application_types <- function() {
  names(PKSIM_APPLICATION_TYPES)
}
