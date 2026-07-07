# Generic print method for snapshot collections

Shared S3 print method that renders any building-block collection: a
header with the kind and item count, one bullet per item with a per-kind
summary, and a friendly message when the collection is empty. Per-item
summary lines and per-kind labels are dispatched to internal generics
[`collection_kind_info()`](https://esqlabs.github.io/osp.snapshots/reference/collection_kind_info.md)
and
[`collection_item_label()`](https://esqlabs.github.io/osp.snapshots/reference/collection_item_label.md),
each with one method per collection class.

## Usage

``` r
# S3 method for class 'snapshot_collection'
print(x, n = 5, ...)
```

## Arguments

- x:

  A snapshot collection (a `snapshot_collection` named list).

- n:

  Maximum number of items to display before truncating with "... and X
  more". Honoured only when the collection's
  [`collection_kind_info()`](https://esqlabs.github.io/osp.snapshots/reference/collection_kind_info.md)
  method returns `truncate = TRUE`; the default is to show every item.
  Currently only the `observed_data_collection` opts in.

- ...:

  Additional arguments passed to print methods.

## Value

Invisibly returns the collection.
