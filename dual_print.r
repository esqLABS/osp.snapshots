library(R6)

# PATTERN: Dual printing behavior for collections vs individual items
# Combines R6 (for objects) with S3 print methods (for collections)

# 1. Define S3 print method for collections
print.collection <- function(x, ...) {
  cat("Collection Summary (", length(x), "items):\n", sep="")
  cat("------------------------------\n")
  
  # Print summarized table view
  if (length(x) > 0) {
    cat(sprintf("%-10s | %s\n", "Name", "Brief Info"))
    cat(sprintf("%-10s-|-%s\n", "----------", "----------"))
    
    for (name in names(x)) {
      item <- x[[name]]
      cat(sprintf("%-10s | %s\n", name, 
                  substr(item$description, 1, 20)))
    }
  } else {
    cat("No items\n")
  }
  
  invisible(x)
}

# 2. Define R6 classes
Parent <- R6Class("Parent",
  private = list(
    .items = list()
  ),
  public = list(
    add_item = function(name, description) {
      private$.items[[name]] <- Child$new(name, description)
      invisible(self)
    }
  ),
  active = list(
    # This is the key element: return a classed list
    items = function() {
      result <- private$.items
      class(result) <- c("collection", "list")
      return(result)
    }
  )
)

Child <- R6Class("Child",
  public = list(
    name = NULL,
    description = NULL,
    
    initialize = function(name, description) {
      self$name <- name
      self$description <- description
    },
    
    # Individual item print method
    print = function() {
      cat("DETAILED VIEW:\n")
      cat("Name:", self$name, "\n")
      cat("Description:", self$description, "\n")
      invisible(self)
    }
  )
)

# Usage example
container <- Parent$new()
container$add_item("item1", "First detailed description")
container$add_item("item2", "Second detailed description")

# Returns collection with table view (uses print.collection)
container$items

# Returns single item with detailed view (uses Child$print)
container$items$item1 
