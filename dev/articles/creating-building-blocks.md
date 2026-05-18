# Creating and Managing Building Blocks

``` r

library(osp.snapshots)
library(ospsuite)
```

## Overview

This vignette demonstrates how to create new building blocks from
scratch and manage existing ones within snapshots. You’ll learn to:

- Create individuals, formulations, parameters, compounds, populations,
  expression profiles, protocols, events, and observed data
- Add and remove building blocks from snapshots
- Work with observed data
- Manage collections efficiently

## Setup

Let’s start with a test snapshot:

``` r

snapshot <- load_snapshot("Midazolam")
```

## Creating New Individuals

### Basic Individual Creation

The most common building block to create is an individual:

``` r

# Create a basic individual
new_patient <- create_individual(
  name = "Patient_001",
  species = "Human",
  population = "European_ICRP_2002",
  gender = "FEMALE",
  age = 35,
  weight = 65,
  height = 165
)

new_patient
#> 
#> ── Individual: Patient_001 ─────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: FEMALE
#> • Age: 35 year(s)
#> • Height: 165 cm
#> • Weight: 65 kg
```

### Advanced Individual Creation

You can create individuals with additional parameters:

``` r

# Create individual with more characteristics
advanced_patient <- create_individual(
  name = "Pregnant_Patient",
  species = "Human",
  population = "European_ICRP_2002",
  gender = "FEMALE",
  age = 28,
  weight = 70,
  height = 168,
  gestational_age = 20 # weeks
)

advanced_patient
#> 
#> ── Individual: Pregnant_Patient ────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: FEMALE
#> • Age: 28 year(s)
#> • Gestational Age: 20 week(s)
#> • Height: 168 cm
#> • Weight: 70 kg
```

### Adding Individuals to Snapshots

``` r

# Add the new individual to the snapshot
add_individual(snapshot, new_patient)

# Verify it was added
snapshot$individuals
#> 
#> ── Individuals (3) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)
#> • Patient_001
```

## Creating New Formulations

### Dissolved Formulations

``` r

# Create a simple dissolved formulation
oral_solution <- create_formulation(
  name = "Oral Solution 10mg/mL",
  type = "Dissolved"
)

oral_solution
#> 
#> ── Formulation: Oral Solution 10mg/mL ──────────────────────────────────────────
#> • Type: Dissolved
```

### Tablet Formulations

``` r

# Create a tablet with Weibull dissolution
tablet <- create_formulation(
  name = "Immediate Release Tablet",
  type = "Weibull",
  parameters = list(
    dissolution_time = 30, # 50% dissolved in 30 min
    dissolution_time_unit = "min",
    lag_time = 5, # 5 min lag time
    lag_time_unit = "min",
    dissolution_shape = 1.2, # shape parameter
    suspension = TRUE # use as suspension
  )
)

tablet
#> 
#> ── Formulation: Immediate Release Tablet ───────────────────────────────────────
#> • Type: Weibull
#> 
#> ── Parameters ──
#> 
#> • Dissolution time (50% dissolved): 30 min
#> • Lag time: 5 min
#> • Dissolution shape: 1.2
#> • Use as suspension: 1
```

### Additional Formulation Types

``` r

# Create a first-order formulation
first_order_form <- create_formulation(
  name = "First Order Release",
  type = "First Order",
  parameters = list(
    thalf = 60,
    thalf_unit = "min"
  )
)

# Create a zero-order formulation
zero_order_form <- create_formulation(
  name = "Zero Order Release",
  type = "Zero Order",
  parameters = list(
    end_time = 120,
    end_time_unit = "min"
  )
)

# Display the formulations
first_order_form
#> 
#> ── Formulation: First Order Release ────────────────────────────────────────────
#> • Type: First Order
#> 
#> ── Parameters ──
#> 
#> • t1/2: 60 min
zero_order_form
#> 
#> ── Formulation: Zero Order Release ─────────────────────────────────────────────
#> • Type: Zero Order
#> 
#> ── Parameters ──
#> 
#> • End time: 120 min
```

### Adding Formulations to Snapshots

