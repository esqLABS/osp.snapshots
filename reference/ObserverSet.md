# ObserverSet class for OSP snapshot observer sets

An R6 class that represents an `ObserverSet` building block in an OSP
snapshot. An `ObserverSet` is a named bundle of
[Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
objects that simulations can reference by name.

## Active bindings

- `data`:

  The raw data of the observer set, refreshed from the wrapped
  [Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
  objects so mutations through the R6 surface flow back into the
  snapshot payload (read-only).

- `name`:

  The name of the observer set. Writable: must be a non-empty scalar
  string.

- `observers`:

  A named list of
  [Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
  objects keyed by each observer's `$name`. Duplicate names are
  disambiguated with `_{n}` suffixes. Assigning accepts either a list of
  [Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
  objects or a list of raw observer dicts; both are normalised to
  [Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
  objects and the underlying raw data is kept in sync.

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
