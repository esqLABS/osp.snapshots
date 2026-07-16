# Create a new protocol

Create a
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
building block from named arguments. This is a thin factory around
`Protocol$new()` that builds the raw list shape for you.

By default this creates a Simple Protocol with a single application type
and dosing interval. To create an Advanced Protocol pass a list of
schemas via `schemas` instead of `application_type` and
`dosing_interval`.

## Usage

``` r
create_protocol(
  name,
  application_type = NULL,
  dosing_interval = NULL,
  target_organ = NULL,
  target_compartment = NULL,
  parameters = NULL,
  schemas = NULL,
  time_unit = NULL,
  dose = NULL,
  dose_unit = "mg",
  start_time = NULL,
  start_time_unit = "h",
  end_time = NULL
)
```

## Arguments

- name:

  Character. Name of the protocol (required).

- application_type:

  Character. Application type for a Simple Protocol. Optional; when
  supplied it must be one of the canonical PK-Sim application types:
  `"Oral"`, `"Intravenous"`, `"IntravenousBolus"`, or `"UserDefined"`.
  Mutually exclusive with `schemas`.

- dosing_interval:

  Character. Dosing interval identifier for a Simple Protocol. Optional;
  when supplied it must be one of the fixed PK-Sim `DosingIntervalId`
  values: `"Single"`, `"DI_6_6_6_6"`, `"DI_6_6_12"`, `"DI_8_8_8"`,
  `"DI_12_12"`, or `"DI_24"`.

- target_organ:

  Character. Target organ for the dose. Only valid when
  `application_type` is `"UserDefined"`.

- target_compartment:

  Character. Target compartment for the dose. Only valid when
  `application_type` is `"UserDefined"`.

- parameters:

  List of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md))
  or raw parameter lists. This is the free-form escape hatch for any
  Simple-Protocol parameter that has no dedicated argument. Dose, start
  time, and end time have the dedicated `dose`, `start_time`, and
  `end_time` arguments; supplying one of those settings both here and
  via its dedicated argument is an error.

- schemas:

  List of schemas for an Advanced Protocol. Entries may be
  [Schema](https://esqlabs.github.io/osp.snapshots/dev/reference/Schema.md)
  objects (created with
  [`create_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema.md))
  or raw schema lists with `Name`, `Parameters`, and `SchemaItems`. If
  provided, the protocol is created as an Advanced Protocol.

- time_unit:

  Character. Display time unit for the protocol, validated against
  dimension `"Time"`; valid units are those in
  `ospsuite::ospUnits$Time`.

- dose:

  Numeric scalar. Optional dose for a Simple Protocol. When supplied it
  is emitted as a single `InputDose` parameter carrying `dose` and
  `dose_unit`. Mutually exclusive with `schemas`, and with an
  `InputDose` entry in `parameters`.

- dose_unit:

  Character. Display unit for `dose`, default `"mg"`. Validated as a
  dose-family unit: the unit must belong to one of the mass, amount,
  dose per body weight, or dose per body surface area dimensions, and
  the unit alone selects the family (the emitted parameter is always a
  single `InputDose`). There is no single `ospsuite::ospUnits$Dose`
  member, so the accepted units are the union of
  `ospsuite::ospUnits$Mass`, `ospsuite::ospUnits$Amount`,
  `ospsuite::ospUnits[["Dose per body weight"]]`, and
  `ospsuite::ospUnits[["Dose per body surface area"]]`. Only consulted
  when `dose` is supplied.

- start_time:

  Numeric scalar. Optional start time for a Simple Protocol. When
  supplied it is emitted as a `Start time` parameter. Mutually exclusive
  with `schemas`, and with a `Start time` entry in `parameters`.

- start_time_unit:

  Character. Display unit for `start_time`, default `"h"`, validated
  against dimension `"Time"`; valid units are those in
  `ospsuite::ospUnits$Time`. Only consulted when `start_time` is
  supplied.

- end_time:

  Numeric scalar. Optional end time for a Simple Protocol. When supplied
  it is emitted as an `End time` parameter. Its display unit is taken
  from `time_unit`, falling back to `"h"` when `time_unit` is unset;
  there is no separate end-time unit argument. Mutually exclusive with
  `schemas`, and with an `End time` entry in `parameters`.

## Value

A
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
object.

## Examples

``` r
# Create a simple oral protocol with one dose via promoted arguments
protocol <- create_protocol(
  name = "Single dose 10mg",
  application_type = "Oral",
  dosing_interval = "Single",
  dose = 10,
  dose_unit = "mg",
  start_time = 0
)

# The same protocol via the free-form `parameters` escape hatch
protocol <- create_protocol(
  name = "Single dose 10mg",
  application_type = "Oral",
  dosing_interval = "Single",
  parameters = list(
    create_parameter(name = "Start time", value = 0, unit = "h"),
    create_parameter(name = "InputDose", value = 10, unit = "mg")
  )
)

# Create a twice-daily intravenous protocol
protocol <- create_protocol(
  name = "BID IV",
  application_type = "IntravenousBolus",
  dosing_interval = "DI_12_12",
  parameters = list(
    create_parameter(name = "InputDose", value = 5, unit = "mg")
  )
)

# Create an Advanced Protocol from Schema objects
protocol <- create_protocol(
  name = "Advanced",
  schemas = list(
    create_schema(
      name = "Schema 1",
      parameters = list(
        create_parameter(name = "NumberOfRepetitions", value = 1)
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
  ),
  time_unit = "h"
)
```
