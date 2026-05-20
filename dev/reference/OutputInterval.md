# OutputInterval class for Simulation output schemas

An R6 class representing one entry in an
[OutputSchema](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputSchema.md)'s
`Intervals` array. Each interval carries optional name and the three
[Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)s
`Start time`, `End time`, and `Resolution`.

## Active bindings

- `data`:

  The raw data of the interval (read-only). Rebuilt from the cached
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  list so that mutations flow back to the export payload.

- `name`:

  The interval name.

- `parameters`:

  Named list of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects, keyed by name.

## Methods

### Public methods

- [`OutputInterval$new()`](#method-OutputInterval-initialize)

- [`OutputInterval$clone()`](#method-OutputInterval-clone)

------------------------------------------------------------------------

### `OutputInterval$new()`

Create a new OutputInterval object.

#### Usage

    OutputInterval$new(data)

#### Arguments

- `data`:

  Raw `OutputInterval` data from a snapshot.

#### Returns

A new OutputInterval object.

------------------------------------------------------------------------

### `OutputInterval$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OutputInterval$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
