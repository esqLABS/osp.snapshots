# Per-item bullet label for a snapshot collection

Internal S3 generic. Returns the text used for the bullet of a single
item in
[`print.snapshot_collection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.snapshot_collection.md).

## Usage

``` r
collection_item_label(x, item, name)
```

## Arguments

- x:

  The owning snapshot collection. Present so that dispatch reads the
  collection class via
  [`UseMethod()`](https://rdrr.io/r/base/UseMethod.html); methods
  typically ignore the value.

- item:

  The current entry, i.e. `x[[name]]`.

- name:

  The current entry's name in `x`.

## Value

A length-1 character (or glue) string.

## Details

Required return shape: length-1 character or glue string.
