#' Create a simulation building block
#'
#' @description
#' Build a [Simulation] from named arguments. Exactly one of
#' `individual` or `population` must be supplied; the other must be left
#' `NULL`.
#'
#' @param name Character. Simulation name (required).
#' @param model Character. PK-Sim model name (defaults to `"4Comp"`).
#' @param individual Character. Name of the individual building block.
#'   Mutually exclusive with `population`.
#' @param population Character. Name of the population building block.
#'   Mutually exclusive with `individual`.
#' @param compounds List of [CompoundProperties] objects or raw lists.
#' @param events List of [EventSelection] objects or raw lists.
#' @param observer_sets List of [ObserverSetSelection] objects or raw
#'   lists.
#' @param observed_data_names Character vector of observed-data names
#'   referenced by the simulation.
#' @param solver A [SolverSettings] object or raw list. Defaults to PK-Sim
#'   defaults.
#' @param output_schema An [OutputSchema] object or raw list. Defaults to
#'   an empty schema.
#' @param output_selections Character vector of output quantity paths.
#' @param output_mappings List of [OutputMapping] objects or raw lists.
#' @param parameters List of [LocalizedParameter] objects (created with
#'   `create_parameter(path = ..., ...)`) or raw parameter lists.
#' @param advanced_parameters List of [AdvancedParameter] objects or raw
#'   lists (population simulations only).
#' @param description Character. Free-text description of the simulation.
#' @param allow_aging Logical. Whether the simulation allows aging.
#'
#' @return A [Simulation] object.
#' @export
#'
#' @examples
#' create_simulation(
#'   name = "Sim 1",
#'   individual = "Adult",
#'   compounds = list(create_compound_properties(name = "Drug X"))
#' )
create_simulation <- function(
  name,
  model = "4Comp",
  individual = NULL,
  population = NULL,
  compounds = NULL,
  events = NULL,
  observer_sets = NULL,
  observed_data_names = NULL,
  solver = NULL,
  output_schema = NULL,
  output_selections = NULL,
  output_mappings = NULL,
  parameters = NULL,
  advanced_parameters = NULL,
  description = NULL,
  allow_aging = NULL
) {
  check_required_string(name, "name")
  check_required_string(model, "model")

  has_individual <- !is.null(individual)
  has_population <- !is.null(population)
  if (has_individual == has_population) {
    cli::cli_abort(c(
      "Simulation must reference exactly one of {.arg individual} or {.arg population}.",
      i = "Supply one and leave the other {.code NULL}."
    ))
  }
  if (has_individual) {
    check_required_string(individual, "individual")
  } else {
    check_required_string(population, "population")
  }

  if (!is.null(allow_aging)) {
    if (!is.logical(allow_aging) || length(allow_aging) != 1) {
      cli::cli_abort("{.arg allow_aging} must be a single logical value")
    }
  }
  if (!is.null(description)) {
    check_required_string(description, "description")
  }

  data <- list(Name = name, Model = model)

  if (!is.null(description)) {
    data$Description <- description
  }
  if (!is.null(allow_aging)) {
    data$AllowAging <- allow_aging
  }
  if (has_individual) {
    data$Individual <- individual
  }
  if (has_population) {
    data$Population <- population
  }

  if (!is.null(compounds)) {
    data$Compounds <- to_raw_r6_or_list(
      compounds,
      "CompoundProperties",
      "compounds"
    )
  }
  if (!is.null(events)) {
    data$Events <- to_raw_r6_or_list(
      events,
      "EventSelection",
      "events"
    )
  }
  if (!is.null(observer_sets)) {
    data$ObserverSets <- to_raw_r6_or_list(
      observer_sets,
      "ObserverSetSelection",
      "observer_sets"
    )
  }
  if (!is.null(observed_data_names)) {
    if (!is.character(observed_data_names)) {
      cli::cli_abort(
        "{.arg observed_data_names} must be a character vector"
      )
    }
    data$ObservedData <- as.list(observed_data_names)
  }
  if (!is.null(output_selections)) {
    if (!is.character(output_selections)) {
      cli::cli_abort(
        "{.arg output_selections} must be a character vector"
      )
    }
    data$OutputSelections <- as.list(output_selections)
  }
  if (!is.null(output_mappings)) {
    data$OutputMappings <- to_raw_r6_or_list(
      output_mappings,
      "OutputMapping",
      "output_mappings"
    )
  }
  if (!is.null(advanced_parameters)) {
    data$AdvancedParameters <- to_raw_r6_or_list(
      advanced_parameters,
      "AdvancedParameter",
      "advanced_parameters"
    )
  }

  # Solver: pre-resolve so the raw $data carries it.
  if (!is.null(solver)) {
    if (inherits(solver, "SolverSettings")) {
      data$Solver <- solver$data
    } else if (is.list(solver) && !is.object(solver)) {
      data$Solver <- solver
    } else {
      cli::cli_abort(
        "{.arg solver} must be a {.cls SolverSettings} or a raw list"
      )
    }
  } else {
    # Empty *named* list so jsonlite writes `{}` (an object). An unnamed
    # `list()` serialises to `[]` (an array), which PK-Sim's snapshot
    # mapper rejects silently.
    data$Solver <- empty_named_list()
  }

  if (!is.null(output_schema)) {
    if (inherits(output_schema, "OutputSchema")) {
      data$OutputSchema <- output_schema$data
    } else if (is.list(output_schema) && !is.object(output_schema)) {
      data$OutputSchema <- output_schema
    } else {
      cli::cli_abort(
        "{.arg output_schema} must be an {.cls OutputSchema} or a raw list"
      )
    }
  } else {
    data$OutputSchema <- list()
  }

  if (!is.null(parameters)) {
    data$Parameters <- to_raw_parameters(parameters, "Path")
  }

  Simulation$new(data)
}
