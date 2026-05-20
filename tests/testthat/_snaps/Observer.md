# Observer formula_references is read-only

    Code
      observer$formula_references <- list()
    Condition
      Error:
      ! formula_references is read-only; assign through formula instead

# Observer container_tags is read-only

    Code
      observer$container_tags <- "x"
    Condition
      Error:
      ! container_tags is read-only

# Observer data is read-only

    Code
      observer$data <- list()
    Condition
      Error:
      ! data is read-only

# print.Observer prints a summary

    Code
      print(observer)
    Output
      
      -- Observer: brain_plasma 
      * Type: Container
      * Dimension: Concentration (molar)
      * Formula expression: Conc_Br
      * Container tags: Brain

