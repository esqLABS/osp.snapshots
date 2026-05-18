#' Schema class for OSP advanced protocols
#'
#' @description
#' An R6 class that represents a repeatable block inside an Advanced
#' [Protocol]. A schema has its own name, schema-level parameters
#' (typically `Start time`, `NumberOfRepetitions`,
#' `TimeBetweenRepetitions`), and an ordered list of [SchemaItem]
#' applications.
#'
#' In an OSP snapshot, each schema is one entry of the `Schemas` array
#' inside a `Protocols` building block.
#'
#' @importFrom R6 R6Class
#'
#' @export
Schema <- R6::R6Class(
  classname = "Schema",
  public = list(
    #' @description
    #' Create a new Schema object.
    #' @param data Raw `Schema` list from a snapshot. May be `NULL` or
    #'   an empty list, both of which create an empty schema.
    #' @return A new Schema object
    initialize = function(data = list()) {
      if (is.null(data)) {
        data <- list()
      }
      private$.data <- data
      private$initialize_parameters()
      private$initialize_items()
    },

    #' @description
    #' Print a summary of the schema.
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the Schema object
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h2("Schema: {self$name %||% '(unnamed)'}")
        if (length(private$.parameters) > 0) {
          cli::cli_li("Parameters:")
          indented_params <- cli::cli_ul()
          for (param in private$.parameters) {
            unit_display <- if (is.null(param$unit)) {
              ""
            } else {
              glue::glue(" {param$unit}")
            }
            cli::cli_li("{param$name}: {param$value}{unit_display}")
          }
          cli::cli_end(indented_params)
        }
        if (length(private$.items) > 0) {
          cli::cli_li("Schema items ({length(private$.items)}):")
          indented_items <- cli::cli_ul()
          for (item in private$.items) {
            cli::cli_li(
              "{item$name %||% '(unnamed)'}: {item$application_type %||% ''}"
            )
          }
          cli::cli_end(indented_items)
        }
      })
      cat(output, sep = "\n")
      invisible(self)
    }
  ),
  active = list(
    #' @field data The raw `Schema` list as it appears in the snapshot
    #'   JSON, refreshed from the wrapped schema items and parameters
    #'   (read-only).
    data = function(value) {
      if (!missing(value)) {
        cli::cli_abort("data is read-only")
      }
      result <- private$.data
      if (length(private$.items) > 0) {
        result$SchemaItems <- lapply(private$.items, function(item) item$data)
      } else if (is.null(private$.data$SchemaItems)) {
        result$SchemaItems <- NULL
      } else {
        result$SchemaItems <- list()
      }
      if (length(private$.parameters) > 0) {
        result$Parameters <- to_raw_parameters(private$.parameters, "Name")
      } else if (is.null(private$.data$Parameters)) {
        result$Parameters <- NULL
      } else {
        result$Parameters <- list()
      }
      result
    },

    #' @field name The name of the schema.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field parameters The schema-level [Parameter] objects (number of
    #'   repetitions, time between repetitions, ...).
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
        private$.parameters <- value
      }
      if (!inherits(private$.parameters, "parameter_collection")) {
        class(private$.parameters) <- c("parameter_collection", "list")
      }
      private$.parameters
    },

    #' @field items List of [SchemaItem] objects in the schema, in
    #'   declaration order.
    items = function(value) {
      if (missing(value)) {
        return(private$.items)
      }
      if (is.null(value)) {
        private$.items <- list()
        return(invisible(private$.items))
      }
      if (!is.list(value)) {
        cli::cli_abort("{.field items} must be a list of SchemaItem objects")
      }
      for (item in value) {
        if (!inherits(item, "SchemaItem")) {
          cli::cli_abort(
            "Every entry of {.field items} must be a {.cls SchemaItem}"
          )
        }
      }
      private$.items <- value
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL,
    .items = list(),
    deep_clone = function(name, value) {
      if (name == ".items" && is.list(value)) {
        return(lapply(value, function(item) {
          if (inherits(item, "R6")) item$clone(deep = TRUE) else item
        }))
      }
      value
    },
    initialize_parameters = function() {
      private$.parameters <- build_parameters_from_raw(
        private$.data$Parameters,
        key_by = "none",
        name_as_path = TRUE
      )
    },
    initialize_items = function() {
      raw_items <- private$.data$SchemaItems %||% list()
      private$.items <- lapply(raw_items, function(item_data) {
        SchemaItem$new(item_data)
      })
    }
  )
)
