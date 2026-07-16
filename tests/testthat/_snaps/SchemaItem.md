# SchemaItem$name requires a non-empty scalar string

    Code
      item$name <- ""
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      item$name <- 5
    Condition
      Error:
      ! `name` must be a non-empty string

# SchemaItem$application_type is validated against the enum

    Code
      item$application_type <- "nonsense"
    Condition
      Error:
      ! `application_type` must be one of the canonical PK-Sim application types.
      x Got "nonsense".
      i Valid values: "Oral", "Intravenous", "IntravenousBolus", and "UserDefined".

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

