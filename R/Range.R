#' Range class for physiological parameters
#'
#' @description
#' An R6 class that represents a range of values with a minimum, maximum and unit.
#' Used for age, weight, height, and BMI ranges in populations.
#' Either min or max can be NULL to represent ranges with only an upper or lower bound.
#'
#' @importFrom R6 R6Class
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
      # Handle NULL-like values - treat empty strings, empty lists, and actual NULL the same way
      if (
        is.null(min) ||
          (is.character(min) && (length(min) == 0 || min == "")) ||
          (is.list(min) && length(min) == 0)
      ) {
        min <- NULL
      }

      if (
        is.null(max) ||
          (is.character(max) && (length(max) == 0 || max == "")) ||
          (is.list(max) && length(max) == 0)
      ) {
        max <- NULL
      }

      # Convert min and max to numeric if they are not NULL
      if (!is.null(min)) {
        min_numeric <- suppressWarnings(as.numeric(min))
        if (length(min_numeric) == 0 || is.na(min_numeric)) {
          cli::cli_abort("Min must be a numeric value")
        }
        min <- min_numeric
      }
      if (!is.null(max)) {
        max_numeric <- suppressWarnings(as.numeric(max))
        if (length(max_numeric) == 0 || is.na(max_numeric)) {
          cli::cli_abort("Max must be a numeric value")
        }
        max <- max_numeric
      }

      # Validate that at least one of min or max is not NULL
      if (is.null(min) && is.null(max)) {
        cli::cli_abort("At least one of min or max must be specified")
      }

      # When both are present, validate that min <= max
      if (!is.null(min) && !is.null(max)) {
        if (min > max) {
          cli::cli_abort("Min must be less than or equal to max")
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
      output <- cli::cli_format_method({
        min_text <- if (is.null(private$.min)) "-\u221e" else private$.min
        max_text <- if (is.null(private$.max)) "\u221e" else private$.max

        cli::cli_text("{min_text} - {max_text} {private$.unit}")
      })

      cat(output, sep = "\n")
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

      # Try numeric conversion
      numeric_value <- suppressWarnings(as.numeric(value))

      # Validate numeric
      if (length(numeric_value) == 0 || is.na(numeric_value)) {
        cli::cli_abort("Min must be a numeric value")
      }

      # Use the converted numeric value
      value <- numeric_value

      # Validate min <= max if max is not NULL
      if (!is.null(private$.max) && value > private$.max) {
        cli::cli_abort("Min must be less than or equal to max")
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

      # Try numeric conversion
      numeric_value <- suppressWarnings(as.numeric(value))

      # Validate numeric
      if (length(numeric_value) == 0 || is.na(numeric_value)) {
        cli::cli_abort("Max must be a numeric value")
      }

      # Use the converted numeric value
      value <- numeric_value

      # Validate min <= max if min is not NULL
      if (!is.null(private$.min) && value < private$.min) {
        cli::cli_abort("Max must be greater than or equal to min")
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
#' Min and max can also be equal to represent a single value.
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
#' # Create a weight range with equal min and max (representing a single value)
#' weight_fixed_range <- range(70, 70, "kg")
#'
#' # Assign to a population
#' population$weight_range <- weight_range
#' }
range <- function(min, max, unit) {
  Range$new(min, max, unit)
}
