#' Create a new schema
#'
#' @description
#' Create a [Schema] for an Advanced [Protocol] from named arguments.
#' This is a thin factory around `Schema$new()` that builds the raw list
#' shape for you.
#'
#' A schema is a repeatable block inside an Advanced [Protocol]: it has
#' a name, schema-level parameters (typically `NumberOfRepetitions` and
#' `TimeBetweenRepetitions`), and an ordered list of [SchemaItem]
#' applications.
#'
#' @param name Character. Name of the schema (required).
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists. These become the
#'   schema-level parameters (`Start time`, `NumberOfRepetitions`,
#'   `TimeBetweenRepetitions`, ...).
#' @param items List of [SchemaItem] objects (created with
#'   [create_schema_item()]) or raw schema item lists. These define the
#'   applications inside the schema.
#'
#' @return A [Schema] object.
#' @export
#'
#' @examples
#' # A once-daily schema with a single oral application
#' schema <- create_schema(
#'   name = "Schema 1",
#'   parameters = list(
#'     create_parameter(name = "NumberOfRepetitions", value = 1),
#'     create_parameter(name = "TimeBetweenRepetitions", value = 0, unit = "h")
#'   ),
#'   items = list(
#'     create_schema_item(
#'       name = "Item 1",
#'       application_type = "Oral",
#'       parameters = list(
#'         create_parameter(name = "InputDose", value = 5, unit = "mg")
#'       )
#'     )
#'   )
#' )
create_schema <- function(name, parameters = NULL, items = NULL) {
  check_required_string(name, "name")
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("{.arg parameters} must be a list")
  }
  if (!is.null(items) && !is.list(items)) {
    cli::cli_abort("{.arg items} must be a list")
  }

  data <- list(Name = name)

  if (!is.null(parameters)) {
    # Schema parameters use Name (not Path) in the JSON shape, mirroring the
    # simple-protocol path.
    data$Parameters <- to_raw_parameters(parameters, "Name")
  }

  if (!is.null(items)) {
    valid <- vapply(
      items,
      function(item) inherits(item, "SchemaItem") || is.list(item),
      logical(1)
    )
    if (!all(valid)) {
      cli::cli_abort(
        "Every entry of {.arg items} must be a {.cls SchemaItem} or a raw list"
      )
    }
    # `unname()` keeps the JSON shape an array rather than an object when a
    # user supplies a named list of schema items.
    data$SchemaItems <- unname(lapply(items, function(item) {
      if (inherits(item, "SchemaItem")) item$data else item
    }))
  }

  Schema$new(data)
}
