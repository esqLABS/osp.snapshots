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

# create_compound rejects both scalar and table solubility

    Code
      create_compound(name = "X", solubility = 1, solubility_table = data.frame(pH = 3,
        value = 5000))
    Condition
      Error in `create_compound()`:
      ! Solubility is set either by a single value or by a table, not both.
      i Supply `solubility` or `solubility_table`, not both.

# create_compound rejects invalid pKa entries

    Code
      create_compound(name = "X", pKa = list(list(type = "Weak", value = 1)))
    Condition
      Error in `create_compound()`:
      ! Entry 1 of `pKa` has an invalid type.
      i type must be one of "Acid", "Base", and "Neutral".

---

    Code
      create_compound(name = "X", pKa = list(list(type = "Base", value = "big")))
    Condition
      Error in `create_compound()`:
      ! Entry 1 of `pKa` must have a numeric value

# create_compound rejects non-numeric property values

    Code
      create_compound(name = "X", lipophilicity = "a")
    Condition
      Error in `create_compound()`:
      ! `lipophilicity` must be a numeric value

---

    Code
      create_compound(name = "X", fraction_unbound = "a")
    Condition
      Error in `create_compound()`:
      ! `fraction_unbound` must be a numeric value

---

    Code
      create_compound(name = "X", solubility = "a")
    Condition
      Error in `create_compound()`:
      ! `solubility` must be a numeric value

---

    Code
      create_compound(name = "X", reference_pH = "a")
    Condition
      Error in `create_compound()`:
      ! `reference_pH` must be a numeric value

---

    Code
      create_compound(name = "X", solubility_gain_per_charge = "a")
    Condition
      Error in `create_compound()`:
      ! `solubility_gain_per_charge` must be a numeric value

---

    Code
      create_compound(name = "X", intestinal_permeability = "a")
    Condition
      Error in `create_compound()`:
      ! `intestinal_permeability` must be a numeric value

---

    Code
      create_compound(name = "X", permeability = "a")
    Condition
      Error in `create_compound()`:
      ! `permeability` must be a numeric value

# create_compound rejects a non-list processes argument

    Code
      create_compound(name = "X", processes = "not a list")
    Condition
      Error in `create_compound()`:
      ! `processes` must be a list

# create_compound rejects a malformed solubility table

    Code
      create_compound(name = "X", solubility_table = c(3, 6))
    Condition
      Error in `create_compound()`:
      ! `solubility_table` must be a data frame with two columns (pH, value)

# create_compound rejects an empty or non-numeric solubility table

    Code
      create_compound(name = "X", solubility_table = data.frame(pH = numeric(0),
      value = numeric(0)))
    Condition
      Error in `create_compound()`:
      ! `solubility_table` must have at least one row with numeric pH and value columns

---

    Code
      create_compound(name = "X", solubility_table = data.frame(pH = c(3, 6), value = c(
        "a", "b")))
    Condition
      Error in `create_compound()`:
      ! `solubility_table` must have at least one row with numeric pH and value columns

# create_compound validates property units

    Code
      create_compound(name = "X", lipophilicity = 2.5, lipophilicity_unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Log Units are: Log Units

---

    Code
      create_compound(name = "X", solubility = 1, solubility_unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Concentration (mass) are: g/l, mg/l, µg/l, ng/l, pg/l, mg/dl, mg/ml, µg/ml, ng/ml, pg/ml, kg/l

---

    Code
      create_compound(name = "X", intestinal_permeability = 1,
        intestinal_permeability_unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Velocity are: cm/min, cm/s, dm/min

---

    Code
      create_compound(name = "X", permeability = 1, permeability_unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Velocity are: cm/min, cm/s, dm/min

