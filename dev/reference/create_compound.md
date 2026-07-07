# Create a new compound

Create a
[Compound](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
building block from named arguments. This is a thin factory around
`Compound$new()` that builds the raw list shape for you, including the
physicochemical properties, pKa, and processes.

Each of lipophilicity, fraction unbound, solubility (including reference
pH, gain per charge, and table solubility), intestinal permeability,
permeability, and pKa must be set through its dedicated argument (or by
mutating the matching writable
[Compound](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
field). The `parameters` argument is for additional/loose compound
parameters only; it cannot set these physicochemical properties, because
each lives in its own top-level alternative array or typed list rather
than in `Parameters`.

## Usage

``` r
create_compound(
  name,
  description = NULL,
  is_small_molecule = NULL,
  plasma_protein_binding_partner = NULL,
  molecular_weight = NULL,
  molecular_weight_unit = "g/mol",
  calculation_methods = NULL,
  parameters = NULL,
  lipophilicity = NULL,
  lipophilicity_unit = "Log Units",
  lipophilicity_name = "User defined",
  fraction_unbound = NULL,
  fraction_unbound_name = "User defined",
  solubility = NULL,
  solubility_unit = "mg/l",
  reference_pH = NULL,
  solubility_gain_per_charge = NULL,
  solubility_table = NULL,
  solubility_name = "User defined",
  intestinal_permeability = NULL,
  intestinal_permeability_unit = "cm/min",
  intestinal_permeability_name = "User defined",
  permeability = NULL,
  permeability_unit = "cm/min",
  permeability_name = "User defined",
  pKa = NULL,
  processes = NULL
)
```

## Arguments

- name:

  Character. Name of the compound (required).

- description:

  Character. Free-text description of the compound.

- is_small_molecule:

  Logical. Whether the compound is a small molecule. Defaults to `TRUE`
  in PK-Sim when omitted.

- plasma_protein_binding_partner:

  Character. Name of the plasma protein binding partner (for example
  `"Albumin"`).

- molecular_weight:

  Numeric. Molecular weight value.

- molecular_weight_unit:

  Character. Unit for molecular weight. Defaults to `"g/mol"`.

- calculation_methods:

  Character vector. Calculation method names that PK-Sim uses to derive
  compound quantities.

- parameters:

  List of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md))
  or raw parameter lists to attach as additional compound parameters.
  This does not set physicochemical properties; use the dedicated
  arguments below for those.

- lipophilicity:

  Numeric scalar. Lipophilicity value. When supplied, one default
  `Lipophilicity` alternative is created.

- lipophilicity_unit:

  Character. Unit for the lipophilicity parameter, validated against
  dimension `"Log Units"`. Defaults to `"Log Units"`.

- lipophilicity_name:

  Character. `Name` of the created lipophilicity alternative. Defaults
  to `"User defined"`.

- fraction_unbound:

  Numeric scalar. Fraction unbound value. When supplied, one default
  `FractionUnbound` alternative is created. The fraction-unbound
  parameter carries no unit.

- fraction_unbound_name:

  Character. `Name` of the created fraction-unbound alternative.
  Defaults to `"User defined"`.

- solubility:

  Numeric scalar. Solubility-at-reference-pH value. When supplied, one
  scalar-based `Solubility` alternative is created. Mutually exclusive
  with `solubility_table`.

- solubility_unit:

  Character. Unit for the solubility parameter, validated against
  dimension `"Concentration (mass)"`. Reused as the table Y unit.
  Defaults to `"mg/l"`.

- reference_pH:

  Numeric scalar. Reference pH added to the same scalar `Solubility`
  alternative as `solubility`. Not a standalone property: it is ignored
  unless `solubility` is supplied, and it does not apply to the table
  path.

- solubility_gain_per_charge:

  Numeric scalar. Optional `Solubility gain per charge` parameter added
  to the same scalar `Solubility` alternative as `solubility`. Not a
  standalone property: it is ignored unless `solubility` is supplied.

