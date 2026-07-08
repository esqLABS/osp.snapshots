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
  fraction_unbound = NULL,
  solubility = NULL,
  intestinal_permeability = NULL,
  permeability = NULL,
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

  Character. Name of the plasma protein binding partner: one of
  `"Unknown"`, `"Albumin"`, `"Glycoprotein"`.

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

  A
  [`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), or `NULL`. When supplied, one
  `Lipophilicity` alternative is created per element.

- fraction_unbound:

  A
  [`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), or `NULL`. When supplied, one
  `FractionUnbound` alternative is created per element.

- solubility:

  A
  [`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), or `NULL`. Each object expresses
  either the scalar form (value at a reference pH, with optional gain
  per charge) or the table form (a pH/value table); a list may mix both
  forms. When supplied, one `Solubility` alternative is created per
  element. See
  [`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md)
  for the scalar vs table forms and the mutual-exclusivity rule.

- intestinal_permeability:

  An
  [`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), or `NULL`. When supplied, one
  `IntestinalPermeability` alternative is created per element.

- permeability:

  A
  [`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), or `NULL`. When supplied, one
  `Permeability` alternative is created per element.

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

## See also

[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md)
for the physicochemical property helpers.

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
  lipophilicity = lipophilicity(2.5),
  fraction_unbound = fraction_unbound(0.1),
  intestinal_permeability = intestinal_permeability(1.14e-05),
  permeability = permeability(0.0069)
)

# Solubility with reference pH and gain per charge
compound <- create_compound(
  name = "Drug X",
  solubility = solubility(9999, reference_pH = 7, gain_per_charge = 1000)
)

# Table-based solubility (first column pH, second column value)
compound <- create_compound(
  name = "Drug X",
  solubility = solubility(
    table = data.frame(
      pH = c(3, 6, 6.8),
      value = c(5000, 3000, 90)
    )
  )
)

# Several named solubility alternatives (the first is the default)
compound <- create_compound(
  name = "Drug X",
  solubility = list(
    solubility(9999, name = "Aqueous"),
    solubility(200, name = "FaSSIF")
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
