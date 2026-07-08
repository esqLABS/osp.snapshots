#' CompoundProcessSelection class for compound process selections
#'
#' @description
#' An R6 class representing one entry in a [CompoundProperties]'s
#' `Processes` array. Selects a compound process by some combination of
#' name, molecule, metabolite, compound, and systemic process type; the
#' resolver in PK-Sim picks the right placeholder when only a subset of
#' fields is supplied.
#'
#' @importFrom R6 R6Class
#' @export
CompoundProcessSelection <- R6::R6Class(
  classname = "CompoundProcessSelection",
  public = list(
    #' @description
    #' Create a new CompoundProcessSelection object.
    #' @param data Raw `CompoundProcessSelection` data from a snapshot.
    #' @return A new CompoundProcessSelection object.
    initialize = function(data) {
      private$.data <- data
    }
  ),
  active = list(
    #' @field data The raw data of the selection (read-only).
    data = function(value) {
      if (missing(value)) {
        return(private$.data)
      }
      cli::cli_abort("data is read-only")
    },

    #' @field name The process name. Writable: a non-empty scalar string
    #'   when supplied, or `NULL` to clear.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      if (!is.null(value)) {
        check_required_string(value, "name")
      }
      private$.data$Name <- value
    },

    #' @field molecule_name The molecule involved in the process. Writable:
    #'   a non-empty scalar string when supplied, or `NULL` to clear.
    molecule_name = function(value) {
      if (missing(value)) {
        return(private$.data$MoleculeName)
      }
      if (!is.null(value)) {
        check_required_string(value, "molecule_name")
      }
      private$.data$MoleculeName <- value
    },

    #' @field metabolite_name The metabolite produced by the process.
    #'   Writable: a non-empty scalar string when supplied, or `NULL` to
    #'   clear.
    metabolite_name = function(value) {
      if (missing(value)) {
        return(private$.data$MetaboliteName)
      }
      if (!is.null(value)) {
        check_required_string(value, "metabolite_name")
      }
      private$.data$MetaboliteName <- value
    },

    #' @field compound_name The other compound involved in the process.
    #'   Writable: a non-empty scalar string when supplied, or `NULL` to
    #'   clear.
    compound_name = function(value) {
      if (missing(value)) {
        return(private$.data$CompoundName)
      }
      if (!is.null(value)) {
        check_required_string(value, "compound_name")
      }
      private$.data$CompoundName <- value
    },

    #' @field systemic_process_type The systemic process type (e.g.
    #'   `"Hepatic"`, `"Renal"`, `"Biliary"`). Writable: a non-empty scalar
    #'   string when supplied, or `NULL` to clear. The closed set is not
    #'   confirmable from the snapshot schema (only examples are given), so
    #'   a required string is the strongest check available.
    systemic_process_type = function(value) {
      if (missing(value)) {
        return(private$.data$SystemicProcessType)
      }
      if (!is.null(value)) {
        check_required_string(value, "systemic_process_type")
      }
      private$.data$SystemicProcessType <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
