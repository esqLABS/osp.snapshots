# Protocol class for OSP snapshot protocols

An R6 class that represents a protocol in an OSP snapshot. This class
provides methods to access different properties of a protocol and
display a summary of its information. Protocols can be either simple
(with dosing intervals) or advanced (with schemas and schema items).

An Advanced Protocol's schemas are exposed as a named list of \[Schema\]
objects, each of which owns a list of \[SchemaItem\] objects. Simple
Protocols expose their single application directly through the
\`application_type\`, \`dosing_interval\`, and \`parameters\` fields.

## Active bindings

- `data`:

  The raw data of the protocol, refreshed from the wrapped \[Schema\]
  objects so mutations through the R6 surface flow back into the
  snapshot payload (read-only).

- `name`:

  The name of the protocol

- `is_advanced`:

  Whether the protocol is advanced (schema-based)

- `application_type`:

  The application type (for simple protocols)

- `dosing_interval`:

  The dosing interval (for simple protocols)

- `time_unit`:

  The time unit for the protocol

- `parameters`:

  The parameters of the protocol (for simple protocols)

- `schemas`:

  A named list of \[Schema\] objects for advanced protocols. Names are
  taken from each schema's \`name\` field (duplicates are disambiguated
  by \`make.unique\`). Simple protocols return an empty list.

## Methods

### Public methods

- [`Protocol$new()`](#method-Protocol-initialize)

- [`Protocol$print()`](#method-Protocol-print)

- [`Protocol$to_df()`](#method-Protocol-to_df)

- [`Protocol$get_human_application_type()`](#method-Protocol-get_human_application_type)

- [`Protocol$get_human_dosing_interval()`](#method-Protocol-get_human_dosing_interval)

- [`Protocol$clone()`](#method-Protocol-clone)

------------------------------------------------------------------------

### `Protocol$new()`

Create a new Protocol object

#### Usage

    Protocol$new(data)

#### Arguments

- `data`:

  Raw protocol data from a snapshot

#### Returns

A new Protocol object

------------------------------------------------------------------------

### `Protocol$print()`

Print a summary of the protocol including its properties and parameters.

#### Usage

    Protocol$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Protocol object for method chaining

------------------------------------------------------------------------

### `Protocol$to_df()`

Convert protocol data to a single consolidated tibble. Advanced
protocols emit one row per \[SchemaItem\] and join back to the protocol
via \`protocol_name\`. Simple protocols emit a single row.

#### Usage

    Protocol$to_df()

#### Returns

A tibble containing all protocol data in a single data frame

------------------------------------------------------------------------

### `Protocol$get_human_application_type()`

Get human-readable application type

#### Usage

    Protocol$get_human_application_type()

#### Returns

Character string with human-readable application type

------------------------------------------------------------------------

### `Protocol$get_human_dosing_interval()`

Get human-readable dosing interval

#### Usage

    Protocol$get_human_dosing_interval()

#### Returns

Character string with human-readable dosing interval

------------------------------------------------------------------------

### `Protocol$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Protocol$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
