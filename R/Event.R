#' Event class for OSP snapshot events
#'
#' @description
#' An R6 class that represents an event in an OSP snapshot.
#' This class provides methods to access different properties of an event
#' and display a summary of its information.
#'
#' @importFrom R6 R6Class
#'
#' @export
Event <- R6::R6Class(
  classname = "Event",
  public = list(
    #' @description
    #' Create a new Event object
    #' @param data Raw event data from a snapshot
    #' @return A new Event object
    initialize = function(data) {
      private$.data <- data
      private$initialize_parameters()
    },

    #' @description
    #' Print a summary of the event
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h1("Event: {self$name}")

        # Display the template
        cli::cli_li("Template: {self$template}")

        # Display parameters if any
        if (length(self$parameters) > 0) {
          cli::cli_h2("Parameters:")
          for (param in self$parameters) {
            if (!is.null(param$unit)) {
              cli::cli_li("{param$name}: {param$value} {param$unit}")
            } else {
              cli::cli_li("{param$name}: {param$value}")
            }
          }
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert the event to a data frame for easier manipulation
    #' @return A tibble with event information
    to_dataframe = function() {
      # Create a main dataframe with event properties
      events_df <- tibble::tibble(
        name = self$name,
        template = self$template
      )

      # If there are parameters, add them as columns
      if (length(self$parameters) > 0) {
        param_df <- lapply(self$parameters, function(param) {
          value <- param$value
          tibble::tibble(
            param_name = param$name,
            param_value = value,
            param_unit = ifelse(is.null(param$unit), NA_character_, param$unit)
          )
        })
        param_df <- do.call(rbind, param_df)

        # Return both info and parameters with new keys
        return(list(
          events = events_df,
          events_parameters = param_df
        ))
      }

      # If no parameters, just return the info
      return(list(events = events_df, events_parameters = NULL))
    }
  ),

  active = list(
    #' @field data The raw data of the event (read-only)
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the event. Writable: must be a non-empty
    #'   scalar string.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      check_required_string(value, "name")
      private$.data$Name <- value
    },

    #' @field template The template of the event. Writable: must be a
    #'   non-empty scalar string.
    template = function(value) {
      if (missing(value)) {
        return(private$.data$Template)
      }
      check_required_string(value, "template")
      private$.data$Template <- value
    },

    #' @field parameters The list of parameter objects. Writable: must be a
    #'   list, or `NULL` to clear.
    parameters = function(value) {
      if (missing(value)) {
        if (is.null(private$.parameters)) {
          private$.parameters <- list()
          class(private$.parameters) <- c("parameter_collection", "list")
        }
        return(private$.parameters)
      }

      if (!is.null(value) && !is.list(value)) {
        cli::cli_abort("{.arg parameters} must be a list")
      }

      if (is.null(value)) {
        private$.parameters <- list()
      } else {
        # Ensure all parameters have Path set to Name for compatibility
        for (i in seq_along(value)) {
          param <- value[[i]]
          if (!is.null(param$name) && is.null(param$data$Path)) {
            param$path <- param$name
          }
        }

        private$.parameters <- value
      }

      # Ensure class for custom printing
      if (!inherits(private$.parameters, "parameter_collection")) {
        class(private$.parameters) <- c("parameter_collection", "list")
      }

      # Update raw data to reflect parameter changes
      private$.data$Parameters <- lapply(
        private$.parameters,
        function(param) param$data
      )

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
