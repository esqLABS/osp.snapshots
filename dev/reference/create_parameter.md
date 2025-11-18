# Create a new parameter

Create a new parameter with the specified properties. All arguments
except name and value are optional.

## Usage

``` r
create_parameter(
  name,
  value,
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

  Character. Name of the parameter

- value:

  Numeric. Value of the parameter

- unit:

  Character. Unit of the parameter (optional)

- source:

  Character. Source of the value (optional)

- description:

  Character. Description of the value origin (optional)

- source_id:

  Integer. ID of the source (optional)

- table_formula:

  List. Table formula data for table parameters (optional)

- table_points:

  List. Points for table parameters, a list of x,y pairs (optional)

- x_name:

  Character. Name of X axis for table parameters (optional)

- y_name:

  Character. Name of Y axis for table parameters (optional)

- x_unit:

  Character. Unit for X axis for table parameters (optional)

- x_dimension:

  Character. Dimension for X axis for table parameters (optional)

- y_dimension:

  Character. Dimension for Y axis for table parameters (optional)

## Value

A Parameter object

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
