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

# solubility() rejects both scalar and table forms

    Code
      solubility(1, table = data.frame(pH = 3, value = 5000))
    Condition
      Error in `solubility()`:
      ! Solubility is set either by a single value or by a table, not both.
      i Supply the scalar form (`value`, `reference_pH`, `gain_per_charge`) or `table`, not both.

# create_compound aborts when two or more alternatives are marked default

    Code
      create_compound(name = "X", solubility = list(solubility(9999, name = "Aqueous",
        default = TRUE), solubility(200, name = "FaSSIF", default = TRUE)))
    Condition
      Error in `create_compound()`:
      ! `solubility` has 2 alternatives marked `default = TRUE`.
      i Exactly one alternative may be the default; mark only one with `default = TRUE`.

---

    Code
      create_compound(name = "X", lipophilicity = list(lipophilicity(2.5, name = "Measured",
        default = TRUE), lipophilicity(3.1, name = "Predicted", default = TRUE)))
    Condition
      Error in `create_compound()`:
      ! `lipophilicity` has 2 alternatives marked `default = TRUE`.
      i Exactly one alternative may be the default; mark only one with `default = TRUE`.

# create_compound rejects a list containing a non-matching helper or a bare scalar

    Code
      create_compound(name = "X", solubility = list(solubility(9999), lipophilicity(
        2.5)))
    Condition
      Error in `create_compound()`:
      ! Element 2 of `solubility` was built with the wrong helper.
      i Use `solubility()` for `solubility`, e.g. `solubility = solubility(9999)`.

---

    Code
      create_compound(name = "X", solubility = list(solubility(9999), 200))
    Condition
      Error in `create_compound()`:
      ! Element 2 of `solubility` must be built with `solubility()`.
      i For example `solubility = solubility(9999)`.

# create_compound rejects duplicate alternative names within one property

    Code
      create_compound(name = "X", solubility = list(solubility(9999), solubility(200)))
    Condition
      Error in `create_compound()`:
      ! `solubility` has duplicate alternative names: "User defined".
      i Give each alternative in the list a distinct name.

---

    Code
      create_compound(name = "X", solubility = list(solubility(9999, name = "Aqueous"),
      solubility(200, name = "Aqueous")))
    Condition
      Error in `create_compound()`:
      ! `solubility` has duplicate alternative names: "Aqueous".
      i Give each alternative in the list a distinct name.

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

# physicochemical helpers reject non-numeric values

    Code
      lipophilicity("a")
    Condition
      Error in `lipophilicity()`:
      ! `value` must be a numeric value

---

    Code
      fraction_unbound("a")
    Condition
      Error in `fraction_unbound()`:
      ! `value` must be a numeric value

---

    Code
      fraction_unbound(1, species = "Klingon")
    Condition
      Error in `validate_species()`:
      ! Invalid species: Klingon
      i Valid species are: Beagle, Dog, Human, Minipig, Monkey, Mouse, Rabbit, Rat

---

    Code
      solubility("a")
    Condition
      Error in `solubility()`:
      ! `value` must be a numeric value

---

    Code
      solubility(9999, reference_pH = "a")
    Condition
      Error in `solubility()`:
      ! `reference_pH` must be a numeric value

---

    Code
      solubility(9999, gain_per_charge = "a")
    Condition
      Error in `solubility()`:
      ! `gain_per_charge` must be a numeric value

---

    Code
      intestinal_permeability("a")
    Condition
      Error in `intestinal_permeability()`:
      ! `value` must be a numeric value

---

    Code
      permeability("a")
    Condition
      Error in `permeability()`:
      ! `value` must be a numeric value

# create_compound rejects a plain scalar or the wrong helper

    Code
      create_compound(name = "X", lipophilicity = 2.5)
    Condition
      Error in `create_compound()`:
      ! `lipophilicity` must be built with `lipophilicity()`.
      i For example `lipophilicity = lipophilicity(2.5)`.

---

    Code
      create_compound(name = "X", lipophilicity = weight(70))
    Condition
      Error in `create_compound()`:
      ! `lipophilicity` was built with the wrong helper.
      i Use `lipophilicity()` for `lipophilicity`, e.g. `lipophilicity = lipophilicity(2.5)`.

# create_compound rejects a non-list processes argument

    Code
      create_compound(name = "X", processes = "not a list")
    Condition
      Error in `create_compound()`:
      ! `processes` must be a list

# solubility() rejects a malformed table

    Code
      solubility(table = c(3, 6))
    Condition
      Error in `solubility()`:
      ! `table` must be a data frame with two columns (pH, value)

# solubility() rejects an empty or non-numeric table

    Code
      solubility(table = data.frame(pH = numeric(0), value = numeric(0)))
    Condition
      Error in `solubility()`:
      ! `table` must have at least one row with numeric pH and value columns

---

    Code
      solubility(table = data.frame(pH = c(3, 6), value = c("a", "b")))
    Condition
      Error in `solubility()`:
      ! `table` must have at least one row with numeric pH and value columns

# physicochemical helpers validate units

    Code
      lipophilicity(2.5, unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Log Units are: Log Units

---

    Code
      solubility(1, unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Concentration (mass) are: g/l, mg/l, µg/l, ng/l, pg/l, mg/dl, mg/ml, µg/ml, ng/ml, pg/ml, kg/l

---

    Code
      intestinal_permeability(1, unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Velocity are: cm/min, cm/s, dm/min

---

    Code
      permeability(1, unit = "nope")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: nope
      i Valid units for Velocity are: cm/min, cm/s, dm/min

# create_compound validates plasma_protein_binding_partner against the enum

    Code
      create_compound(name = "X", plasma_protein_binding_partner = "Casein")
    Condition
      Error in `create_compound()`:
      ! `plasma_protein_binding_partner` must be one of "Unknown", "Albumin", and "Glycoprotein"

