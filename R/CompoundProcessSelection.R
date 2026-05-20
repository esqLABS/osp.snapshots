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

    #' @field name The process name.
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field molecule_name The molecule involved in the process.
    molecule_name = function(value) {
      if (missing(value)) {
        return(private$.data$MoleculeName)
      }
      private$.data$MoleculeName <- value
    },

    #' @field metabolite_name The metabolite produced by the process.
    metabolite_name = function(value) {
      if (missing(value)) {
        return(private$.data$MetaboliteName)
      }
      private$.data$MetaboliteName <- value
    },

    #' @field compound_name The other compound involved in the process.
    compound_name = function(value) {
      if (missing(value)) {
        return(private$.data$CompoundName)
      }
      private$.data$CompoundName <- value
    },

    #' @field systemic_process_type The systemic process type (e.g.
    #'   `"Hepatic"`, `"Renal"`, `"Biliary"`).
    systemic_process_type = function(value) {
      if (missing(value)) {
        return(private$.data$SystemicProcessType)
      }
      private$.data$SystemicProcessType <- value
    }
  ),
  private = list(
    .data = NULL
  )
)
