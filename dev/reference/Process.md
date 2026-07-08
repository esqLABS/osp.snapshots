# Process class for OSP snapshot compound processes

An R6 class that represents a single compound process in an OSP
snapshot.

A `Process` wraps one entry of a `Compound`'s `Processes` array (PK-Sim
`CompoundProcess`). The PK-Sim JSON does not bucket processes by
subtype; subtypes are inferred from `internal_name`. The derived
`category` field surfaces that bucketing for R consumers:
`"protein_binding_partners"`, `"metabolizing_enzymes"`,
`"hepatic_clearance"`, `"transporter_proteins"`, `"renal_clearance"`,
`"biliary_clearance"`, `"inhibition"`, `"induction"`, or `NA` when the
`internal_name` does not match any known pattern.

## Active bindings

- `data`:

  The raw underlying data list (read-only).

- `internal_name`:

  The PK-Sim `InternalName` (process template key). Writable: must be a
  non-empty scalar string.

- `data_source`:

  The `DataSource` string identifying the process. Writable: must be a
  non-empty scalar string.

- `molecule`:

  Optional `Molecule` field (for partial processes). Writable: a
  non-empty scalar string when supplied, or `NULL` to clear.

- `metabolite`:

  Optional `Metabolite` field (for enzymatic processes). Writable: a
  non-empty scalar string when supplied, or `NULL` to clear.

- `species`:

  Optional `Species` field (for species-dependent processes). Writable:
  a non-empty scalar string when supplied, or `NULL` to clear. This is a
  free molecule/species string (not the `Individual`/`OriginData`
  species enum), so
  [`validate_species()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_species.md)
  does not apply here.

- `parameters`:

  A named list of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects (one entry per `Parameter` in the snapshot JSON), keyed by
  parameter name. Assigning accepts either a list of
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  objects or raw parameter dicts; the underlying raw data and the
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  cache are kept in sync.

- `category`:

  Derived category string. One of `"protein_binding_partners"`,
  `"metabolizing_enzymes"`, `"hepatic_clearance"`,
  `"transporter_proteins"`, `"renal_clearance"`, `"biliary_clearance"`,
  `"inhibition"`, `"induction"`, or `NA_character_`.

## Methods

### Public methods

- [`Process$new()`](#method-Process-initialize)

- [`Process$print()`](#method-Process-print)

- [`Process$clone()`](#method-Process-clone)

------------------------------------------------------------------------

### `Process$new()`

Create a new Process object.

#### Usage

    Process$new(data)

#### Arguments

- `data`:

  Raw process data (a `CompoundProcess` entry from a snapshot).

#### Returns

A new Process object.

------------------------------------------------------------------------

### `Process$print()`

Print a short summary of the process.

#### Usage

    Process$print(...)

#### Arguments

- `...`:

  Additional arguments (unused).

#### Returns

Invisibly returns the Process object.

------------------------------------------------------------------------

### `Process$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Process$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
