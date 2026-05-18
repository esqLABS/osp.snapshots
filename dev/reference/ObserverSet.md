# ObserverSet class for OSP snapshot observer sets

An R6 class that represents an `ObserverSet` building block in an OSP
snapshot. An `ObserverSet` is a named bundle of observers that
simulations can reference by name. The class exposes the set's name and
its raw `Observers` list; richer wrapping of individual observers is
deferred to a follow-up.

## Active bindings

- `data`:

  The raw data of the observer set (read-only)

- `name`:

  The name of the observer set

- `observers`:

  The raw list of observers in the set

## Methods

### Public methods

- [`ObserverSet$new()`](#method-ObserverSet-initialize)

- [`ObserverSet$print()`](#method-ObserverSet-print)

- [`ObserverSet$clone()`](#method-ObserverSet-clone)

------------------------------------------------------------------------

### `ObserverSet$new()`

Create a new ObserverSet object

#### Usage

    ObserverSet$new(data)

#### Arguments

- `data`:

  Raw observer set data from a snapshot

#### Returns

A new ObserverSet object

------------------------------------------------------------------------

### `ObserverSet$print()`

Print a summary of the observer set

#### Usage

    ObserverSet$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `ObserverSet$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ObserverSet$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
