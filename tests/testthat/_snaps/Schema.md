# Schema rejects non-SchemaItem entries in items

    Code
      schema$items <- list("not a schema item")
    Condition
      Error:
      ! Every entry of items must be a <SchemaItem>

# Schema$data is read-only

    Code
      schema$data <- list()
    Condition
      Error:
      ! data is read-only

# Schema$name requires a non-empty scalar string

    Code
      schema$name <- ""
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      schema$name <- 5
    Condition
      Error:
      ! `name` must be a non-empty string

# Schema$parameters requires a list

    Code
      schema$parameters <- 5
    Condition
      Error:
      ! `parameters` must be a list

---

    Code
      schema$parameters <- "x"
    Condition
      Error:
      ! `parameters` must be a list

# Schema prints a summary

    Code
      print(schema)
    Output
      
      -- Schema: Schema 1 --
      
      * Parameters:
        * NumberOfRepetitions: 3
      * Schema items (1):
        * Schema Item 1: Oral

