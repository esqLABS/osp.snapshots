# Create a new parameter

Create a new parameter with the specified properties. All arguments
except name and value are optional.

Returns a
[LocalizedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/LocalizedParameter.md)
when a non-NULL `path` is supplied (i.e. the parameter is identified by
its position within a target's parameter tree); otherwise returns a
plain
[Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md).

## Usage

``` r
create_parameter(
  name,
  value,
  path = NULL,
  unit = NULL,
  source = NULL,
  description = NULL,
  source_id = NULL,
  table_formula = NULL,
  table_points = NULL,
  x_name = NULL,
  y_name = NULL,
  x_unit = NULL,
  x_dimension = NULL,
  y_dimension = NULL
)
```

## Arguments

- name:

  Character. Name of the parameter.

- value:

  Numeric. Value of the parameter.

- path:

  Character. Full container path of the parameter within its parameter
  tree. Supply this to obtain a
  [LocalizedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/LocalizedParameter.md)
  (used in Individual, ExpressionProfile, and Simulation parameter
  sections).

- unit:

  Character. Unit of the parameter (optional).

- source:

  Character. Source of the value (optional).

- description:

  Character. Description of the value origin (optional).

- source_id:

  Integer. ID of the source (optional).

- table_formula:

  List. Table formula data for table parameters (optional).

- table_points:

  List. Points for table parameters, a list of x,y pairs (optional).

- x_name:

  Character. Name of X axis for table parameters (optional).

- y_name:

  Character. Name of Y axis for table parameters (optional).

- x_unit:

  Character. Unit for X axis for table parameters (optional).

- x_dimension:

  Character. Dimension for X axis for table parameters (optional).

- y_dimension:

  Character. Dimension for Y axis for table parameters (optional).

## Value

A
[Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
object, or a
[LocalizedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/LocalizedParameter.md)
when `path` is supplied.

## Data shape

Plain `Parameter` objects carry the identifier in `data$Name`, matching
the JSON shape used by `Parameter` slots in `Compound`, `Formulation`,
`Protocol`, and `Event` (per `snapshot-spec.md`). `LocalizedParameter`
objects carry the identifier in `data$Path`. The factory writes
whichever field matches the returned class so the raw `data` shape
reflects the kind of parameter unambiguously.

## Examples

``` r
# Create a basic parameter
param <- create_parameter(
  name = "Organism|Liver|Volume",
  value = 1.5
)

# Create a parameter with unit
param <- create_parameter(
  name = "Organism|Liver|Volume",
  value = 1.5,
  unit = "L"
)

# Create a parameter with value origin
param <- create_parameter(
  name = "Organism|Liver|Volume",
  value = 1.5,
  unit = "L",
  source = "Publication",
  description = "Reference XYZ"
)

# Create a localized parameter (path-bearing)
localized <- create_parameter(
  path = "Organism|Liver|Volume",
  value = 1.5,
  unit = "L"
)

# Create a table parameter
param <- create_parameter(
  name = "Fraction (dose)",
  value = 0.0,
  table_points = list(
    list(x = 0.0, y = 0.0),
    list(x = 1.0, y = 0.5),
    list(x = 2.0, y = 0.8),
    list(x = 4.0, y = 1.0)
  ),
  x_name = "Time",
  y_name = "Fraction (dose)",
  x_unit = "h",
  x_dimension = "Time",
  y_dimension = "Dimensionless"
)
```
