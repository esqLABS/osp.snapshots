# Create a new observed data set

Create an
[`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
from named arguments. This is a thin factory around
[`loadDataSetFromSnapshot()`](https://esqlabs.github.io/osp.snapshots/reference/loadDataSetFromSnapshot.md)
that builds the raw snapshot observed-data shape for you and converts it
into a `DataSet`.

An observed data entry is the time + value (+ optional error) series
attached to a snapshot. It is referenced by name from a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)'s
simulations.

## Usage

``` r
create_observed_data(
  name,
  time,
  values,
  error = NULL,
  molecular_weight = NULL,
  lloq = NULL,
  metadata = NULL
)
```

## Arguments

- name:

  Character. Name of the observed data set (required).

- time:

  A
  [`time()`](https://esqlabs.github.io/osp.snapshots/reference/time.md)
  object giving the time grid x-values and their unit (required).

- values:

  A
  [`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md)
  object giving the measurement y-values, their dimension, and an
  optional unit (required), same length as `time`. The dimension is
  supplied to
  [`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md)
  and is required there.

- error:

  A
  [`error()`](https://esqlabs.github.io/osp.snapshots/reference/error.md)
  object giving the optional error y-values, an optional unit
  (defaulting to the values unit), and the auxiliary type. Same length
  as the values series. `NULL` for no error series.

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

## See also

[`time()`](https://esqlabs.github.io/osp.snapshots/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/reference/error.md)
for the series value-object helpers.

## Examples

``` r
# Create a minimal observed data set
obs <- create_observed_data(
  name = "Subject 001",
  time = time(c(0, 1, 2, 4, 8)),
  values = values(c(0, 12, 18, 11, 5), dimension = "Concentration (mass)")
)

# Create observed data with units and error
obs <- create_observed_data(
  name = "Subject 001",
  time = time(c(0, 1, 2, 4, 8), unit = "h"),
  values = values(
    c(0, 12, 18, 11, 5),
    unit = "mg/l",
    dimension = "Concentration (mass)"
  ),
  error = error(c(0, 1.2, 1.5, 1.1, 0.6), type = "ArithmeticStdDev")
)
```
