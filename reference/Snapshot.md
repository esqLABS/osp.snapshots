# Snapshot class for OSP snapshots

An R6 class that represents an OSP snapshot file. This class provides
methods to access different components of the snapshot and visualize its
structure.

## Active bindings

- `data`:

  The aggregated data of the snapshot from all components

- `pksim_version`:

  The human-readable PKSIM version corresponding to the snapshot version

- `path`:

  The path to the snapshot file relative to the working directory

- `compounds`:

  List of Compound objects in the snapshot

- `expression_profiles`:

  List of ExpressionProfile objects in the snapshot

- `individuals`:

  List of Individual objects in the snapshot

- `formulations`:

  List of Formulation objects in the snapshot

- `populations`:

  List of Population objects in the snapshot

- `events`:

  List of Event objects in the snapshot

- `protocols`:

  List of Protocol objects in the snapshot

- `observed_data`:

  List of DataSet objects (observed data) in the snapshot

## Methods

### Public methods

- [`Snapshot$new()`](#method-Snapshot-new)

- [`Snapshot$print()`](#method-Snapshot-print)

- [`Snapshot$export()`](#method-Snapshot-export)

- [`Snapshot$add_individual()`](#method-Snapshot-add_individual)

- [`Snapshot$remove_individual()`](#method-Snapshot-remove_individual)

- [`Snapshot$add_formulation()`](#method-Snapshot-add_formulation)

- [`Snapshot$remove_formulation()`](#method-Snapshot-remove_formulation)

- [`Snapshot$remove_population()`](#method-Snapshot-remove_population)

- [`Snapshot$add_expression_profile()`](#method-Snapshot-add_expression_profile)

- [`Snapshot$remove_expression_profile()`](#method-Snapshot-remove_expression_profile)

- [`Snapshot$add_observed_data()`](#method-Snapshot-add_observed_data)

- [`Snapshot$remove_observed_data()`](#method-Snapshot-remove_observed_data)

- [`Snapshot$clone()`](#method-Snapshot-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Snapshot object from a JSON file or a list

#### Usage

    Snapshot$new(input)

#### Arguments

- `input`:

  Path to the snapshot JSON file, URL, template name, or a list
  containing snapshot data

#### Returns

A new Snapshot object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the snapshot

#### Usage

    Snapshot$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the snapshot object

------------------------------------------------------------------------

### Method `export()`

Export the snapshot to a JSON file

#### Usage

    Snapshot$export(path)

#### Arguments

- `path`:

  Path to save the JSON file

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### Method [`add_individual()`](https://esqlabs.github.io/osp.snapshots/reference/add_individual.md)

Add an Individual object to the snapshot

#### Usage

    Snapshot$add_individual(individual)

#### Arguments

- `individual`:

  An Individual object created with create_individual()

#### Returns

Invisibly returns the object

#### Examples

    \dontrun{
    # Create a new individual
    ind <- create_individual(name = "New Patient", age = 35, weight = 70)

    # Add the individual to a snapshot
    snapshot$add_individual(ind)
    }

------------------------------------------------------------------------

### Method [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/reference/remove_individual.md)

Remove an individual from the snapshot by name

#### Usage

    Snapshot$remove_individual(individual_name)

#### Arguments

- `individual_name`:

  Character vector of individual name(s) to remove

#### Returns

Invisibly returns the object

#### Examples

    \dontrun{
    # Remove an individual from the snapshot
    snapshot$remove_individual("Subject_001")
    }

------------------------------------------------------------------------

### Method [`add_formulation()`](https://esqlabs.github.io/osp.snapshots/reference/add_formulation.md)

Add a Formulation object to the snapshot

#### Usage

    Snapshot$add_formulation(formulation)

#### Arguments

- `formulation`:

  A Formulation object created with create_formulation()

#### Returns

Invisibly returns the object

#### Examples

    \dontrun{
    # Create a new formulation
    form <- create_formulation(name = "Tablet", type = "Weibull")

    # Add the formulation to a snapshot
    snapshot$add_formulation(form)
    }

------------------------------------------------------------------------

### Method [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/reference/remove_formulation.md)

Remove a formulation from the snapshot by name

#### Usage

    Snapshot$remove_formulation(formulation_name)

#### Arguments

- `formulation_name`:

  Character vector of formulation name(s) to remove

#### Returns

Invisibly returns the object

#### Examples

    \dontrun{
    # Remove a formulation from the snapshot
    snapshot$remove_formulation("Tablet")
    }

------------------------------------------------------------------------

### Method [`remove_population()`](https://esqlabs.github.io/osp.snapshots/reference/remove_population.md)

Remove a population from the snapshot by name

#### Usage

    Snapshot$remove_population(population_name)

#### Arguments

- `population_name`:

  Character vector of population name(s) to remove

#### Returns

Invisibly returns the object

#### Examples

    \dontrun{
    # Remove a population from the snapshot
    snapshot$remove_population("pop_1")
    }

------------------------------------------------------------------------

### Method [`add_expression_profile()`](https://esqlabs.github.io/osp.snapshots/reference/add_expression_profile.md)

Add an ExpressionProfile object to the snapshot

#### Usage

    Snapshot$add_expression_profile(expression_profile)

#### Arguments

- `expression_profile`:

  An ExpressionProfile object

#### Returns

Invisibly returns the object

#### Examples

    \dontrun{
    # Create a new expression profile
    profile_data <- list(
      Type = "Enzyme",
      Species = "Human",
      Molecule = "CYP3A4",
      Category = "Healthy",
      Parameters = list()
    )
    profile <- ExpressionProfile$new(profile_data)

    # Add the expression profile to a snapshot
    snapshot$add_expression_profile(profile)
    }

------------------------------------------------------------------------

### Method [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/reference/remove_expression_profile.md)

Remove expression profiles from the snapshot by ID

#### Usage

    Snapshot$remove_expression_profile(profile_id)

#### Arguments

- `profile_id`:

  Character vector of expression profile IDs to remove

#### Returns

Invisibly returns the object

#### Examples

    \dontrun{
    # Remove an expression profile from the snapshot
    snapshot$remove_expression_profile("CYP3A4|Human|Healthy")
    }

------------------------------------------------------------------------

### Method `add_observed_data()`

Add a DataSet object (observed data) to the snapshot

#### Usage

    Snapshot$add_observed_data(observed_data)

#### Arguments

- `observed_data`:

  A DataSet object created from snapshot observed data

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### Method `remove_observed_data()`

Remove observed data from the snapshot by name

#### Usage

    Snapshot$remove_observed_data(observed_data_name)

#### Arguments

- `observed_data_name`:

  Character vector of observed data names to remove

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Snapshot$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
## ------------------------------------------------
## Method `Snapshot$add_individual`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Create a new individual
ind <- create_individual(name = "New Patient", age = 35, weight = 70)

# Add the individual to a snapshot
snapshot$add_individual(ind)
} # }

## ------------------------------------------------
## Method `Snapshot$remove_individual`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove an individual from the snapshot
snapshot$remove_individual("Subject_001")
} # }

## ------------------------------------------------
## Method `Snapshot$add_formulation`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Create a new formulation
form <- create_formulation(name = "Tablet", type = "Weibull")

# Add the formulation to a snapshot
snapshot$add_formulation(form)
} # }

## ------------------------------------------------
## Method `Snapshot$remove_formulation`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove a formulation from the snapshot
snapshot$remove_formulation("Tablet")
} # }

## ------------------------------------------------
## Method `Snapshot$remove_population`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove a population from the snapshot
snapshot$remove_population("pop_1")
} # }

## ------------------------------------------------
## Method `Snapshot$add_expression_profile`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Create a new expression profile
profile_data <- list(
  Type = "Enzyme",
  Species = "Human",
  Molecule = "CYP3A4",
  Category = "Healthy",
  Parameters = list()
)
profile <- ExpressionProfile$new(profile_data)

# Add the expression profile to a snapshot
snapshot$add_expression_profile(profile)
} # }

## ------------------------------------------------
## Method `Snapshot$remove_expression_profile`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove an expression profile from the snapshot
snapshot$remove_expression_profile("CYP3A4|Human|Healthy")
} # }
```
