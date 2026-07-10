# Observer class for OSP snapshot observer sets

An R6 class that represents a single observer inside an
[ObserverSet](https://esqlabs.github.io/osp.snapshots/reference/ObserverSet.md).
An observer is a simulation-time formula that computes a derived
quantity from the underlying model (for example an amount observer or a
container observer), used to expose values that are not natural model
outputs.

In an OSP snapshot, each observer is one entry of the `Observers` array
nested inside an `ObserverSets` building block. An observer is not
itself a building block; it lives inside an `ObserverSet`.

## Active bindings

- `data`:

  The raw `Observer` list as it appears in the snapshot JSON
  (read-only).

- `name`:

  The name of the observer. Writable: must be a non-empty scalar string.

- `type`:

  The observer type. PK-Sim recognises `"Amount"` (an
  `AmountObserverBuilder`) and `"Container"` (a
  `ContainerObserverBuilder`). On assignment, a non-`NULL` value is
  validated against these two; assigning `NULL` removes the type.

- `dimension`:

  The dimension of the observed quantity, resolved in PK-Sim via
  `IDimensionRepository.DimensionByName()`. Writable: must be a
  non-empty scalar string, or `NULL` to clear. There is no closed set of
  dimension names to validate against, so a required string is the
  strongest check available.

- `formula`:

  The full `ExplicitFormula` object backing the observer, as a list with
  `Name`, `Formula` (the expression string), `Dimension`, and
  `References` (a list of `FormulaUsablePath` entries, each with
  `Alias`, `Path`, and `Dimension`). `NULL` when the observer carries no
  formula. Setting this field replaces the whole structure; pass `NULL`
  to drop it. For the inner expression string or dimension only, use
  `formula_expression` or `formula_dimension`.

- `formula_expression`:

  The expression string of the underlying `ExplicitFormula`
  (`Formula$Formula` in the snapshot JSON). Setting writes back to the
  inner `Formula$Formula` field and preserves the sibling `Name`,
  `Dimension`, and `References` entries. To build a complete
  `ExplicitFormula` (including `Name` and `References`), assign to
  `formula` instead.

- `formula_dimension`:

  The output dimension of the underlying `ExplicitFormula`
  (`Formula$Dimension` in the snapshot JSON), resolved in PK-Sim via
  `IDimensionRepository.DimensionByName()`. Setting writes back to the
  inner `Formula$Dimension` field.

- `formula_references`:

  The `References` list of the underlying `ExplicitFormula`, where each
  entry is a named list with `Alias`, `Path`, and `Dimension`. Assign a
  list of
  [`create_formula_reference()`](https://esqlabs.github.io/osp.snapshots/reference/create_formula_reference.md)
  outputs (or raw `{Alias, Path, Dimension}` lists) to replace it,
  preserving the sibling `Formula$Name`, `Formula$Formula`, and
  `Formula$Dimension` (the `Formula` is created if absent). Assign
  `NULL` to remove the references; when no `Formula` exists this is a
  no-op that does not create an empty `Formula`.

- `container_tags`:

  The `Tag` values from the observer's `ContainerCriteria`, joined with
  `|`. There is no `ContainerPath` field in the snapshot JSON; this
  binding is synthesized from the tags found in `ContainerCriteria`.
  `NULL` when the observer carries no container criteria.

- `container_criteria`:

  The full `ContainerCriteria` list, each entry a named list with `Tag`
  and (optionally) `Type`. Unlike `container_tags`, this preserves each
  condition's `Type` verbatim (including non-enum values such as
  `"MatchTag"`). Assign a list of
  [`create_descriptor_condition()`](https://esqlabs.github.io/osp.snapshots/reference/create_descriptor_condition.md)
  outputs (or raw `{Tag, Type}` lists) to replace it; assign `NULL` to
  remove it.

- `molecule_list`:

  The full `MoleculeList` object (`ForAll`, `MoleculeNamesToInclude`,
  `MoleculeNamesToExclude`) or `NULL`. Assign a
  [`create_molecule_list()`](https://esqlabs.github.io/osp.snapshots/reference/create_molecule_list.md)
  output (or an equivalent raw list) to replace it; assign `NULL` to
  remove it.

## Methods

### Public methods

- [`Observer$new()`](#method-Observer-initialize)

- [`Observer$print()`](#method-Observer-print)

- [`Observer$to_df()`](#method-Observer-to_df)

- [`Observer$clone()`](#method-Observer-clone)

------------------------------------------------------------------------

### `Observer$new()`

Create a new Observer object.

#### Usage

    Observer$new(data = list())

#### Arguments

- `data`:

  Raw `Observer` list from a snapshot. May be `NULL` or an empty list,
  both of which create an empty observer.

#### Returns

A new Observer object

------------------------------------------------------------------------

### `Observer$print()`

Print a short summary of the observer.

#### Usage

    Observer$print(...)

#### Arguments

- `...`:

  Additional arguments (unused).

#### Returns

Invisibly returns the Observer object.

------------------------------------------------------------------------

### `Observer$to_df()`

Convert the observer to a single-row tibble suitable for the
tibble-layer exporter. Columns are `name`, `type`, `dimension`,
`formula_expression`, `formula_dimension`, `formula_references`, and
`container_tags`. `formula_references` collapses each
`FormulaUsablePath` entry (`Alias`, `Path`, `Dimension`) to
`"alias=path"` and joins entries with `|`; `NA` when the observer
carries no references.

#### Usage

    Observer$to_df()

#### Returns

A tibble with one row.

------------------------------------------------------------------------

### `Observer$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Observer$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
observer <- Observer$new(list(
  Name = "brain_plasma_conc",
  Type = "Container",
  Dimension = "Concentration (molar)",
  Formula = list(
    Name = "brain_plasma_conc_formula",
    Formula = "Conc_Br",
    Dimension = "Concentration (molar)",
    References = list(list(
      Alias = "Conc_Br",
      Path = "Organism|Brain|Plasma|Drug|Concentration",
      Dimension = "Concentration (molar)"
    ))
  )
))
observer$name
#> [1] "brain_plasma_conc"
observer$type
#> [1] "Container"
observer$formula_expression
#> [1] "Conc_Br"
observer$formula_dimension
#> [1] "Concentration (molar)"
observer$formula_references
#> [[1]]
#> [[1]]$Alias
#> [1] "Conc_Br"
#> 
#> [[1]]$Path
#> [1] "Organism|Brain|Plasma|Drug|Concentration"
#> 
#> [[1]]$Dimension
#> [1] "Concentration (molar)"
#> 
#> 
```
