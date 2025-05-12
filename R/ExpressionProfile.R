#' ExpressionProfile class for OSP snapshot expression profiles
#'
#' @description
#' An R6 class that represents an expression profile in an OSP snapshot.
#' This class provides methods to access different properties of an expression profile
#' and display a summary of its information.
#'
#' @export
ExpressionProfile <- R6::R6Class(
  classname = "ExpressionProfile",
  public = list(
    #' @field data The raw data of the expression profile
    data = NULL,
    #' @description
    #' Create a new ExpressionProfile object
    #' @param data Raw expression profile data from a snapshot
    #' @return A new ExpressionProfile object
    initialize = function(data) {
      self$data <- data
    },
    #' @description
    #' Print a summary of the expression profile
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      cli::cli_h1("Expression Profile: {self$molecule} ({self$type})")

      # Display basic information
      cli::cli_li("Species: {self$species}")
      cli::cli_li("Category: {self$category}")

      if (!is.null(self$data$Localization) && !is.na(self$data$Localization)) {
        cli::cli_li("Localization: {self$data$Localization}")
      }

      if (!is.null(self$data$Ontogeny) && length(self$data$Ontogeny) > 0) {
        cli::cli_li("Ontogeny: {self$data$Ontogeny$Name}")
      }

      # Display parameter count
      if (length(self$parameters) > 0) {
        cli::cli_li("Parameters: {length(self$parameters)}")
      }

      # Return the object invisibly
      invisible(self)
    },
    #' @description
    #' Convert the expression profile to data frames for easier manipulation
    #' @return A list with basic information and parameters as tibbles
    to_df = function() {
      # Create a basic dataframe with expression profile properties
      expression_profiles_df <- tibble::tibble(
        expression_id = self$id,
        molecule = self$molecule,
        type = self$type,
        species = self$species,
        category = self$category %||% NA_character_,
        localization = self$localization %||% NA_character_,
        ontogeny = if (!is.null(self$ontogeny) && !is.null(self$ontogeny$Name))
          self$ontogeny$Name else NA_character_
      )

      # If there are parameters, create a parameter dataframe
      if (length(self$parameters) > 0) {
        param_df <- do.call(
          rbind,
          lapply(self$parameters, function(param) {
            # Extract path for parameter name
            path <- if (!is.null(param$Path)) param$Path else NA_character_

            # Extract value
            value <- if (!is.null(param$Value)) param$Value else NA_real_

            # Extract unit if present
            unit <- if (!is.null(param$Unit)) param$Unit else NA_character_

            # Extract source and description if present
            source <- NA_character_
            description <- NA_character_
            if (!is.null(param$ValueOrigin)) {
              source <- param$ValueOrigin$Source %||% NA_character_
              description <- param$ValueOrigin$Description %||% NA_character_
            }

            # Create a tibble for this parameter
            tibble::tibble(
              expression_id = self$id,
              parameter = path,
              value = value,
              unit = unit,
              source = source,
              description = description
            )
          })
        )

        # Return both info and parameters with new keys
        return(list(
          expression_profiles = expression_profiles_df,
          expression_profiles_parameters = param_df
        ))
      }

      # If no parameters, just return the info
      return(list(
        expression_profiles = expression_profiles_df,
        expression_profiles_parameters = NULL
      ))
    }
  ),
  active = list(
    #' @field type The type of the expression profile
    type = function() {
      self$data$Type
    },

    #' @field species The species of the expression profile
    species = function() {
      self$data$Species
    },

    #' @field molecule The molecule name of the expression profile
    molecule = function() {
      self$data$Molecule
    },

    #' @field category The category of the expression profile
    category = function() {
      self$data$Category
    },

    #' @field localization The localization of the expression profile
    localization = function() {
      self$data$Localization
    },

    #' @field ontogeny The ontogeny information of the expression profile
    ontogeny = function() {
      self$data$Ontogeny
    },

    #' @field parameters The parameters of the expression profile
    parameters = function() {
      self$data$Parameters
    },

    #' @field id The unique identifier of the expression profile
    id = function() {
      category_value <- if (is.null(self$category)) "NA" else self$category
      paste(self$molecule, self$species, category_value, sep = "_")
    }
  )
)
