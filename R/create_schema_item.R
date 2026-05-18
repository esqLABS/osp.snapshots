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
#' @param formulation_key Character. Formulation key linking the schema
#'   item to a formulation selection in the owning simulation.
#' @param target_organ Character. Target organ for the application.
#' @param target_compartment Character. Target compartment for the
#'   application.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists. These become the
#'   application-level parameters (dose, start time, ...).
#'
#' @return A [SchemaItem] object.
#' @export
#'
#' @examples
#' # An oral schema item with one dose
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
#'   parameters = list(
#'     create_parameter(name = "InputDose", value = 5, unit = "mg")
#'   )
#' )
create_schema_item <- function(
  name,
  application_type,
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
  if (!is.null(parameters)) {
    # Schema item parameters use Name (not Path) in the JSON shape, mirroring
    # the simple-protocol path.
    data$Parameters <- to_raw_parameters(parameters, "Name")
  }

  SchemaItem$new(data)
}

# Canonical PK-Sim application types accepted by `create_schema_item()` and
# `Schema/SchemaItem` JSON. PK-Sim resolves these via `ApplicationTypes.ByName()`
# (see `snapshot-spec.md`). This is the curated public list from PK-Sim; if
# PK-Sim adds new application types this list must be updated in lockstep.
schema_item_application_types <- function() {
  c(
    "Oral",
    "IntravenousBolus",
    "IntravenousInfusion",
    "Intramuscular",
    "Subcutaneous",
    "Dermal",
    "Rectal",
    "Inhalation",
    "Intraperitoneal"
  )
}
