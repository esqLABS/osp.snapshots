# Create a new compound

Create a minimally populated
[Compound](https://esqlabs.github.io/osp.snapshots/reference/Compound.md)
building block from named arguments. This is a thin factory around
`Compound$new()` that builds the raw list shape for you.

For richer compound structures (full lipophilicity alternatives,
processes, calculation methods, and so on), build the raw list directly
or load a template snapshot and mutate it.

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
  parameters = NULL
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
  [Parameter](https://esqlabs.github.io/osp.snapshots/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/reference/create_parameter.md))
  or raw parameter lists to attach to the compound.

## Value

A
[Compound](https://esqlabs.github.io/osp.snapshots/reference/Compound.md)
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

# Create a compound with additional parameters
compound <- create_compound(
  name = "Drug X",
  parameters = list(
    create_parameter(name = "Cl_spec", value = 5, unit = "ml/min/kg")
  )
)
```
