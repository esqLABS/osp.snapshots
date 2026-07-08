# Compound class for OSP snapshot compounds

An R6 class that represents a compound in an OSP snapshot. This class
provides methods to access different properties of a compound and
display a summary of its information.

Compound processes are exposed via `$processes`, a flat named list of
[Process](https://esqlabs.github.io/osp.snapshots/dev/reference/Process.md)
objects. The per-category tibble accessors (`$protein_binding_partners`,
`$metabolizing_enzymes`, `$hepatic_clearance`, `$transporter_proteins`,
`$renal_clearance`, `$biliary_clearance`, `$inhibition`, `$induction`)
are
[`lifecycle::deprecate_soft()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)-warned
in favour of `$processes` and the long-form `processes` tibble returned
by
[`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md).

## Active bindings

- `data`:

  The raw data of the compound (read-only). Refreshed from the embedded
  [CalculationMethods](https://esqlabs.github.io/osp.snapshots/dev/reference/CalculationMethods.md)
  and the cached
  [Process](https://esqlabs.github.io/osp.snapshots/dev/reference/Process.md)
  objects so that mutations flow back to the export payload.

- `name`:

  The name of the compound

- `is_small_molecule`:

  Whether the compound is a small molecule

- `plasma_protein_binding_partner`:

  The plasma protein binding partner of the compound

- `molecular_weight`:

  The molecular weight of the compound

- `molecular_weight_unit`:

  The unit of the molecular weight

- `lipophilicity`:

  The lipophilicity data of the compound. Writable: assign a
  [`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), a numeric scalar to create a
  single default `Lipophilicity` alternative (parameter
  `"Lipophilicity"`, unit `"Log Units"`), a raw alternative list to set
  the array verbatim (the escape hatch for species-specific
  alternatives), or `NULL` to clear the property.

- `fraction_unbound`:

  The fraction unbound data of the compound. Writable: assign a
  [`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), a numeric scalar to create a
  single default `FractionUnbound` alternative (parameter
  `"Fraction unbound (plasma, reference value)"`, no unit), a raw
  alternative list to set the array verbatim, or `NULL` to clear the
  property.

- `solubility`:

  The solubility data of the compound. Writable: assign a
  [`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md)
  object to express reference pH, gain per charge, or a pH/value table,
  a list of such objects to define several named alternatives (the first
  element is the default), a numeric scalar to create a single default
  `Solubility` alternative (parameter `"Solubility at reference pH"`,
  unit `"mg/l"`), a raw alternative list to set the array verbatim, or
  `NULL` to clear the property. The numeric-scalar form cannot express
  reference pH, gain per charge, or table solubility; use a
  [`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md)
  object or a raw alternative list for those.

- `intestinal_permeability`:

  The intestinal permeability data of the compound. Writable: assign an
  [`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), a numeric scalar to create a
  single default `IntestinalPermeability` alternative (parameter
  `"Specific intestinal permeability (transcellular)"`, unit
  `"cm/min"`), a raw alternative list to set the array verbatim, or
  `NULL` to clear the property.

- `permeability`:

  The permeability data of the compound. Writable: assign a
  [`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md)
  object, a list of such objects to define several named alternatives
  (the first element is the default), a numeric scalar to create a
  single default `Permeability` alternative (parameter `"Permeability"`,
  unit `"cm/min"`), a raw alternative list to set the array verbatim, or
  `NULL` to clear the property.

- `pka_types`:

  The pKa types of the compound. Writable: assign a list of
  `list(type =, value =)` entries (the
  [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
  `pKa` shape, converted to `list(Type =, Pka =)`), a raw `PkaType[]`
  list (entries carrying `Type`/`Pka`, set verbatim), or `NULL` /
  [`list()`](https://rdrr.io/r/base/list.html) to clear the pKa types.

- `processes`:

  A flat named list of
  [Process](https://esqlabs.github.io/osp.snapshots/dev/reference/Process.md)
  objects, one per entry in the compound's `Processes` array. Duplicate
  names are disambiguated with a numeric suffix (`_1`, `_2`, ...). The
  list is built once at construction so that state changes made on a
  [Process](https://esqlabs.github.io/osp.snapshots/dev/reference/Process.md)
  persist across accesses. Writable: assign a list of
  [Process](https://esqlabs.github.io/osp.snapshots/dev/reference/Process.md)
  objects and/or raw process lists to rebuild the processes (duplicate
  names are disambiguated as at construction), or `NULL` /
  [`list()`](https://rdrr.io/r/base/list.html) to clear them.

- `calculation_methods`:

  A
  [CalculationMethods](https://esqlabs.github.io/osp.snapshots/dev/reference/CalculationMethods.md)
  object holding the compound's calculation methods.

- `parameters`:

  The additional parameters of the compound (excluding molecular weight)

- `protein_binding_partners`:

  Deprecated. Filter
  [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)`$processes`
  on `category == "protein_binding_partners"`, or iterate
  `self$processes` and check `process$category`.

- `metabolizing_enzymes`:

  Deprecated. See `$protein_binding_partners`.

- `hepatic_clearance`:

  Deprecated. See `$protein_binding_partners`.

- `transporter_proteins`:

  Deprecated. See `$protein_binding_partners`.

- `renal_clearance`:

  Deprecated. See `$protein_binding_partners`.

- `biliary_clearance`:

  Deprecated. See `$protein_binding_partners`.

- `inhibition`:

  Deprecated. See `$protein_binding_partners`.

- `induction`:

  Deprecated. See `$protein_binding_partners`.

## Methods

### Public methods

- [`Compound$new()`](#method-Compound-initialize)

- [`Compound$print()`](#method-Compound-print)

- [`Compound$to_df()`](#method-Compound-to_df)

- [`Compound$clone()`](#method-Compound-clone)

------------------------------------------------------------------------

### `Compound$new()`

Create a new Compound object

#### Usage

    Compound$new(data)

#### Arguments

- `data`:

  Raw compound data from a snapshot

#### Returns

A new Compound object

------------------------------------------------------------------------

### `Compound$print()`

Print a summary of the compound including its properties and parameters.

#### Usage

    Compound$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Compound object for method chaining

------------------------------------------------------------------------

### `Compound$to_df()`

Convert this compound's physicochemical properties and process
parameters to a single long-form tibble (legacy shape).

Used by
[`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
to assemble the compound-wide `properties` tibble. The process-derived
rows produced here are
[`lifecycle::deprecate_soft()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)-warned
at the
[`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
entry point; prefer the long-form `processes` tibble returned alongside.

#### Usage

    Compound$to_df()

#### Returns

A tibble with columns `compound`, `category`, `type`, `parameter`,
`value`, `unit`, `data_source`, `source`.

------------------------------------------------------------------------

### `Compound$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Compound$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
