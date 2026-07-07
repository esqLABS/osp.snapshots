# Per-kind header info for a snapshot collection

Internal S3 generic. Returns a list describing how
[`print.snapshot_collection()`](https://esqlabs.github.io/osp.snapshots/reference/print.snapshot_collection.md)
should label the collection.

## Usage

``` r
collection_kind_info(x)
```

## Arguments

- x:

  A snapshot collection. Used for dispatch only.

## Value

A list with `title`, `empty_message`, and optionally `truncate`.

## Details

Required return shape:

- `title`: length-1 character. Header title (e.g. "Compounds").

- `empty_message`: length-1 character. Message shown when the collection
  has no items.

- `truncate` (optional): length-1 logical. When `TRUE`,
  [`print.snapshot_collection()`](https://esqlabs.github.io/osp.snapshots/reference/print.snapshot_collection.md)
  truncates the listing at its `n` argument. Defaults to `FALSE` (show
  every item) when absent.
