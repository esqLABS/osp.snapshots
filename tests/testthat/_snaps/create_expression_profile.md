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

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", disease = "CKD")
    Condition
      Error in `create_expression_profile()`:
      ! `disease` must be a named list with a non-empty name

# create_expression_profile rejects an invalid promoted unit

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = 1, reference_concentration_unit = "umol/l")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: umol/l
      i Valid units for Concentration (molar) are: mol/l, mmol/l, µmol/l, nmol/l, pmol/l, fmol/l, M, mM, µM, nM, pM, fM, mol/ml, mmol/ml, µmol/ml, nmol/ml, pmol/ml, fmol/ml

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", half_life_liver = 1, half_life_liver_unit = "bogus")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: bogus
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

# create_expression_profile rejects an invalid promoted value

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = NA)
    Condition
      Error in `create_expression_profile()`:
      ! `reference_concentration` must be a single finite numeric value

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = "x")
    Condition
      Error in `create_expression_profile()`:
      ! `reference_concentration` must be a single finite numeric value

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = c(1, 2))
    Condition
      Error in `create_expression_profile()`:
      ! `reference_concentration` must be a single finite numeric value

---

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = Inf)
    Condition
      Error in `create_expression_profile()`:
      ! `reference_concentration` must be a single finite numeric value

# create_expression_profile rejects a Path conflict

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = 4.32, parameters = list(
          create_parameter(path = "CYP3A4|Reference concentration", value = 4.32,
            unit = "µmol/l")))
    Condition
      Error in `create_expression_profile()`:
      ! Promoted argument conflict with `parameters` entry.
      x `reference_concentration` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_expression_profile rejects a Name-only conflict

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = 4.32, parameters = list(
          create_parameter(name = "CYP3A4|Reference concentration", value = 4.32,
            unit = "µmol/l")))
    Condition
      Error in `create_expression_profile()`:
      ! Promoted argument conflict with `parameters` entry.
      x `reference_concentration` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_expression_profile reports all conflicting promoted arguments at once

    Code
      create_expression_profile(molecule = "CYP3A4", species = "Human", category = "Healthy",
        type = "Enzyme", reference_concentration = 4.32, half_life_liver = 36,
        half_life_intestine = 24, parameters = list(create_parameter(path = "CYP3A4|Reference concentration",
          value = 4.32, unit = "µmol/l"), create_parameter(path = "CYP3A4|t1/2 (liver)",
          value = 36, unit = "h"), create_parameter(path = "CYP3A4|t1/2 (intestine)",
          value = 24, unit = "h")))
    Condition
      Error in `create_expression_profile()`:
      ! Promoted arguments conflict with `parameters` entries.
      x `reference_concentration`, `half_life_liver`, and `half_life_intestine` are also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

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

