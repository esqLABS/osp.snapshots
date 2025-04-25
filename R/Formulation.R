# Map from PK-Sim formulation types to human-readable types
FORMULATION_TYPE_MAP <- list(
  "Formulation_Dissolved" = "Dissolved",
  "Formulation_Tablet_Weibull" = "Weibull",
  "Formulation_Tablet_Lint80" = "Lint80",
  "Formulation_Particles" = "Particle",
  "Formulation_Table" = "Table",
  "Formulation_ZeroOrder" = "Zero Order",
  "Formulation_FirstOrder" = "First Order"
)

# Valid formulation types (PK-Sim formulation types)
VALID_FORMULATION_TYPES <- names(FORMULATION_TYPE_MAP)

#' Formulation class for OSP snapshot formulations
#'
#' @description
#' An R6 class that represents a formulation in an OSP snapshot.
#' This class provides methods to access different properties of a formulation
#' and display a summary of its information.
#'
#' @importFrom tibble tibble as_tibble
#' @export
Formulation <- R6::R6Class(
  classname = "Formulation",
  public = list(
    #' @description
    #' Create a new Formulation object
    #' @param data Raw formulation data from a snapshot
    #' @return A new Formulation object
    initialize = function(data) {
      private$.data <- data
      private$initialize_parameters()
    },

    #' @description
    #' Print a summary of the formulation including its properties and parameters.
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the Formulation object for method chaining
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h1("Formulation: {self$name}")

        # Display formulation type if available
        if (!is.null(self$formulation_type)) {
          formulation_type_human <- self$get_human_formulation_type()
          cli::cli_li("Type: {formulation_type_human}")
        }

        # Display parameters if available
        if (length(self$parameters) > 0) {
          cli::cli_h2("Parameters")
          for (param in self$parameters) {
            unit_display <- if (is.null(param$unit)) {
              ""
            } else {
              glue::glue(" {param$unit}")
            }
            cli::cli_li("{param$name}: {param$value}{unit_display}")

            # Display table points if available (for table-based formulations)
            if (!is.null(param$data$TableFormula)) {
              cli::cli_li("Release profile:")
              points <- param$data$TableFormula$Points
              x_unit <- param$data$TableFormula$XUnit

              # Create a table with time and fraction data
              time_points <- sapply(points, function(p) p$X)
              fraction_points <- sapply(points, function(p) p$Y)

              # Use sprintf for consistent table formatting like in print_methods.R
              cat("\n")
              cat(sprintf(
                "    %-12s | %s\n",
                glue::glue("Time [{x_unit}]"),
                "Fraction (dose)"
              ))
              cat(sprintf(
                "    %-12s-|-%s\n",
                glue::glue_collapse(rep("-", 12)),
                glue::glue_collapse(rep("-", 15))
              ))

              for (i in seq_along(time_points)) {
                cat(sprintf(
                  "    %-12s | %s\n",
                  format(
                    time_points[i],
                    digits = 2,
                    nsmall = 2
                  ),
                  format(
                    fraction_points[i],
                    digits = 2,
                    nsmall = 2
                  )
                ))
              }
              cat("\n")
            }
          }
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert formulation data to tibbles
    #' @param type Character. Type of data to convert: "all" (default) or "parameters"
    #' @return A list of tibbles containing the requested data
    to_df = function(type = "all") {
      # Validate type argument
      valid_types <- c("all", "parameters")
      if (!type %in% valid_types) {
        cli::cli_abort("{.arg type} must be one of: {valid_types}")
      }

      # Get the formulation name to use as ID
      formulation_id <- self$name

      # Initialize result list
      result <- list()

      # Add basic formulation data if requested
      if (type %in% c("all", "basic")) {
        # Create a list to store the data
        data_list <- list(
          formulation_id = formulation_id,
          name = self$name,
          formulation_type = self$formulation_type,
          formulation_type_human = self$get_human_formulation_type()
        )

        result$basic <- tibble::as_tibble(data_list)
      }

      # Add parameters data if requested
      if (type %in% c("all", "parameters")) {
        if (length(self$parameters) == 0) {
          result$parameters <- tibble::tibble(
            formulation_id = character(0),
            name = character(0),
            value = numeric(0),
            unit = character(0)
          )
        } else {
          # Extract parameter data
          param_rows <- lapply(self$parameters, function(param) {
            list(
              formulation_id = formulation_id,
              name = param$name,
              value = param$value,
              unit = param$unit %||% NA_character_
            )
          })
          result$parameters <- tibble::as_tibble(dplyr::bind_rows(
            param_rows
          ))
        }
      }

      # If only one type requested, return just that tibble
      if (type != "all") {
        return(result[[type]])
      }

      result
    },

    #' @description
    #' Get human-readable formulation type
    #' @return Character string with human-readable formulation type
    get_human_formulation_type = function() {
      # Return human-readable type or the original if not found
      FORMULATION_TYPE_MAP[[self$formulation_type]] %||%
        self$formulation_type
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL,
    initialize_parameters = function() {
      if (!is.null(private$.data$Parameters)) {
        # Convert each parameter to a Parameter object
        private$.parameters <- lapply(
          private$.data$Parameters,
          function(param) {
            # Map formulation parameter fields to Parameter structure
            param_data <- list(
              Path = param$Name, # Use Name as Path for parameters
              Value = param$Value
            )

            # Add Unit if present
            if (!is.null(param$Unit)) {
              param_data$Unit <- param$Unit
            }

            # Add ValueOrigin if present
            if (!is.null(param$ValueOrigin)) {
              param_data$ValueOrigin <- param$ValueOrigin
            }

            # Create Parameter object
            param_obj <- Parameter$new(param_data)

            # Store TableFormula as a custom attribute if present
            if (!is.null(param$TableFormula)) {
              param_obj$data$TableFormula <- param$TableFormula
            }

            param_obj
          }
        )

        # Name the parameters by their name
        names(private$.parameters) <- sapply(
          private$.parameters,
          function(p) p$name
        )

        # Add collection class for custom printing
        class(private$.parameters) <- c(
          "parameter_collection",
          "list"
        )
      }
    }
  ),
  active = list(
    #' @field data The raw data of the formulation (read-only)
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the formulation
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field formulation_type The formulation type identifier
    formulation_type = function(value) {
      if (missing(value)) {
        return(private$.data$FormulationType)
      }
      # Validate formulation type
      if (!(value %in% VALID_FORMULATION_TYPES)) {
        cli::cli_abort(
          "Invalid formulation type: {value}",
          "Formulation type must be one of {VALID_FORMULATION_TYPES}"
        )
      }
      private$.data$FormulationType <- value
    },

    #' @field parameters The list of parameter objects
    parameters = function(value) {
      if (missing(value)) {
        if (is.null(private$.parameters)) {
          private$.parameters <- list()
          class(private$.parameters) <- c(
            "parameter_collection",
            "list"
          )
        }
        return(private$.parameters)
      }

      if (is.null(value)) {
        private$.parameters <- list()
      } else {
        private$.parameters <- value
      }

      # Ensure class for custom printing
      if (
        !inherits(
          private$.parameters,
          "parameter_collection"
        )
      ) {
        class(private$.parameters) <- c(
          "parameter_collection",
          "list"
        )
      }

      # Update raw data to reflect parameter changes
      # Convert Parameter objects back to the format expected in .data
      private$.data$Parameters <- lapply(
        private$.parameters,
        function(param) {
          # Extract the data from Parameter object
          raw_param <- list(
            Name = param$name,
            Value = param$value
          )

          # Add Unit if present
          if (!is.null(param$unit)) {
            raw_param$Unit <- param$unit
          }

          # Add ValueOrigin if present
          if (!is.null(param$value_origin)) {
            raw_param$ValueOrigin <- param$value_origin
          }

          # Copy TableFormula if present
          if (!is.null(param$data$TableFormula)) {
            raw_param$TableFormula <- param$data$TableFormula
          }

          raw_param
        }
      )

      private$.parameters
    }
  )
)

#' Create a new formulation
#'
#' @description
#' Create a new formulation with the specified properties.
#' All arguments are optional except for name and type.
#'
#' @param name Character. Name of the formulation
#' @param type Character. Type of formulation, one of:
#'   * "Dissolved" - Immediate release solution
#'   * "Weibull" - Weibull tablet formulation
#'   * "Lint80" - Lint80 tablet formulation
#'   * "Particle" - Particle formulation
#'   * "Table" - Custom release profile table
#'   * "ZeroOrder" - Zero-order release formulation
#'   * "FirstOrder" - First-order release formulation
#' @param parameters List. A named list of parameters for the formulation. The valid parameters
#'        depend on the formulation type. Invalid parameters will result in an error.
#'
#' @section Weibull formulation parameters:
#' * dissolution_time - Time to achieve 50% dissolution (numeric, default: 240)
#' * dissolution_time_unit - Unit for dissolution time (character, default: "min")
#' * lag_time - Lag time before dissolution starts (numeric, default: 0)
#' * lag_time_unit - Unit for lag time (character, default: "min")
#' * dissolution_shape - Dissolution shape parameter (numeric, default: 0.92)
#' * suspension - Whether to use as suspension (logical, default: TRUE)
#'
#' @section Lint80 formulation parameters:
#' * dissolution_time - Time to achieve 80% dissolution (numeric, default: 240)
#' * dissolution_time_unit - Unit for dissolution time (character, default: "min")
#' * lag_time - Lag time before dissolution starts (numeric, default: 0)
#' * lag_time_unit - Unit for lag time (character, default: "min")
#' * suspension - Whether to use as suspension (logical, default: TRUE)
#'
#' @section Particle formulation parameters:
#' * thickness - Thickness of unstirred water layer (numeric, default: 30)
#' * thickness_unit - Unit for thickness (character, default: "µm")
#' * distribution_type - Type of distribution, "mono" or "poly" (character, default: "mono")
#' * radius - Particle radius (mean or geometric mean) (numeric, default: 10)
#' * radius_unit - Unit for radius (character, default: "µm")
#'
#' Parameters for polydisperse distribution (when distribution_type = "poly"):
#' * particle_size_distribution - "normal" or "lognormal" (character, default: "normal")
#' * radius_sd - Radius standard deviation, for normal distribution (numeric, default: 3)
#' * radius_sd_unit - Unit for radius SD (character, default: "µm")
#' * radius_cv - Coefficient of variation, for lognormal distribution (numeric, default: 1.5)
#' * radius_min - Minimum particle radius (numeric, default: 1)
#' * radius_min_unit - Unit for minimum radius (character, default: "µm")
#' * radius_max - Maximum particle radius (numeric, default: 19)
#' * radius_max_unit - Unit for maximum radius (character, default: "µm")
#' * n_bins - Number of bins (integer, default: 3)
#'
#' @section Table formulation parameters:
#' * tableX - Vector of time points for release profile in hours (numeric vector, required)
#' * tableY - Vector of fraction of dose at each time point (numeric vector, required)
#' * suspension - Whether to use as suspension (logical, default: TRUE)
#'
#' @section ZeroOrder formulation parameters:
#' * end_time - Time of administration end (numeric, default: 60)
#' * end_time_unit - Unit for end time (character, default: "min")
#'
#' @section FirstOrder formulation parameters:
#' * thalf - Half-life of the drug release (numeric, default: 0.01)
#' * thalf_unit - Unit for half-life (character, default: "min")
#'
#' @return A Formulation object
#' @export
#'
#' @examples
#' # Create a dissolved formulation (simplest type)
#' dissolved <- create_formulation(name = "Oral Solution", type = "Dissolved")
#'
#' # Create a Weibull tablet formulation
#' tablet <- create_formulation(
#'   name = "Standard Tablet",
#'   type = "Weibull",
#'   parameters = list(
#'     dissolution_time = 60,
#'     dissolution_time_unit = "min",
#'     lag_time = 10,
#'     lag_time_unit = "min",
#'     dissolution_shape = 0.92,
#'     suspension = TRUE
#'   )
#' )
#'
#' # Create a particle formulation with monodisperse distribution
#' particle <- create_formulation(
#'   name = "Suspension",
#'   type = "Particle",
#'   parameters = list(
#'     thickness = 25,
#'     thickness_unit = "µm",
#'     radius = 5,
#'     radius_unit = "µm"
#'   )
#' )
#'
#' # Create a table formulation with custom release profile
#' custom <- create_formulation(
#'   name = "Custom Release",
#'   type = "Table",
#'   parameters = list(
#'     tableX = c(0, 0.5, 1, 2, 4, 8),
#'     tableY = c(0, 0.1, 0.3, 0.6, 0.9, 1.0),
#'     suspension = TRUE
#'   )
#' )
create_formulation <- function(name, type, parameters = NULL) {
  # Convert human-readable type to PK-Sim formulation type if needed
  # Use the inverse mapping of FORMULATION_TYPE_MAP
  inverse_map <- stats::setNames(
    names(FORMULATION_TYPE_MAP),
    FORMULATION_TYPE_MAP
  )
  pk_sim_type <- inverse_map[[type]] %||% type

  # Validate formulation type
  if (!(pk_sim_type %in% VALID_FORMULATION_TYPES)) {
    cli::cli_abort(
      "Invalid formulation type: {type}",
      "Formulation type must be one of {VALID_FORMULATION_TYPES}"
    )
  }

  # Define valid parameters for each formulation type
  valid_params <- list(
    "Formulation_Dissolved" = list(),
    "Formulation_Tablet_Weibull" = c(
      "dissolution_time",
      "dissolution_time_unit",
      "lag_time",
      "lag_time_unit",
      "dissolution_shape",
      "suspension"
    ),
    "Formulation_Tablet_Lint80" = c(
      "dissolution_time",
      "dissolution_time_unit",
      "lag_time",
      "lag_time_unit",
      "suspension"
    ),
    "Formulation_Particles" = c(
      "thickness",
      "thickness_unit",
      "distribution_type",
      "radius",
      "radius_unit",
      "particle_size_distribution",
      "radius_sd",
      "radius_sd_unit",
      "radius_cv",
      "radius_min",
      "radius_min_unit",
      "radius_max",
      "radius_max_unit",
      "n_bins"
    ),
    "Formulation_Table" = c("tableX", "tableY", "suspension"),
    "Formulation_ZeroOrder" = c("end_time", "end_time_unit"),
    "Formulation_FirstOrder" = c("thalf", "thalf_unit")
  )

  # Check if there are any invalid parameters for this formulation type
  if (!is.null(parameters) && !is.list(parameters)) {
    cli::cli_abort("Parameters must be provided as a named list")
  }

  param_names <- names(parameters)
  if (length(param_names) > 0) {
    invalid_params <- param_names[
      !param_names %in% valid_params[[pk_sim_type]]
    ]
    if (length(invalid_params) > 0) {
      cli::cli_abort(c(
        "Invalid parameters for {type} formulation: {invalid_params}",
        "i" = "Valid parameters are: {valid_params[[pk_sim_type]]}"
      ))
    }
  }

  # Create parameter list with correct structure for the Formulation class
  param_list <- list()

  # Process parameters based on formulation type
  if (
    pk_sim_type %in%
      c("Formulation_Tablet_Weibull", "Formulation_Tablet_Lint80")
  ) {
    # Set default values and check for provided values
    dissolution_time <- 240
    dissolution_time_unit <- "min"
    lag_time <- 0
    lag_time_unit <- "min"
    dissolution_shape <- 0.92
    suspension <- TRUE

    if (!is.null(parameters$dissolution_time)) {
      dissolution_time <- parameters$dissolution_time
    } else {
      cli::cli_inform(
        "No dissolution_time provided, using default value of {dissolution_time} {dissolution_time_unit}"
      )
    }

    if (!is.null(parameters$dissolution_time_unit)) {
      dissolution_time_unit <- parameters$dissolution_time_unit
    } else {
      cli::cli_inform(
        "No dissolution_time_unit provided, using default unit of {dissolution_time_unit}"
      )
    }

    if (!is.null(parameters$lag_time)) {
      lag_time <- parameters$lag_time
    } else {
      cli::cli_inform(
        "No lag_time provided, using default value of {lag_time}"
      )
    }

    if (!is.null(parameters$lag_time_unit)) {
      lag_time_unit <- parameters$lag_time_unit
    } else {
      cli::cli_inform(
        "No lag_time_unit provided, using default unit of {lag_time_unit}"
      )
    }

    if (!is.null(parameters$suspension)) {
      suspension <- parameters$suspension
    } else {
      cli::cli_inform(
        "No suspension parameter provided, using default value of {suspension}"
      )
    }

    # Create parameter list
    param_list <- list(
      list(
        Name = paste0(
          "Dissolution time (",
          ifelse(
            pk_sim_type == "Formulation_Tablet_Weibull",
            "50%",
            "80%"
          ),
          " dissolved)"
        ),
        Value = dissolution_time,
        Unit = dissolution_time_unit
      ),
      list(
        Name = "Lag time",
        Value = lag_time,
        Unit = lag_time_unit
      )
    )

    # Add dissolution shape for Weibull formulation
    if (pk_sim_type == "Formulation_Tablet_Weibull") {
      if (!is.null(parameters$dissolution_shape)) {
        dissolution_shape <- parameters$dissolution_shape
      } else {
        cli::cli_inform(
          "No dissolution_shape provided, using default value of {dissolution_shape}"
        )
      }

      param_list <- c(
        param_list,
        list(
          list(
            Name = "Dissolution shape",
            Value = dissolution_shape
          )
        )
      )
    }

    # Add suspension parameter
    param_list <- c(
      param_list,
      list(
        list(
          Name = "Use as suspension",
          Value = as.numeric(suspension)
        )
      )
    )
  } else if (pk_sim_type == "Formulation_Particles") {
    # Set default values for particle formulation
    thickness <- 30
    thickness_unit <- "µm"
    distribution_type <- "mono"
    radius <- 10
    radius_unit <- "µm"
    particle_size_distribution <- "normal"
    radius_sd <- 3
    radius_sd_unit <- "µm"
    radius_cv <- 1.5
    radius_min <- 1
    radius_min_unit <- "µm"
    radius_max <- 19
    radius_max_unit <- "µm"
    n_bins <- 3

    # Override defaults with provided values
    if (!is.null(parameters$thickness)) {
      thickness <- parameters$thickness
    } else {
      cli::cli_inform(
        "No thickness provided, using default value of {thickness}"
      )
    }

    if (!is.null(parameters$thickness_unit)) {
      thickness_unit <- parameters$thickness_unit
    } else {
      cli::cli_inform(
        "No thickness_unit provided, using default unit of {thickness_unit}"
      )
    }

    if (!is.null(parameters$distribution_type)) {
      distribution_type <- parameters$distribution_type
      if (!distribution_type %in% c("mono", "poly")) {
        cli::cli_abort("distribution_type must be 'mono' or 'poly'")
      }
    } else {
      cli::cli_inform(
        "No distribution_type provided, using default of {distribution_type}"
      )
    }

    if (!is.null(parameters$radius)) {
      radius <- parameters$radius
    } else {
      cli::cli_inform(
        "No radius provided, using default value of {radius}"
      )
    }

    if (!is.null(parameters$radius_unit)) {
      radius_unit <- parameters$radius_unit
    } else {
      cli::cli_inform(
        "No radius_unit provided, using default unit of {radius_unit}"
      )
    }

    # Build parameter list
    param_list <- list(
      list(
        Name = "Thickness (unstirred water layer)",
        Value = thickness,
        Unit = thickness_unit
      ),
      list(
        Name = "Type of particle size distribution",
        Value = ifelse(distribution_type == "mono", 0, 1)
      ),
      list(
        Name = paste0(
          "Particle radius (",
          ifelse(
            distribution_type == "mono" ||
              (distribution_type == "poly" &&
                particle_size_distribution == "lognormal"),
            "",
            "geo"
          ),
          "mean)"
        ),
        Value = radius,
        Unit = radius_unit
      )
    )

    # Add additional parameters for polydisperse distribution
    if (distribution_type == "poly") {
      if (!is.null(parameters$particle_size_distribution)) {
        particle_size_distribution <- parameters$particle_size_distribution
        if (!particle_size_distribution %in% c("normal", "lognormal")) {
          cli::cli_abort(
            "particle_size_distribution must be 'normal' or 'lognormal'"
          )
        }
      } else {
        cli::cli_inform(
          "No particle_size_distribution provided, using default of {particle_size_distribution}"
        )
      }

      param_list <- c(
        param_list,
        list(
          list(
            Name = "Particle size distribution",
            Value = ifelse(
              particle_size_distribution == "normal",
              0,
              1
            )
          )
        )
      )

      if (particle_size_distribution == "normal") {
        if (!is.null(parameters$radius_sd)) {
          radius_sd <- parameters$radius_sd
        } else {
          cli::cli_inform(
            "No radius_sd provided, using default value of {radius_sd}"
          )
        }

        if (!is.null(parameters$radius_sd_unit)) {
          radius_sd_unit <- parameters$radius_sd_unit
        } else {
          cli::cli_inform(
            "No radius_sd_unit provided, using default unit of {radius_sd_unit}"
          )
        }

        param_list <- c(
          param_list,
          list(
            list(
              Name = "Particle radius (SD)",
              Value = radius_sd,
              Unit = radius_sd_unit
            )
          )
        )
      } else {
        if (!is.null(parameters$radius_cv)) {
          radius_cv <- parameters$radius_cv
        } else {
          cli::cli_inform(
            "No radius_cv provided, using default value of {radius_cv}"
          )
        }

        param_list <- c(
          param_list,
          list(
            list(
              Name = "Coefficient of variation",
              Value = radius_cv
            )
          )
        )
      }

      # Add min/max radius and bins for poly distribution
      if (!is.null(parameters$radius_min)) {
        radius_min <- parameters$radius_min
      } else {
        cli::cli_inform(
          "No radius_min provided, using default value of {radius_min}"
        )
      }

      if (!is.null(parameters$radius_min_unit)) {
        radius_min_unit <- parameters$radius_min_unit
      } else {
        cli::cli_inform(
          "No radius_min_unit provided, using default unit of {radius_min_unit}"
        )
      }

      if (!is.null(parameters$radius_max)) {
        radius_max <- parameters$radius_max
      } else {
        cli::cli_inform(
          "No radius_max provided, using default value of {radius_max}"
        )
      }

      if (!is.null(parameters$radius_max_unit)) {
        radius_max_unit <- parameters$radius_max_unit
      } else {
        cli::cli_inform(
          "No radius_max_unit provided, using default unit of {radius_max_unit}"
        )
      }

      if (!is.null(parameters$n_bins)) {
        n_bins <- parameters$n_bins
      } else {
        cli::cli_inform(
          "No n_bins provided, using default value of {n_bins}"
        )
      }

      param_list <- c(
        param_list,
        list(
          list(
            Name = "Particle radius (min)",
            Value = radius_min,
            Unit = radius_min_unit
          ),
          list(
            Name = "Particle radius (max)",
            Value = radius_max,
            Unit = radius_max_unit
          ),
          list(
            Name = "Number of bins",
            Value = n_bins
          )
        )
      )
    }
  } else if (pk_sim_type == "Formulation_Table") {
    # Table formulation requires tableX and tableY
    if (is.null(parameters$tableX) || is.null(parameters$tableY)) {
      cli::cli_abort(
        "Table formulation requires both tableX and tableY parameters"
      )
    }

    if (length(parameters$tableX) != length(parameters$tableY)) {
      cli::cli_abort("tableX and tableY must have the same length")
    }

    suspension <- TRUE
    if (!is.null(parameters$suspension)) {
      suspension <- parameters$suspension
    } else {
      cli::cli_inform(
        "No suspension parameter provided, using default value of TRUE"
      )
    }

    # Create parameter list for table formulation
    param_list <- list(
      list(
        Name = "Use as suspension",
        Value = as.numeric(suspension)
      ),
      list(
        Name = "Fraction (dose)",
        Value = parameters$tableY[1],
        TableFormula = list(
          Name = "Fraction (dose)",
          XName = "Time",
          XDimension = "Time",
          XUnit = "h",
          YName = "Fraction (dose)",
          YDimension = "Dimensionless",
          UseDerivedValues = TRUE,
          Points = lapply(seq_along(parameters$tableX), function(i) {
            list(
              X = parameters$tableX[i],
              Y = parameters$tableY[i],
              RestartSolver = FALSE
            )
          })
        )
      )
    )
  } else if (pk_sim_type == "Formulation_ZeroOrder") {
    # ZeroOrder formulation parameters
    end_time <- 60
    end_time_unit <- "min"

    if (!is.null(parameters$end_time)) {
      end_time <- parameters$end_time
    } else {
      cli::cli_inform(
        "No end_time provided, using default value of {end_time}"
      )
    }

    if (!is.null(parameters$end_time_unit)) {
      end_time_unit <- parameters$end_time_unit
    } else {
      cli::cli_inform(
        "No end_time_unit provided, using default unit of {end_time_unit}"
      )
    }

    param_list <- list(
      list(
        Name = "End time",
        Value = end_time,
        Unit = end_time_unit
      )
    )
  } else if (pk_sim_type == "Formulation_FirstOrder") {
    # FirstOrder formulation parameters
    thalf <- 0.01
    thalf_unit <- "min"

    if (!is.null(parameters$thalf)) {
      thalf <- parameters$thalf
    } else {
      cli::cli_inform(
        "No thalf provided, using default value of {thalf}"
      )
    }

    if (!is.null(parameters$thalf_unit)) {
      thalf_unit <- parameters$thalf_unit
    } else {
      cli::cli_inform(
        "No thalf_unit provided, using default unit of {thalf_unit}"
      )
    }

    param_list <- list(
      list(
        Name = "t1/2",
        Value = thalf,
        Unit = thalf_unit
      )
    )
  }

  # Create the data structure
  data <- list(
    Name = name,
    FormulationType = pk_sim_type
  )

  # Add parameters if any were created
  if (length(param_list) > 0) {
    data$Parameters <- param_list
  }

  # Create and return the Formulation object
  Formulation$new(data)
}

#' Load formulations from a list
#'
#' @description
#' Converts a list of formulation data to Formulation objects
#'
#' @param formulation_list List. List of formulation data from a snapshot
#'
#' @return List of Formulation objects
#' @export
#'
#' @examples
#' \dontrun{
#' # Load snapshot and get formulations
#' snapshot <- load_snapshot("path/to/snapshot.json")
#' formulations <- load_formulations(snapshot$data$Formulations)
#' }
load_formulations <- function(formulation_list) {
  # Check if input is NULL or empty
  if (is.null(formulation_list) || length(formulation_list) == 0) {
    empty_result <- list()
    # Add class for consistent behavior
    class(empty_result) <- c("formulation_collection", "list")
    return(empty_result)
  }

  # Create formulation objects
  formulations <- lapply(formulation_list, function(data) {
    Formulation$new(data)
  })

  # Name the list elements by formulation name
  names(formulations) <- sapply(formulations, function(f) f$name)

  # Add class for potential custom printing
  class(formulations) <- c("formulation_collection", "list")

  return(formulations)
}

#' Add a formulation to a snapshot
#'
#' @description
#' Add a Formulation object to a Snapshot. This is a convenience function
#' that works with the Snapshot class.
#'
#' @param snapshot A Snapshot object
#' @param formulation A Formulation object created with create_formulation()
#' @return The updated Snapshot object
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a snapshot
#' snapshot <- load_snapshot("path/to/snapshot.json")
#'
#' # Create a new formulation
#' form <- create_formulation(
#'   name = "Custom Tablet",
#'   type = "Weibull",
#'   parameters = list(
#'     dissolution_time = 60,
#'     dissolution_time_unit = "min",
#'     lag_time = 0,
#'     lag_time_unit = "min",
#'     dissolution_shape = 0.92,
#'     suspension = TRUE
#'   )
#' )
#'
#' # Add the formulation to the snapshot
#' snapshot <- add_formulation(snapshot, form)
#' }
# See R/Snapshot.R for add_formulation implementation
