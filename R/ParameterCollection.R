#' ParameterCollection class for managing a collection of parameters
#'
#' @description
#' An R6 class that manages a collection of Parameter objects.
#' Provides methods to get, set, and add parameters.
#'
#' @export
ParameterCollection <- R6::R6Class(
    classname = "ParameterCollection",
    public = list(
        #' @description
        #' Create a new ParameterCollection object
        #' @param parameters List of raw parameter data
        #' @return A new ParameterCollection object
        initialize = function(parameters = NULL) {
            if (!is.null(parameters)) {
                private$initialize_parameters(parameters)
            }
        },

        #' @description
        #' Get a parameter by path
        #' @param path Character. The path of the parameter to get
        #' @return Parameter object or NULL if not found
        get_parameter = function(path) {
            private$.parameters[[path]]
        },

        #' @description
        #' Set a parameter by path
        #' @param path Character. The path of the parameter to set
        #' @param parameter Parameter object to set
        set_parameter = function(path, parameter) {
            if (!inherits(parameter, "Parameter")) {
                cli::cli_abort("Parameter must be a Parameter object")
            }
            private$.parameters[[path]] <- parameter
        },

        #' @description
        #' Add a new parameter
        #' @param parameter Parameter object to add
        add_parameter = function(parameter) {
            if (!inherits(parameter, "Parameter")) {
                cli::cli_abort("Parameter must be a Parameter object")
            }
            private$.parameters[[parameter$path]] <- parameter
        },

        #' @description
        #' Print a summary of the parameters
        #' @param ... Additional arguments passed to print methods
        #' @return Invisibly returns the object
        print = function(...) {
            if (length(private$.parameters) == 0) {
                cat("Empty ParameterCollection\n")
                return(invisible(self))
            }

            cat(
                "ParameterCollection with",
                length(private$.parameters),
                "parameters:\n"
            )
            for (param in private$.parameters) {
                cat(sprintf(
                    "  %s: %s %s\n",
                    param$path,
                    param$value,
                    param$unit
                ))
            }
            invisible(self)
        }
    ),

    private = list(
        .parameters = NULL,

        initialize_parameters = function(parameters) {
            private$.parameters <- lapply(
                parameters,
                function(param_data) Parameter$new(param_data)
            )
            # Name the parameters by their paths for easier access
            names(private$.parameters) <- vapply(
                private$.parameters,
                function(p) p$path,
                character(1)
            )
        }
    ),

    active = list(
        #' @field parameters Named list of Parameter objects
        parameters = function(value) {
            if (missing(value)) return(private$.parameters)
            private$.parameters <- utils::modifyList(private$.parameters, value)
            private$.parameters
        }
    )
)
