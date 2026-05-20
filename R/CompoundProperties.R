#' CompoundProperties class for Simulation compound configurations
#'
#' @description
#' An R6 class representing one entry in a [Simulation]'s `Compounds`
#' array. Carries the compound reference (by name) plus the simulation's
#' calculation-method overrides, alternative selections, process
#' selections, and optional [ProtocolSelection].
#'
#' @importFrom R6 R6Class
#' @export
CompoundProperties <- R6::R6Class(
  classname = "CompoundProperties",
  public = list(
    #' @description
    #' Create a new CompoundProperties object.
    #' @param data Raw `CompoundProperties` data from a snapshot.
    #' @return A new CompoundProperties object.
    initialize = function(data) {
      private$.data <- data

      if (!is.null(data$Alternatives)) {
        private$.alternatives <- lapply(
          data$Alternatives,
          function(d) CompoundGroupSelection$new(d)
        )
      } else {
        private$.alternatives <- list()
      }

      if (!is.null(data$Processes)) {
        private$.processes <- lapply(
          data$Processes,
          function(d) CompoundProcessSelection$new(d)
        )
      } else {
        private$.processes <- list()
      }

      if (!is.null(data$Protocol)) {
        private$.protocol <- ProtocolSelection$new(data$Protocol)
      }
    }
  ),
  active = list(
    #' @field data The raw data of the entry (read-only). Rebuilt from the
    #'   nested caches so that mutations on the wrapped objects flow back
    #'   to the export payload.
    data = function(value) {
      if (missing(value)) {
        result <- private$.data

        if (length(private$.alternatives) > 0) {
          alts <- lapply(private$.alternatives, function(a) a$data)
          names(alts) <- NULL
          result$Alternatives <- alts
        } else if (!is.null(private$.data$Alternatives)) {
          result$Alternatives <- list()
        }

        if (length(private$.processes) > 0) {
          procs <- lapply(private$.processes, function(p) p$data)
          names(procs) <- NULL
          result$Processes <- procs
        } else if (!is.null(private$.data$Processes)) {
          result$Processes <- list()
        }

        if (!is.null(private$.protocol)) {
          result$Protocol <- private$.protocol$data
        }

        return(result)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The name of the compound building block.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field calculation_methods Character vector of calculation method
    #'   names that override the compound's defaults in this simulation.
    calculation_methods = function(value) {
      if (missing(value)) {
        return(private$.data$CalculationMethods)
      }
      private$.data$CalculationMethods <- value
    },

    #' @field alternatives List of [CompoundGroupSelection] objects.
    alternatives = function(value) {
      if (missing(value)) {
        return(private$.alternatives)
      }
      if (is.null(value)) {
        private$.alternatives <- list()
      } else if (is.list(value)) {
        private$.alternatives <- value
      } else {
        cli::cli_abort("{.field alternatives} must be a list")
      }
    },

    #' @field processes List of [CompoundProcessSelection] objects.
    processes = function(value) {
      if (missing(value)) {
        return(private$.processes)
      }
      if (is.null(value)) {
        private$.processes <- list()
      } else if (is.list(value)) {
        private$.processes <- value
      } else {
        cli::cli_abort("{.field processes} must be a list")
      }
    },

    #' @field protocol A [ProtocolSelection] object or `NULL`.
    protocol = function(value) {
      if (missing(value)) {
        return(private$.protocol)
      }
      if (is.null(value)) {
        private$.protocol <- NULL
        private$.data$Protocol <- NULL
      } else if (inherits(value, "ProtocolSelection")) {
        private$.protocol <- value
      } else if (is.list(value)) {
        private$.protocol <- ProtocolSelection$new(value)
      } else {
        cli::cli_abort(
          "{.field protocol} must be a {.cls ProtocolSelection} or a raw list"
        )
      }
    }
  ),
  private = list(
    .data = NULL,
    .alternatives = NULL,
    .processes = NULL,
    .protocol = NULL,
    deep_clone = function(name, value) {
      if (name == ".protocol" && inherits(value, "R6")) {
        return(value$clone(deep = TRUE))
      }
      if (name %in% c(".alternatives", ".processes") && is.list(value)) {
        return(lapply(value, function(x) {
          if (inherits(x, "R6")) x$clone(deep = TRUE) else x
        }))
      }
      value
    }
  )
)
