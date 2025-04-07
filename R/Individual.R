#' Individual class for OSP snapshot individuals
#'
#' @description
#' An R6 class that represents an individual in an OSP snapshot.
#' This class provides methods to access different properties of an individual
#' and display a summary of its information.
#'
#' @export
Individual <- R6::R6Class(
  classname = "Individual",
  public = list(
    #' @description
    #' Create a new Individual object
    #' @param data Raw individual data from a snapshot
    #' @return A new Individual object
    initialize = function(data) {
      private$.data <- data
      private$initialize_parameters()
    },

    #' @description
    #' Print a summary of the individual
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h1("Individual: {self$name}")

        # Display origin data if available
        if (!is.null(self$data$OriginData)) {
          cli::cli_h2("Origin Data")

          # Display seed if available
          if (!is.null(self$seed)) {
            cli::cli_li("Seed: {self$seed}")
          }

          # Display species and population if available
          if (!is.null(self$species)) {
            cli::cli_li("Species: {self$species}")
          }
          if (!is.null(self$population)) {
            cli::cli_li("Population: {self$population}")
          }

          # Display gender if available
          if (!is.null(self$gender)) {
            cli::cli_li("Gender: {self$gender}")
          }

          # Display age if available
          if (!is.null(self$age)) {
            cli::cli_li(
              "Age: {self$age} {self$age_unit}"
            )
          }

          # Display height and weight if available
          if (!is.null(self$height)) {
            cli::cli_li(
              "Height: {self$height} {self$height_unit}"
            )
          }
          if (!is.null(self$weight)) {
            cli::cli_li(
              "Weight: {self$weight} {self$weight_unit}"
            )
          }

          # Display disease state if available
          if (!is.null(self$disease_state)) {
            cli::cli_li(
              "Disease State: {self$disease_state}"
            )

            # Display disease state parameters if available
            if (!is.null(self$disease_state_parameters)) {
              for (param in self$disease_state_parameters) {
                cli::cli_li(
                  "  {param$Name}: {param$Value} {param$Unit}"
                )
              }
            }
          }
        }

        # Display parameters if available
        if (
          !is.null(private$.parameters) &&
            length(private$.parameters) > 0
        ) {
          cli::cli_h2("Parameters")
          for (param in private$.parameters) {
            unit_display <- if (is.null(param$unit)) "" else
              paste0(" ", param$unit)
            cli::cli_li("{param$path}: {param$value}{unit_display}")
          }
        }

        # Display expression profiles if available
        if (
          !is.null(self$expression_profiles) &&
            length(self$expression_profiles) > 0
        ) {
          cli::cli_h2("Expression Profiles")
          for (profile in self$expression_profiles) {
            cli::cli_li(profile)
          }
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL,
    initialize_parameters = function() {
      if (!is.null(private$.data$Parameters)) {
        # Create parameters list
        private$.parameters <- lapply(
          private$.data$Parameters,
          function(param_data) Parameter$new(param_data)
        )
        # Name the parameters by their paths for easier access
        names(private$.parameters) <- vapply(
          private$.parameters,
          function(p) p$path,
          character(1)
        )
        # Add collection class for custom printing
        class(private$.parameters) <- c("parameter_collection", "list")
      }
    }
  ),
  active = list(
    #' @field data The raw data of the individual (read-only)
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the individual
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field seed The simulation seed for the individual
    seed = function(value) {
      if (missing(value)) {
        return(private$.data$Seed)
      }
      private$.data$Seed <- value
    },

    #' @field species The species of the individual
    species = function(value) {
      if (missing(value)) {
        return(private$.data$OriginData$Species)
      }
      validate_species(value)
      private$.data$OriginData$Species <- value
    },

    #' @field population The population of the individual
    population = function(value) {
      if (missing(value)) {
        return(private$.data$OriginData$Population)
      }
      validate_population(value)
      private$.data$OriginData$Population <- value
    },

    #' @field gender The gender of the individual
    gender = function(value) {
      if (missing(value)) {
        return(private$.data$OriginData$Gender)
      }
      validate_gender(value)
      private$.data$OriginData$Gender <- value
    },

    #' @field age The age value of the individual
    age = function(value) {
      if (missing(value)) {
        if (is.null(private$.data$OriginData$Age)) {
          return(NULL)
        }
        return(private$.data$OriginData$Age$Value)
      }
      private$.data$OriginData$Age$Value <- value
      if (is.null(private$.data$OriginData$Age$Unit)) {
        private$.data$OriginData$Age$Unit <- "year(s)"
      }
    },

    #' @field age_unit The age unit of the individual
    age_unit = function(value) {
      if (missing(value)) {
        if (is.null(private$.data$OriginData$Age)) {
          return(NULL)
        }
        return(private$.data$OriginData$Age$Unit)
      }
      # Validate unit
      validate_unit(value, "Age in years")
      private$.data$OriginData$Age$Unit <- value
    },

    #' @field weight The weight value of the individual
    weight = function(value) {
      if (missing(value)) {
        if (is.null(private$.data$OriginData$Weight)) {
          return(NULL)
        }
        return(private$.data$OriginData$Weight$Value)
      }
      private$.data$OriginData$Weight$Value <- value
      if (is.null(private$.data$OriginData$Weight$Unit)) {
        private$.data$OriginData$Weight$Unit <- "kg"
      }
    },

    #' @field weight_unit The weight unit of the individual
    weight_unit = function(value) {
      if (missing(value)) {
        if (is.null(private$.data$OriginData$Weight)) {
          return(NULL)
        }
        return(private$.data$OriginData$Weight$Unit)
      }
      # Validate unit
      validate_unit(value, "Mass")
      private$.data$OriginData$Weight$Unit <- value
    },

    #' @field height The height value of the individual
    height = function(value) {
      if (missing(value)) {
        if (is.null(private$.data$OriginData$Height)) {
          return(NULL)
        }
        return(private$.data$OriginData$Height$Value)
      }
      private$.data$OriginData$Height$Value <- value
      if (is.null(private$.data$OriginData$Height$Unit)) {
        private$.data$OriginData$Height$Unit <- "cm"
      }
    },

    #' @field height_unit The height unit of the individual
    height_unit = function(value) {
      if (missing(value)) {
        if (is.null(private$.data$OriginData$Height)) {
          return(NULL)
        }
        return(private$.data$OriginData$Height$Unit)
      }
      # Validate unit
      validate_unit(value, "Length")
      private$.data$OriginData$Height$Unit <- value
    },

    #' @field disease_state The disease state of the individual
    disease_state = function(value) {
      if (missing(value)) {
        return(private$.data$OriginData$DiseaseState)
      }
      private$.data$OriginData$DiseaseState <- value
    },

    #' @field disease_state_parameters The disease state parameters of the individual
    disease_state_parameters = function(value) {
      if (missing(value)) {
        return(private$.data$OriginData$DiseaseStateParameters)
      }
      private$.data$OriginData$DiseaseStateParameters <- value
    },

    #' @field parameters The list of parameter objects with a custom print method
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
    },

    #' @field expression_profiles The expression profiles of the individual (read-only)
    expression_profiles = function() {
      private$.data$ExpressionProfiles
    }
  )
)

