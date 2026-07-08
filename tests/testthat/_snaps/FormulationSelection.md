# FormulationSelection$data is read-only

    Code
      sel$data <- list()
    Condition
      Error:
      ! data is read-only

# FormulationSelection$name and $key require non-empty scalar strings

    Code
      sel$name <- ""
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      sel$name <- 5
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      sel$key <- ""
    Condition
      Error:
      ! `key` must be a non-empty string

---

    Code
      sel$key <- 5
    Condition
      Error:
      ! `key` must be a non-empty string

