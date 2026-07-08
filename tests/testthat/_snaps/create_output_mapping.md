# create_output_mapping validates argument types

    Code
      create_output_mapping(weight = "x")
    Condition
      Error in `create_output_mapping()`:
      ! `weight` must be a single numeric value

---

    Code
      create_output_mapping(weights = "x")
    Condition
      Error in `create_output_mapping()`:
      ! `weights` must be a numeric vector

# create_output_mapping validates scaling against the enum

    Code
      create_output_mapping(scaling = "Sqrt")
    Condition
      Error in `create_output_mapping()`:
      ! `scaling` must be one of "Linear" and "Log"

