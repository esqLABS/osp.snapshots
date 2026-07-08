# Create a compound alternative group selection

Build a
[CompoundGroupSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundGroupSelection.md)
entry, used inside a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)
to record which alternative is selected within an alternative group.
Internal machinery only: the friendly `alternatives` selection in
[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)'s
`compounds` argument is the user-facing way to select an alternative;
this constructor and the `COMPOUND_*` group constants it takes are not
part of the public API.

## Usage

``` r
create_compound_group_selection(group_name, alternative_name)
```

## Arguments

- group_name:

  Character. Name of the alternative group (required), for example
  `"COMPOUND_SOLUBILITY"`.

- alternative_name:

  Character. Name of the selected alternative within the group
  (required).

## Value

A
[CompoundGroupSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundGroupSelection.md)
object.
