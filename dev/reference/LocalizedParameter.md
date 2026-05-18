# LocalizedParameter class for path-bearing OSP snapshot parameters

An R6 class that represents a Localized parameter in an OSP snapshot. A
Localized parameter is a \[Parameter\] identified by its full path
within a target's parameter tree (typically a Simulation or Individual).
The path locates where the override applies.

\`LocalizedParameter\` inherits from \[Parameter\]; everything that
works on a \`Parameter\` also works on a \`LocalizedParameter\`. The
only addition is a required \`path\` field, populated from the \`Path\`
element of the raw data (and falling back to \`Name\` when only a name
is supplied, so a \`LocalizedParameter\` can still be created from
existing schema-style data).

In v11+ snapshots, path segments named \`Applications\` are migrated to
\`Events\`. The migration runs in \`initialize()\`, so any path read
back from a \`LocalizedParameter\` is already normalized.

## Super class

[`Parameter`](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
-\> `LocalizedParameter`

## Methods

### Public methods

- [`LocalizedParameter$new()`](#method-LocalizedParameter-initialize)

- [`LocalizedParameter$clone()`](#method-LocalizedParameter-clone)

Inherited methods

- [`Parameter$print()`](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.html#method-print)
- [`Parameter$to_df()`](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.html#method-to_df)

------------------------------------------------------------------------

### `LocalizedParameter$new()`

Create a new LocalizedParameter object.

Requires a non-empty path supplied either through \`data\$Path\` or
\`data\$Name\`. Path segments named \`Applications\` are rewritten to
\`Events\` (v11+ migration).

#### Usage

    LocalizedParameter$new(data)

#### Arguments

- `data`:

  Raw parameter data from a snapshot. Must contain a \`Path\` (or, for
  legacy data, a \`Name\` used as the path).

#### Returns

A new LocalizedParameter object.

------------------------------------------------------------------------

### `LocalizedParameter$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LocalizedParameter$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
