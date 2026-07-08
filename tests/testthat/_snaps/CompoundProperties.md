# CompoundProperties$name requires a non-empty scalar string

    Code
      props$name <- ""
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      props$name <- 5
    Condition
      Error:
      ! `name` must be a non-empty string

# CompoundProperties$calculation_methods requires a character vector

    Code
      props$calculation_methods <- 5
    Condition
      Error:
      ! `calculation_methods` must be a character vector

