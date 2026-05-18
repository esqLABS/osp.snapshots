# create_expression_profile validates required arguments

    Code
      create_expression_profile()
    Condition
      Error in `create_expression_profile()`:
      ! `molecule` must be a non-empty string

---

    Code
      create_expression_profile(molecule = "CYP3A4")
    Condition
      Error in `create_expression_profile()`:
      ! `species` must be a non-empty string

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", ontogeny = 1)
    Condition
      Error in `create_expression_profile()`:
      ! `ontogeny` must be a scalar character or a list

