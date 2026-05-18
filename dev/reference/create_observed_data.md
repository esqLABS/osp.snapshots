# Create a new observed data set

Create an
[`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
from named arguments. This is a thin factory around
[`loadDataSetFromSnapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/loadDataSetFromSnapshot.md)
that builds the raw snapshot observed-data shape for you and converts it
into a `DataSet`.

An observed data entry is the time + value (+ optional error) series
attached to a snapshot. It is referenced by name from a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)'s
simulations.

## Usage

``` r
create_observed_data(
  name,
  time,
  values,
  time_unit = "h",
  value_unit = NULL,
  value_dimension = NULL,
  error = NULL,
  error_type = NULL,
  error_unit = NULL,
  molecular_weight = NULL,
  lloq = NULL,
  metadata = NULL
)
```

## Arguments

- name:

  Character. Name of the observed data set (required).

- time:

  Numeric vector. Time grid x-values (required).

- values:

  Numeric vector. Measurement y-values, same length as `time`
  (required).

- time_unit:

  Character. Unit for `time` (for example `"h"`, `"min"`, `"day(s)"`).
  Validated against `ospsuite::ospUnits$Time`. Defaults to `"h"`.

- value_unit:

  Character. Unit for `values` (for example `"mg/l"`). When supplied
  alongside `value_dimension`, the unit is validated against the
  dimension via
  [`validate_unit()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_unit.md).

- value_dimension:

  Character. Dimension for `values` (for example
  `"Concentration (mass)"`). Required (no default): pass one of the
  names of
  [`ospsuite::ospDimensions`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/ospDimensions.html).
  Previously defaulted silently to `"Concentration (mass)"`, which was
  wrong for non-concentration data.

- error:

  Numeric vector. Optional error y-values, same length as `values`.

- error_type:

  Character. Auxiliary type for `error`, typically one of
  `"ArithmeticStdDev"`, `"GeometricStdDev"`, or `"ArithmeticStdErr"`.
  Defaults to `"ArithmeticStdDev"` when `error` is provided.

- error_unit:

  Character. Unit for `error`. Defaults to `value_unit`.

- molecular_weight:

  Numeric. Molecular weight to attach to the data set, in g/mol.

- lloq:

  Numeric. Lower limit of quantification.

- metadata:

  Named list. Extended properties (key/value pairs) stored alongside the
  data set.

## Value

An
[`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
object.

## Examples

``` r
# Create a minimal observed data set
obs <- create_observed_data(
  name = "Subject 001",
  time = c(0, 1, 2, 4, 8),
  values = c(0, 12, 18, 11, 5),
  value_dimension = "Concentration (mass)"
)

# Create observed data with units and error
obs <- create_observed_data(
  name = "Subject 001",
  time = c(0, 1, 2, 4, 8),
  values = c(0, 12, 18, 11, 5),
  time_unit = "h",
  value_unit = "mg/l",
  value_dimension = "Concentration (mass)",
  error = c(0, 1.2, 1.5, 1.1, 0.6),
  error_type = "ArithmeticStdDev"
)
```
