# Protocol class for OSP snapshot protocols

An R6 class that represents a protocol in an OSP snapshot. This class
provides methods to access different properties of a protocol and
display a summary of its information. Protocols can be either simple
(with dosing intervals) or advanced (with schemas and schema items).

## Active bindings

- `data`:

  The raw data of the protocol

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

  The schemas of the protocol (for advanced protocols)

## Methods

### Public methods

- [`Protocol$new()`](#method-Protocol-new)

- [`Protocol$print()`](#method-Protocol-print)

- [`Protocol$to_df()`](#method-Protocol-to_df)

- [`Protocol$get_human_application_type()`](#method-Protocol-get_human_application_type)

- [`Protocol$get_human_dosing_interval()`](#method-Protocol-get_human_dosing_interval)

- [`Protocol$clone()`](#method-Protocol-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Protocol object

#### Usage

    Protocol$new(data)

#### Arguments

- `data`:

  Raw protocol data from a snapshot

#### Returns

A new Protocol object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the protocol including its properties and parameters.

#### Usage

    Protocol$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Protocol object for method chaining

------------------------------------------------------------------------

### Method `to_df()`

Convert protocol data to a single consolidated tibble

#### Usage

    Protocol$to_df()

#### Returns

A tibble containing all protocol data in a single data frame

------------------------------------------------------------------------

### Method `get_human_application_type()`

Get human-readable application type

#### Usage

    Protocol$get_human_application_type()

#### Returns

Character string with human-readable application type

------------------------------------------------------------------------

### Method `get_human_dosing_interval()`

Get human-readable dosing interval

#### Usage

    Protocol$get_human_dosing_interval()

#### Returns

Character string with human-readable dosing interval

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Protocol$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
