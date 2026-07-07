# Observer type setter validates against Amount/Container

    Code
      observer$type <- "Bogus"
    Condition
      Error:
      ! `type` must be one of "Amount" and "Container"

# Observer formula_references setter aborts on non-list input

    Code
      observer$formula_references <- "x"
    Condition
      Error:
      ! `formula_references` must be a list

# Observer container_tags is read-only

    Code
      observer$container_tags <- "x"
    Condition
      Error:
      ! container_tags is read-only

# Observer container_criteria setter aborts on non-list input

    Code
      observer$container_criteria <- "x"
    Condition
      Error:
      ! `container_criteria` must be a list

# Observer molecule_list setter aborts on non-list input

    Code
      observer$molecule_list <- "x"
    Condition
      Error:
      ! `molecule_list` must be a list

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