- solubility_table:

  Two-column data frame giving table-based solubility: the first column
  is pH and the second is the solubility value. When supplied, one
  `Solubility` alternative with a `Solubility table` parameter carrying
  a `TableFormula` is created instead of a scalar solubility. Mutually
  exclusive with `solubility`. Note: on import PK-Sim runs a
  table-solubility preparation step that this package does not perform;
  the package emits the faithful raw `Solubility table` + `TableFormula`
  shape that round-trips through load/export at the JSON level.

- solubility_name:

  Character. `Name` of the created solubility alternative (scalar or
  table). Defaults to `"User defined"`.

- intestinal_permeability:

  Numeric scalar. Intestinal permeability value. When supplied, one
  default `IntestinalPermeability` alternative is created.

- intestinal_permeability_unit:

  Character. Unit for the intestinal-permeability parameter, validated
  against dimension `"Velocity"`. Defaults to `"cm/min"`.

- intestinal_permeability_name:

  Character. `Name` of the created intestinal-permeability alternative.
  Defaults to `"User defined"`.

- permeability:

  Numeric scalar. Permeability value. When supplied, one default
  `Permeability` alternative is created.

- permeability_unit:

  Character. Unit for the permeability parameter, validated against
  dimension `"Velocity"`. Defaults to `"cm/min"`.

- permeability_name:

  Character. `Name` of the created permeability alternative. Defaults to
  `"User defined"`.

- pKa:

  List of typed pKa entries, each a list with a `type` (one of `"Acid"`,
  `"Base"`, `"Neutral"`) and a numeric `value`, for example
  `list(list(type = "Base", value = 10.02))`. Order is preserved. Both
  `NULL` (the default) and an empty
  [`list()`](https://rdrr.io/r/base/list.html) leave the created
  compound with no pKa types set. (The clearing semantics, where an
  empty [`list()`](https://rdrr.io/r/base/list.html) removes existing
  values, apply to the writable `Compound$pka_types` field, not to
  construction.)

- processes:

  List of
  [Process](https://esqlabs.github.io/osp.snapshots/dev/reference/Process.md)
  objects (created with
  [`create_process()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_process.md))
  or raw process lists to attach to the compound.

## Value

A
[Compound](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
object.

## Examples

``` r
# Create a minimal compound
compound <- create_compound(name = "Drug X")

# Create a small molecule with molecular weight and binding partner
compound <- create_compound(
  name = "Drug X",
  is_small_molecule = TRUE,
  molecular_weight = 250.3,
  plasma_protein_binding_partner = "Albumin"
)

# Set the single-parameter physicochemical properties
compound <- create_compound(
  name = "Drug X",
  lipophilicity = 2.5,
  fraction_unbound = 0.1,
  intestinal_permeability = 1.14e-05,
  permeability = 0.0069
)

# Solubility with reference pH and gain per charge
compound <- create_compound(
  name = "Drug X",
  solubility = 9999,
  reference_pH = 7,
  solubility_gain_per_charge = 1000
)

# Table-based solubility (first column pH, second column value)
compound <- create_compound(
  name = "Drug X",
  solubility_table = data.frame(
    pH = c(3, 6, 6.8),
    value = c(5000, 3000, 90)
  )
)

# Multiple pKa entries
compound <- create_compound(
  name = "Drug X",
  pKa = list(
    list(type = "Base", value = 10.02),
    list(type = "Acid", value = 1.7)
  )
)

# Attach a process
compound <- create_compound(
  name = "Drug X",
  processes = list(
    create_process(
      internal_name = "GlomerularFiltration",
      data_source = "Publication X"
    )
  )
)

# Additional/loose parameters (not physicochemical properties)
compound <- create_compound(
  name = "Drug X",
  parameters = list(
    create_parameter(name = "Cl_spec", value = 5, unit = "ml/min/kg")
  )
)
```
