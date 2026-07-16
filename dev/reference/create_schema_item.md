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
  parameters = NULL,
  dose = NULL,
  dose_unit = "mg",
  start_time = NULL,
  start_time_unit = "h"
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
  (dose, start time, ...). The promoted `dose` and `start_time`
  arguments flow into the same `"InputDose"` and `"Start time"`
  parameters, so supplying a setting both as a promoted argument and as
  the matching `parameters` entry is an error.

- dose:

  Numeric scalar dose for the application, written as a single
  `InputDose` parameter. `NULL` (default) emits no dose parameter. The
  dose family (plain dose, per body weight, or per body surface area) is
  selected by `dose_unit`.

- dose_unit:

  Character. Unit for `dose`, default `"mg"`. Must be a dose-family unit
  (a Mass, Amount, dose-per-body-weight, or dose-per-body-surface-area
  unit, for example `"mg"`, `"mg/kg"`, or `"mg/m²"`). Consulted only
  when `dose` is supplied.

- start_time:

  Numeric scalar application start time, written as a `"Start time"`
  parameter. `NULL` (default) emits no start-time parameter. Zero and
  negative values are allowed.

- start_time_unit:

  Character. Unit for `start_time`, default `"h"`, validated against the
  `"Time"` dimension. Consulted only when `start_time` is supplied.

## Value

A
[SchemaItem](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
object.

## Examples

``` r
# An oral schema item using the promoted dose and start-time arguments
item <- create_schema_item(
  name = "Item 1",
  application_type = "Oral",
  dose = 10,
  dose_unit = "mg",
  start_time = 0
)

# The same, authored through the free-form `parameters` escape hatch
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
  dose = 5
)
```
