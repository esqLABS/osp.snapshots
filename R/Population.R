# Valid DistributionType enum values, used by
# `AdvancedParameter$distribution_type`. No dedicated factory exists for
# AdvancedParameter, so this setter is the sole enforcement point.
DISTRIBUTION_TYPES <- c("Normal", "LogNormal", "Uniform", "Discrete", "Unknown")

#' Population class for OSP snapshot populations
#'
#' @description
#' An R6 class that represents a population in an OSP snapshot.
#' This class provides methods to access different properties of a population
#' and display a summary of its information.
#'
#' @importFrom tibble tibble as_tibble
#' @importFrom glue glue
#' @importFrom R6 R6Class
#'
#' @export
Population <- R6::R6Class(
  classname = "Population",
  public = list(
    #' @description
    #' Create a new Population object
    #' @param data Raw population data from a snapshot
    #' @return A new Population object
    initialize = function(data) {
      private$.data <- data

      # Initialize ranges if present
      if (!is.null(data$Settings$Age)) {
        private$.age_range <- Range$new(
          data$Settings$Age$Min,
          data$Settings$Age$Max,
          data$Settings$Age$Unit
        )
      }

      if (!is.null(data$Settings$Weight)) {
        private$.weight_range <- Range$new(
          data$Settings$Weight$Min,
          data$Settings$Weight$Max,
          data$Settings$Weight$Unit
        )
      }

      if (!is.null(data$Settings$Height)) {
        private$.height_range <- Range$new(
          data$Settings$Height$Min,
          data$Settings$Height$Max,
          data$Settings$Height$Unit
        )
      }

      if (!is.null(data$Settings$BMI)) {
        private$.bmi_range <- Range$new(
          data$Settings$BMI$Min,
          data$Settings$BMI$Max,
          data$Settings$BMI$Unit
        )
      }

      if (!is.null(data$Settings$GestationalAge)) {
        private$.gestational_age_range <- Range$new(
          data$Settings$GestationalAge$Min,
          data$Settings$GestationalAge$Max,
          data$Settings$GestationalAge$Unit
        )
      }

      # Initialize advanced parameters if present
      if (!is.null(data$AdvancedParameters)) {
        private$.advanced_parameters <- lapply(
          data$AdvancedParameters,
          function(param) {
            AdvancedParameter$new(param)
          }
        )
      }

      # Initialize disease state parameter ranges (eGFR convenience cache)
      private$.egfr_range <- egfr_range_from_entries(
        data$Settings$DiseaseStateParameters
      )
    },

    #' @description
    #' Print a summary of the population including its properties and settings.
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the Population object for method chaining
    print = function(...) {
      output <- cli::cli_format_method({
        # Header with name and seed (if available)
        seed_text <- if (!is.null(self$seed)) {
          glue::glue(" (Seed: {self$seed})")
        } else {
          ""
        }
        cli::cli_h2("Population: {self$name}{seed_text}")

        # Description (if available)
        if (!is.null(self$description)) {
          cli::cli_text("Description: {self$description}")
        }

        # Individual name (if available)
        if (!is.null(self$individual_name)) {
          cli::cli_text("Individual name: {self$individual_name}")
        }

        # Source population (if available)
        if (!is.null(self$source_population)) {
          cli::cli_text(
            "Source Population: {self$source_population}"
          )
        }

        # Basic properties
        cli::cli_text("Number of individuals: {self$number_of_individuals}")
        cli::cli_text(
          "Proportion of females: {self$proportion_of_females}%"
        )

        # Age range
        if (!is.null(self$age_range)) {
          cli::cli_text(
            "Age range: {self$age_range$min} - {self$age_range$max} {self$age_range$unit}"
          )
        }

        # Weight range (if available)
        if (!is.null(self$weight_range)) {
          cli::cli_text(
            "Weight range: {self$weight_range$min} - {self$weight_range$max} {self$weight_range$unit}"
          )
        }

        # Height range (if available)
        if (!is.null(self$height_range)) {
          cli::cli_text(
            "Height range: {self$height_range$min} - {self$height_range$max} {self$height_range$unit}"
          )
        }

        # BMI range (if available)
        if (!is.null(self$bmi_range)) {
          cli::cli_text(
            "BMI range: {self$bmi_range$min} - {self$bmi_range$max} {self$bmi_range$unit}"
          )
        }

        # Gestational age range (if available)
        if (!is.null(self$gestational_age_range)) {
          cli::cli_text(
            "Gestational age range: \\
            {self$gestational_age_range$min} - \\
            {self$gestational_age_range$max} \\
            {self$gestational_age_range$unit}"
          )
        }

        # Disease state parameter ranges (eGFR for now)
        if (!is.null(self$egfr_range)) {
          cli::cli_text(
            "eGFR range: {self$egfr_range$min} - {self$egfr_range$max} {self$egfr_range$unit}"
          )
        }

        # Advanced parameters
        if (length(private$.advanced_parameters) > 0) {
          cli::cli_h3("Advanced Parameters")
          cli::cli_text(
            "{length(private$.advanced_parameters)} advanced parameters defined"
          )
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert the population to a list of data frames for easier analysis
    #'
    #' @return A list containing data frames with population information:
    #' \itemize{
    #'   \item characteristics: Population characteristics including basic information and physiological parameters
    #'   \item parameters: Advanced parameters information
    #' }
    to_df = function() {
      # Create characteristics data frame with all columns
      characteristics_df <- tibble::tibble(
        population_id = self$name,
        name = self$name,
        seed = self$seed,
        number_of_individuals = self$number_of_individuals,
        proportion_of_females = self$proportion_of_females,
        source_population = self$source_population %||% NA_character_,
        individual_name = self$individual_name %||% NA_character_,
        age_min = self$age_range$min %||% NA_real_,
        age_max = self$age_range$max %||% NA_real_,
        age_unit = self$age_range$unit %||% NA_character_,
        weight_min = self$weight_range$min %||% NA_real_,
        weight_max = self$weight_range$max %||% NA_real_,
        weight_unit = self$weight_range$unit %||% NA_character_,
        height_min = self$height_range$min %||% NA_real_,
        height_max = self$height_range$max %||% NA_real_,
        height_unit = self$height_range$unit %||% NA_character_,
        bmi_min = self$bmi_range$min %||% NA_real_,
        bmi_max = self$bmi_range$max %||% NA_real_,
        bmi_unit = self$bmi_range$unit %||% NA_character_,
        egfr_min = self$egfr_range$min %||% NA_real_,
        egfr_max = self$egfr_range$max %||% NA_real_,
        egfr_unit = self$egfr_range$unit %||% NA_character_
      )

      # Create parameters data frame
      params_df <- tibble::tibble(
        population_id = character(0),
        parameter = character(0),
        seed = integer(0),
        distribution_type = character(0),
        statistic = character(0),
        value = numeric(0),
        unit = character(0),
        source = character(0),
        description = character(0)
      )

      if (length(private$.advanced_parameters) > 0) {
        for (param in private$.advanced_parameters) {
          if (length(param$parameters) > 0) {
            for (stat in param$parameters) {
              # Get source and description if available
              source <- NA_character_
              description <- NA_character_

              if (!is.null(stat$ValueOrigin)) {
                source <- stat$ValueOrigin$Source
                if (!is.null(stat$ValueOrigin$Description)) {
                  description <- stat$ValueOrigin$Description
                }
              }

              params_df <- dplyr::bind_rows(
                params_df,
                tibble::tibble(
                  population_id = self$name,
                  parameter = param$name,
                  seed = param$seed,
                  distribution_type = param$distribution_type,
                  statistic = stat$Name,
                  value = stat$Value,
                  unit = ifelse(is.null(stat$Unit), NA_character_, stat$Unit),
                  source = source,
                  description = description
                )
              )
            }
          } else {
            # If no parameters, add just the basic info
            params_df <- dplyr::bind_rows(
              params_df,
              tibble::tibble(
                population_id = self$name,
                parameter = param$name,
                seed = param$seed,
                distribution_type = param$distribution_type,
                statistic = NA_character_,
                value = NA_real_,
                unit = NA_character_,
                source = NA_character_,
                description = NA_character_
              )
            )
          }
        }
      }
      # Return all data frames as a list
      return(list(
        characteristics = characteristics_df,
        parameters = params_df
      ))
    }
  ),

  active = list(
    #' @field data The raw data of the population (read-only)
    data = function() {
      private$.data
    },

    #' @field name The name of the population. Writable: must be a
    #'   non-empty scalar string.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      check_required_string(value, "name")
      private$.data$Name <- value
    },

    #' @field description A free-text description of the population
    description = function(value) {
      if (missing(value)) {
        return(private$.data$Description)
      }
      private$.data$Description <- value
    },

    #' @field source_population The source population name (read-only)
    source_population = function(value) {
      # not editable
      if (!missing(value)) {
        cli::cli_abort("source_population is read-only")
      }
      return(private$.data$Settings$Individual$OriginData$Population)
    },

    #' @field individual_name The individual name (read-only)
    individual_name = function(value) {
      # not editable
      if (!missing(value)) {
        cli::cli_abort("individual_name is read-only")
      }
      return(private$.data$Settings$Individual$Name)
    },

    #' @field individual The base individual the population samples from,
    #'   returned as an [Individual] object built from the base individual
    #'   in the population settings, or `NULL` when none is set
    #'   (read-only). Author it at construction time via the `individual`
    #'   argument of [create_population()].
    individual = function(value) {
      if (!missing(value)) {
        cli::cli_abort("individual is read-only")
      }
      if (is.null(private$.data$Settings$Individual)) {
        return(NULL)
      }
      Individual$new(private$.data$Settings$Individual)
    },

    #' @field seed The seed used for population generation
    seed = function(value) {
      if (missing(value)) {
        return(private$.data$Seed)
      }
      private$.data$Seed <- value
    },

    #' @field number_of_individuals The number of individuals in the
    #'   population. Writable: must be a single positive whole number.
    number_of_individuals = function(value) {
      if (missing(value)) {
        return(private$.data$Settings$NumberOfIndividuals)
      }
      if (
        !is.numeric(value) ||
          length(value) != 1 ||
          !is.finite(value) ||
          value < 1 ||
          value != round(value)
      ) {
        cli::cli_abort(
          "{.arg number_of_individuals} must be a positive integer"
        )
      }
      private$.data$Settings$NumberOfIndividuals <- value
    },

    #' @field proportion_of_females The percentage of females in the population
    proportion_of_females = function(value) {
      if (missing(value)) {
        return(private$.data$Settings$ProportionOfFemales)
      }
      if (!is.numeric(value) || value < 0 || value > 100) {
        cli::cli_abort(
          "Proportion of females must be a number between 0 and 100"
        )
      }
      private$.data$Settings$ProportionOfFemales <- value
    },

    #' @field age_range The age range for the population. Writable: the
    #'   `Range`'s `unit` must be a valid unit for dimension `"Age in
    #'   years"`.
    age_range = function(value) {
      if (missing(value)) {
        return(private$.age_range)
      }
      # If value is NULL, set age_range to NULL and remove from data
      if (is.null(value)) {
        private$.age_range <- NULL
        private$.data$Settings$Age <- NULL
        return(invisible(NULL))
      }

      # If value is not a Range object, check if age_range is empty
      if (!inherits(value, "Range")) {
        if (is.null(private$.age_range)) {
          cli::cli_abort(c(
            "age_range is empty and individual elements cannot be set",
            "i" = "Use `...$age_range <- range(...)` to initialize a new range first."
          ))
        } else {
          cli::cli_abort("age_range must be a Range object")
        }
      }
      validate_unit(value$unit, "Age in years")
      # Set age_range and update data
      private$.age_range <- value
      private$.data$Settings$Age <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field weight_range The weight range for the population. Writable:
    #'   the `Range`'s `unit` must be a valid unit for dimension `"Mass"`.
    weight_range = function(value) {
      if (missing(value)) {
        return(private$.weight_range)
      }
      if (is.null(value)) {
        private$.weight_range <- NULL
        private$.data$Settings$Weight <- NULL
        return(invisible(NULL))
      }
      if (!inherits(value, "Range")) {
        if (is.null(private$.weight_range)) {
          cli::cli_abort(c(
            "weight_range is empty and individual elements cannot be set",
            "i" = "Use `...$weight_range <- range(...)` to initialize a new range first."
          ))
        } else {
          cli::cli_abort("weight_range must be a Range object")
        }
      }
      validate_unit(value$unit, "Mass")
      # Set weight_range and update data
      private$.weight_range <- value
      private$.data$Settings$Weight <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field height_range The height range for the population. Writable:
    #'   the `Range`'s `unit` must be a valid unit for dimension `"Length"`.
    height_range = function(value) {
      if (missing(value)) {
        return(private$.height_range)
      }
      if (is.null(value)) {
        private$.height_range <- NULL
        private$.data$Settings$Height <- NULL
        return(invisible(NULL))
      }
      if (!inherits(value, "Range")) {
        if (is.null(private$.height_range)) {
          cli::cli_abort(c(
            "height_range is empty and individual elements cannot be set",
            "i" = "Use `...$height_range <- range(...)` to initialize a new range first."
          ))
        } else {
          cli::cli_abort("height_range must be a Range object")
        }
      }
      validate_unit(value$unit, "Length")
      # Set height_range and update data
      private$.height_range <- value
      private$.data$Settings$Height <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field bmi_range The BMI range for the population. Writable: when
    #'   the `"BMI"` dimension resolves in the installed `ospsuite`, the
    #'   `Range`'s `unit` must be a valid unit for it; otherwise the unit is
    #'   left unvalidated (a documented, opportunistic limitation).
    bmi_range = function(value) {
      if (missing(value)) {
        return(private$.bmi_range)
      }
      if (is.null(value)) {
        private$.bmi_range <- NULL
        private$.data$Settings$BMI <- NULL
        return(invisible(NULL))
      }
      if (!inherits(value, "Range")) {
        if (is.null(private$.bmi_range)) {
          cli::cli_abort(c(
            "bmi_range is empty and individual elements cannot be set",
            "i" = "Use `...$bmi_range <- range(...)` to initialize a new range first."
          ))
        } else {
          cli::cli_abort("bmi_range must be a Range object")
        }
      }
      if (bmi_dimension_resolves()) {
        validate_unit(value$unit, "BMI")
      }
      # Set bmi_range and update data
      private$.bmi_range <- value
      private$.data$Settings$BMI <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field gestational_age_range The gestational age range used for
    #'   population generation. Writable: the `Range`'s `unit` must be a
    #'   valid unit for dimension `"Time"`.
    gestational_age_range = function(value) {
      if (missing(value)) {
        return(private$.gestational_age_range)
      }
      if (is.null(value)) {
        private$.gestational_age_range <- NULL
        private$.data$Settings$GestationalAge <- NULL
        return(invisible(NULL))
      }
      if (!inherits(value, "Range")) {
        if (is.null(private$.gestational_age_range)) {
          cli::cli_abort(c(
            "gestational_age_range is empty and individual elements cannot be set",
            "i" = "Use `...$gestational_age_range <- range(...)` to initialize a new range first."
          ))
        } else {
          cli::cli_abort("gestational_age_range must be a Range object")
        }
      }
      validate_unit(value$unit, "Time")
      # Set gestational_age_range and update data
      private$.gestational_age_range <- value
      private$.data$Settings$GestationalAge <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field egfr_range The eGFR range for the population (if available).
    #'   Convenience over the case-insensitive `"egfr"` entry of
    #'   `disease_state_parameters`; writes persist into the population
    #'   settings so they survive export.
    egfr_range = function(value) {
      if (missing(value)) {
        return(private$.egfr_range)
      }
      if (is.null(value)) {
        private$.egfr_range <- NULL
        private$.data$Settings$DiseaseStateParameters <- upsert_egfr_entry(
          private$.data$Settings$DiseaseStateParameters,
          NULL
        )
        return(invisible(NULL))
      }
      if (!inherits(value, "Range")) {
        if (is.null(private$.egfr_range)) {
          cli::cli_abort(c(
            "egfr_range is empty and individual elements cannot be set",
            "i" = "Use `...$egfr_range <- range(...)` to initialize a new range first."
          ))
        } else {
          cli::cli_abort("egfr_range must be a Range object")
        }
      }
      private$.egfr_range <- value
      private$.data$Settings$DiseaseStateParameters <- upsert_egfr_entry(
        private$.data$Settings$DiseaseStateParameters,
        value
      )
    },

    #' @field disease_state_parameters The population disease-state
    #'   parameters as a named list mapping each parameter name to a
    #'   [Range] object. Assign a named list of `Range` objects to
    #'   replace them, or `NULL` to clear them. This population-level
    #'   name-to-`Range` map is distinct from the base individual's own
    #'   `disease_state_parameters`, which carries scalar parameter
    #'   values.
    disease_state_parameters = function(value) {
      if (missing(value)) {
        result <- list()
        for (param in private$.data$Settings$DiseaseStateParameters) {
          result[[param$Name]] <- Range$new(
            param$Min,
            param$Max,
            param$Unit
          )
        }
        return(result)
      }
      if (is.null(value)) {
        private$.data$Settings$DiseaseStateParameters <- NULL
        private$.egfr_range <- NULL
        return(invisible(NULL))
      }
      if (!is.list(value)) {
        cli::cli_abort(c(
          "disease_state_parameters must be a named list of Range objects",
          "i" = "Use `range()` to create one."
        ))
      }
      param_names <- names(value)
      if (
        is.null(param_names) ||
          any(is.na(param_names)) ||
          any(param_names == "")
      ) {
        cli::cli_abort(c(
          "disease_state_parameters must be a named list of Range objects",
          "i" = "Each entry must be `name = range(...)`."
        ))
      }
      entries <- list()
      for (nm in param_names) {
        range_value <- value[[nm]]
        if (!inherits(range_value, "Range")) {
          cli::cli_abort(c(
            "disease_state_parameters must be a named list of Range objects",
            "i" = "Use `range()` to create one."
          ))
        }
        entries[[length(entries) + 1]] <- disease_state_param_to_list(
          nm,
          list(
            Min = range_value$min,
            Max = range_value$max,
            Unit = range_value$unit
          )
        )
      }
      private$.data$Settings$DiseaseStateParameters <- entries
      private$.egfr_range <- egfr_range_from_entries(entries)
    },

    #' @field advanced_parameters Advanced parameters for the population
    advanced_parameters = function() {
      private$.advanced_parameters
    }
  ),

  private = list(
    .data = NULL,
    .advanced_parameters = list(),
    .age_range = NULL,
    .weight_range = NULL,
    .height_range = NULL,
    .bmi_range = NULL,
    .gestational_age_range = NULL,
    .egfr_range = NULL
  )
)

#' AdvancedParameter class for Population advanced parameters
#'
#' @description
#' An R6 class that represents an advanced parameter in a population.
#'
#' @export
AdvancedParameter <- R6::R6Class(
  classname = "AdvancedParameter",
  public = list(
    #' @description
    #' Create a new AdvancedParameter object
    #' @param data Raw parameter data from a population
    #' @return A new AdvancedParameter object
    initialize = function(data) {
      private$.data <- data
    },

    #' @description
    #' Print a summary of the advanced parameter
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the AdvancedParameter object for method chaining
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_text("Parameter: {self$name}")
        cli::cli_text("Distribution type: {self$distribution_type}")
        cli::cli_text("Seed: {self$seed}")

        if (length(self$parameters) > 0) {
          for (param in self$parameters) {
            unit_text <- ifelse(
              is.null(param$Unit),
              "",
              paste0(" ", param$Unit)
            )
            cli::cli_text("  {param$Name}: {param$Value}{unit_text}")
          }
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    }
  ),

  active = list(
    #' @field data The raw data of the parameter (read-only)
    data = function() {
      private$.data
    },

    #' @field name The name of the parameter
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field seed The seed used for parameter generation
    seed = function(value) {
      if (missing(value)) {
        return(private$.data$Seed)
      }
      private$.data$Seed <- value
    },

    #' @field distribution_type The distribution type of the parameter.
    #'   Writable: one of `"Normal"`, `"LogNormal"`, `"Uniform"`,
    #'   `"Discrete"`, `"Unknown"`, or `NULL` to clear.
    distribution_type = function(value) {
      if (missing(value)) {
        return(private$.data$DistributionType)
      }
      if (!is.null(value)) {
        check_required_string(value, "distribution_type")
        if (!(value %in% DISTRIBUTION_TYPES)) {
          cli::cli_abort(
            "{.arg distribution_type} must be one of {.val {DISTRIBUTION_TYPES}}"
          )
        }
      }
      private$.data$DistributionType <- value
    },

    #' @field parameters The parameters of the distribution
    parameters = function(value) {
      if (missing(value)) {
        return(private$.data$Parameters)
      }
      private$.data$Parameters <- value
    }
  ),

  private = list(
    .data = NULL
  )
)

# Internal: whether the "BMI" dimension resolves in the installed
# `ospsuite`. Used by `Population$bmi_range` to opportunistically validate
# the range's unit only when the dimension is resolvable, per the
# documented limitation that this check depends on the installed
# `ospsuite` version. Re-checked on every call rather than cached, since
# the cost is negligible and caching would risk staleness across sessions.
bmi_dimension_resolves <- function() {
  tryCatch(
    {
      ospsuite::getUnitsForDimension("BMI")
      TRUE
    },
    error = function(e) FALSE
  )
}

# Serialize a single disease-state parameter to its `ParameterRange` shape.
# `range_list` is the `list(Min, Max, Unit)` produced by `range_to_list()`,
# so the element order is exactly `Name, Min, Max, Unit`.
disease_state_param_to_list <- function(name, range_list) {
  c(list(Name = name), range_list)
}

# Upsert or remove the case-insensitive "egfr" entry of a
# `DiseaseStateParameters` list, preserving all other entries and their
# order. Returns the updated list (or NULL when it becomes empty).
upsert_egfr_entry <- function(entries, range) {
  entries <- entries %||% list()
  egfr_index <- NULL
  for (i in seq_along(entries)) {
    nm <- entries[[i]]$Name
    if (!is.null(nm) && tolower(nm) == "egfr") {
      egfr_index <- i
      break
    }
  }
  if (is.null(range)) {
    if (!is.null(egfr_index)) {
      entries[[egfr_index]] <- NULL
    }
    if (length(entries) == 0) {
      return(NULL)
    }
    return(entries)
  }
  range_list <- list(Min = range$min, Max = range$max, Unit = range$unit)
  if (is.null(egfr_index)) {
    entries[[length(entries) + 1]] <- disease_state_param_to_list(
      "eGFR",
      range_list
    )
  } else {
    entries[[egfr_index]] <- disease_state_param_to_list(
      entries[[egfr_index]]$Name,
      range_list
    )
  }
  entries
}

# Reconstruct the eGFR `Range` from a `DiseaseStateParameters` list using
# the case-insensitive "egfr" match. Returns NULL when absent.
egfr_range_from_entries <- function(entries) {
  for (param in entries) {
    if (!is.null(param$Name) && tolower(param$Name) == "egfr") {
      return(Range$new(param$Min, param$Max, param$Unit))
    }
  }
  NULL
}
