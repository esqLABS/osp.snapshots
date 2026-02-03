# Formulation class for OSP snapshot formulations

An R6 class that represents a formulation in an OSP snapshot. This class
provides methods to access different properties of a formulation and
display a summary of its information.

## Active bindings

- `data`:

  The raw data of the formulation (read-only)

- `name`:

  The name of the formulation

- `formulation_type`:

  The formulation type identifier

- `parameters`:

  The list of parameter objects

## Methods

### Public methods

- [`Formulation$new()`](#method-Formulation-new)

- [`Formulation$print()`](#method-Formulation-print)

- [`Formulation$to_df()`](#method-Formulation-to_df)

- [`Formulation$get_human_formulation_type()`](#method-Formulation-get_human_formulation_type)

- [`Formulation$clone()`](#method-Formulation-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Formulation object

#### Usage

    Formulation$new(data)

#### Arguments

- `data`:

  Raw formulation data from a snapshot

#### Returns

A new Formulation object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the formulation including its properties and
parameters.

#### Usage

    Formulation$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Formulation object for method chaining

------------------------------------------------------------------------

### Method `to_df()`

Convert formulation data to tibbles

#### Usage

    Formulation$to_df(type = "all")

#### Arguments

- `type`:

  Character. Type of data to convert: "all" (default) or "parameters"

#### Returns

A list of tibbles containing the requested data: \* formulations: Basic
formulation information (ID, name, type) \* formulations_parameters: All
parameters including table parameter points

The formulations_parameters tibble includes the following columns: \*
formulation_id: ID of the formulation \* name: Name of the parameter \*
value: Value of the parameter (NA for table points) \* unit: Unit of the
parameter (NA for table points) \* is_table_point: TRUE for table
parameter points, FALSE for regular parameters \* x_value: X-axis value
for table points (NA for regular parameters) \* y_value: Y-axis value
for table points (NA for regular parameters) \* table_name: Name of the
table (usually "Time" for release profiles) \* source: Source of the
parameter (NA if not available) \* description: Description of the
parameter (NA if not available) \* source_id: ID of the source (NA if
not available)

------------------------------------------------------------------------

### Method `get_human_formulation_type()`

Get human-readable formulation type

#### Usage

    Formulation$get_human_formulation_type()

#### Returns

Character string with human-readable formulation type

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Formulation$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
