# validate_species rejects a non-scalar or empty species with a clear message

    Code
      validate_species(c("Human", "Dog"))
    Condition
      Error in `validate_species()`:
      ! `species` must be a single, non-missing value

---

    Code
      validate_species(character(0))
    Condition
      Error in `validate_species()`:
      ! `species` must be a single, non-missing value

---

    Code
      validate_species(NA_character_)
    Condition
      Error in `validate_species()`:
      ! `species` must be a single, non-missing value

