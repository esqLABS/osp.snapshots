#' Compound class for OSP snapshot compounds
#'
#' @description
#' An R6 class that represents a compound in an OSP snapshot.
#' This class provides methods to access different properties of a compound
#' and display a summary of its information.
#'
#' @export
Compound <- R6::R6Class(
  classname = "Compound",
  public = list(
    #' @field data The raw data of the compound
    data = NULL,
    #' @description
    #' Create a new Compound object
    #' @param data Raw compound data from a snapshot
    #' @return A new Compound object
    initialize = function(data) {
      self$data <- data
    },
    #' @description
    #' Print a summary of the compound
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      cli::cli_h1("Compound: {self$name}")

      # First, display simple properties (non-list fields)
      # Get all fields that are not lists or are empty lists
      non_list_fields <- names(self$data)[vapply(
        self$data,
        function(x) !is.list(x) || length(x) == 0,
        logical(1)
      )]

      # Display all non-list fields except Name
      for (field in non_list_fields) {
        # Skip Name field as it's already displayed in the header
        if (field == "Name") {
          next
        }

        formatted_field <- gsub("([a-z])([A-Z])", "\\1 \\2", field)
        cli::cli_li("{formatted_field}: {self$data[[field]]}")
      }

      # Add special handling for molecular weight which is nested in Parameters
      if (!is.na(self$molecular_weight)) {
        cli::cli_li(
          "Molecular Weight: {self$molecular_weight} {self$molecular_weight_unit}"
        )
      }

      # Then, display list fields as categories with counts
      cli::cat_line() # Add a blank line

      # Get all fields that are lists and not empty
      list_fields <- names(self$data)[vapply(
        self$data,
        function(x) is.list(x) && length(x) > 0,
        logical(1)
      )]

      for (field in list_fields) {
        # Get count of items in the list
        count <- length(self$data[[field]])

        # Format field name for display
        formatted_field <- gsub("([a-z])([A-Z])", "\\1 \\2", field)
        cli::cli_li("{formatted_field}: {count}")
      }

      # Return the object invisibly
      invisible(self)
    }
  ),
  active = list(
    #' @field name The name of the compound
    name = function() {
      self$data$Name
    },

    #' @field is_small_molecule Whether the compound is a small molecule
    is_small_molecule = function() {
      if (!is.null(self$data$IsSmallMolecule)) {
        return(self$data$IsSmallMolecule)
      }
      return(NA)
    },

    #' @field plasma_protein_binding_partner The plasma protein binding partner of the compound
    plasma_protein_binding_partner = function() {
      self$data$PlasmaProteinBindingPartner
    },

    #' @field molecular_weight The molecular weight of the compound
    molecular_weight = function() {
      if (length(self$data$Parameters) > 0) {
        for (param in self$data$Parameters) {
          if (param$Name == "Molecular weight") {
            return(param$Value)
          }
        }
      }
      return(NA)
    },

    #' @field molecular_weight_unit The unit of the molecular weight
    molecular_weight_unit = function() {
      if (length(self$data$Parameters) > 0) {
        for (param in self$data$Parameters) {
          if (param$Name == "Molecular weight" && !is.null(param$Unit)) {
            return(param$Unit)
          }
        }
      }
      return("")
    },

    #' @field lipophilicity The lipophilicity data of the compound
    lipophilicity = function() {
      self$data$Lipophilicity
    },

    #' @field fraction_unbound The fraction unbound data of the compound
    fraction_unbound = function() {
      self$data$FractionUnbound
    },

    #' @field solubility The solubility data of the compound
    solubility = function() {
      self$data$Solubility
    },

    #' @field intestinal_permeability The intestinal permeability data of the compound
    intestinal_permeability = function() {
      self$data$IntestinalPermeability
    },

    #' @field pka_types The pKa types of the compound
    pka_types = function() {
      self$data$PkaTypes
    },

    #' @field processes The processes of the compound
    processes = function() {
      self$data$Processes
    },

    #' @field calculation_methods The calculation methods of the compound
    calculation_methods = function() {
      self$data$CalculationMethods
    },

    #' @field parameters The parameters of the compound
    parameters = function() {
      self$data$Parameters
    }
  )
)
