# Create a container criterion for an observer

Build a single `DescriptorCondition` entry for an
[Observer](https://esqlabs.github.io/osp.snapshots/dev/reference/Observer.md)'s
`ContainerCriteria`. A container criterion matches the containers an
observer applies to by a `Tag` and an optional match `Type`. This is a
small builder that returns the raw named list; assemble several of them
into a list for
[`create_observer()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer.md)
or `observer$container_criteria`.

## Usage

``` r
create_descriptor_condition(tag, type = NULL)
```

## Arguments

- tag:

  Character. The container tag to match (required).

- type:

  Character. The match type. This is an open string, not a closed enum:
  PK-Sim writes values such as `"InContainer"`, `"NotInContainer"`,
  `"InParent"`, or `"MatchTag"`, and any of these (or another string
  PK-Sim emits) is preserved verbatim. Omitted when `NULL`.

## Value

A named list with `Tag` and, when supplied, `Type`.

## Examples

``` r
create_descriptor_condition("Brain", "InContainer")
#> $Tag
#> [1] "Brain"
#> 
#> $Type
#> [1] "InContainer"
#> 

# The match type is optional
create_descriptor_condition("Brain")
#> $Tag
#> [1] "Brain"
#> 
```
