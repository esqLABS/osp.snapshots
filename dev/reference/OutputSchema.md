# OutputSchema class for Simulation output schedules

An R6 class representing the `OutputSchema` field of a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md),
a collection of
[OutputInterval](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputInterval.md)s.
The raw JSON shape is a bare array of intervals (no enclosing object);
the `intervals` active binding exposes the wrapped list directly.

## Active bindings

- `data`:

  The raw data of the schema (read-only). Rebuilt from the cached
  [OutputInterval](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputInterval.md)
  list so that mutations flow back to the export payload. Returns a bare
  list of interval named lists.

- `intervals`:

  List of
  [OutputInterval](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputInterval.md)
  objects.

## Methods

### Public methods

- [`OutputSchema$new()`](#method-OutputSchema-initialize)

- [`OutputSchema$clone()`](#method-OutputSchema-clone)

------------------------------------------------------------------------

### `OutputSchema$new()`

Create a new OutputSchema object.

#### Usage

    OutputSchema$new(data)

#### Arguments

- `data`:

  Raw `OutputSchema` data from a snapshot. May be a bare list of
  interval named lists or `NULL` for an empty schema.

#### Returns

A new OutputSchema object.

------------------------------------------------------------------------

### `OutputSchema$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OutputSchema$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
