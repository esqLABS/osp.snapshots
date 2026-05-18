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
  time_unit = NULL
)
```

## Arguments

- name:

  Character. Name of the protocol (required).

- application_type:

  Character. Application type for a Simple Protocol (for example
  `"Oral"`, `"IntravenousBolus"`, or `"IntravenousInfusion"`). Mutually
  exclusive with `schemas`.

- dosing_interval:

  Character. Dosing interval identifier for a Simple Protocol (for
  example `"Single"`, `"DI_12_12"`, `"DI_8_8_8"`, or `"DI_24"`).

- target_organ:

  Character. Target organ for the dose.

- target_compartment:

  Character. Target compartment for the dose.

- parameters:

  List of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md))
  or raw parameter lists for Simple Protocol parameters such as start
  time, end time, and dose.

- schemas:

  List of schema lists for an Advanced Protocol. Each schema is a list
  with `Name`, `Parameters`, and `SchemaItems`. If provided, the
  protocol is created as an Advanced Protocol.

- time_unit:

  Character. Display time unit for the protocol.

## Value

A
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
object.

## Examples

``` r
# Create a simple oral protocol with one dose
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
```
