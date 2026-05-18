# LocalizedParameter class for path-bearing OSP snapshot parameters

An R6 class that represents a Localized parameter in an OSP snapshot. A
Localized parameter is a \[Parameter\] identified by its full path
within a target's parameter tree (typically a Simulation or Individual).
The path locates where the override applies.

\`LocalizedParameter\` inherits from \[Parameter\]; everything that
works on a \`Parameter\` also works on a \`LocalizedParameter\`. The
only addition is a required \`path\` field, populated from the \`Path\`
element of the raw data.

\# Snapshot version assumption

\`osp.snapshots\` only supports v11+ snapshots (numeric \`Version\` \>=
79); the check is enforced by \`Snapshot\$new()\` at load time. In v11+
snapshots, path segments named \`Applications\` are migrated to
\`Events\`. The migration runs in \`initialize()\`; for v11+ data it is
a no-op because PK-Sim already uses \`Events\`, and the constructor
itself does not re-check the version.

\# Legacy \`Name\` fallback

A v11+ snapshot's localized parameter always carries \`Path\`. As a
convenience for hand-rolled data, \`initialize()\` falls back to
\`data\$Name\` when \`data\$Path\` is missing and emits a deprecation
warning so the substitution is not silent; the resulting object stores
the value in \`data\$Path\` and drops \`data\$Name\`. Real snapshots
never trigger this branch.

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

Requires a non-empty path supplied through \`data\$Path\`. If
\`data\$Path\` is missing but \`data\$Name\` is present, the name is
used as the path and a deprecation warning is emitted; \`data\$Name\` is
then cleared so the resulting raw shape is unambiguous. Path segments
named \`Applications\` are rewritten to \`Events\` (legacy migration
kept for robustness; no-op on v11+ data).

#### Usage

    LocalizedParameter$new(data)

#### Arguments

- `data`:

  Raw parameter data from a snapshot. Must contain a \`Path\`.

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
