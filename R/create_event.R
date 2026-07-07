#' Create a new event
#'
#' @description
#' Create an [Event] building block from named arguments. This is a thin
#' factory around `Event$new()` that builds the raw list shape for you.
#'
#' An [Event] is a discrete non-administration perturbation that fires
#' at a specific simulation time (for example a meal, gallbladder
#' emptying, or organ removal). PK-Sim creates events by cloning a named
#' template and overriding parameters, so a template name is required.
#'
#' @param name Character. Name of the event (required). This package
#'   requires a name because events are added, referenced, and removed by
#'   name, so an unnamed event cannot be used. This is intentionally
#'   stricter than the PK-Sim snapshot specification, which marks the
#'   event name as optional.
#' @param template Character. Event template name passed to the PK-Sim
#'   factory (required). Determines which event type is created.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists overriding values on
#'   the cloned template.
#'
#' @return An [Event] object.
#' @export
#'
#' @examples
#' # Create a minimal event
#' event <- create_event(
#'   name = "Breakfast",
#'   template = "Meal: Standard (Human)"
#' )
#'
#' # Create an event with parameter overrides
#' event <- create_event(
#'   name = "Breakfast",
#'   template = "Meal: Standard (Human)",
#'   parameters = list(
#'     create_parameter(name = "Meal energy content", value = 500, unit = "kcal"),
#'     create_parameter(name = "Meal volume", value = 0.3, unit = "l")
#'   )
#' )
create_event <- function(name, template, parameters = NULL) {
  check_required_string(name, "name")
  check_required_string(template, "template")
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("{.arg parameters} must be a list")
  }

  data <- list(Name = name, Template = template)

  if (!is.null(parameters)) {
    # Event parameters use Name (not Path) in the JSON shape.
    data$Parameters <- to_raw_parameters(parameters, "Name")
  }

  Event$new(data)
}
