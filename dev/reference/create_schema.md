# Create a new schema

Create a
[Schema](https://esqlabs.github.io/osp.snapshots/dev/reference/Schema.md)
for an Advanced
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
from named arguments. This is a thin factory around `Schema$new()` that
builds the raw list shape for you.

A schema is a repeatable block inside an Advanced
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md):
it has a name, schema-level parameters (typically `NumberOfRepetitions`,
`TimeBetweenRepetitions`, and `Start time`), and an ordered list of
[SchemaItem](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
applications. The three repetition parameters are available as the
plain, unit-aware arguments `number_of_repetitions`,
`time_between_repetitions`, and `start_time`; anything else is supplied
through the `parameters` escape hatch.

## Usage

``` r
create_schema(
  name,
  parameters = NULL,
  items = NULL,
  number_of_repetitions = NULL,
  time_between_repetitions = NULL,
  time_between_repetitions_unit = "h",
  start_time = NULL,
  start_time_unit = "h"
)
```

## Arguments

- name:

  Character. Name of the schema (required).

- parameters:

  List of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md))
  or raw parameter lists. This is the escape hatch for any schema-level
  parameter not promoted to a plain argument. Each promoted argument is
  mutually exclusive with a matching entry here (an entry named
  `"NumberOfRepetitions"`, `"TimeBetweenRepetitions"`, or
  `"Start time"`): supply a repetition parameter either as the plain
  argument or as a `parameters` entry, not both.

- items:

  List of
  [SchemaItem](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
  objects (created with
  [`create_schema_item()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema_item.md))
  or raw schema item lists. These define the applications inside the
  schema.

- number_of_repetitions:

  Numeric. Optional count of schema repetitions (`NumberOfRepetitions`).
  A single finite whole number (dimensionless, no unit). Mutually
  exclusive with a `"NumberOfRepetitions"` entry in `parameters`.

- time_between_repetitions:

  Numeric. Optional time between repetitions (`TimeBetweenRepetitions`).
  A single finite numeric. Mutually exclusive with a
  `"TimeBetweenRepetitions"` entry in `parameters`.

- time_between_repetitions_unit:

  Character. Display unit for `time_between_repetitions`, default `"h"`,
  validated against the `"Time"` dimension.

- start_time:

  Numeric. Optional schema start time (`Start time`). A single finite
  numeric. Mutually exclusive with a `"Start time"` entry in
  `parameters`.

- start_time_unit:

  Character. Display unit for `start_time`, default `"h"`, validated
  against the `"Time"` dimension.

## Value

A
[Schema](https://esqlabs.github.io/osp.snapshots/dev/reference/Schema.md)
object.

## Examples

``` r
# A schema using the promoted repetition arguments
schema <- create_schema(
  name = "Schema 1",
  number_of_repetitions = 3,
  time_between_repetitions = 24,
  start_time = 0
)

# A once-daily schema with a single oral application, using the
# `parameters` escape hatch for the schema-level parameters
schema <- create_schema(
  name = "Schema 1",
  parameters = list(
    create_parameter(name = "NumberOfRepetitions", value = 1),
    create_parameter(name = "TimeBetweenRepetitions", value = 0, unit = "h")
  ),
  items = list(
    create_schema_item(
      name = "Item 1",
      application_type = "Oral",
      parameters = list(
        create_parameter(name = "InputDose", value = 5, unit = "mg")
      )
    )
  )
)
```
