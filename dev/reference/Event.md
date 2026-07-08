# Event class for OSP snapshot events

An R6 class that represents an event in an OSP snapshot. This class
provides methods to access different properties of an event and display
a summary of its information.

## Active bindings

- `data`:

  The raw data of the event (read-only)

- `name`:

  The name of the event. Writable: must be a non-empty scalar string.

- `template`:

  The template of the event. Writable: must be a non-empty scalar
  string.

- `parameters`:

  The list of parameter objects. Writable: must be a list, or `NULL` to
  clear.

## Methods

### Public methods

- [`Event$new()`](#method-Event-initialize)

- [`Event$print()`](#method-Event-print)

- [`Event$to_dataframe()`](#method-Event-to_dataframe)

- [`Event$clone()`](#method-Event-clone)

------------------------------------------------------------------------

### `Event$new()`

Create a new Event object

#### Usage

    Event$new(data)

#### Arguments

- `data`:

  Raw event data from a snapshot

#### Returns

A new Event object

------------------------------------------------------------------------

### `Event$print()`

Print a summary of the event

#### Usage

    Event$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `Event$to_dataframe()`

Convert the event to a data frame for easier manipulation

#### Usage

    Event$to_dataframe()

#### Returns

A tibble with event information

------------------------------------------------------------------------

### `Event$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Event$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
