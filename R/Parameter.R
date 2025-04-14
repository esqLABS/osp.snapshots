#' Parameter class for OSP snapshot parameters
#'
#' @description
#' An R6 class that represents a parameter in an OSP snapshot.
#' This class provides methods to access different properties of a parameter
#' and display a summary of its information.
#'
#' @importFrom tibble tibble as_tibble
#' @export
Parameter <- R6::R6Class(
  classname = "Parameter",
  public = list(
    #' @field data The raw data of the parameter
    data = NULL,

    #' @description
    #' Create a new Parameter object
    #' @param data Raw parameter data from a snapshot
    #' @return A new Parameter object
    initialize = function(data) {
      self$data <- data
    },

    #' @description
    #' Print a summary of the parameter
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h3("Parameter: {self$path}")
        cli::cli_li("Value: {self$value}")
        if (!is.null(self$unit)) {
          cli::cli_li("Unit: {self$unit}")
        }
        if (!is.null(self$value_origin)) {
          cli::cli_li("Source: {self$value_origin$Source}")
          if (!is.null(self$value_origin$Description)) {
            cli::cli_li(
              "Description: {self$value_origin$Description}"
            )
          }
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert parameter data to a tibble row
    #' @param individual_id Character. ID of the individual this parameter belongs to
    #' @return A tibble with one row containing the parameter data
    to_df = function(individual_id) {
      tibble::tibble(
        individual_id = individual_id,
        path = self$path,
        value = self$value,
        unit = self$unit %||% NA_character_,
        source = if (!is.null(self$value_origin)) self$value_origin$Source else
          NA_character_,
        description = if (!is.null(self$value_origin))
          self$value_origin$Description else NA_character_,
        source_id = if (!is.null(self$value_origin)) self$value_origin$Id else
          NA_integer_
      )
    }
  ),
  active = list(
    #' @field path The path of the parameter
    path = function(value) {
      if (missing(value)) {
        return(self$data$Path)
      }
      self$data$Path <- value
    },

    #' @field value The value of the parameter
    value = function(value) {
      if (missing(value)) {
        return(self$data$Value)
      }
      self$data$Value <- value
    },

    #' @field unit The unit of the parameter (if any)
    unit = function(value) {
      if (missing(value)) {
        return(self$data$Unit)
      }
      if (!is.null(value)) {
        # TODO: Add unit validation when we know the dimension
        self$data$Unit <- value
      } else {
        self$data$Unit <- NULL
      }
    },

    #' @field value_origin The origin information for the parameter value
    value_origin = function(value) {
      if (missing(value)) {
        return(self$data$ValueOrigin)
      }
      if (!is.null(value)) {
        if (is.null(self$data$ValueOrigin)) {
          self$data$ValueOrigin <- value
        } else {
          self$data$ValueOrigin <- utils::modifyList(
            self$data$ValueOrigin,
            value
          )
        }
      } else {
        self$data$ValueOrigin <- NULL
      }
    }
  )
)

#' Create a new parameter
#'
#' @description
#' Create a new parameter with the specified properties.
#' All arguments except path and value are optional.
#'
#' @param path Character. Path of the parameter
#' @param value Numeric. Value of the parameter
#' @param unit Character. Unit of the parameter (optional)
#' @param source Character. Source of the value (optional)
#' @param description Character. Description of the value origin (optional)
#' @param source_id Integer. ID of the source (optional)
#'
#' @return A Parameter object
#' @export
#'
#' @examples
#' # Create a basic parameter
#' param <- create_parameter(
#'   path = "Organism|Liver|Volume",
#'   value = 1.5
#' )
#'
#' # Create a parameter with unit
#' param <- create_parameter(
#'   path = "Organism|Liver|Volume",
#'   value = 1.5,
#'   unit = "L"
#' )
#'
#' # Create a parameter with value origin
#' param <- create_parameter(
#'   path = "Organism|Liver|Volume",
#'   value = 1.5,
#'   unit = "L",
#'   source = "Publication",
#'   description = "Reference XYZ"
#' )
create_parameter <- function(
  path,
  value,
  unit = NULL,
  source = NULL,
  description = NULL,
  source_id = NULL
) {
  # Create the data structure
  data <- list(
    Path = path,
    Value = value
  )

  # Add unit if provided
  if (!is.null(unit)) {
    data$Unit <- unit
  }

  # Add value origin if any source information is provided
  if (!is.null(source) || !is.null(description) || !is.null(source_id)) {
    value_origin <- list()
    if (!is.null(source)) value_origin$Source <- source
    if (!is.null(description)) value_origin$Description <- description
    if (!is.null(source_id)) value_origin$Id <- source_id
    data$ValueOrigin <- value_origin
  }

  # Create and return the Parameter object
  Parameter$new(data)
}
