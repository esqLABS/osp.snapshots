#' Process class for OSP snapshot compound processes
#'
#' @description
#' An R6 class that represents a single compound process in an OSP snapshot.
#'
#' A `Process` wraps one entry of a `Compound`'s `Processes` array
#' (PK-Sim `CompoundProcess`). The PK-Sim JSON does not bucket processes by
#' subtype; subtypes are inferred from `internal_name`. The derived
#' `category` field surfaces that bucketing for R consumers:
#' `"protein_binding_partners"`, `"metabolizing_enzymes"`,
#' `"hepatic_clearance"`, `"transporter_proteins"`, `"renal_clearance"`,
#' `"biliary_clearance"`, `"inhibition"`, `"induction"`, or `NA` when the
#' `internal_name` does not match any known pattern.
#'
#' @importFrom R6 R6Class
#'
#' @export
Process <- R6::R6Class(
  classname = "Process",
  public = list(
    #' @description
    #' Create a new Process object.
    #' @param data Raw process data (a `CompoundProcess` entry from a snapshot).
    #' @return A new Process object.
    initialize = function(data) {
      private$.data <- data %||% list()
      private$.parameters <- build_parameters_from_raw(
        private$.data$Parameters,
        key_by = "name"
      )
    },

    #' @description
    #' Print a short summary of the process.
    #' @param ... Additional arguments (unused).
    #' @return Invisibly returns the Process object.
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h3("Process: {self$internal_name %||% '<unknown>'}")
        cli::cli_li("Category: {self$category %||% NA_character_}")
        if (!is.null(self$data_source)) {
          cli::cli_li("Data source: {self$data_source}")
        }
        if (!is.null(self$molecule)) {
          cli::cli_li("Molecule: {self$molecule}")
        }
        if (!is.null(self$metabolite)) {
          cli::cli_li("Metabolite: {self$metabolite}")
        }
        if (!is.null(self$species)) {
          cli::cli_li("Species: {self$species}")
        }
        if (length(self$parameters) > 0) {
          cli::cli_li("Parameters: {length(self$parameters)}")
        }
      })
      cat(output, sep = "\n")
      invisible(self)
    }
  ),
  active = list(
    #' @field data The raw underlying data list (read-only).
    data = function() {
      private$.data
    },

    #' @field internal_name The PK-Sim `InternalName` (process template key).
    internal_name = function(value) {
      if (missing(value)) {
        return(private$.data$InternalName)
      }
      private$.data$InternalName <- value
    },

    #' @field data_source The `DataSource` string identifying the process.
    data_source = function(value) {
      if (missing(value)) {
        return(private$.data$DataSource)
      }
      private$.data$DataSource <- value
    },

    #' @field molecule Optional `Molecule` field (for partial processes).
    molecule = function(value) {
      if (missing(value)) {
        return(private$.data$Molecule)
      }
      private$.data$Molecule <- value
    },

    #' @field metabolite Optional `Metabolite` field (for enzymatic processes).
    metabolite = function(value) {
      if (missing(value)) {
        return(private$.data$Metabolite)
      }
      private$.data$Metabolite <- value
    },

    #' @field species Optional `Species` field (for species-dependent
    #'   processes).
    species = function(value) {
      if (missing(value)) {
        return(private$.data$Species)
      }
      private$.data$Species <- value
    },

    #' @field parameters A named list of [Parameter] objects (one entry per
    #'   `Parameter` in the snapshot JSON), keyed by parameter name. Assigning
    #'   accepts either a list of [Parameter] objects or raw parameter dicts;
    #'   the underlying raw data and the [Parameter] cache are kept in sync.
    parameters = function(value) {
      if (missing(value)) {
        return(private$.parameters)
      }
      raw <- if (is.null(value)) NULL else to_raw_parameters(value, "Name")
      private$.data$Parameters <- raw
      private$.parameters <- build_parameters_from_raw(
        raw,
        key_by = "name"
      )
    },

    #' @field category Derived category string. One of
    #'   `"protein_binding_partners"`, `"metabolizing_enzymes"`,
    #'   `"hepatic_clearance"`, `"transporter_proteins"`,
    #'   `"renal_clearance"`, `"biliary_clearance"`, `"inhibition"`,
    #'   `"induction"`, or `NA_character_`.
    category = function() {
      process_category(private$.data$InternalName)
    }
  ),
  private = list(
    .data = NULL,
    .parameters = NULL
  )
)

# Internal: derive the category from an `InternalName`. Returns
# `NA_character_` for unrecognised names.
process_category <- function(internal_name) {
  if (is.null(internal_name) || !nzchar(internal_name)) {
    return(NA_character_)
  }

  if (identical(internal_name, "SpecificBinding")) {
    return("protein_binding_partners")
  }
  if (grepl("Metabolization|rCYP", internal_name)) {
    return("metabolizing_enzymes")
  }
  if (
    grepl(
      "Hepatocytes|LiverClearance|LiverMicrosomeR|LiverMicrosomeH",
      internal_name
    )
  ) {
    return("hepatic_clearance")
  }
  if (grepl("ActiveTransport", internal_name)) {
    return("transporter_proteins")
  }
  if (grepl("Tubular|Kidney|Glomerular", internal_name)) {
    return("renal_clearance")
  }
  if (identical(internal_name, "BiliaryClearance")) {
    return("biliary_clearance")
  }
  if (grepl("Inhibition", internal_name)) {
    return("inhibition")
  }
  if (identical(internal_name, "Induction")) {
    return("induction")
  }
  NA_character_
}

# Internal: build a flat named list of `Process` objects from a raw
# `CompoundProcess[]` list. Duplicate names produced by the default keying
# rule are disambiguated with the standard `_{n}` suffix used elsewhere in
# the package.
build_processes_from_raw <- function(raw_processes) {
  raw_processes <- raw_processes %||% list()
  if (length(raw_processes) == 0) {
    return(list())
  }

  processes <- lapply(raw_processes, function(d) Process$new(d))

  keys <- vapply(
    processes,
    function(p) {
      key <- p$internal_name %||% "Unknown"
      ds <- p$data_source
      if (!is.null(ds) && nzchar(ds)) {
        key <- paste(key, ds, sep = ", ")
      }
      mol <- p$molecule
      if (!is.null(mol) && nzchar(mol)) {
        key <- paste(key, mol, sep = ", ")
      }
      key
    },
    character(1)
  )

  names(processes) <- disambiguate_names(keys)
  processes
}
