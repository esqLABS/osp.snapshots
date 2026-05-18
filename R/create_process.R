#' Create a new compound process
#'
#' @description
#' Create a [Process] (a PK-Sim `CompoundProcess`) from named arguments.
#' This is a thin factory around `Process$new()` that builds the raw list
#' shape for you.
#'
#' For richer process structures (such as parameters with full value
#' origins), build the raw list directly or load a snapshot and copy the
#' relevant entry.
#'
#' @param internal_name Character. The PK-Sim `InternalName` for the
#'   process template (e.g. `"SpecificBinding"`,
#'   `"MetabolizationSpecific_MM"`, `"GlomerularFiltration"`). Required.
#' @param data_source Character. The `DataSource` string identifying the
#'   process. Required.
#' @param molecule Character. Optional molecule name for partial processes
#'   (e.g. the enzyme catalysing the reaction).
#' @param metabolite Character. Optional metabolite name for enzymatic
#'   processes.
#' @param species Character. Optional species name for species-dependent
#'   processes.
#' @param parameters List of [Parameter] objects (created with
#'   [create_parameter()]) or raw parameter lists to attach to the process.
#'
#' @return A [Process] object.
#' @export
#'
#' @examples
#' # Minimal protein-binding process
#' p <- create_process(
#'   internal_name = "SpecificBinding",
#'   data_source = "Publication X",
#'   molecule = "Albumin"
#' )
#'
#' # Metabolizing enzyme with a parameter
#' p <- create_process(
#'   internal_name = "MetabolizationSpecific_MM",
#'   data_source = "Optimized",
#'   molecule = "CYP3A4",
#'   metabolite = "Hydroxy-Drug",
#'   parameters = list(
#'     create_parameter(name = "Km", value = 1.2, unit = "µmol/l")
#'   )
#' )
create_process <- function(
  internal_name,
  data_source,
  molecule = NULL,
  metabolite = NULL,
  species = NULL,
  parameters = NULL
) {
  check_required_string(internal_name, "internal_name")
  check_required_string(data_source, "data_source")

  data <- list(
    InternalName = internal_name,
    DataSource = data_source
  )

  if (!is.null(molecule)) {
    check_required_string(molecule, "molecule")
    data$Molecule <- molecule
  }
  if (!is.null(metabolite)) {
    check_required_string(metabolite, "metabolite")
    data$Metabolite <- metabolite
  }
  if (!is.null(species)) {
    check_required_string(species, "species")
    data$Species <- species
  }
  if (!is.null(parameters)) {
    if (!is.list(parameters)) {
      cli::cli_abort("{.arg parameters} must be a list")
    }
    data$Parameters <- to_raw_parameters(parameters, "Name")
  }

  Process$new(data)
}
