#' Simulation class for OSP snapshot simulations
#'
#' @description
#' An R6 class that represents a simulation in an OSP snapshot. A
#' simulation references building blocks (compounds, events,
#' formulations, observer sets, observed data, protocols, plus exactly
#' one of an individual or a population) and binds them together with a
#' solver configuration, an output schema, and parameter overrides.
#'
#' # Subject type
#'
#' Exactly one of `Individual` / `Population` must be non-empty. Setting
#' or clearing one through the active bindings is the user's
#' responsibility; the initialiser only checks the inbound raw data.
#'
#' # Passthrough fields
#'
#' Four fields are preserved byte-equivalent from the input rather than
#' parsed: `Interactions`, `AlteredBuildingBlocks`, `IndividualAnalyses`,
#' and `PopulationAnalyses`. They survive round-trip without modelling.
#'
#' @importFrom R6 R6Class
#' @export
Simulation <- R6::R6Class(
  classname = "Simulation",
  public = list(
    #' @description
    #' Create a new Simulation object.
    #' @param data Raw simulation data from a snapshot.
    #' @return A new Simulation object.
    initialize = function(data) {
      # Use [[ ]] not $ throughout: $ would partial-match
      # `Individual` to `IndividualAnalyses`, `Population` to
      # `PopulationAnalyses`, etc.
      ind <- data[["Individual"]]
      pop <- data[["Population"]]
      has_individual <- !is.null(ind) && nzchar(as.character(ind))
      has_population <- !is.null(pop) && nzchar(as.character(pop))
      if (has_individual == has_population) {
        cli::cli_abort(c(
          "Simulation must reference exactly one of {.field Individual} or {.field Population}.",
          i = "Set one and leave the other absent or empty."
        ))
      }

      private$.data <- data

      private$.solver <- SolverSettings$new(data[["Solver"]] %||% list())
      private$.output_schema <- OutputSchema$new(data[["OutputSchema"]])

      private$.compounds <- if (!is.null(data[["Compounds"]])) {
        lapply(data[["Compounds"]], function(d) CompoundProperties$new(d))
      } else {
        list()
      }
      private$.events <- if (!is.null(data[["Events"]])) {
        lapply(data[["Events"]], function(d) EventSelection$new(d))
      } else {
        list()
      }
      private$.observer_sets <- if (!is.null(data[["ObserverSets"]])) {
        lapply(data[["ObserverSets"]], function(d) ObserverSetSelection$new(d))
      } else {
        list()
      }
      private$.output_mappings <- if (!is.null(data[["OutputMappings"]])) {
        lapply(data[["OutputMappings"]], function(d) OutputMapping$new(d))
      } else {
        list()
      }
      private$.advanced_parameters <- if (
        !is.null(data[["AdvancedParameters"]])
      ) {
        lapply(
          data[["AdvancedParameters"]],
          function(d) AdvancedParameter$new(d)
        )
      } else {
        list()
      }

      private$.parameters <- build_parameters_from_raw(
        data[["Parameters"]],
        key_by = "path",
        ctor = function(d) LocalizedParameter$new(d)
      )
    },

    #' @description
    #' Print a summary of the simulation.
    #' @param ... Additional arguments passed to print methods.
    #' @return Invisibly returns the simulation object.
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h1("Simulation: {self$name}")

        cli::cli_li("Model: {self$model}")
        ind <- private$.data[["Individual"]]
        if (!is.null(ind)) {
          cli::cli_li("Individual: {ind}")
        }
        pop <- private$.data[["Population"]]
        if (!is.null(pop)) {
          cli::cli_li("Population: {pop}")
        }
        if (!is.null(self$description)) {
          cli::cli_li("Description: {self$description}")
        }
        if (!is.null(self$allow_aging)) {
          cli::cli_li("Allow aging: {self$allow_aging}")
        }

        if (length(self$compounds) > 0) {
          cli::cli_h2("Compounds ({length(self$compounds)})")
          for (c in self$compounds) {
            cli::cli_li("{c$name}")
          }
        }

        if (length(self$events) > 0) {
          cli::cli_h2("Events ({length(self$events)})")
          for (e in self$events) {
            cli::cli_li("{e$name}")
          }
        }

        if (length(self$observer_sets) > 0) {
          cli::cli_h2("Observer sets ({length(self$observer_sets)})")
          for (o in self$observer_sets) {
            cli::cli_li("{o$name}")
          }
        }

        if (length(self$observed_data_names) > 0) {
          cli::cli_h2("Observed data ({length(self$observed_data_names)})")
          for (od in self$observed_data_names) {
            cli::cli_li("{od}")
          }
        }

        if (length(self$output_selections) > 0) {
          cli::cli_h2("Output selections ({length(self$output_selections)})")
          for (sel in self$output_selections) {
            cli::cli_li("{sel}")
          }
        }

        n_intervals <- length(self$output_schema$intervals)
        if (n_intervals > 0) {
          cli::cli_h2("Output schema")
          cli::cli_li("{n_intervals} interval{?s}")
        }

        solver_fields <- self$solver$data
        if (length(solver_fields) > 0) {
          cli::cli_h2("Solver")
          for (key in names(solver_fields)) {
            cli::cli_li("{key}: {solver_fields[[key]]}")
          }
        }

        if (length(self$parameters) > 0) {
          cli::cli_h2("Parameter overrides ({length(self$parameters)})")
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    }
  ),
  active = list(
    #' @field data The raw data of the simulation (read-only). Rebuilt
    #'   from the nested caches so that mutations on wrapped objects flow
    #'   back to the export payload. Passthrough fields are preserved
    #'   byte-equivalent.
    data = function(value) {
      if (missing(value)) {
        result <- private$.data

        # Solver: always emit if non-empty input had it; otherwise keep
        # absent unless the user added settings.
        solver_data <- private$.solver$data
        if (length(solver_data) > 0 || !is.null(private$.data[["Solver"]])) {
          result$Solver <- solver_data
        }

        # OutputSchema
        schema_data <- private$.output_schema$data
        if (
          length(schema_data) > 0 || !is.null(private$.data[["OutputSchema"]])
        ) {
          result$OutputSchema <- schema_data
        }

        # Compounds
        if (length(private$.compounds) > 0) {
          items <- lapply(private$.compounds, function(c) c$data)
          names(items) <- NULL
          result$Compounds <- items
        } else if (!is.null(private$.data[["Compounds"]])) {
          result$Compounds <- list()
        }

        # Events
        if (length(private$.events) > 0) {
          items <- lapply(private$.events, function(e) e$data)
          names(items) <- NULL
          result$Events <- items
        } else if (!is.null(private$.data[["Events"]])) {
          result$Events <- list()
        }

        # ObserverSets
        if (length(private$.observer_sets) > 0) {
          items <- lapply(private$.observer_sets, function(o) o$data)
          names(items) <- NULL
          result$ObserverSets <- items
        } else if (!is.null(private$.data[["ObserverSets"]])) {
          result$ObserverSets <- list()
        }

        # OutputMappings
        if (length(private$.output_mappings) > 0) {
          items <- lapply(private$.output_mappings, function(m) m$data)
          names(items) <- NULL
          result$OutputMappings <- items
        } else if (!is.null(private$.data[["OutputMappings"]])) {
          result$OutputMappings <- list()
        }

        # AdvancedParameters
        if (length(private$.advanced_parameters) > 0) {
          items <- lapply(private$.advanced_parameters, function(p) p$data)
          names(items) <- NULL
          result$AdvancedParameters <- items
        } else if (!is.null(private$.data[["AdvancedParameters"]])) {
          result$AdvancedParameters <- list()
        }

        # Parameters: LocalizedParameter list rebuilt from cache.
        if (length(private$.parameters) > 0) {
          items <- lapply(private$.parameters, function(p) p$data)
          names(items) <- NULL
          result$Parameters <- items
        } else if (!is.null(private$.data[["Parameters"]])) {
          result$Parameters <- list()
        }

        return(result)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the simulation.
    name = function(value) {
      if (missing(value)) {
        return(private$.data[["Name"]])
      }
      private$.data[["Name"]] <- value
    },

    #' @field description Free-text description of the simulation.
    description = function(value) {
      if (missing(value)) {
        return(private$.data[["Description"]])
      }
      private$.data[["Description"]] <- value
    },

    #' @field model The PK-Sim model used to build the simulation
    #'   (e.g. `"4Comp"`).
    model = function(value) {
      if (missing(value)) {
        return(private$.data[["Model"]])
      }
      private$.data[["Model"]] <- value
    },

    #' @field allow_aging Whether the simulation allows aging.
    allow_aging = function(value) {
      if (missing(value)) {
        return(private$.data[["AllowAging"]])
      }
      private$.data[["AllowAging"]] <- value
    },

    #' @field individual Name of the individual building block (or
    #'   `NULL` for a population simulation).
    individual = function(value) {
      if (missing(value)) {
        return(private$.data[["Individual"]])
      }
      private$.data[["Individual"]] <- value
    },

    #' @field population Name of the population building block (or
    #'   `NULL` for an individual simulation).
    population = function(value) {
      if (missing(value)) {
        return(private$.data[["Population"]])
      }
      private$.data[["Population"]] <- value
    },

    #' @field solver The [SolverSettings] object.
    solver = function(value) {
      if (missing(value)) {
        return(private$.solver)
      }
      if (inherits(value, "SolverSettings")) {
        private$.solver <- value
      } else if (is.list(value)) {
        private$.solver <- SolverSettings$new(value)
      } else {
        cli::cli_abort(
          "{.field solver} must be a {.cls SolverSettings} or a raw list"
        )
      }
    },

    #' @field output_schema The [OutputSchema] object.
    output_schema = function(value) {
      if (missing(value)) {
        return(private$.output_schema)
      }
      if (inherits(value, "OutputSchema")) {
        private$.output_schema <- value
      } else if (is.list(value) || is.null(value)) {
        private$.output_schema <- OutputSchema$new(value)
      } else {
        cli::cli_abort(
          "{.field output_schema} must be an {.cls OutputSchema} or a raw list"
        )
      }
    },

    #' @field compounds List of [CompoundProperties] objects.
    compounds = function(value) {
      if (missing(value)) {
        return(private$.compounds)
      }
      private$.compounds <- value %||% list()
    },

    #' @field events List of [EventSelection] objects.
    events = function(value) {
      if (missing(value)) {
        return(private$.events)
      }
      private$.events <- value %||% list()
    },

    #' @field observer_sets List of [ObserverSetSelection] objects.
    observer_sets = function(value) {
      if (missing(value)) {
        return(private$.observer_sets)
      }
      private$.observer_sets <- value %||% list()
    },

    #' @field observed_data_names Character vector of observed-data
    #'   building-block names referenced by this simulation.
    observed_data_names = function(value) {
      if (missing(value)) {
        return(private$.data[["ObservedData"]])
      }
      private$.data[["ObservedData"]] <- value
    },

    #' @field output_selections Character vector of output quantity
    #'   paths selected for reporting.
    output_selections = function(value) {
      if (missing(value)) {
        return(private$.data[["OutputSelections"]])
      }
      private$.data[["OutputSelections"]] <- value
    },

    #' @field output_mappings List of [OutputMapping] objects.
    output_mappings = function(value) {
      if (missing(value)) {
        return(private$.output_mappings)
      }
      private$.output_mappings <- value %||% list()
    },

    #' @field parameters Named list of [LocalizedParameter] objects
    #'   (keyed by path) overriding parameters in the simulation's tree.
    parameters = function(value) {
      if (missing(value)) {
        return(private$.parameters)
      }
      if (is.null(value)) {
        private$.parameters <- build_parameters_from_raw(
          list(),
          key_by = "path"
        )
      } else if (is.list(value)) {
        # Wrap raw list entries through LocalizedParameter so the export
        # path (which calls `p$data` on every element) keeps working.
        # Pre-wrapped `Parameter`/`LocalizedParameter` objects are passed
        # through unchanged.
        wrapped <- lapply(value, function(p) {
          if (inherits(p, "Parameter")) p else LocalizedParameter$new(p)
        })
        names(wrapped) <- vapply(
          wrapped,
          function(p) p$path %||% "Unknown",
          character(1)
        )
        class(wrapped) <- c("parameter_collection", "list")
        private$.parameters <- wrapped
      } else {
        cli::cli_abort("{.field parameters} must be a list")
      }
    },

    #' @field advanced_parameters List of [AdvancedParameter] objects
    #'   (population simulations only).
    advanced_parameters = function(value) {
      if (missing(value)) {
        return(private$.advanced_parameters)
      }
      private$.advanced_parameters <- value %||% list()
    }
  ),
  private = list(
    .data = NULL,
    .solver = NULL,
    .output_schema = NULL,
    .compounds = NULL,
    .events = NULL,
    .observer_sets = NULL,
    .output_mappings = NULL,
    .parameters = NULL,
    .advanced_parameters = NULL,
    deep_clone = function(name, value) {
      if (
        name %in%
          c(".solver", ".output_schema") &&
          inherits(value, "R6")
      ) {
        return(value$clone(deep = TRUE))
      }
      if (
        name %in%
          c(
            ".compounds",
            ".events",
            ".observer_sets",
            ".output_mappings",
            ".parameters",
            ".advanced_parameters"
          ) &&
          is.list(value)
      ) {
        return(lapply(value, function(x) {
          if (inherits(x, "R6")) x$clone(deep = TRUE) else x
        }))
      }
      value
    }
  )
)
