# Create a new schema

Create a
[Schema](https://esqlabs.github.io/osp.snapshots/dev/reference/Schema.md)
for an Advanced
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
from named arguments. This is a thin factory around `Schema$new()` that
builds the raw list shape for you.

A schema is a repeatable block inside an Advanced
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md):
it has a name, schema-level parameters (typically `NumberOfRepetitions`
and `TimeBetweenRepetitions`), and an ordered list of
[SchemaItem](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
applications.

## Usage

``` r
create_schema(name, parameters = NULL, items = NULL)
```

## Arguments

- name:

  Character. Name of the schema (required).

- parameters:

  List of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md))
  or raw parameter lists. These become the schema-level parameters
  (`Start time`, `NumberOfRepetitions`, `TimeBetweenRepetitions`, ...).

- items:

  List of
  [SchemaItem](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
  objects (created with
  [`create_schema_item()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema_item.md))
  or raw schema item lists. These define the applications inside the
  schema.

## Value

A
[Schema](https://esqlabs.github.io/osp.snapshots/dev/reference/Schema.md)
object.

## Examples

``` r
# A once-daily schema with a single oral application
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
