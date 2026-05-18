# Observer container_path is read-only

    Code
      observer$container_path <- "x"
    Condition
      Error:
      ! container_path is read-only

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
      * Formula: Conc_Br
      * Container path: Brain