``` r

# Add formulations to the snapshot
add_formulation(snapshot, oral_solution)
add_formulation(snapshot, tablet)

# Check they were added
snapshot$formulations
#> 
#> ── Formulations (4) ────────────────────────────────────────────────────────────
#> • Oral solution (Dissolved)
#> • Tablet (Dormicum) (Weibull)
#> • Oral Solution 10mg/mL (Dissolved)
#> • Immediate Release Tablet (Weibull)
```

## Creating Parameters

### Basic Parameter Creation

``` r

# Create a parameter with basic properties
liver_param <- create_parameter(
  name = "Organism|Liver|Specific organ clearance",
  value = 0.5,
  unit = "1/min"
)

liver_param
#> 
#> ── Parameter: Organism|Liver|Specific organ clearance 
#> • Value: 0.5
#> • Unit: 1/min
```

### Parameter with Additional Properties

``` r

# Create parameter with source information
detailed_param <- create_parameter(
  name = "Organism|Kidney|GFR",
  value = 120,
  unit = "ml/min",
  source = "Literature",
  description = "Normal adult GFR",
  source_id = 123
)

detailed_param
#> 
#> ── Parameter: Organism|Kidney|GFR 
#> • Value: 120
#> • Unit: ml/min
#> • Source: Literature
#> • Description: Normal adult GFR
```

## Creating Compounds

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
wraps `Compound$new()` so you can build a \[Compound\] from named
arguments instead of a raw list.

``` r

# Create a minimal compound
drug <- create_compound(name = "Drug X")

# Create a small molecule with molecular weight and binding partner
drug <- create_compound(
  name = "Drug X",
  is_small_molecule = TRUE,
  molecular_weight = 250.3,
  plasma_protein_binding_partner = "Albumin",
  parameters = list(
    create_parameter(name = "Cl_spec", value = 5, unit = "ml/min/kg")
  )
)

drug
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> • Type: Small Molecule
#> • Plasma Protein Binding Partner: Albumin
#> • Molecular Weight: 250.3 g/mol
#> 
#> ── Physicochemical Properties ──
#> 
#> ── Additional Parameters ──
#> 
#> • Additional Parameters (1 total):
#>   • Cl_spec: 5 ml/min/kg [Unknown]
```

## Creating Populations

[`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md)
builds a \[Population\] recipe: settings used by PK-Sim to sample a
cohort at simulation time. Use \[range()\] for age, weight, height, and
BMI bounds.

``` r

adults <- create_population(
  name = "Healthy Adults",
  number_of_individuals = 50,
  proportion_of_females = 50,
  species = "Human",
  source_population = "European_ICRP_2002",
  age_range = range(20, 60, "year(s)"),
  weight_range = range(50, 90, "kg")
)

adults
#> 
#> ── Population: Healthy Adults ──
#> 
#> Source Population: European_ICRP_2002
#> Number of individuals: 50
#> Proportion of females: 50%
#> Age range: 20 - 60 year(s)
#> Weight range: 50 - 90 kg
```

## Creating Expression Profiles

[`create_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_expression_profile.md)
builds an \[ExpressionProfile\]. The identity of a profile is the
composite `Molecule|Species|Category`, so all three are required, along
with the molecule `type`.

``` r

cyp3a4 <- create_expression_profile(
  molecule = "CYP3A4",
  species = "Human",
  category = "Healthy",
  type = "Enzyme",
  ontogeny = "CYP3A4"
)

cyp3a4
#> 
#> ── Expression Profile: CYP3A4 (Enzyme) ─────────────────────────────────────────
#> • Species: Human
#> • Category: Healthy
#> • Ontogeny: CYP3A4
```

## Creating Protocols

