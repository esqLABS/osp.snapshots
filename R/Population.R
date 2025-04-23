#' Population class for OSP snapshot populations
#'
#' @description
#' An R6 class that represents a population in an OSP snapshot.
#' This class provides methods to access different properties of a population
#' and display a summary of its information.
#'
#' @importFrom tibble tibble as_tibble
#' @importFrom glue glue
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

      # If the population has an individual template, initialize it
      if (!is.null(data$Settings$Individual)) {
        private$.template_individual <- Individual$new(
          data$Settings$Individual
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
    },

    #' @description
    #' Print a summary of the population including its properties and settings.
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the Population object for method chaining
    print = function(...) {
      # Header with name and seed (if available)
      seed_text <- if (!is.null(self$seed))
        glue::glue(" (Seed: {self$seed})") else ""
      cli::cli_h2("Population: {self$name}{seed_text}")

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

      # Advanced parameters
      if (length(private$.advanced_parameters) > 0) {
        cli::cli_h3("Advanced Parameters")
        cli::cli_text(
          "{length(private$.advanced_parameters)} advanced parameters defined"
        )
      }

      invisible(self)
    },

    #' @description
    #' Convert the population to a list of data frames for easier analysis
    #'
    #' @return A list containing data frames with population information:
    #' \itemize{
    #'   \item characteristics: Population characteristics including basic information and physiological parameters
    #'   \item advanced_parameters: Advanced parameters information
    #' }
    to_df = function() {
      # Create characteristics data frame with all columns
      characteristics_df <- tibble::tibble(
        population_id = self$name,
        name = self$name,
        seed = self$seed,
        number_of_individuals = self$number_of_individuals,
        proportion_of_females = self$proportion_of_females,
        source_population = NA_character_,
        age_min = NA_real_,
        age_max = NA_real_,
        age_unit = NA_character_,
        weight_min = NA_real_,
        weight_max = NA_real_,
        weight_unit = NA_character_,
        height_min = NA_real_,
        height_max = NA_real_,
        height_unit = NA_character_,
        bmi_min = NA_real_,
        bmi_max = NA_real_,
        bmi_unit = NA_character_
      )

      # Add source population if available
      if (!is.null(self$source_population)) {
        characteristics_df$source_population <- self$source_population
      }

      # Add age range
      if (!is.null(self$age_range)) {
        characteristics_df$age_min <- self$age_range$min
        characteristics_df$age_max <- self$age_range$max
        characteristics_df$age_unit <- self$age_range$unit
      }

      # Add weight range if available
      if (!is.null(self$weight_range)) {
        characteristics_df$weight_min <- self$weight_range$min
        characteristics_df$weight_max <- self$weight_range$max
        characteristics_df$weight_unit <- self$weight_range$unit
      }

      # Add height range if available
      if (!is.null(self$height_range)) {
        characteristics_df$height_min <- self$height_range$min
        characteristics_df$height_max <- self$height_range$max
        characteristics_df$height_unit <- self$height_range$unit
      }

      # Add BMI range if available
      if (!is.null(self$bmi_range)) {
        characteristics_df$bmi_min <- self$bmi_range$min
        characteristics_df$bmi_max <- self$bmi_range$max
        characteristics_df$bmi_unit <- self$bmi_range$unit
      }

      # Create advanced parameters data frame
      adv_params_df <- tibble::tibble(
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

              adv_params_df <- dplyr::bind_rows(
                adv_params_df,
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
            adv_params_df <- dplyr::bind_rows(
              adv_params_df,
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
        advanced_parameters = adv_params_df
      ))
    }
  ),

  active = list(
    #' @field data The raw data of the population (read-only)
    data = function() {
      private$.data
    },

    #' @field name The name of the population
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field source_population The source population name (read-only)
    source_population = function() {
      return(private$.data$Settings$Individual$OriginData$Population)
    },

    #' @field seed The seed used for population generation
    seed = function(value) {
      if (missing(value)) {
        return(private$.data$Seed)
      }
      private$.data$Seed <- value
    },

    #' @field number_of_individuals The number of individuals in the population
    number_of_individuals = function(value) {
      if (missing(value)) {
        return(private$.data$Settings$NumberOfIndividuals)
      }
      if (!is.numeric(value) || value < 1) {
        cli::cli_abort(
          "Number of individuals must be a positive number"
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

    #' @field age_range The age range for the population
    age_range = function(value) {
      if (missing(value)) {
        return(private$.age_range)
      }
      if (is.null(value)) {
        private$.age_range <- NULL
        private$.data$Settings$Age <- NULL
        return(invisible(NULL))
      }
      if (!inherits(value, "Range")) {
        cli::cli_abort("age_range must be a Range object")
      }
      private$.age_range <- value
      private$.data$Settings$Age <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field weight_range The weight range for the population
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
        cli::cli_abort("weight_range must be a Range object")
      }
      private$.weight_range <- value
      private$.data$Settings$Weight <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field height_range The height range for the population
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
        cli::cli_abort("height_range must be a Range object")
      }
      private$.height_range <- value
      private$.data$Settings$Height <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field bmi_range The BMI range for the population
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
        cli::cli_abort("bmi_range must be a Range object")
      }
      private$.bmi_range <- value
      private$.data$Settings$BMI <- list(
        Min = value$min,
        Max = value$max,
        Unit = value$unit
      )
    },

    #' @field disease_state_parameters Disease state parameters for the population (if available)
    disease_state_parameters = function(value) {
      if (missing(value)) {
        return(private$.data$Settings$DiseaseStateParameters)
      }
      private$.data$Settings$DiseaseStateParameters <- value
    },

    #' @field template_individual The template individual used for the population
    template_individual = function() {
      private$.template_individual
    },

    #' @field advanced_parameters Advanced parameters for the population
    advanced_parameters = function() {
      private$.advanced_parameters
    }
  ),

  private = list(
    .data = NULL,
    .template_individual = NULL,
    .advanced_parameters = list(),
    .age_range = NULL,
    .weight_range = NULL,
    .height_range = NULL,
    .bmi_range = NULL
  )
)

