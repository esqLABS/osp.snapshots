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