[`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md)
builds a \[Protocol\]. By default it creates a Simple Protocol; pass
`schemas` to create an Advanced Protocol.

``` r

# Simple oral protocol with one dose
single_dose <- create_protocol(
  name = "Single dose 10mg",
  application_type = "Oral",
  dosing_interval = "Single",
  parameters = list(
    create_parameter(name = "Start time", value = 0, unit = "h"),
    create_parameter(name = "InputDose", value = 10, unit = "mg")
  )
)

single_dose
#> 
#> ── Protocol: Single dose 10mg ──────────────────────────────────────────────────
#> • Type: Simple
#> • Application Type: Oral
#> • Dosing Interval: Once
#> 
#> ── Parameters ──
#> 
#> • Start time: 0 h
#> • InputDose: 10 mg
```

## Creating Events

[`create_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event.md)
builds an \[Event\] from a named template (for example a meal). PK-Sim
clones the template and applies your parameter overrides.

``` r

breakfast <- create_event(
  name = "Breakfast",
  template = "Meal: Standard (Human)",
  parameters = list(
    create_parameter(name = "Meal energy content", value = 500, unit = "kcal"),
    create_parameter(name = "Meal volume", value = 0.3, unit = "l")
  )
)

breakfast
#> 
#> ── Event: Breakfast ────────────────────────────────────────────────────────────
#> • Template: Meal: Standard (Human)
#> 
#> ── Parameters: ──
#> 
#> • Meal energy content: 500 kcal
#> • Meal volume: 0.3 l
```

## Creating Observed Data

