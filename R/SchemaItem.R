#' SchemaItem class for OSP advanced protocols
#'
#' @description
#' An R6 class that represents one application inside a [Schema] of an
#' Advanced [Protocol]. A schema item carries an application type, an
#' optional formulation key, target organ and compartment, and the
#' application-level parameters (dose, start time, ...).
#'
#' In an OSP snapshot, each schema item is one entry of the
#' `SchemaItems` array nested inside a `Schemas` entry of a
#' `Protocols` building block.
#'
#' @importFrom R6 R6Class
#'
#' @export
SchemaItem <- R6::R6Class(
  classname = "SchemaItem",
  public = list(
    #' @description
    #' Create a new SchemaItem object.
    #' @param data Raw `SchemaItem` list from a snapshot. May be `NULL` or
    #'   an empty list, both of which create an empty schema item.
    #' @return A new SchemaItem object
    initialize = function(data = list()) {
      if (is.null(data)) {
        data <- list()
      }
      private$.data <- data
      private$initialize_parameters()
    },

    #' @description
    #' Print a summary of the schema item.
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the SchemaItem object
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h2("SchemaItem: {self$name %||% '(unnamed)'}")
        if (!is.null(self$application_type)) {
          cli::cli_li("Application type: {self$application_type}")
        }
        if (!is.null(self$formulation_key)) {
          cli::cli_li("Formulation key: {self$formulation_key}")
        }
        if (!is.null(self$target_organ)) {
          cli::cli_li("Target organ: {self$target_organ}")
        }
        if (!is.null(self$target_compartment)) {
          cli::cli_li("Target compartment: {self$target_compartment}")
        }
        if (length(private$.parameters) > 0) {
          cli::cli_li("Parameters:")
          indented <- cli::cli_ul()
          for (param in private$.parameters) {
            unit_display <- if (is.null(param$unit)) {
              ""
            } else {
              glue::glue(" {param$unit}")
            }
            cli::cli_li("{param$name}: {param$value}{unit_display}")
          }
          cli::cli_end(indented)
        }
      })
      cat(output, sep = "\n")
      invisible(self)
    }
  ),
  active = list(
    #' @field data The raw `SchemaItem` list as it appears in the snapshot
    #'   JSON, refreshed from the wrapped parameters (read-only).
    data = function(value) {
      if (!missing(value)) {
        cli::cli_abort("data is read-only")
      }
      result <- private$.data
      if (length(private$.parameters) > 0) {
        result$Parameters <- to_raw_parameters(private$.parameters, "Name")
      } else if (is.null(private$.data$Parameters)) {
        result$Parameters <- NULL
      } else {
        result$Parameters <- list()
      }
      result
    },

    #' @field name The name of the schema item. Writable: must be a
    #'   non-empty scalar string.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      check_required_string(value, "name")
      private$.data$Name <- value
    },

    #' @field application_type The application type of the schema item
    #'   (for example `"Oral"`, `"IntravenousBolus"`). Writable: must be one
    #'   of the canonical PK-Sim application types (see
    #'   [create_schema_item()]'s `application_type` argument), or `NULL`
    #'   to clear.
    application_type = function(value) {
      if (missing(value)) {
        return(private$.data$ApplicationType)
      }
      if (!is.null(value) && !(value %in% schema_item_application_types())) {
        cli::cli_abort(c(
          "{.arg application_type} must be one of the canonical PK-Sim application types.",
          "x" = "Got {.val {value}}.",
          "i" = "Valid values: {.val {schema_item_application_types()}}."
        ))
      }
      private$.data$ApplicationType <- value
    },

    #' @field formulation_key The formulation key, linking the schema item
    #'   to a formulation selection in the owning simulation.
    formulation_key = function(value) {
      if (missing(value)) {
        return(private$.data$FormulationKey)
      }
      private$.data$FormulationKey <- value
    },

    #' @field target_organ The target organ for the application.
    target_organ = function(value) {
      if (missing(value)) {
        return(private$.data$TargetOrgan)
      }
      private$.data$TargetOrgan <- value
    },

    #' @field target_compartment The target compartment for the
    #'   application.
    target_compartment = function(value) {
      if (missing(value)) {
        return(private$.data$TargetCompartment)
      }
      private$.data$TargetCompartment <- value
    },

    #' @field parameters The schema item's application-level [Parameter]
    #'   objects (dose, start time, ...). Writable: must be a list, or
    #'   `NULL` to clear.
    parameters = function(value) {
      if (missing(value)) {
        if (is.null(private$.parameters)) {
          private$.parameters <- list()
          class(private$.parameters) <- c("parameter_collection", "list")
        }
        return(private$.parameters)
      }
      if (is.null(value)) {
        private$.parameters <- list()
      } else {
        if (!is.list(value)) {
          cli::cli_abort("{.arg parameters} must be a list")
        }
        private$.parameters <- value
      }
      if (!inherits(private$.parameters, "parameter_collection")) {
        class(private$.parameters) <- c("parameter_collection", "list")
      }
      private$.parameters
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL,
    initialize_parameters = function() {
      private$.parameters <- build_parameters_from_raw(
        private$.data$Parameters,
        key_by = "none",
        name_as_path = TRUE
      )
    }
  )
)
