# EventSelection$name requires a non-empty scalar string

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

