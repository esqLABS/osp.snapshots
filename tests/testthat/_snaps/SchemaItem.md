# SchemaItem$data is read-only

    Code
      item$data <- list()
    Condition
      Error:
      ! data is read-only

# SchemaItem prints a summary

    Code
      print(item)
    Output
      
      -- SchemaItem: Schema Item 1 --
      
      * Application type: Oral
      * Formulation key: Tablet
      * Parameters:
        * InputDose: 15 mg

