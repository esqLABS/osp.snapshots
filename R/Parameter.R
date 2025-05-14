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

        # Different display for regular parameters vs table parameters
        if (is.null(self$table_formula)) {
          # Regular parameter display
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
        } else {
          # Create a simple table to display points
          points <- self$table_formula$Points
          if (length(points) > 0) {
            # Create descriptive headers with dimension information
            x_header <- self$table_formula$XName
            if (!is.null(self$table_formula$XUnit)) {
              x_header <- glue::glue(
                "{x_header} ({self$table_formula$XUnit})"
              )
            }

            y_header <- self$table_formula$YName
            if (!is.null(self$table_formula$YUnit)) {
              y_header <- glue::glue(
                "{y_header} ({self$table_formula$YUnit})"
              )
            }

            # Format table headers with the descriptive headers
            cat(sprintf("%-25s | %-25s\n", x_header, y_header))
            cat(sprintf(
              "%-25s-|-%-25s\n",
              glue::glue_collapse(rep("-", 25)),
              glue::glue_collapse(rep("-", 25))
            ))

            # Print each row of data
            for (point in points) {
              # Format the X value with unit if available
              x_value <- format(point$X, digits = 4)
              if (!is.null(self$table_formula$XUnit)) {
                x_value <- glue::glue("{x_value}")
              }

              cat(sprintf(
                "%-25s | %-25s\n",
                x_value,
                format(point$Y, digits = 4)
              ))
            }
          }
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert parameter data to a tibble row
    #' @return A tibble with one row containing the parameter data
    to_df = function() {
      # Basic parameter info
      result <- tibble::tibble(
        path = self$path,
        value = if (!is.null(self$table_formula)) "Table" else self$value,
        unit = self$unit %||% NA_character_,
        source = if (!is.null(self$value_origin)) self$value_origin$Source else
          NA_character_,
        description = if (
          !is.null(self$value_origin) && !is.null(self$value_origin$Description)
        )
          self$value_origin$Description else NA_character_,
        source_id = if (
          !is.null(self$value_origin) && !is.null(self$value_origin$Id)
        )
          self$value_origin$Id else NA_integer_
      )

      # For table parameters, also create separate dataframe of points
      if (
        !is.null(self$table_formula) && length(self$table_formula$Points) > 0
      ) {
        # Extract table points
        points_df <- do.call(
          rbind,
          lapply(self$table_formula$Points, function(p) {
            data.frame(
              parameter_path = self$path,
              x = p$X,
              y = p$Y,
              x_name = self$table_formula$XName,
              y_name = self$table_formula$YName,
              x_unit = self$table_formula$XUnit %||% NA_character_,
              stringsAsFactors = FALSE
            )
          })
        )

        # Return list with both dataframes
        return(list(
          parameter = result,
          points = points_df
        ))
      }

      return(result)
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

    #' @field name The name of the parameter (same as path)
    name = function(value) {
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
    },

    #' @field table_formula The table formula data for table parameters
    table_formula = function(value) {
      if (missing(value)) {
        return(self$data$TableFormula)
      }
      if (!is.null(value)) {
        self$data$TableFormula <- value
      } else {
        self$data$TableFormula <- NULL
      }
    }
  )
)

#' Create a new parameter
#'
#' @description
#' Create a new parameter with the specified properties.
#' All arguments except name and value are optional.
#'
#' @param name Character. Name of the parameter
#' @param value Numeric. Value of the parameter
#' @param unit Character. Unit of the parameter (optional)
#' @param source Character. Source of the value (optional)
#' @param description Character. Description of the value origin (optional)
#' @param source_id Integer. ID of the source (optional)
#' @param table_formula List. Table formula data for table parameters (optional)
#' @param table_points List. Points for table parameters, a list of x,y pairs (optional)
#' @param x_name Character. Name of X axis for table parameters (optional)
#' @param y_name Character. Name of Y axis for table parameters (optional)
#' @param x_unit Character. Unit for X axis for table parameters (optional)
#' @param x_dimension Character. Dimension for X axis for table parameters (optional)
#' @param y_dimension Character. Dimension for Y axis for table parameters (optional)
#'
#' @return A Parameter object
#' @export
#'
#' @examples
#' # Create a basic parameter
#' param <- create_parameter(
#'   name = "Organism|Liver|Volume",
#'   value = 1.5
#' )
#'
#' # Create a parameter with unit
#' param <- create_parameter(
#'   name = "Organism|Liver|Volume",
#'   value = 1.5,
#'   unit = "L"
#' )
#'
#' # Create a parameter with value origin
#' param <- create_parameter(
#'   name = "Organism|Liver|Volume",
#'   value = 1.5,
#'   unit = "L",
#'   source = "Publication",
#'   description = "Reference XYZ"
#' )
#'
#' # Create a table parameter
#' param <- create_parameter(
#'   name = "Fraction (dose)",
#'   value = 0.0,
#'   table_points = list(
#'     list(x = 0.0, y = 0.0),
#'     list(x = 1.0, y = 0.5),
#'     list(x = 2.0, y = 0.8),
#'     list(x = 4.0, y = 1.0)
#'   ),
#'   x_name = "Time",
#'   y_name = "Fraction (dose)",
#'   x_unit = "h",
#'   x_dimension = "Time",
#'   y_dimension = "Dimensionless"
#' )
create_parameter <- function(
  name,
  value,
  unit = NULL,
  source = NULL,
  description = NULL,
  source_id = NULL,
  table_formula = NULL,
  table_points = NULL,
  x_name = NULL,
  y_name = NULL,
  x_unit = NULL,
  x_dimension = NULL,
  y_dimension = NULL
) {
  # Create the data structure
  data <- list(
    Path = name,
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

  # Add table formula if table points are provided
  if (!is.null(table_points) || !is.null(table_formula)) {
    if (!is.null(table_formula)) {
      # Use provided table formula directly
      data$TableFormula <- table_formula
    } else if (!is.null(table_points)) {
      # Convert table_points to required format
      points <- lapply(table_points, function(point) {
        list(
          X = point$x,
          Y = point$y,
          RestartSolver = FALSE
        )
      })

      # Create table formula structure
      data$TableFormula <- list(
        Name = name,
        XName = x_name %||% "X",
        YName = y_name %||% "Y",
        XDimension = x_dimension %||% "Dimensionless",
        YDimension = y_dimension %||% "Dimensionless",
        UseDerivedValues = TRUE,
        Points = points
      )

      # Add X unit if provided
      if (!is.null(x_unit)) {
        data$TableFormula$XUnit <- x_unit
      }
    }
  }

  # Create and return the Parameter object
  Parameter$new(data)
}
