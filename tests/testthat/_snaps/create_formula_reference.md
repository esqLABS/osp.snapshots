# create_formula_reference aborts on missing alias or path

    Code
      create_formula_reference(path = "p")
    Condition
      Error in `create_formula_reference()`:
      ! `alias` must be a non-empty string

---

    Code
      create_formula_reference("a")
    Condition
      Error in `create_formula_reference()`:
      ! `path` must be a non-empty string

---

    Code
      create_formula_reference("", "p")
    Condition
      Error in `create_formula_reference()`:
      ! `alias` must be a non-empty string

