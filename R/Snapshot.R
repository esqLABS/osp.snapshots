#' Snapshot class for OSP snapshots
#'
#' @description
#' An R6 class that represents an OSP snapshot file. This class provides
#' methods to access different components of the snapshot and visualize its structure.
#'
#' @export
Snapshot <- R6::R6Class(
  classname = "Snapshot",
  
  public = list(
    #' @field data The raw data of the snapshot
    data = NULL,
    
    #' @field path The path to the snapshot file
    path = NULL,
    
    #' @description
    #' Create a new Snapshot object from a JSON file
    #' @param path Path to the snapshot JSON file
    #' @return A new Snapshot object
    initialize = function(path) {
      cli::cli_alert_info("Reading snapshot from {.file {path}}")
      self$path <- path
      self$data <- jsonlite::fromJSON(txt = path, simplifyDataFrame = FALSE)
      cli::cli_alert_success("Snapshot loaded successfully")
    },
    
    #' @description
    #' Print a summary of the snapshot
    #' @param ... Additional arguments passed to print methods
    #' @return Invisibly returns the object
    print = function(...) {
      cli::cli_h1("PKSIM Snapshot")
      
      # Version information
      raw_version <- self$data$Version
      pksim_version <- self$pksim_version
      cli::cli_alert_info("Version: {raw_version} (PKSIM {pksim_version})")
      
      # Define all possible sections
      sections <- c(
        "Compounds", 
        "Events", 
        "ExpressionProfiles", 
        "Formulations", 
        "Individuals", 
        "ObservedData", 
        "ObservedDataClassifications", 
        "ObserverSets", 
        "ParameterIdentification", 
        "Populations", 
        "Protocols", 
        "Simulations"
      )
      
      # Filter only sections that exist in the data
      existing_sections <- sections[sections %in% names(self$data)]
      
      # Display sections in alphabetical order
      for (section in sort(existing_sections)) {
        items <- self$data[[section]]
        count <- length(items)
        
        if (count > 0) {
          cli::cli_h2("{section}: {count}")
          
          # Display limited number of items
          max_display <- min(count, 5)
          for (i in 1:max_display) {
            if (!is.null(items[[i]]$Name)) {
              cli::cli_li("{items[[i]]$Name}")
            } else {
              item_type <- if (!is.null(items[[i]]$Type)) items[[i]]$Type else ""
              item_molecule <- if (!is.null(items[[i]]$Molecule)) items[[i]]$Molecule else ""
              item_desc <- paste(item_type, item_molecule, sep = " ")
              item_desc <- gsub("^\\s+|\\s+$", "", item_desc)  # Trim whitespace
              
              if (item_desc == "") {
                cli::cli_li("Item {i}")
              } else {
                cli::cli_li("{item_desc}")
              }
            }
          }
          
          # Show ellipsis if there are more items
          if (count > max_display) {
            cli::cli_li("... and {count - max_display} more")
          }
          
          cli::cli_end()
        }
      }
      
      # Return the object invisibly
      invisible(self)
    },
    #' @description
    #' Export the snapshot to a JSON file
    #' @param path Path to save the JSON file
    #' @return Invisibly returns the object
    export = function(path) {
      jsonlite::write_json(self$data, path, auto_unbox = TRUE, pretty = TRUE, digits = NA)
      cli::cli_alert_success("Snapshot exported to {.file {path}}")
      invisible(self)
    }
  ),
  
  active = list(
    #' @field pksim_version The human-readable PKSIM version corresponding to the snapshot version
    pksim_version = function() {
      private$.get_pksim_version()
    }
  ),
  
  private = list(
    #' @description
    #' Convert the raw version number to a human-readable PKSIM version
    #' @return A string with the human-readable PKSIM version
    #' @noRd
    .get_pksim_version = function() {
      version_num <- as.integer(self$data$Version)
      
      pksim_version <- switch(as.character(version_num),
                             "80" = "12.0",
                             "79" = "11.2",
                             "78" = "10.0",
                             "77" = "9.1",
                             "Unknown")
      
      return(pksim_version)
    }
  )
) 