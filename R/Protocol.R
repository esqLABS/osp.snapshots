#' Protocol class for OSP snapshot protocols
#'
#' @description
#' An R6 class that represents a protocol in an OSP snapshot.
#' This class provides methods to access different properties of a protocol
#' and display a summary of its information. Protocols can be either simple
#' (with dosing intervals) or advanced (with schemas and schema items).
#'
#' @importFrom tibble tibble as_tibble
#' @importFrom glue glue
#' @importFrom lubridate duration
#' @importFrom stringr str_replace
#' @importFrom R6 R6Class
#'
#' @export
Protocol <- R6::R6Class(
  classname = "Protocol",
  public = list(
    #' @description
    #' Create a new Protocol object
    #' @param data Raw protocol data from a snapshot
    #' @return A new Protocol object
    initialize = function(data) {
      private$.data <- data
      private$initialize_parameters()
      private$initialize_schemas()
    },

    #' @description
    #' Print a summary of the protocol including its properties and parameters.
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the Protocol object for method chaining
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h1("Protocol: {self$name}")

        # Display protocol type
        if (self$is_advanced) {
          cli::cli_li("Type: Advanced (Schema-based)")
        } else {
          cli::cli_li("Type: Simple")
        }

        # Display application type for simple protocols
        if (!is.null(self$application_type)) {
          cli::cli_li("Application Type: {self$get_human_application_type()}")
        }

        # Display dosing interval for simple protocols
        if (!is.null(self$dosing_interval)) {
          cli::cli_li("Dosing Interval: {self$get_human_dosing_interval()}")
        }

        # Display time unit if available
        if (!is.null(self$time_unit)) {
          cli::cli_li("Time Unit: {self$time_unit}")
        }

        # Display parameters for simple protocols
        if (!self$is_advanced && length(private$.parameters) > 0) {
          cli::cli_h2("Parameters")
          for (param in private$.parameters) {
            unit_display <- if (is.null(param$unit)) {
              ""
            } else {
              glue::glue(" {param$unit}")
            }
            cli::cli_li("{param$name}: {param$value}{unit_display}")
          }
        }

        # Display schemas for advanced protocols
        if (self$is_advanced && length(self$schemas) > 0) {
          cli::cli_h2("Schemas")
          for (schema in self$schemas) {
            cli::cli_li("Schema: {schema$name}")
            if (length(schema$schema_items) > 0) {
              indented_list <- cli::cli_ul()
              for (item in schema$schema_items) {
                cli::cli_li(
                  "{item$name}: {item$application_type} - {item$formulation_key}"
                )
              }
              cli::cli_end(indented_list)
            }
          }
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert protocol data to a single consolidated tibble
    #' @return A tibble containing all protocol data in a single data frame
    to_df = function() {
      all_protocols <- list()

      if (self$is_advanced) {
        for (schema in self$schemas) {
          for (item in schema$schema_items) {
            schema_start_time_param <- private$extract_parameter(
              schema$parameters,
              "Start time"
            )
            item_start_time_param <- private$extract_parameter(
              item$parameters,
              "Start time"
            )

            schema_start_time_value <- schema_start_time_param$value %||% 0
            item_start_time_value <- item_start_time_param$value %||% 0
            total_start_time <- schema_start_time_value + item_start_time_value
            start_time_unit <- item_start_time_param$unit %||%
              schema_start_time_param$unit

            dose_param <- private$extract_parameter(
              item$parameters,
              "InputDose"
            )
            rep_num_param <- private$extract_parameter(
              schema$parameters,
              "NumberOfRepetitions"
            )
            rep_time_param <- private$extract_parameter(
              schema$parameters,
              "TimeBetweenRepetitions"
            )

            row <- list(
              protocol_name = self$name,
              schema_name = stringr::str_replace(
                schema$name,
                "Schema",
                "Sub Protocol"
              ),
              schema_item_name = stringr::str_replace(
                item$name,
                "Schema Item",
                "Sub Protocol Step"
              ),
              type = private$get_human_application_type_from_value(
                item$application_type
              ),
              formulation = item$formulation_key %||% NA_character_,
              dosing_interval = private$get_dosing_interval_from_reps(
                rep_num_param,
                rep_time_param
              ),
              start_time = total_start_time,
              start_time_unit = start_time_unit %||% NA_character_,
              dose = if (!is.null(dose_param)) dose_param$value else NA_real_,
              dose_unit = if (!is.null(dose_param)) {
                dose_param$unit
              } else {
                NA_character_
              },
              rep_number = if (!is.null(rep_num_param)) {
                rep_num_param$value
              } else {
                NA_real_
              },
              rep_time = as.character(
                if (!is.null(rep_time_param)) {
                  as.numeric(rep_time_param$value)
                } else {
                  NA_real_
                }
              ),
              rep_time_unit = if (!is.null(rep_time_param)) {
                rep_time_param$unit
              } else {
                NA_character_
              }
            )
            all_protocols <- c(all_protocols, list(row))
          }
        }
      } else {
        dosing_interval <- self$dosing_interval
        rep_number_val <- 1
        rep_time_val <- 0
        rep_time_unit <- "h"

        if (!is.null(dosing_interval) && dosing_interval != "Single") {
          rep_time_val <- switch(
            dosing_interval,
            "DI_8_8_8" = 8,
            "DI_12_12" = 12,
            "DI_6_6_6_6" = 6,
            "DI_6_6_12" = 8, # Average for calculation
            0
          )

          start_param <- private$extract_parameter(
            self$parameters,
            "Start time"
          )
          end_param <- private$extract_parameter(self$parameters, "End time")

          if (!is.null(start_param) && !is.null(end_param)) {
            duration <- convert_ospsuite_time_to_duration(
              end_param$value,
              end_param$unit
            ) -
              convert_ospsuite_time_to_duration(
                start_param$value,
                start_param$unit
              )
            rep_number_val <- as.numeric(duration) /
              as.numeric(
                convert_ospsuite_time_to_duration(rep_time_val, "h")
              )
          }

          if (dosing_interval == "DI_6_6_12") {
            rep_time_val <- "6, 12"
          }
        }

        start_time_param <- private$extract_parameter(
          self$parameters,
          "Start time"
        )
        dose_param <- private$extract_parameter(self$parameters, "InputDose")

        row <- list(
          protocol_name = self$name,
          schema_name = NA_character_,
          schema_item_name = NA_character_,
          type = self$get_human_application_type(),
          formulation = NA_character_,
          dosing_interval = self$get_human_dosing_interval(),
          start_time = if (!is.null(start_time_param)) {
            start_time_param$value
          } else {
            NA_real_
          },
          start_time_unit = if (!is.null(start_time_param)) {
            start_time_param$unit
          } else {
            NA_character_
          },
          dose = if (!is.null(dose_param)) dose_param$value else NA_real_,
          dose_unit = if (!is.null(dose_param)) {
            dose_param$unit
          } else {
            NA_character_
          },
          rep_number = rep_number_val,
          rep_time = as.character(rep_time_val),
          rep_time_unit = rep_time_unit
        )
        all_protocols <- c(all_protocols, list(row))
      }

      if (length(all_protocols) > 0) {
        # Ensure all rows are lists, not data frames, before rbind
        if (any(sapply(all_protocols, is.data.frame))) {
          all_protocols <- lapply(all_protocols, as.list)
        }
        result_data <- do.call(rbind.data.frame, all_protocols)
        return(tibble::as_tibble(result_data))
      } else {
        return(tibble::tibble(
          protocol_name = character(0),
          schema_name = character(0),
          schema_item_name = character(0),
          type = character(0),
          formulation = character(0),
          dosing_interval = character(0),
          start_time = numeric(0),
          start_time_unit = character(0),
          dose = numeric(0),
          dose_unit = character(0),
          rep_number = numeric(0),
          rep_time = character(0),
          rep_time_unit = character(0)
        ))
      }
    },

    #' @description
    #' Get human-readable application type
    #' @return Character string with human-readable application type
    get_human_application_type = function() {
      if (is.null(self$application_type)) {
        return(NA_character_)
      }

      switch(
        self$application_type,
        "Oral" = "Oral",
        "IntravenousBolus" = "Intravenous bolus",
        "IntravenousInfusion" = "Intravenous infusion",
        self$application_type
      )
    },

    #' @description
    #' Get human-readable dosing interval
    #' @return Character string with human-readable dosing interval
    get_human_dosing_interval = function() {
      if (is.null(self$dosing_interval)) {
        return(NA_character_)
      }

      switch(
        self$dosing_interval,
        "Single" = "Once",
        "DI_8_8_8" = "3 times a day",
        "DI_12_12" = "2 times a day",
        "DI_6_6_6_6" = "4 times a day",
        "DI_6_6_12" = "3 times a day",
        "DI_24" = "Once a day",
        self$dosing_interval
      )
    }
  ),
  active = list(
    #' @field data The raw data of the protocol
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      private$.data <- value
    },

    #' @field name The name of the protocol
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field is_advanced Whether the protocol is advanced (schema-based)
    is_advanced = function(value) {
      if (missing(value)) {
        return(!is.null(private$.data$Schemas))
      }
      # Read-only field
      cli::cli_abort("is_advanced is a read-only field")
    },

    #' @field application_type The application type (for simple protocols)
    application_type = function(value) {
      if (missing(value)) {
        return(private$.data$ApplicationType)
      }
      private$.data$ApplicationType <- value
    },

    #' @field dosing_interval The dosing interval (for simple protocols)
    dosing_interval = function(value) {
      if (missing(value)) {
        return(private$.data$DosingInterval)
      }
      private$.data$DosingInterval <- value
    },

    #' @field time_unit The time unit for the protocol
    time_unit = function(value) {
      if (missing(value)) {
        return(private$.data$TimeUnit)
      }
      private$.data$TimeUnit <- value
    },

    #' @field parameters The parameters of the protocol (for simple protocols)
    parameters = function(value) {
      if (missing(value)) {
        return(private$.parameters)
      }
      private$.parameters <- value
    },

    #' @field schemas The schemas of the protocol (for advanced protocols)
    schemas = function(value) {
      if (missing(value)) {
        return(private$.schemas)
      }
      private$.schemas <- value
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL,
    .schemas = NULL,

    # Initialize parameters for simple protocols
    initialize_parameters = function() {
      if (!is.null(private$.data$Parameters)) {
        private$.parameters <- lapply(
          private$.data$Parameters,
          function(param_data) {
            # Convert Name to Path for Parameter class compatibility
            if (!is.null(param_data$Name) && is.null(param_data$Path)) {
              param_data$Path <- param_data$Name
            }
            Parameter$new(param_data)
          }
        )
      } else {
        private$.parameters <- list()
      }
    },

    # Initialize schemas for advanced protocols
    initialize_schemas = function() {
      if (!is.null(private$.data$Schemas)) {
        private$.schemas <- lapply(
          private$.data$Schemas,
          function(schema_data) {
            # Create schema object with schema items
            schema_items <- lapply(
              schema_data$SchemaItems %||% list(),
              function(item_data) {
                list(
                  name = item_data$Name,
                  application_type = item_data$ApplicationType,
                  formulation_key = item_data$FormulationKey,
                  parameters = lapply(
                    item_data$Parameters %||% list(),
                    function(param_data) {
                      # Convert Name to Path for Parameter class compatibility
                      if (
                        !is.null(param_data$Name) && is.null(param_data$Path)
                      ) {
                        param_data$Path <- param_data$Name
                      }
                      Parameter$new(param_data)
                    }
                  )
                )
              }
            )

            list(
              name = schema_data$Name,
              schema_items = schema_items,
              parameters = lapply(
                schema_data$Parameters %||% list(),
                function(param_data) {
                  # Convert Name to Path for Parameter class compatibility
                  if (!is.null(param_data$Name) && is.null(param_data$Path)) {
                    param_data$Path <- param_data$Name
                  }
                  Parameter$new(param_data)
                }
              )
            )
          }
        )
      } else {
        private$.schemas <- list()
      }
    },

    # Helper function to extract a parameter from a list of Parameter objects
    extract_parameter = function(params, param_name) {
      if (length(params) == 0 || is.null(param_name)) {
        return(NULL)
      }
      for (param in params) {
        if (!is.null(param$name) && param$name == param_name) {
          return(param)
        }
      }
      return(NULL)
    },

    get_human_application_type_from_value = function(application_type) {
      if (is.null(application_type)) {
        return(NA_character_)
      }

      switch(
        application_type,
        "Oral" = "Oral",
        "IntravenousBolus" = "Intravenous bolus",
        "IntravenousInfusion" = "Intravenous infusion",
        application_type
      )
    },

    get_dosing_interval_from_reps = function(rep_num_param, rep_time_param) {
      rep_number <- rep_num_param$value %||% 1
      rep_time <- rep_time_param$value %||% 0
      rep_time_unit <- rep_time_param$unit %||% "h"

      if (rep_number == 1) {
        return("Once")
      }

      # Convert any time unit to hours using the robust conversion function
      rep_time_duration <- convert_ospsuite_time_to_duration(
        rep_time,
        rep_time_unit
      )
      one_hour_duration <- convert_ospsuite_time_to_duration(1, "h")
      total_time_hours <- as.numeric(rep_time_duration) /
        as.numeric(one_hour_duration)

      doses_per_day <- 24 / total_time_hours

      if (abs(doses_per_day - 3) < 0.1) {
        return("3 times a day")
      }
      if (abs(doses_per_day - 2) < 0.1) {
        return("2 times a day")
      }
      if (abs(doses_per_day - 4) < 0.1) {
        return("4 times a day")
      }
      if (abs(doses_per_day - 1) < 0.1) {
        return("Once a day")
      }

      return(paste(rep_number, "times every", rep_time, rep_time_unit))
    }
  )
)
