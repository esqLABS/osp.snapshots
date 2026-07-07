# create_expression_profile validates expression and disease

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", expression = data.frame(value = 1))
    Condition
      Error in `create_expression_profile()`:
      ! `expression` data frame must have a name column

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", expression = data.frame(name = c("Liver", NA), value = c(1,
          2)))
    Condition
      Error in `create_expression_profile()`:
      ! Every name in `expression` must be a non-empty string

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", expression = "Liver")
    Condition
      Error in `create_expression_profile()`:
      ! `expression` must be a data frame or a list

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", disease = list(parameters = list()))
    Condition
      Error in `create_expression_profile()`:
      ! `disease` must be a named list with a non-empty name

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

