# OutputMapping$path and $observed_data require non-empty strings

    Code
      mapping$path <- ""
    Condition
      Error:
      ! `path` must be a non-empty string

---

    Code
      mapping$path <- 5
    Condition
      Error:
      ! `path` must be a non-empty string

---

    Code
      mapping$observed_data <- ""
    Condition
      Error:
      ! `observed_data` must be a non-empty string

---

    Code
      mapping$observed_data <- 5
    Condition
      Error:
      ! `observed_data` must be a non-empty string

# OutputMapping$scaling is validated against the enum

    Code
      mapping$scaling <- "Sqrt"
    Condition
      Error:
      ! `scaling` must be one of "Linear" and "Log"

# OutputMapping$weight and $weights are type-checked

    Code
      mapping$weight <- c(1, 2)
    Condition
      Error:
      ! `weight` must be a single numeric value

---

    Code
      mapping$weight <- "x"
    Condition
      Error:
      ! `weight` must be a single numeric value

---

    Code
      mapping$weights <- "x"
    Condition
      Error:
      ! `weights` must be a numeric vector

