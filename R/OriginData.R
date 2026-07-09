#' OriginData class for OSP snapshot individuals
#'
#' @description
#' An R6 class that represents the demographic starting point of an
#' [Individual]: species, population, gender, and the physiological
#' parameters (age, gestational age, weight, height) that PK-Sim uses when
#' creating the subject. The set of calculation methods used while deriving
#' the individual is exposed as a [CalculationMethods] object. Optional
#' disease state metadata is preserved as-is for round-trip fidelity.
#'
#' In an OSP snapshot, the JSON object is named `OriginData` and lives under
#' each entry of the `Individuals` array.
#'
#' @importFrom R6 R6Class
#'
#' @export
OriginData <- R6::R6Class(
  classname = "OriginData",
  public = list(
    #' @description
    #' Create a new OriginData object
    #' @param data Raw `OriginData` list from a snapshot. May be `NULL` or
    #'   an empty list, both of which create an empty OriginData.
    #' @return A new OriginData object
    initialize = function(data = list()) {
      if (is.null(data)) {
        data <- list()
      }
      private$.data <- data
      private$.calculation_methods <- CalculationMethods$new(
        data$CalculationMethods
      )
    },

    #' @description
    #' Print a summary of the origin data
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the OriginData object
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h2("OriginData")
        if (!is.null(self$species)) {
          cli::cli_li("Species: {self$species}")
        }
        if (!is.null(self$population)) {
          cli::cli_li("Population: {self$population}")
        }
        if (!is.null(self$gender)) {
          cli::cli_li("Gender: {self$gender}")
        }
        if (!is.null(self$age)) {
          cli::cli_li("Age: {self$age} {self$age_unit}")
        }
        if (!is.null(self$gestational_age)) {
          cli::cli_li(
            "Gestational age: {self$gestational_age} {self$gestational_age_unit}"
          )
        }
        if (!is.null(self$weight)) {
          cli::cli_li("Weight: {self$weight} {self$weight_unit}")
        }
        if (!is.null(self$height)) {
          cli::cli_li("Height: {self$height} {self$height_unit}")
        }
        if (private$.calculation_methods$length > 0) {
          cli::cli_li("Calculation methods:")
          indented <- cli::cli_ul()
          for (name in private$.calculation_methods$names) {
            cli::cli_li("{name}")
          }
          cli::cli_end(indented)
        }
        if (!is.null(self$disease_state)) {
          cli::cli_li("Disease state: {self$disease_state}")
        }
      })
      cat(output, sep = "\n")
      invisible(self)
    }
  ),
  active = list(
    #' @field data The raw `OriginData` list as it appears in the snapshot
    #'   JSON, refreshed from the embedded [CalculationMethods] object
    #'   (read-only).
    data = function(value) {
      if (!missing(value)) {
        cli::cli_abort("data is read-only")
      }
      result <- private$.data
      cm <- private$.calculation_methods$to_list()
      if (is.null(cm) && is.null(private$.data$CalculationMethods)) {
        result$CalculationMethods <- NULL
      } else {
        result$CalculationMethods <- cm
      }
      result
    },

    #' @field species The species of the individual.
    species = function(value) {
      if (missing(value)) {
        return(private$.data$Species)
      }
      validate_species(value)
      private$.data$Species <- value
    },

    #' @field population The population of the individual.
    population = function(value) {
      if (missing(value)) {
        return(private$.data$Population)
      }
      validate_population(value)
      private$.data$Population <- value
    },

    #' @field gender The gender of the individual.
    gender = function(value) {
      if (missing(value)) {
        return(private$.data$Gender)
      }
      validate_gender(value)
      private$.data$Gender <- value
    },

    #' @field age Numeric age value of the individual (in `age_unit`).
    #'   Writable: assign an [age()] object to set the value and unit
    #'   together. A bare numeric scalar is rejected; use [age()] instead.
    age = function(value) {
      if (missing(value)) {
        return(private$.data$Age$Value)
      }
      private$set_demographic("Age", value, "age_spec", "age")
    },

    #' @field age_unit Unit string for `age`.
    age_unit = function(value) {
      if (missing(value)) {
        return(private$.data$Age$Unit)
      }
      if (is.null(value) || (is.atomic(value) && is.na(value))) {
        private$.data$Age$Unit <- NULL
        return(invisible(NULL))
      }
      validate_unit(value, "Age in years")
      private$.data$Age$Unit <- value
    },

    #' @field gestational_age Numeric gestational age value (in
    #'   `gestational_age_unit`), used for preterm individuals. Writable:
    #'   assign a [gestational_age()] object to set the value and unit
    #'   together. A bare numeric scalar is rejected; use [gestational_age()]
    #'   instead.
    gestational_age = function(value) {
      if (missing(value)) {
        return(private$.data$GestationalAge$Value)
      }
      private$set_demographic(
        "GestationalAge",
        value,
        "gestational_age_spec",
        "gestational_age"
      )
    },

    #' @field gestational_age_unit Unit string for `gestational_age`.
    gestational_age_unit = function(value) {
      if (missing(value)) {
        return(private$.data$GestationalAge$Unit)
      }
      if (is.null(value) || (is.atomic(value) && is.na(value))) {
        private$.data$GestationalAge$Unit <- NULL
        return(invisible(NULL))
      }
      validate_unit(value, "Time")
      private$.data$GestationalAge$Unit <- value
    },

    #' @field weight Numeric weight value of the individual (in
    #'   `weight_unit`). Writable: assign a [weight()] object to set the
    #'   value and unit together. A bare numeric scalar is rejected; use
    #'   [weight()] instead.
    weight = function(value) {
      if (missing(value)) {
        return(private$.data$Weight$Value)
      }
      private$set_demographic("Weight", value, "weight_spec", "weight")
    },

    #' @field weight_unit Unit string for `weight`.
    weight_unit = function(value) {
      if (missing(value)) {
        return(private$.data$Weight$Unit)
      }
      if (is.null(value) || (is.atomic(value) && is.na(value))) {
        private$.data$Weight$Unit <- NULL
        return(invisible(NULL))
      }
      validate_unit(value, "Mass")
      private$.data$Weight$Unit <- value
    },

    #' @field height Numeric height value of the individual (in
    #'   `height_unit`). Writable: assign a [height()] object to set the
    #'   value and unit together. A bare numeric scalar is rejected; use
    #'   [height()] instead.
    height = function(value) {
      if (missing(value)) {
        return(private$.data$Height$Value)
      }
      private$set_demographic("Height", value, "height_spec", "height")
    },

    #' @field height_unit Unit string for `height`.
    height_unit = function(value) {
      if (missing(value)) {
        return(private$.data$Height$Unit)
      }
      if (is.null(value) || (is.atomic(value) && is.na(value))) {
        private$.data$Height$Unit <- NULL
        return(invisible(NULL))
      }
      validate_unit(value, "Length")
      private$.data$Height$Unit <- value
    },

    #' @field calculation_methods A [CalculationMethods] object holding the
    #'   calculation methods PK-Sim applies while creating the individual.
    calculation_methods = function(value) {
      if (missing(value)) {
        return(private$.calculation_methods)
      }
      if (inherits(value, "CalculationMethods")) {
        private$.calculation_methods <- value
      } else {
        private$.calculation_methods <- CalculationMethods$new(value)
      }
    },

    #' @field disease_state Optional disease-state name. Read from the modern
    #'   `Disease` object (`Disease$Name`) or, for a loaded legacy snapshot,
    #'   the legacy `DiseaseState` key. Writing sets the modern `Disease$Name`.
    disease_state = function(value) {
      if (missing(value)) {
        return(private$.data$Disease$Name %||% private$.data$DiseaseState)
      }
      private$.data$Disease$Name <- value
    },

    #' @field disease_state_parameters Optional list of disease-state
    #'   parameters. Read from the modern `Disease` object
    #'   (`Disease$Parameters`) or, for a loaded legacy snapshot, the legacy
    #'   `DiseaseStateParameters` key. Writing sets the modern
    #'   `Disease$Parameters`.
    disease_state_parameters = function(value) {
      if (missing(value)) {
        return(
          private$.data$Disease$Parameters %||%
            private$.data$DiseaseStateParameters
        )
      }
      private$.data$Disease$Parameters <- value
    }
  ),
  private = list(
    .data = NULL,
    .calculation_methods = NULL,

    # Shared setter for the four demographic value fields (`Age`,
    # `GestationalAge`, `Weight`, `Height`). Each field's writable binding
    # delegates here after handling its own getter path. `value` must be the
    # matching value-object helper (e.g. `age()`), which sets both `Value`
    # and `Unit`; a bare scalar or any other input aborts pointing at the
    # helper, mirroring the `create_individual()` factory.
    set_demographic = function(field, value, subclass, arg) {
      # Point the abort at the active-binding setter that delegated here, so
      # the error reads the same as when the guard lived inline in it.
      require_value_spec(value, subclass, arg, call = parent.frame())
      private$.data[[field]]$Value <- value$value
      private$.data[[field]]$Unit <- value$unit
      invisible(NULL)
    }
  )
)
