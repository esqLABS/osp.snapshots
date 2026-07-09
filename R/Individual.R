#' Individual class for OSP snapshot individuals
#'
#' @description
#' An R6 class that represents an individual in an OSP snapshot.
#' This class provides methods to access different properties of an individual
#' and display a summary of its information.
#'
#' @importFrom tibble tibble as_tibble
#' @importFrom glue glue
#' @importFrom R6 R6Class
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
      private$.origin_data <- OriginData$new(data$OriginData)
      private$initialize_parameters()
    },

    #' @description
    #' Print a summary of the individual including its properties and parameters.
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the Individual object for method chaining
    print = function(...) {
      output <- cli::cli_format_method({
        if (is.null(self$seed)) {
          cli::cli_h1("Individual: {self$name}")
        } else {
          cli::cli_h1("Individual: {self$name} | Seed: {self$seed}")
        }

        # Display characteristics if available
        if (!is.null(self$data$OriginData)) {
          cli::cli_h2("Characteristics")

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

          # Display gestational age if available
          if (!is.null(self$gestational_age)) {
            cli::cli_li(
              "Gestational Age: {self$gestational_age} {self$gestational_age_unit}"
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

          # Display calculation methods if available
          if (
            !is.null(self$calculation_methods) &&
              length(self$calculation_methods) > 0
          ) {
            cli::cli_li("Calculation Methods:")
            indented_list <- cli::cli_ul()
            for (method in self$calculation_methods) {
              cli::cli_li("{method}")
            }
            cli::cli_end(indented_list)
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
            unit_display <- if (is.null(param$unit)) {
              ""
            } else {
              glue::glue(" {param$unit}")
            }
            cli::cli_li("{param$name}: {param$value}{unit_display}")
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
    },

    #' @description
    #' Convert individual data to tibbles
    #' @param type Character. Type of data to convert: "all" (default), "individuals", "individuals_parameters", or "individuals_expressions"
    #' @return A list of tibbles containing the requested data
    to_df = function(type = "all") {
      # Validate type argument
      valid_types <- c(
        "all",
        "individuals",
        "individuals_parameters",
        "individuals_expressions"
      )
      if (!type %in% valid_types) {
        cli::cli_abort(
          "type must be one of: {valid_types}"
        )
      }

      # Get the individual name to use as ID
      individual_id <- self$name

      # Initialize result list
      result <- list()

      # Add individuals data if requested
      if (type %in% c("all", "individuals")) {
        # Create a list to store the data
        data_list <- list(
          individual_id = individual_id,
          name = self$name,
          description = self$description %||% NA_character_,
          seed = self$seed %||% NA_integer_,
          species = self$species %||% NA_character_,
          population = self$population %||% NA_character_,
          gender = self$gender %||% NA_character_,
          age = self$age %||% NA_real_,
          age_unit = self$age_unit %||% NA_character_,
          gestational_age = self$gestational_age %||% NA_real_,
          gestational_age_unit = self$gestational_age_unit %||% NA_character_,
          weight = self$weight %||% NA_real_,
          weight_unit = self$weight_unit %||% NA_character_,
          height = self$height %||% NA_real_,
          height_unit = self$height_unit %||% NA_character_,
          disease_state = self$disease_state %||% NA_character_
        )

        # Convert calculation methods to a single string if present
        if (!is.null(self$calculation_methods)) {
          data_list$calculation_methods <- glue::glue_collapse(
            self$calculation_methods,
            sep = "; "
          )
        } else {
          data_list$calculation_methods <- NA_character_
        }

        # Convert disease state parameters to a single string if present
        if (!is.null(self$disease_state_parameters)) {
          data_list$disease_state_parameters <- glue::glue_collapse(
            vapply(
              self$disease_state_parameters,
              function(param) {
                sprintf(
                  "%s: %g %s",
                  param$Name,
                  param$Value,
                  param$Unit %||% ""
                )
              },
              character(1)
            ),
            sep = "; "
          )
        } else {
          data_list$disease_state_parameters <- NA_character_
        }

        result$individuals <- tibble::as_tibble(data_list)
      }

      # Add individuals_parameters data if requested
      if (type %in% c("all", "individuals_parameters")) {
        if (length(self$parameters) == 0) {
          result$individuals_parameters <- tibble::tibble(
            individual_id = character(0),
            path = character(0),
            value = numeric(0),
            unit = character(0),
            source = character(0),
            description = character(0),
            source_id = integer(0)
          )
        } else {
          # Extract parameter data using Parameter's to_df method
          param_data <- lapply(self$parameters, function(param) {
            df <- param$to_df()
            df <- dplyr::mutate(df, individual_id = individual_id)
            df <- dplyr::relocate(df, individual_id)
            return(df)
          })
          result$individuals_parameters <- dplyr::bind_rows(param_data)
        }
      }

      # Add individuals_expressions data if requested
      if (type %in% c("all", "individuals_expressions")) {
        if (
          is.null(self$expression_profiles) ||
            length(self$expression_profiles) == 0
        ) {
          result$individuals_expressions <- tibble::tibble(
            individual_id = character(0),
            profile = character(0)
          )
        } else {
          result$individuals_expressions <- tibble::tibble(
            individual_id = individual_id,
            profile = as.character(unlist(self$expression_profiles))
          )
        }
      }

      # If only one type requested, return just that tibble
      if (type != "all") {
        return(result[[type]])
      }

      result
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL,
    .origin_data = NULL,
    deep_clone = function(name, value) {
      if (name == ".origin_data" && inherits(value, "R6")) {
        return(value$clone(deep = TRUE))
      }
      value
    },
    initialize_parameters = function() {
      # Individual parameters are LocalizedParameter[] per the snapshot spec;
      # routing through the shared helper preserves the lazy-init shape while
      # forcing path validation and the v11+ Applications-to-Events migration
      # at construction.
      private$.parameters <- build_parameters_from_raw(
        private$.data$Parameters,
        key_by = "path",
        ctor = function(data) LocalizedParameter$new(data)
      )
    }
  ),
  active = list(
    #' @field data The raw data of the individual (read-only)
    data = function(value) {
      if (missing(value)) {
        result <- private$.data
        # Refresh OriginData from the embedded OriginData object so that any
        # mutation flows back to the export payload. When OriginData was
        # originally absent, keep it absent unless something was added.
        origin_payload <- private$.origin_data$data
        if (length(origin_payload) == 0 && is.null(private$.data$OriginData)) {
          result$OriginData <- NULL
        } else {
          result$OriginData <- origin_payload
        }
        return(result)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the individual. Writable: must be a
    #'   non-empty scalar string.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      check_required_string(value, "name")
      private$.data$Name <- value
    },

    #' @field seed The simulation seed for the individual
    seed = function(value) {
      if (missing(value)) {
        return(private$.data$Seed)
      }
      private$.data$Seed <- value
    },

    #' @field origin_data The [OriginData] object holding species, population,
    #'   gender, physiological parameters, and calculation methods.
    origin_data = function(value) {
      if (missing(value)) {
        return(private$.origin_data)
      }
      if (!inherits(value, "OriginData")) {
        cli::cli_abort("origin_data must be an OriginData object")
      }
      private$.origin_data <- value
    },

    #' @field species The species of the individual
    species = function(value) {
      if (missing(value)) {
        return(private$.origin_data$species)
      }
      private$.origin_data$species <- value
    },

    #' @field population The population of the individual
    population = function(value) {
      if (missing(value)) {
        return(private$.origin_data$population)
      }
      private$.origin_data$population <- value
    },

    #' @field gender The gender of the individual
    gender = function(value) {
      if (missing(value)) {
        return(private$.origin_data$gender)
      }
      private$.origin_data$gender <- value
    },

    #' @field age The age value of the individual. Writable: assign an
    #'   [age()] object; see [OriginData]'s `age` field for the full
    #'   contract (a bare numeric scalar is rejected).
    age = function(value) {
      if (missing(value)) {
        return(private$.origin_data$age)
      }
      private$.origin_data$age <- value
    },

    #' @field age_unit The age unit of the individual
    age_unit = function(value) {
      if (missing(value)) {
        return(private$.origin_data$age_unit)
      }
      private$.origin_data$age_unit <- value
    },

    #' @field weight The weight value of the individual. Writable: assign a
    #'   [weight()] object; see [OriginData]'s `weight` field for the full
    #'   contract (a bare numeric scalar is rejected).
    weight = function(value) {
      if (missing(value)) {
        return(private$.origin_data$weight)
      }
      private$.origin_data$weight <- value
    },

    #' @field weight_unit The weight unit of the individual
    weight_unit = function(value) {
      if (missing(value)) {
        return(private$.origin_data$weight_unit)
      }
      private$.origin_data$weight_unit <- value
    },

    #' @field height The height value of the individual. Writable: assign a
    #'   [height()] object; see [OriginData]'s `height` field for the full
    #'   contract (a bare numeric scalar is rejected).
    height = function(value) {
      if (missing(value)) {
        return(private$.origin_data$height)
      }
      private$.origin_data$height <- value
    },

    #' @field height_unit The height unit of the individual
    height_unit = function(value) {
      if (missing(value)) {
        return(private$.origin_data$height_unit)
      }
      private$.origin_data$height_unit <- value
    },

    #' @field gestational_age The gestational age value of the individual.
    #'   Writable: assign a [gestational_age()] object; see [OriginData]'s
    #'   `gestational_age` field for the full contract (a bare numeric
    #'   scalar is rejected).
    gestational_age = function(value) {
      if (missing(value)) {
        return(private$.origin_data$gestational_age)
      }
      private$.origin_data$gestational_age <- value
    },

    #' @field gestational_age_unit The gestational age unit of the individual
    gestational_age_unit = function(value) {
      if (missing(value)) {
        return(private$.origin_data$gestational_age_unit)
      }
      private$.origin_data$gestational_age_unit <- value
    },

    #' @field disease_state The disease state of the individual
    disease_state = function(value) {
      if (missing(value)) {
        return(private$.origin_data$disease_state)
      }
      private$.origin_data$disease_state <- value
    },

    #' @field disease_state_parameters The disease state parameters of the individual
    disease_state_parameters = function(value) {
      if (missing(value)) {
        return(private$.origin_data$disease_state_parameters)
      }
      private$.origin_data$disease_state_parameters <- value
    },

    #' @field parameters The list of parameter objects with a custom print
    #'   method. Writable: must be a list, or `NULL` to clear.
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

    #' @field calculation_methods The calculation methods of the individual,
    #'   returned as a character vector for backwards compatibility. Use
    #'   `$origin_data$calculation_methods` to access the
    #'   [CalculationMethods] object directly.
    calculation_methods = function(value) {
      if (missing(value)) {
        names <- private$.origin_data$calculation_methods$names
        if (length(names) == 0) {
          return(NULL)
        }
        return(names)
      }
      private$.origin_data$calculation_methods <- value
    },

    #' @field expression_profiles Read/write. The expression profiles attached
    #'   to the individual, as a character vector of composite names
    #'   (`Molecule|Species|Category`) or `NULL` when none are attached.
    #'   Assigning a character vector replaces the attached profiles; assigning
    #'   `NULL` or `character(0)` removes them (no empty array is serialized).
    expression_profiles = function(value) {
      if (missing(value)) {
        return(private$.data$ExpressionProfiles)
      }
      if (is.null(value) || (is.character(value) && length(value) == 0)) {
        private$.data$ExpressionProfiles <- NULL
        return(invisible(private$.data$ExpressionProfiles))
      }
      if (!is.character(value)) {
        cli::cli_abort(
          "{.field expression_profiles} must be a character vector of \\
          expression-profile names, not {.obj_type_friendly {value}}."
        )
      }
      private$.data$ExpressionProfiles <- value
    },

    #' @field description Read/write. Free-text description of the individual,
    #'   or `NULL` when none is set. Assigning a length-1 character sets it;
    #'   assigning `NULL` removes it.
    description = function(value) {
      if (missing(value)) {
        return(private$.data$Description)
      }
      if (is.null(value)) {
        private$.data$Description <- NULL
        return(invisible(private$.data$Description))
      }
      if (!is.character(value) || length(value) != 1) {
        cli::cli_abort(
          "{.field description} must be a single character string, not \\
          {.obj_type_friendly {value}}."
        )
      }
      private$.data$Description <- value
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
#' @param age An [age()] object, or `NULL`.
#' @param weight A [weight()] object, or `NULL`.
#' @param height A [height()] object, or `NULL`.
#' @param gestational_age A [gestational_age()] object, or `NULL` (for
#'   infant/preterm individuals).
#' @param calculation_methods Character vector. Calculation methods used for the individual
#' @param disease_state Character. Disease-state name of the individual
#'   (optional). Together with `disease_state_parameters` it feeds the modern
#'   `Disease` object (`{ Name, Parameters }`) emitted under
#'   `OriginData$Disease`, matching [create_expression_profile()].
#' @param disease_state_parameters List. Parameters for the disease state
#'   (optional), keyed on `Name` in the emitted `Disease` object.
#' @param seed Integer. Simulation seed (optional)
#' @param expression_profiles Character vector of expression-profile composite
#'   names (`Molecule|Species|Category`) to attach to the individual. Default
#'   `NULL` (no profiles).
#' @param description Character. Free-text description of the individual.
#'   Default `NULL` (no description).
#' @param parameters List of localized parameters (each created with
#'   `create_parameter(path = ...)`), or the equivalent raw list form the
#'   loader consumes, applied as the individual's `Parameters` overrides. Each
#'   entry must be path-bearing. Default `NULL` (no parameter overrides).
#'
#' @return An Individual object
#' @seealso [age()], [weight()], [height()], [gestational_age()] for the
#'   demographic value-object helpers.
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
#'   age = age(30),
#'   weight = weight(70),
#'   height = height(175)
#' )
#'
#' # Create an individual with calculation methods
#' individual <- create_individual(
#'   name = "Test Individual",
#'   calculation_methods = c("Method 1", "Method 2", "Method 3")
#' )
#'
#' # Create an individual with disease state (emitted as the modern
#' # `Disease` object: `OriginData$Disease = { Name, Parameters }`)
#' individual <- create_individual(
#'   name = "Patient",
#'   disease_state = "CKD",
#'   disease_state_parameters = list(
#'     list(Name = "eGFR", Value = 45.0, Unit = "ml/min/1.73m²")
#'   )
#' )
#'
#' # Create an individual referencing expression profiles with a localized
#' # parameter and a description
#' individual <- create_individual(
#'   name = "Subject 1",
#'   expression_profiles = c("CYP3A4|Human|Healthy", "P-gp|Human|Healthy"),
#'   description = "Reference healthy adult",
#'   parameters = list(
#'     create_parameter(
#'       path = "Organism|Liver|EHC continuous fraction",
#'       value = 1
#'     )
#'   )
#' )
create_individual <- function(
  name = "New Individual",
  species = NULL,
  population = NULL,
  gender = NULL,
  age = NULL,
  weight = NULL,
  height = NULL,
  gestational_age = NULL,
  calculation_methods = NULL,
  disease_state = NULL,
  disease_state_parameters = NULL,
  seed = NULL,
  expression_profiles = NULL,
  description = NULL,
  parameters = NULL
) {
  # Validate inputs if provided
  if (!is.null(species)) {
    validate_species(species)
  }
  if (!is.null(population)) {
    validate_population(population)
  }
  if (!is.null(gender)) {
    validate_gender(gender)
  }
  # Each demographic field must be built with its helper (value, unit, and
  # unit validation live in the helper). A bare scalar aborts with guidance.
  require_value_spec(age, "age_spec", "age", example = "age = age(30)")
  require_value_spec(
    weight,
    "weight_spec",
    "weight",
    example = "weight = weight(70)"
  )
  require_value_spec(
    height,
    "height_spec",
    "height",
    example = "height = height(175)"
  )
  require_value_spec(
    gestational_age,
    "gestational_age_spec",
    "gestational_age",
    example = "gestational_age = gestational_age(38)"
  )

  # Validate the expression profiles, description, and parameters up front so
  # a bad argument aborts before any object is constructed (no half-built
  # individual).
  if (!is.null(expression_profiles) && !is.character(expression_profiles)) {
    cli::cli_abort(
      "{.arg expression_profiles} must be a character vector of \\
      expression-profile names, not {.obj_type_friendly {expression_profiles}}."
    )
  }
  if (
    !is.null(description) &&
      (!is.character(description) || length(description) != 1)
  ) {
    cli::cli_abort(
      "{.arg description} must be a single character string, not \\
      {.obj_type_friendly {description}}."
    )
  }
  raw_parameters <- normalize_individual_parameters(parameters)

  # Create characteristics data structure
  characteristics_data <- list()

  # Add basic demographic information
  if (!is.null(species)) {
    characteristics_data$Species <- species
  }
  if (!is.null(population)) {
    characteristics_data$Population <- population
  }
  if (!is.null(gender)) {
    characteristics_data$Gender <- gender
  }

  # Add measurements with units
  if (!is.null(age)) {
    characteristics_data$Age <- list(Value = age$value, Unit = age$unit)
  }
  if (!is.null(weight)) {
    characteristics_data$Weight <- list(
      Value = weight$value,
      Unit = weight$unit
    )
  }
  if (!is.null(height)) {
    characteristics_data$Height <- list(
      Value = height$value,
      Unit = height$unit
    )
  }
  if (!is.null(gestational_age)) {
    characteristics_data$GestationalAge <- list(
      Value = gestational_age$value,
      Unit = gestational_age$unit
    )
  }

  # Add calculation methods if provided
  if (!is.null(calculation_methods)) {
    characteristics_data$CalculationMethods <- calculation_methods
  }

  # Emit the modern Disease object (shared with create_expression_profile()),
  # not the legacy DiseaseState / DiseaseStateParameters pair.
  if (!is.null(disease_state)) {
    disease_input <- list(name = disease_state)
    if (!is.null(disease_state_parameters)) {
      disease_input$parameters <- disease_state_parameters
    }
    characteristics_data$Disease <- build_disease_state(disease_input)
  }

  # Create the data structure
  data <- list(
    Name = name,
    OriginData = characteristics_data
  )

  # Add seed if provided
  if (!is.null(seed)) {
    data$Seed <- seed
  }

  # Attach expression profiles as a character vector of composite names. A
  # length-1 name stays a length-1 vector; an empty vector adds no key so the
  # export emits no empty array.
  if (!is.null(expression_profiles) && length(expression_profiles) > 0) {
    data$ExpressionProfiles <- expression_profiles
  }

  # Attach the description if provided.
  if (!is.null(description)) {
    data$Description <- description
  }

  # Attach localized parameters as the raw `Parameters[]` shape. Constructing
  # the Individual then routes these through `initialize_parameters()` ->
  # `build_parameters_from_raw(ctor = LocalizedParameter$new)`, the same path
  # a loaded individual uses, so construct-with-parameters equals
  # construct-then-set.
  if (length(raw_parameters) > 0) {
    data$Parameters <- raw_parameters
  }

  # Create and return the Individual object
  Individual$new(data)
}

# Normalise the `parameters` argument of `create_individual()` into the raw
# `Parameters[]` shape (a list of dicts) the loader consumes, validating that
# every entry is a path-bearing (localized) parameter. Accepts a list whose
# entries are `Parameter`/`LocalizedParameter` R6 objects or already-raw dicts.
# Individual parameters are `LocalizedParameter[]` per the snapshot spec, so a
# name-only (pathless) entry is rejected here rather than being silently
# migrated by the `LocalizedParameter` constructor's `Name`->`Path` fallback.
# Returns an empty list when `parameters` is `NULL` or empty.
normalize_individual_parameters <- function(parameters) {
  if (is.null(parameters)) {
    return(list())
  }
  if (!is.list(parameters) || inherits(parameters, "R6")) {
    cli::cli_abort(
      "{.arg parameters} must be a list of localized parameters, not \\
      {.obj_type_friendly {parameters}}."
    )
  }

  lapply(parameters, function(entry) {
    raw <- if (inherits(entry, "Parameter")) entry$data else entry
    path <- if (is.list(raw)) raw$Path else NULL
    has_path <- !is.null(path) &&
      length(path) == 1 &&
      !is.na(path) &&
      nzchar(path)
    if (!has_path) {
      cli::cli_abort(
        c(
          "Each {.arg parameters} entry must be a localized parameter with a \\
          {.field path}.",
          i = "Create it with {.code create_parameter(path = ...)}."
        )
      )
    }
    raw
  })
}
