#' Create a new observer set
#'
#' @description
#' Create an [ObserverSet] building block from named arguments. This is a
#' thin factory around `ObserverSet$new()` that builds the raw list shape
#' for you.
#'
#' An [ObserverSet] bundles a collection of [Observer] objects (each one
#' a simulation-time formula that computes a derived quantity from the
#' underlying model) so a simulation can reference the whole bundle by
#' name.
#'
#' @param name Character. Name of the observer set (required).
#' @param observers List of [Observer] objects or raw observer lists to
#'   include in the set. Entries that inherit from `Observer` contribute
#'   their underlying raw data; other entries are assumed to already be
#'   raw observer lists.
#'
#' @return An [ObserverSet] object.
#' @export
#'
#' @examples
#' # Create an empty observer set
#' empty_set <- create_observer_set(name = "BrainPlasmaConcentration")
#'
#' # Create an observer set from raw observer lists
#' raw_set <- create_observer_set(
#'   name = "BrainPlasmaConcentration",
#'   observers = list(
#'     list(
#'       Name = "brain_plasma_conc",
#'       Type = "Container",
#'       Dimension = "Concentration (molar)",
#'       Formula = list(Formula = "Conc_Br")
#'     )
#'   )
#' )
#'
#' # Create an observer set from Observer R6 objects
#' observer <- Observer$new(list(
#'   Name = "brain_plasma_conc",
#'   Type = "Container",
#'   Dimension = "Concentration (molar)",
#'   Formula = list(Formula = "Conc_Br")
#' ))
#' observer_set <- create_observer_set(
#'   name = "BrainPlasmaConcentration",
#'   observers = list(observer)
#' )
create_observer_set <- function(name, observers = NULL) {
  check_required_string(name, "name")
  if (!is.null(observers) && (!is.list(observers) || is.object(observers))) {
    cli::cli_abort("{.arg observers} must be a list")
  }

  data <- list(Name = name)

  if (!is.null(observers)) {
    call <- environment()
    data$Observers <- unname(lapply(observers, function(observer) {
      if (inherits(observer, "Observer")) {
        return(observer$data)
      }
      if (is.list(observer) && !is.object(observer)) {
        return(observer)
      }
      cli::cli_abort(
        "Every entry of {.arg observers} must be an {.cls Observer} or a list",
        call = call
      )
    }))
  }

  ObserverSet$new(data)
}
