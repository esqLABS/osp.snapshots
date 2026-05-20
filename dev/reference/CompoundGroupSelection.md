# CompoundGroupSelection class for compound alternative selections

An R6 class representing one entry in a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)'s
`Alternatives` array. Each entry pairs an alternative group (e.g.
`"COMPOUND_SOLUBILITY"`) with the selected alternative within that
group.

## Active bindings

- `data`:

  The raw data of the selection (read-only).

- `group_name`:

  The alternative group name.

- `alternative_name`:

  The selected alternative name in the group.

## Methods

### Public methods

- [`CompoundGroupSelection$new()`](#method-CompoundGroupSelection-initialize)

- [`CompoundGroupSelection$clone()`](#method-CompoundGroupSelection-clone)

------------------------------------------------------------------------

### `CompoundGroupSelection$new()`

Create a new CompoundGroupSelection object.

#### Usage

    CompoundGroupSelection$new(data)

#### Arguments

- `data`:

  Raw `CompoundGroupSelection` data from a snapshot.

#### Returns

A new CompoundGroupSelection object.

------------------------------------------------------------------------

### `CompoundGroupSelection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CompoundGroupSelection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
