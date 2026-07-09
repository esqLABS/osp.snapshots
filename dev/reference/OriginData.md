# OriginData class for OSP snapshot individuals

An R6 class that represents the demographic starting point of an
[Individual](https://esqlabs.github.io/osp.snapshots/dev/reference/Individual.md):
species, population, gender, and the physiological parameters (age,
gestational age, weight, height) that PK-Sim uses when creating the
subject. The set of calculation methods used while deriving the
individual is exposed as a
[CalculationMethods](https://esqlabs.github.io/osp.snapshots/dev/reference/CalculationMethods.md)
object. Optional disease state metadata is preserved as-is for
round-trip fidelity.

In an OSP snapshot, the JSON object is named `OriginData` and lives
under each entry of the `Individuals` array.

## Active bindings

- `data`:

  The raw `OriginData` list as it appears in the snapshot JSON,
  refreshed from the embedded
  [CalculationMethods](https://esqlabs.github.io/osp.snapshots/dev/reference/CalculationMethods.md)
  object (read-only).

- `species`:

  The species of the individual.

- `population`:

  The population of the individual.

- `gender`:

  The gender of the individual.

- `age`:

  Numeric age value of the individual (in `age_unit`). Writable: assign
  an
  [`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md)
  object to set the value and unit together. A bare numeric scalar is
  rejected; use
  [`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md)
  instead.

- `age_unit`:

  Unit string for `age`.

- `gestational_age`:

  Numeric gestational age value (in `gestational_age_unit`), used for
  preterm individuals. Writable: assign a
  [`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md)
  object to set the value and unit together. A bare numeric scalar is
  rejected; use
  [`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md)
  instead.

- `gestational_age_unit`:

  Unit string for `gestational_age`.

- `weight`:

  Numeric weight value of the individual (in `weight_unit`). Writable:
  assign a
  [`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)
  object to set the value and unit together. A bare numeric scalar is
  rejected; use
  [`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)
  instead.

- `weight_unit`:

  Unit string for `weight`.

- `height`:

  Numeric height value of the individual (in `height_unit`). Writable:
  assign a
  [`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md)
  object to set the value and unit together. A bare numeric scalar is
  rejected; use
  [`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md)
  instead.

- `height_unit`:

  Unit string for `height`.

- `calculation_methods`:

  A
  [CalculationMethods](https://esqlabs.github.io/osp.snapshots/dev/reference/CalculationMethods.md)
  object holding the calculation methods PK-Sim applies while creating
  the individual.

- `disease_state`:

  Optional disease-state name. Read from the modern `Disease` object
  (`Disease$Name`) or, for a loaded legacy snapshot, the legacy
  `DiseaseState` key. Writing sets the modern `Disease$Name`.

- `disease_state_parameters`:

  Optional list of disease-state parameters. Read from the modern
  `Disease` object (`Disease$Parameters`) or, for a loaded legacy
  snapshot, the legacy `DiseaseStateParameters` key. Writing sets the
  modern `Disease$Parameters`.

## Methods

### Public methods

- [`OriginData$new()`](#method-OriginData-initialize)

- [`OriginData$print()`](#method-OriginData-print)

- [`OriginData$clone()`](#method-OriginData-clone)

------------------------------------------------------------------------

### `OriginData$new()`

Create a new OriginData object

#### Usage

    OriginData$new(data = list())

#### Arguments

- `data`:

  Raw `OriginData` list from a snapshot. May be `NULL` or an empty list,
  both of which create an empty OriginData.

#### Returns

A new OriginData object

------------------------------------------------------------------------

### `OriginData$print()`

Print a summary of the origin data

#### Usage

    OriginData$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the OriginData object

------------------------------------------------------------------------

### `OriginData$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OriginData$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
