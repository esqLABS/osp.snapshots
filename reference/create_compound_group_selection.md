# Create a compound alternative group selection

Build a
[CompoundGroupSelection](https://esqlabs.github.io/osp.snapshots/reference/CompoundGroupSelection.md)
entry, used inside a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/reference/CompoundProperties.md)
to record which alternative is selected within an alternative group.

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
[CompoundGroupSelection](https://esqlabs.github.io/osp.snapshots/reference/CompoundGroupSelection.md)
object.

## Examples

``` r
create_compound_group_selection(
  group_name = "COMPOUND_SOLUBILITY",
  alternative_name = "Aqueous"
)
#> <CompoundGroupSelection>
#>   Public:
#>     alternative_name: active binding
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     group_name: active binding
#>     initialize: function (data) 
#>   Private:
#>     .data: list
```