#' Range class for physiological parameters
#'
#' @description
#' An R6 class that represents a range of values with a minimum, maximum and unit.
#' Used for age, weight, height, and BMI ranges in populations.
#' Either min or max can be NULL to represent ranges with only an upper or lower bound.
#'
#' @export
Range <- R6::R6Class(
  classname = "Range",
  public = list(
    #' @description
    #' Create a new Range object
    #' @param min Numeric or NULL. Minimum value, can be NULL for ranges with only an upper bound
    #' @param max Numeric or NULL. Maximum value, can be NULL for ranges with only a lower bound
    #' @param unit Character. Unit for the range
    #' @return A new Range object
    initialize = function(min, max, unit) {
      # Validate that at least one of min or max is not NULL
      if (is.null(min) && is.null(max)) {
        cli::cli_abort("At least one of min or max must be specified")
      }

      # When both are present, validate that min < max
      if (!is.null(min) && !is.null(max)) {
        if (!is.numeric(min) || !is.numeric(max) || min >= max) {
          cli::cli_abort("Min must be less than max")
        }
      } else {
        # When only one is present, validate that it's numeric
        if (!is.null(min) && !is.numeric(min)) {
          cli::cli_abort("Min must be a numeric value")
        }
        if (!is.null(max) && !is.numeric(max)) {
          cli::cli_abort("Max must be a numeric value")
        }
      }

      private$.min <- min
      private$.max <- max
      private$.unit <- unit
    },

    #' @description
    #' Print a summary of the range
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the Range object for method chaining
    print = function(...) {
      min_text <- if (is.null(private$.min)) "-∞" else private$.min
      max_text <- if (is.null(private$.max)) "∞" else private$.max

      cli::cli_text("{min_text} - {max_text} {private$.unit}")
      invisible(self)
    }
  ),

  active = list(
    #' @field min The minimum value of the range
    min = function(value) {
      if (missing(value)) {
        return(private$.min)
      }

      # Allow setting to NULL
      if (is.null(value)) {
        # Ensure max is not NULL when setting min to NULL
        if (is.null(private$.max)) {
          cli::cli_abort("Cannot set min to NULL when max is also NULL")
        }
        private$.min <- NULL
        return(invisible(NULL))
      }

      # Validate numeric
      if (!is.numeric(value)) {
        cli::cli_abort("Min must be a numeric value")
      }

      # Validate min < max if max is not NULL
      if (!is.null(private$.max) && value >= private$.max) {
        cli::cli_abort("Min must be less than max")
      }

      private$.min <- value
    },

    #' @field max The maximum value of the range
    max = function(value) {
      if (missing(value)) {
        return(private$.max)
      }

      # Allow setting to NULL
      if (is.null(value)) {
        # Ensure min is not NULL when setting max to NULL
        if (is.null(private$.min)) {
          cli::cli_abort("Cannot set max to NULL when min is also NULL")
        }
        private$.max <- NULL
        return(invisible(NULL))
      }

      # Validate numeric
      if (!is.numeric(value)) {
        cli::cli_abort("Max must be a numeric value")
      }

      # Validate min < max if min is not NULL
      if (!is.null(private$.min) && value <= private$.min) {
        cli::cli_abort("Max must be greater than min")
      }

      private$.max <- value
    },

    #' @field unit The unit of the range
    unit = function(value) {
      if (missing(value)) {
        return(private$.unit)
      }
      private$.unit <- value
    }
  ),

  private = list(
    .min = NULL,
    .max = NULL,
    .unit = NULL
  )
)

