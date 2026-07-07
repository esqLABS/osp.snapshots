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
    time_values <- as.numeric(unlist(observedDataStructure$BaseGrid$Values))

    # Set time unit directly if available, mirroring the y-column handling
    # below. The raw snapshot unit string is a valid ospsuite Time unit
    # (e.g. "h", "min", "day(s)", "week(s)", "ks"); the `DataSet` setter
    # accepts it as-is and labels the axis without rescaling `xValues`.
    if (!is.null(observedDataStructure$BaseGrid$Unit)) {
      dataset$xUnit <- observedDataStructure$BaseGrid$Unit
    }

    # Process the first column for now (DataSet handles one y-series at a time)
    if (
      !is.null(observedDataStructure$Columns) &&
        length(observedDataStructure$Columns) > 0
    ) {
      first_col <- observedDataStructure$Columns[[1]]

      if (!is.null(first_col$Values)) {
        y_values <- as.numeric(unlist(first_col$Values))
        y_error_values <- NULL

        dataset$yDimension <- first_col$Dimension

        # set y unit if available (not available for unitless dimensions like fractions)
        if (!is.null(first_col$Unit)) {
          dataset$yUnit <- first_col$Unit
        }

        # set molecular weight if available
        if (!is.null(first_col$DataInfo$MolWeight)) {
          dataset$molWeight <- first_col$DataInfo$MolWeight
        }

        # Set LLOQ if available
        if (!is.null(first_col$DataInfo$LLOQ)) {
          dataset$LLOQ <- first_col$DataInfo$LLOQ
        }

        # Process RelatedColumns for error data
        if (
          !is.null(first_col$RelatedColumns) &&
            length(first_col$RelatedColumns) > 0
        ) {
          # Look for error columns (typically ArithmeticStdDev, GeometricStdDev, etc.)
          for (related_col in first_col$RelatedColumns) {
            # Check if this is an error column based on AuxiliaryType
            if (
              !is.null(related_col$DataInfo$AuxiliaryType) &&
                related_col$DataInfo$AuxiliaryType != "Undefined"
            ) {
              # Get error values (to be passed to setValues)
              if (!is.null(related_col$Values)) {
                y_error_values <- as.numeric(unlist(related_col$Values))
              }

              # Set error dimension and unit
              if (!is.null(related_col$Unit)) {
                dataset$yErrorUnit <- related_col$Unit
              }

              # Map AuxiliaryType to yErrorType
              # Common types: ArithmeticStdDev, GeometricStdDev, ArithmeticStdErr
              if (!is.null(related_col$DataInfo$AuxiliaryType)) {
                auxiliary_type <- related_col$DataInfo$AuxiliaryType
                # Map to ospsuite error types
                error_type_mapping <- list(
                  "ArithmeticStdDev" = "ArithmeticStdDev",
                  "GeometricStdDev" = "GeometricStdDev",
                  "ArithmeticStdErr" = "ArithmeticStdErr"
                )

                if (auxiliary_type %in% names(error_type_mapping)) {
                  dataset$yErrorType <- error_type_mapping[[auxiliary_type]]
                } else {
                  # Use the auxiliary type as-is if not in mapping
                  dataset$yErrorType <- auxiliary_type
                }
              }

              # Only process the first error column
              break
            }
          }
        }

        # Set the values (including error values if available)
        dataset$setValues(
          xValues = time_values,
          yValues = y_values,
          yErrorValues = y_error_values
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
        y_vals <- as.numeric(unlist(first_col$Values))
        n_points <- length(y_vals)
        dataset$setValues(
          xValues = seq_len(n_points),
          yValues = y_vals
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

#' @rdname loadDataSetFromSnapshot
#' @usage NULL
#' @format NULL
#' @details
#' `ObservedData` is a backwards-compatible alias for
#' [loadDataSetFromSnapshot()] and may be retired in a future release if this
#' functionality migrates to the `ospsuite` package. Prefer the
#' `loadDataSetFromSnapshot()` name in new code.
#' @export
ObservedData <- loadDataSetFromSnapshot

# Serialize a runtime `ospsuite::DataSet` back into the list shape used by the
# snapshot JSON `ObservedData[[i]]`. This is the inverse of
# `loadDataSetFromSnapshot()` and is, like the loader, lossy: it can only emit
# fields the public `DataSet` API exposes. In particular `QuantityInfo$Path`
# is synthesized from `dataset$name` (the original PK-Sim hierarchical path is
# not preserved on load), `ExtendedProperties[[i]]$Type` is always "String"
# (the loader coerces values via `as.character` and drops the type tag), and
# only one y-column is emitted ("Avg"); multi-column observed-data entries
# are not representable through a single `DataSet`. The synthesized payload
# is sufficient for round-trip through `osp.snapshots`; round-trip through
# PK-Sim has not been validated and may require additional fields.
.dataset_to_snapshot_list <- function(dataset) {
  values_as_list <- function(x) {
    if (length(x) == 0) {
      return(list())
    }
    lapply(x, identity)
  }

  base_grid <- list(
    Name = "Time",
    QuantityInfo = list(
      Path = paste0(dataset$name, "|Time"),
      Type = "Time"
    ),
    DataInfo = list(
      Origin = "BaseGrid",
      AuxiliaryType = "Undefined"
    ),
    Values = values_as_list(dataset$xValues),
    Dimension = dataset$xDimension %||% "Time",
    Unit = dataset$xUnit %||% "h"
  )

  data_info <- list(
    Origin = "Observation",
    AuxiliaryType = "Undefined"
  )
  if (!is.null(dataset$molWeight) && !is.na(dataset$molWeight)) {
    data_info$MolWeight <- dataset$molWeight
  }
  if (!is.null(dataset$LLOQ) && !is.na(dataset$LLOQ)) {
    data_info$LLOQ <- dataset$LLOQ
  }

  base_path <- paste0(dataset$name, "|ObservedData|", dataset$name)

  column <- list(
    Name = "Avg",
    QuantityInfo = list(
      Path = paste0(base_path, "|ArithmeticMean")
    ),
    DataInfo = data_info,
    Values = values_as_list(dataset$yValues),
    Dimension = dataset$yDimension,
    Unit = dataset$yUnit
  )

  if (length(dataset$yErrorValues) > 0) {
    error_type <- dataset$yErrorType %||% "ArithmeticStdDev"
    related_data_info <- list(
      Origin = "ObservationAuxiliary",
      AuxiliaryType = error_type
    )
    if (!is.null(dataset$molWeight) && !is.na(dataset$molWeight)) {
      related_data_info$MolWeight <- dataset$molWeight
    }
    column$RelatedColumns <- list(list(
      Name = "Var",
      QuantityInfo = list(
        Path = paste0(base_path, "|", error_type)
      ),
      DataInfo = related_data_info,
      Values = values_as_list(dataset$yErrorValues),
      Dimension = dataset$yDimension,
      Unit = dataset$yErrorUnit %||% dataset$yUnit
    ))
  }

  extended_properties <- list()
  meta <- dataset$metaData
  if (length(meta) > 0) {
    extended_properties <- lapply(names(meta), function(k) {
      list(Name = k, Value = as.character(meta[[k]]), Type = "String")
    })
  }

  list(
    Name = dataset$name,
    ExtendedProperties = extended_properties,
    Columns = list(column),
    BaseGrid = base_grid
  )
}

# Export adapter for the ObservedData section of a Snapshot.
#
# Entries that are still present in the raw JSON slice (matched by name) are
# replayed byte-for-byte from `.original_data`, so post-load mutations to a
# loaded `DataSet` (e.g. `dataset$xUnit <- "min"`) are NOT reflected on
# export. Entries added at runtime via `add_observed_data()` are serialized
# through `.dataset_to_snapshot_list()`; that path is lossy (see the comment
# on the helper) but round-trips through `osp.snapshots` itself.
#
# Contract:
#   items     cache slot value: `NULL` (untouched), `list()` (cleared by
#             user), or a non-empty list of `DataSet` objects.
#   original  the raw `ObservedData` slice from `.original_data` (may be NULL).
# Returns the value to write back into the export payload.
.observed_data_export_adapter <- function(items, original) {
  if (is.null(items)) {
    return(original)
  }
  if (length(items) == 0) {
    return(NULL)
  }
  original_names <- if (length(original) == 0) {
    character()
  } else {
    vapply(
      original,
      function(od) od$Name %||% od$name,
      character(1)
    )
  }
  lapply(items, function(item) {
    idx <- match(item$name, original_names)
    if (!is.na(idx)) {
      original[[idx]]
    } else {
      .dataset_to_snapshot_list(item)
    }
  })
}
