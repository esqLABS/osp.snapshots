# Create a new schema item

Create a
[SchemaItem](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
for an Advanced
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
from named arguments. This is a thin factory around `SchemaItem$new()`
that builds the raw list shape for you.

A schema item is one application inside a
[Schema](https://esqlabs.github.io/osp.snapshots/dev/reference/Schema.md)
of an Advanced Protocol. It carries an application type, an optional
formulation key, target organ and compartment, and the application-level
parameters (dose, start time, ...).

## Usage

``` r
create_schema_item(
  name,
  application_type,
  formulation_key = NULL,
  target_organ = NULL,
  target_compartment = NULL,
  parameters = NULL
)
```

## Arguments

- name:

  Character. Name of the schema item (required).

- application_type:

  Character. Application type for the schema item (required). Must be
  one of the canonical PK-Sim application types: `"Oral"`,
  `"IntravenousBolus"`, `"IntravenousInfusion"`, `"Intramuscular"`,
  `"Subcutaneous"`, `"Dermal"`, `"Rectal"`, `"Inhalation"`, or
  `"Intraperitoneal"`.

- formulation_key:

  Character. Formulation key linking the schema item to a formulation
  selection in the owning simulation.

- target_organ:

  Character. Target organ for the application.

- target_compartment:

  Character. Target compartment for the application.

- parameters:

  List of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md))
  or raw parameter lists. These become the application-level parameters
  (dose, start time, ...).

## Value

A
[SchemaItem](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
object.

## Examples

``` r
# An oral schema item with one dose
item <- create_schema_item(
  name = "Item 1",
  application_type = "Oral",
  parameters = list(
    create_parameter(name = "Start time", value = 0, unit = "h"),
    create_parameter(name = "InputDose", value = 10, unit = "mg")
  )
)

# An intravenous bolus schema item targeting the venous blood
item <- create_schema_item(
  name = "IV bolus",
  application_type = "IntravenousBolus",
  target_organ = "VenousBlood",
  target_compartment = "Plasma",
  parameters = list(
    create_parameter(name = "InputDose", value = 5, unit = "mg")
  )
)
```