#' Create a new individual
#'
#' @description
#' Create a new individual with the specified properties.
#' All arguments are optional and will use default values if not provided.
#'
#' @param name Character. Name of the individual
#' @param species Character. Species of the individual (must be valid ospsuite Species)
#' @param population Character. Population of the individual (must be valid ospsuite HumanPopulation)
#' @param gender Character. Gender of the individual (must be valid ospsuite Gender)
#' @param age Numeric. Age of the individual
#' @param age_unit Character. Unit for age (must be valid unit for "Age in years")
#' @param weight Numeric. Weight of the individual
#' @param weight_unit Character. Unit for weight (must be valid unit for "Mass")
#' @param height Numeric. Height of the individual
#' @param height_unit Character. Unit for height (must be valid unit for "Length")
#' @param disease_state Character. Disease state of the individual (optional)
#' @param disease_state_parameters List. Parameters for disease state (optional)
#' @param seed Integer. Simulation seed (optional)
#'
#' @return An Individual object
#' @export
#'
#' @examples
#' # Create a minimal individual
#' individual <- create_individual(name = "Test Individual")
#'
#' # Create a complete individual
#' individual <- create_individual(
#'   name = "John Doe",
#'   species = "Human",
#'   population = "European_ICRP_2002",
#'   gender = "MALE",
#'   age = 30,
#'   weight = 70,
#'   height = 175
#' )
#'
#' # Create an individual with disease state
#' individual <- create_individual(
#'   name = "Patient",
#'   disease_state = "CKD",
#'   disease_state_parameters = list(
#'     list(Name = "eGFR", Value = 45.0, Unit = "ml/min/1.73m²")
#'   )
#' )
create_individual <- function(
  name = "New Individual",
  species = NULL,
  population = NULL,
  gender = NULL,
  age = NULL,
  age_unit = "year(s)",
  weight = NULL,
  weight_unit = "kg",
  height = NULL,
  height_unit = "cm",
  disease_state = NULL,
  disease_state_parameters = NULL,
  seed = NULL
) {
  # Validate inputs if provided
  if (!is.null(species)) validate_species(species)
  if (!is.null(population)) validate_population(population)
  if (!is.null(gender)) validate_gender(gender)
  if (!is.null(age_unit)) validate_unit(age_unit, "Age in years")
  if (!is.null(weight_unit)) validate_unit(weight_unit, "Mass")
  if (!is.null(height_unit)) validate_unit(height_unit, "Length")

  # Create origin data structure
  origin_data <- list()

  # Add basic demographic information
  if (!is.null(species)) origin_data$Species <- species
  if (!is.null(population)) origin_data$Population <- population
  if (!is.null(gender)) origin_data$Gender <- gender

  # Add measurements with units
  if (!is.null(age)) {
    origin_data$Age <- list(Value = age, Unit = age_unit)
  }
  if (!is.null(weight)) {
    origin_data$Weight <- list(Value = weight, Unit = weight_unit)
  }
  if (!is.null(height)) {
    origin_data$Height <- list(Value = height, Unit = height_unit)
  }

  # Add disease state information if provided
  if (!is.null(disease_state)) {
    origin_data$DiseaseState <- disease_state
    if (!is.null(disease_state_parameters)) {
      origin_data$DiseaseStateParameters <- disease_state_parameters
    }
  }

  # Create the data structure
  data <- list(
    Name = name,
    OriginData = origin_data
  )

  # Add seed if provided
  if (!is.null(seed)) {
    data$Seed <- seed
  }

  # Create and return the Individual object
  Individual$new(data)
}
