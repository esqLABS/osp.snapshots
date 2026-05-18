# create_compound validates required arguments

    Code
      create_compound()
    Condition
      Error in `create_compound()`:
      ! `name` must be a non-empty string

---

    Code
      create_compound(name = "")
    Condition
      Error in `create_compound()`:
      ! `name` must be a non-empty string

---

    Code
      create_compound(name = "Drug", is_small_molecule = "yes")
    Condition
      Error in `create_compound()`:
      ! `is_small_molecule` must be a logical value

---

    Code
      create_compound(name = "Drug", molecular_weight = "heavy")
    Condition
      Error in `create_compound()`:
      ! `molecular_weight` must be a numeric value

---

    Code
      create_compound(name = "Drug", parameters = "not a list")
    Condition
      Error in `create_compound()`:
      ! `parameters` must be a list

---

    Code
      create_compound(name = "Drug", molecular_weight = 250, molecular_weight_unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Molecular weight are: kg/µmol, kg/mol, kDa, g/mol

