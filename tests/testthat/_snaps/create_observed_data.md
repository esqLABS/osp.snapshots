# create_observed_data validates required arguments

    Code
      create_observed_data()
    Condition
      Error in `create_observed_data()`:
      ! `name` must be a non-empty string

---

    Code
      create_observed_data(name = "X", time = numeric(), values = numeric())
    Condition
      Error in `create_observed_data()`:
      ! `time` must be a non-empty numeric vector

---

    Code
      create_observed_data(name = "X", time = 1:5, values = 1:4)
    Condition
      Error in `create_observed_data()`:
      ! `time` and `values` must have the same length, got 5 and 4

---

    Code
      create_observed_data(name = "X", time = 1:3, values = 1:3, error = 1:2)
    Condition
      Error in `create_observed_data()`:
      ! `error` must be a numeric vector of the same length as `values`

---

    Code
      create_observed_data(name = "X", time = 1:3, values = 1:3, metadata = list(
        "missing-key"))
    Condition
      Error in `create_observed_data()`:
      ! `metadata` must be a named list

