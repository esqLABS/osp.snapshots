#' Load DataSet from OSP snapshot observed data
#'
#' @description
#' Creates a DataSet object (from ospsuite package) from observed data in an OSP snapshot.
#' This function converts snapshot observed data format to the standardized DataSet format
#' used throughout the OSP ecosystem.
#'
#' @details
#' This function follows the same pattern as other DataSet loading functions in ospsuite:
#' - `ospsuite::loadDataSetFromPKML()`
#' - `ospsuite::loadDataSetFromExcel()`
#' - `osp.snapshots::loadDataSetFromSnapshot()` (this function)
#'
#' @section Migration Plan:
#' This function is designed for eventual migration to the ospsuite package.
#' When migrated, the usage pattern will be:
#'
#' ```r
#' # Future usage (when moved to ospsuite):
#' dataset <- ospsuite::loadDataSetFromSnapshot(observedDataStructure)
#'
#' # Current usage:
#' dataset <- osp.snapshots::loadDataSetFromSnapshot(observedDataStructure)
#'
#' # Migration steps:
#' # 1. Copy this function to ospsuite package
#' # 2. Update osp.snapshots to import from ospsuite
#' # 3. Eventually remove from osp.snapshots
#' ```
#'
#' @param observedDataStructure Raw observed data structure from a snapshot JSON
#' @return A DataSet object from the ospsuite package
#' @importFrom ospsuite DataSet
#' @export
loadDataSetFromSnapshot <- function(observedDataStructure) {
  if (is.null(observedDataStructure$Name)) {
    cli::cli_abort("Observed data must have a Name field")
  }

  # Create the base DataSet with the name
  dataset <- ospsuite::DataSet$new(observedDataStructure$Name)

  # Set time values and units from BaseGrid if available
  if (
    !is.null(observedDataStructure$BaseGrid) &&
      !is.null(observedDataStructure$BaseGrid$Values)
  ) {
    time_values <- observedDataStructure$BaseGrid$Values

    # Set time unit if available
    if (!is.null(observedDataStructure$BaseGrid$Unit)) {
      # Map common time units to ospsuite units
      time_unit_mapping <- list(
        "h" = ospsuite::ospUnits$Time$h,
        "min" = ospsuite::ospUnits$Time$min,
        "s" = ospsuite::ospUnits$Time$s,
        "day" = ospsuite::ospUnits$Time$day
      )

      if (observedDataStructure$BaseGrid$Unit %in% names(time_unit_mapping)) {
        dataset$xUnit <- time_unit_mapping[[
          observedDataStructure$BaseGrid$Unit
        ]]
      }
    }

    # Process the first column for now (DataSet handles one y-series at a time)
    if (
      !is.null(observedDataStructure$Columns) &&
        length(observedDataStructure$Columns) > 0
    ) {
      first_col <- observedDataStructure$Columns[[1]]

      if (!is.null(first_col$Values)) {
        y_values <- first_col$Values

        # Set y unit if available
        if (!is.null(first_col$DataInfo$Unit)) {
          # For now, use the unit as-is - ospsuite will handle conversion
          # In a full implementation, we'd need proper unit mapping
          dataset$yUnit <- first_col$DataInfo$Unit
        }

        # set molecular weight if available
        if (!is.null(first_col$DataInfo$MolWeight)) {
          dataset$molWeight <- first_col$DataInfo$MolWeight
        }

        # Set the values
        dataset$setValues(
          xValues = time_values,
          yValues = y_values
        )
      }
    }
  } else {
    # If no time grid, try to handle single-column data
    if (
      !is.null(observedDataStructure$Columns) &&
        length(observedDataStructure$Columns) > 0
    ) {
      first_col <- observedDataStructure$Columns[[1]]
      if (!is.null(first_col$Values)) {
        # Create dummy time values if none exist
        n_points <- length(first_col$Values)
        dataset$setValues(
          xValues = seq_len(n_points),
          yValues = first_col$Values
        )
      }
    }
  }

  # Add metadata from ExtendedProperties
  if (!is.null(observedDataStructure$ExtendedProperties)) {
    for (prop in observedDataStructure$ExtendedProperties) {
      if (!is.null(prop$Name) && !is.null(prop$Value)) {
        # Convert value to string as required by DataSet$addMetaData
        value_string <- as.character(prop$Value)
        dataset$addMetaData(name = prop$Name, value = value_string)
      }
    }
  }
  return(dataset)
}

# Compatibility alias for backward compatibility
# Will be deprecated when function moves to ospsuite
#' @export
ObservedData <- loadDataSetFromSnapshot