#' Create a range object for physiological parameters
#'
#' @description
#' Create a new Range object with the specified min, max, and unit values.
#' Either min or max can be NULL to represent ranges with only an upper or lower bound.
#'
#' @param min Numeric or NULL. Minimum value, can be NULL for ranges with only an upper bound
#' @param max Numeric or NULL. Maximum value, can be NULL for ranges with only a lower bound
#' @param unit Character. Unit for the range
#'
#' @return A Range object
#' @export
#'
#' @examples
#' \dontrun{
#' # Create a weight range with both bounds
#' weight_range <- range(60, 90, "kg")
#'
#' # Create a weight range with only a lower bound
#' weight_min_range <- range(60, NULL, "kg")
#'
#' # Create a weight range with only an upper bound
#' weight_max_range <- range(NULL, 90, "kg")
#'
#' # Assign to a population
#' population$weight_range <- weight_range
#' }
range <- function(min, max, unit) {
  Range$new(min, max, unit)
}

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

    #' @field distribution_type The distribution type of the parameter
    distribution_type = function(value) {
      if (missing(value)) {
        return(private$.data$DistributionType)
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

#' Create a new population
#'
#' @description
#' Create a new population with the specified properties.
#' Most arguments are optional and will use default values if not provided.
#' Note that this function doesn't support creating advanced parameters or
#' defining template individuals manually. Template individuals are loaded
#' directly from snapshot files.
#'
#' @param name Character. Name of the population
#' @param number_of_individuals Numeric. Number of individuals in the population
#' @param proportion_of_females Numeric. Percentage of females in the population (0-100)
#' @param age_min Numeric. Minimum age for the population
#' @param age_max Numeric. Maximum age for the population
#' @param age_unit Character. Unit for age (must be valid unit for "Age in years")
#' @param weight_min Numeric. Minimum weight for the population (optional)
#' @param weight_max Numeric. Maximum weight for the population (optional)
#' @param weight_unit Character. Unit for weight (must be valid unit for "Mass")
#' @param height_min Numeric. Minimum height for the population (optional)
#' @param height_max Numeric. Maximum height for the population (optional)
#' @param height_unit Character. Unit for height (must be valid unit for "Length")
#' @param seed Integer. Simulation seed (optional)
#'
#' @return A Population object
#' @export
#'
#' @examples
#' \dontrun{
#' # Create a minimal population
#' population <- create_population(
#'   name = "Test Population",
#'   number_of_individuals = 100,
#'   proportion_of_females = 50,
#'   age_min = 18,
#'   age_max = 65
#' )
#'
#' # Create a more detailed population
#' population <- create_population(
#'   name = "Detailed Population",
#'   number_of_individuals = 50,
#'   proportion_of_females = 60,
#'   age_min = 30,
#'   age_max = 60,
#'   age_unit = "year(s)",
#'   weight_min = 60,
#'   weight_max = 90,
#'   weight_unit = "kg",
#'   height_min = 160,
#'   height_max = 180,
#'   height_unit = "cm"
#' )
#' }
create_population <- function(
  name,
  number_of_individuals = 100,
  proportion_of_females = 50,
  age_min = 18,
  age_max = 65,
  age_unit = "year(s)",
  weight_min = NULL,
  weight_max = NULL,
  weight_unit = "kg",
  height_min = NULL,
  height_max = NULL,
  height_unit = "cm",
  seed = NULL
) {
  # Validate inputs
  if (!is.numeric(number_of_individuals) || number_of_individuals < 1) {
    cli::cli_abort("Number of individuals must be a positive number")
  }

  if (
    !is.numeric(proportion_of_females) ||
      proportion_of_females < 0 ||
      proportion_of_females > 100
  ) {
    cli::cli_abort(
      "Proportion of females must be a number between 0 and 100"
    )
  }

  if (!is.numeric(age_min) || !is.numeric(age_max) || age_min >= age_max) {
    cli::cli_abort("Age min must be less than age max")
  }

  # Validate units
  validate_unit(age_unit, "Age in years")

  # Create settings object
  settings <- list(
    NumberOfIndividuals = number_of_individuals,
    ProportionOfFemales = proportion_of_females,
    Age = list(
      Min = age_min,
      Max = age_max,
      Unit = age_unit
    )
  )

  # Add weight if provided
  if (!is.null(weight_min) && !is.null(weight_max)) {
    if (
      !is.numeric(weight_min) ||
        !is.numeric(weight_max) ||
        weight_min >= weight_max
    ) {
      cli::cli_abort("Weight min must be less than weight max")
    }
    validate_unit(weight_unit, "Mass")
    settings$Weight <- list(
      Min = weight_min,
      Max = weight_max,
      Unit = weight_unit
    )
  }

  # Add height if provided
  if (!is.null(height_min) && !is.null(height_max)) {
    if (
      !is.numeric(height_min) ||
        !is.numeric(height_max) ||
        height_min >= height_max
    ) {
      cli::cli_abort("Height min must be less than height max")
    }
    validate_unit(height_unit, "Length")
    settings$Height <- list(
      Min = height_min,
      Max = height_max,
      Unit = height_unit
    )
  }

  # Create population data
  population_data <- list(
    Name = name,
    Seed = seed,
    Settings = settings,
    AdvancedParameters = list()
  )

  # Create and return population object
  Population$new(population_data)
}

#' Load populations from snapshot data
#'
#' @description
#' Load populations from a list of population data from a snapshot
#'
#' @param population_list List of population data from a snapshot
#' @return A named list of Population objects
#' @export
load_populations <- function(population_list) {
  # Check if input is NULL or empty
  if (is.null(population_list) || length(population_list) == 0) {
    empty_result <- list()
    # Add class for consistent behavior
    class(empty_result) <- "population_collection"
    return(empty_result)
  }

  # Create population objects
  populations <- lapply(population_list, function(data) {
    Population$new(data)
  })

  # Name the list elements by population name
  names(populations) <- sapply(populations, function(p) p$name)

  # Add class for custom printing
  class(populations) <- "population_collection"

  return(populations)
}