[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)
builds an
[`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
from named arguments for the time grid, measurement values, units, and
optional error series.

``` r

obs <- create_observed_data(
  name = "Phase I - Subject 001",
  time = c(0, 0.5, 1, 2, 4, 8, 12, 24),
  values = c(0, 12.5, 18.2, 15.8, 11.2, 6.8, 3.4, 1.1),
  time_unit = "h",
  value_unit = "mg/l",
  value_dimension = "Concentration (mass)"
)

obs
#> <DataSet>
#>   • Name: Phase I - Subject 001
#>   • X dimension: Time
#>   • X unit: h
#>   • Y dimension: Concentration (mass)
#>   • Y unit: mg/l
#>   • Error type: NULL
#>   • Error unit: NULL
#>   • Molecular weight: NULL
#>   • LLOQ: NULL
#> Meta data:
```

## Managing Building Blocks

### Removing Building Blocks

``` r

# Remove individuals by name
remove_individual(snapshot, "Patient_001")

# Remove multiple individuals at once
# remove_individual(snapshot, c("Patient_001", "Patient_002"))

# Remove formulations
remove_formulation(snapshot, "Oral Solution 10mg/mL")

# Remove populations
# remove_population(snapshot, "Population_Name")

# Remove expression profiles by ID (molecule|species|category)
# remove_expression_profile(snapshot, "CYP3A4|Human|Healthy")
```

### Batch Operations

``` r

# Create multiple individuals at once
patients <- list(
  create_individual("Patient_A", age = 25, gender = "MALE"),
  create_individual("Patient_B", age = 45, gender = "FEMALE"),
  create_individual("Patient_C", age = 65, gender = "MALE")
)

# Add them all
for (patient in patients) {
  add_individual(snapshot, patient)
}

# Verify
snapshot$individuals
#> 
#> ── Individuals (5) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)
#> • Patient_A
#> • Patient_B
#> • Patient_C
```

## Working with Observed Data

### Creating DataSet Objects

Observed data must be provided as
[`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
objects:

``` r

# Create a new DataSet
study_data <- DataSet$new(name = "Phase I Study - Subject 001")

# Set the data values
time_points <- c(0, 0.5, 1, 2, 4, 8, 12, 24)
concentrations <- c(0, 12.5, 18.2, 15.8, 11.2, 6.8, 3.4, 1.1)

study_data$setValues(xValues = time_points, yValues = concentrations)

# Set dimensions and units
study_data$xDimension <- "Time"
study_data$xUnit <- "h"
study_data$yDimension <- "Concentration (mass)"
study_data$yUnit <- "mg/l"

study_data
#> <DataSet>
#>   • Name: Phase I Study - Subject 001
#>   • X dimension: Time
#>   • X unit: h
#>   • Y dimension: Concentration (mass)
#>   • Y unit: mg/l
#>   • Error type: NULL
#>   • Error unit: NULL
#>   • Molecular weight: NULL
#>   • LLOQ: NULL
#> Meta data:
```

### Adding Observed Data

``` r

# Add to snapshot (function needs to be implemented)
# add_observed_data(snapshot, study_data)

# Remove observed data by name
# remove_observed_data(snapshot, "Phase I Study - Subject 001")
```

## Advanced Building Block Management

### Modifying Existing Building Blocks

``` r

# Get an individual and modify properties
patient <- snapshot$individuals$`Patient_A`
patient$age <- 30
patient$weight <- 75

# Add custom parameters
custom_param <- create_parameter(
  name = "Organism|Custom|Clearance",
  value = 1.5,
  unit = "L/h"
)

# Note: Adding parameters to existing individuals requires
# working with the parameter collection directly
```

### Copying and Modifying Building Blocks

``` r

# Create a copy of an existing individual with modifications
original <- snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`

# Create modified copy
modified_individual <- create_individual(
  name = "Modified European",
  species = original$species,
  population = original$population,
  gender = original$gender,
  age = 50, # Changed age
  weight = 80 # Changed weight
)

add_individual(snapshot, modified_individual)
```

### Validation and Error Handling

The package includes validation for common inputs:

``` r

# These will produce validation errors:
tryCatch(
  {
    create_individual(
      name = "Invalid Patient",
      species = "InvalidSpecies", # Invalid species
      gender = "OTHER" # Invalid gender
    )
  },
  error = function(e) cat("Error:", e$message, "\n")
)
#> Error: Invalid species: InvalidSpecies

tryCatch(
  {
    create_formulation(
      name = "Invalid Form",
      type = "NonexistentType" # Invalid formulation type
    )
  },
  error = function(e) cat("Error:", e$message, "\n")
)
#> Error: subscript out of bounds
```

Valid options are available through validation functions:

``` r

# Check valid species (this would show available options)
# validate_species("Human")  # Returns TRUE

# Check valid genders
# validate_gender("MALE")    # Returns TRUE
```

## Working with Templates

You can load predefined templates and modify them:

``` r

# Load a template (if available)
# template_snapshot <- load_snapshot("TemplateName")

# Modify template building blocks
# template_individual <- template_snapshot$individuals[[1]]
# template_individual$age <- 40

# Add to your snapshot
# add_individual(snapshot, template_individual)
```

## Exporting Your Work

After creating and managing building blocks, export your snapshot:

``` r

# Export the modified snapshot
export_snapshot(snapshot, "modified_snapshot_with_new_blocks.json")
```

## Best Practices

### Naming Conventions

Use descriptive names for building blocks:

``` r

# Good naming
create_individual(
  "Elderly_Female_80kg",
  age = 75,
  gender = "FEMALE",
  weight = 80
)
create_formulation("IR_Tablet_Fast_Release", type = "Weibull")

# Less descriptive
create_individual("Patient1", age = 75)
create_formulation("Form1", type = "Weibull")
```

### Organization

Keep related building blocks together:

``` r

# Create a family of related individuals
pediatric_patients <- list(
  create_individual("Pediatric_5yr", age = 5, weight = 18),
  create_individual("Pediatric_10yr", age = 10, weight = 32),
  create_individual("Pediatric_15yr", age = 15, weight = 55)
)

# Create related formulations
pediatric_formulations <- list(
  create_formulation("Oral_Suspension_Pediatric", type = "Dissolved"),
  create_formulation("Chewable_Tablet_Pediatric", type = "Weibull")
)
```

### Documentation

Document your building blocks with meaningful metadata:

``` r

# Add comments or descriptions when creating parameters
hepatic_clearance <- create_parameter(
  name = "Organism|Liver|Hepatic clearance",
  value = 2.5,
  unit = "L/h",
  description = "Estimated from in vitro data scaled with ISEF=0.5",
  source = "Laboratory study 2023"
)
```

## Next Steps

- Explore data frame conversion in
  [`vignette("working-with-dataframes")`](https://esqlabs.github.io/osp.snapshots/dev/articles/working-with-dataframes.md)
- See the complete API reference at [function
  reference](https://esqlabs.github.io/osp.snapshots/reference/)
