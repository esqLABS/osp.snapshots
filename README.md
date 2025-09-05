
# osp.snapshots

<!-- badges: start -->

[![R-CMD-check](https://github.com/esqLABS/osp.snapshots/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/esqLABS/osp.snapshots/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/esqLABS/osp.snapshots/graph/badge.svg)](https://app.codecov.io/gh/esqLABS/osp.snapshots)
<!-- badges: end -->

The goal of osp.snapshots is to provide an R interface to work with
PK-Sim project snapshots.

## Installation

You can install the development version of osp.snapshots from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("esqLABS/osp.snapshots")
```

## Basic Usage

### Importing a Snapshot

``` r
library(osp.snapshots)

# Load a snapshot from a JSON file
snapshot <- load_snapshot("path/to/snapshot.json")
```

For this demo, we’ll use a test snapshot included with the package:

``` r
library(osp.snapshots)
#> 
#> Attaching package: 'osp.snapshots'
#> The following object is masked from 'package:base':
#> 
#>     range
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(magrittr)

# Load the test snapshot
snapshot_path <- system.file("extdata", "test_snapshot.json", package = "osp.snapshots")
snapshot <- load_snapshot(snapshot_path)
#> ℹ Reading snapshot from '/private/var/folders/_6/hdp78hfx2qg6415svlx5rb680000gn/T/Rtmpm8wOi0/temp_libpathf209764b7e64/osp.snapshots/extdata/test_snapshot.json'
#> ✔ Snapshot loaded successfully

# View snapshot overview
snapshot
#> 
#> ── PKSIM Snapshot ──────────────────────────────────────────────────────────────
#> ℹ Version: 79 (PKSIM 11.2)
#> ℹ Path: '../../../../private/var/folders/_6/hdp78hfx2qg6415svlx5rb680000gn/T/Rtmpm8wOi0/temp_libpathf209764b7e64/osp.snapshots/extdata/test_snapshot.json'
#> • Compounds: 6
#> • Events: 10
#> • ExpressionProfiles: 14
#> • Formulations: 9
#> • Individuals: 5
#> • ObservedData: 64
#> • ObservedDataClassifications: 20
#> • ObserverSets: 1
#> • ParameterIdentifications: 1
#> • Populations: 7
#> • Protocols: 9
#> • Simulations: 2
```

### Exploring Snapshot Contents

``` r
# List all individuals in the snapshot
snapshot$individuals
#> 
#> ── Individuals (5) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)
#> • ind_modified
#> • Asian
#> • CKD

# Get a detailed view of a building block
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
#> 
#> ── Individual: European (P-gp modified, CYP3A4 36 h) | Seed: 17189110 ──────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: MALE
#> • Age: 30 year(s)
#> • Calculation Methods:
#>   • SurfaceAreaPlsInt_VAR1
#>   • Body surface area - Mosteller
#> 
#> ── Parameters ──
#> 
#> • Organism|Gallbladder|Gallbladder ejection fraction: 0.8
#> • Organism|Liver|EHC continuous fraction: 1
#> 
#> ── Expression Profiles ──
#> 
#> • CYP3A4|Human|Healthy
#> • AADAC|Human|Healthy
#> • P-gp|Human|Healthy
#> • OATP1B1|Human|Healthy
#> • ATP1A2|Human|Healthy
#> • UGT1A4|Human|Healthy
#> • GABRG2|Human|Healthy

# All fields are accessible as list elements
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$age
#> [1] 30
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$gender
#> [1] "MALE"

# Parameters are also accessible as list element but they have their own nested structure and behavior
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$parameters
#> Parameter Collection with 2 parameters:
#> Name                                     | Value           | Unit
#> -----------------------------------------|-----------------|----------------
#> ...bladder|Gallbladder ejection fraction | 0.8             | 
#> Organism|Liver|EHC continuous fraction   | 1               |

# They can be accessed by path
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$parameters$`Organism|Gallbladder|Gallbladder ejection fraction`
#> 
#> ── Parameter: Organism|Gallbladder|Gallbladder ejection fraction 
#> • Value: 0.8
#> • Source: Publication
#> • Description: R24-4081
```

### Exploring Other Collections

The snapshot provides access to all building block types used in PK-Sim:

``` r
# View all compounds
snapshot$compounds
#> 
#> ── Compounds (6) ───────────────────────────────────────────────────────────────
#> • Rifampicin
#> • BI 123456
#> • Perpetrator_2
#> • BI 100777- initial table parameters
#> • BI 100777
#> • test

# View all populations  
snapshot$populations
#> 
#> ── Populations (7) ─────────────────────────────────────────────────────────────
#> • pop_1 [Source: European_ICRP_2002] (100 individuals)
#> • pop2 [Source: European_ICRP_2002] (10 individuals)
#> • pop3 [Source: Asian_Tanaka_1996] (10 individuals)
#> • pop4 [Source: European_ICRP_2002] (10 individuals)
#> • pop6 [Source: European_ICRP_2002] (15 individuals)
#> • pop7 [Source: Asian_Tanaka_1996] (12 individuals)
#> • pop [Source: European_ICRP_2002] (100 individuals)

# View all events
snapshot$events
#> 
#> ── Events (10) ─────────────────────────────────────────────────────────────────
#> • GB emptying (Gallbladder emptying)
#> • urinary (Urinary bladder emptying)
#> • urinary2 (Urinary bladder emptying) - 1 parameter
#> • Standard Meal (Meal: Standard (Human))
#> • High fat Breakfast (Meal: High-fat breakfast (Human))
#> • Ensure plus (Meal: Ensure Plus (Human))
#> • High fat soup (Meal: High-fat soup (Human))
#> • mixed (Meal: Mixed solid/liquid meal (Human))
#> • Dextrose_1984 (Meal: Dextrose solution (Human)) - 3 parameters
#> • Egg sandwich (Meal: Egg sandwich (Human)) - 2 parameters

# View all protocols
snapshot$protocols
#> 
#> ── Protocols (9) ───────────────────────────────────────────────────────────────
#> • Backman 1996 - Midazolam - 15 mg (Control) (Advanced - 1 schema)
#> • Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56) (Advanced - 4
#> schemas)
#> • Kharasch 2011 - Midazolam - iv 1 mg and po 3 mg (with Rifampicin) (Advanced -
#> 2 schemas)
#> • Shin 2016 - Midazolam - iv 1 mg (Control) (Simple - Intravenous bolus - Once)
#> • Yu 2004 - Rifampicin - 600 mg MD OD 10 days (Advanced - 1 schema)
#> • Wiesinger - Rifampicin - low dose and high dose OD (Advanced - 2 schemas)
#> • test 6-6-12 till 48 (Simple - Oral - 3 times a day)
#> • test 12-12 till 24 (Simple - Intravenous bolus - 2 times a day)
#> • test_single_34 (Advanced - 1 schema)

# View all expression profiles
snapshot$expression_profiles
#> 
#> ── Expression Profiles (14) ────────────────────────────────────────────────────
#> • CYP3A4 (Enzyme, Human, Healthy)
#> • AADAC (Enzyme, Human, Healthy)
#> • P-gp (Transporter, Human, Healthy)
#> • OATP1B1 (Transporter, Human, Healthy)
#> • ATP1A2 (OtherProtein, Human, Healthy)
#> • UGT1A4 (Enzyme, Human, Healthy)
#> • GABRG2 (OtherProtein, Human, Healthy)
#> • CYP3A4 (Enzyme, Human, Korean (Yu 2004 study))
#> • AADAC (Enzyme, Human, Korean (Yu 2004 study))
#> • P-gp (Transporter, Human, Korean (Yu 2004 study))
#> • OATP1B1 (Transporter, Human, Korean (Yu 2004 study))
#> • ATP1A2 (OtherProtein, Human, Korean (Yu 2004 study))
#> • UGT1A4 (Enzyme, Human, Korean (Yu 2004 study))
#> • GABRG2 (OtherProtein, Human, Korean (Yu 2004 study))

# View all formulations
snapshot$formulations
#> 
#> ── Formulations (9) ────────────────────────────────────────────────────────────
#> • Tablet (Dormicum) (Weibull)
#> • Oral solution (Dissolved)
#> • form_dissolved (Dissolved)
#> • form_Lint80 (Lint80)
#> • form-particle-dissolution (Particle)
#> • form-table (Table)
#> • form-ZO (Zero Order)
#> • form-FO (First Order)
#> • form-particle-dissolution-2 (Particle)
```

### Working with Observed Data

The snapshot contains observed data that can be easily accessed and
manipulated:

``` r
# View all observed data in the snapshot
snapshot$observed_data
#> 
#> ── Observed Data (64) ──────────────────────────────────────────────────────────
#> • Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg -
#> Plasma - agg. (n=10)
#> • Backman 1996 - with Perpetrator (Rifampicin) - Midazolam - PO - 15 mg -
#> Plasma - agg. (n=10)
#> • Backman 1998 - Phase I (Control (Perpetrator Placebo)) - Midazolam - PO - 15
#> mg - Plasma - agg. (n=9)
#> • Backman 1998 - Phase IV (during Perpetrator (Rifampicin)) - Midazolam - PO -
#> 15 mg - Plasma - agg. (n=9)
#> • Backman 1998 - Phase V (4 days after Perpetrator (Rifampicin)) - Midazolam -
#> PO - 15 mg - Plasma - agg. (n=9)
#> ... and 59 more

# Access a specific observed data set
first_obs_data <- snapshot$observed_data[[1]]
first_obs_data
#> <DataSet>
#>   • Name: Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg
#>   - Plasma - agg. (n=10)
#>   • X dimension: Time
#>   • X unit: h
#>   • Y dimension: Concentration (mass)
#>   • Y unit: mg/l
#>   • Error type: NULL
#>   • Error unit: NULL
#>   • Molecular weight: NULL
#>   • LLOQ: NULL
#> Meta data:
#>   • DB Version: OSP DATABASE
#>   • ID: 53
#>   • Study Id: Backman 1996
#>   • Reference: https://www.ncbi.nlm.nih.gov/pubmed/8549036
#>   • Source: Fig. 1
#>   • Grouping: Control (Perpetrator Placebo)
#>   • Data type: aggregated
#>   • N: 10
#>   • Molecule: BI 123456
#>   • Species: Human
#>   • Organ: Peripheral Venous Blood
#>   • Compartment: Plasma
#>   • Route: PO
#>   • Dose: 15 mg
#>   • Times of Administration [h]: 0
#>   • Formulation: Dormicum, tablet
#>   • Food state: fasted
#>   • Comment: Arith. SEM converted to arith. SD

# Observed data are DataSet objects from the ospsuite package
class(first_obs_data)
#> [1] "DataSet"       "DotNetWrapper" "NetObject"     "R6"
```

### Modifying Building Blocks

All these elements are mutable and can be modified in place.

``` r
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$age <- 35

snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$value <- 0.6

snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
#> 
#> ── Individual: European (P-gp modified, CYP3A4 36 h) | Seed: 17189110 ──────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: MALE
#> • Age: 35 year(s)
#> • Calculation Methods:
#>   • SurfaceAreaPlsInt_VAR1
#>   • Body surface area - Mosteller
#> 
#> ── Parameters ──
#> 
#> • Organism|Gallbladder|Gallbladder ejection fraction: 0.6
#> • Organism|Liver|EHC continuous fraction: 1
#> 
#> ── Expression Profiles ──
#> 
#> • CYP3A4|Human|Healthy
#> • AADAC|Human|Healthy
#> • P-gp|Human|Healthy
#> • OATP1B1|Human|Healthy
#> • ATP1A2|Human|Healthy
#> • UGT1A4|Human|Healthy
#> • GABRG2|Human|Healthy
```

## Creating new building blocks

### Creating a New Individual

``` r
# Create a new individual
new_individual <- create_individual(
  name = "Patient_001",
  species = "Human",
  population = "European_ICRP_2002",
  gender = "MALE",
  age = 45,
  weight = 85,
  height = 180
)

# Display the new individual
new_individual
#> 
#> ── Individual: Patient_001 ─────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: MALE
#> • Age: 45 year(s)
#> • Height: 180 cm
#> • Weight: 85 kg

# Add to snapshot
add_individual(snapshot, new_individual)
#> ✔ Added individual 'Patient_001' to the snapshot

# Verify it was added
snapshot$individuals
#> 
#> ── Individuals (6) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)
#> • ind_modified
#> • Asian
#> • CKD
#> • Patient_001
```

### Creating a New Formulation

``` r
# Create a simple dissolved formulation
dissolved_form <- create_formulation(
  name = "Oral Solution",
  type = "Dissolved"
)

# Create a tablet formulation with Weibull dissolution profile
tablet_form <- create_formulation(
  name = "Standard Tablet",
  type = "Weibull",
  parameters = list(
    dissolution_time = 60,
    dissolution_time_unit = "min",
    lag_time = 10,
    lag_time_unit = "min",
    dissolution_shape = 0.92,
    suspension = TRUE
  )
)

# Display the tablet formulation
tablet_form
#> 
#> ── Formulation: Standard Tablet ────────────────────────────────────────────────
#> • Type: Weibull
#> 
#> ── Parameters ──
#> 
#> • Dissolution time (50% dissolved): 60 min
#> • Lag time: 10 min
#> • Dissolution shape: 0.92
#> • Use as suspension: 1

# Add to snapshot
add_formulation(snapshot, tablet_form)
#> ✔ Added formulation 'Standard Tablet' to the snapshot

# Verify it was added
snapshot$formulations
#> 
#> ── Formulations (10) ───────────────────────────────────────────────────────────
#> • Tablet (Dormicum) (Weibull)
#> • Oral solution (Dissolved)
#> • form_dissolved (Dissolved)
#> • form_Lint80 (Lint80)
#> • form-particle-dissolution (Particle)
#> • form-table (Table)
#> • form-ZO (Zero Order)
#> • form-FO (First Order)
#> • form-particle-dissolution-2 (Particle)
#> • Standard Tablet (Weibull)
```

### Managing Building Blocks

You can add and remove various building blocks from snapshots:

#### Managing Observed Data

Observed data should be provided as `ospsuite::DataSet` objects:

``` r
# Create a new DataSet object (this is just an example)
library(ospsuite)
new_dataset <- DataSet$new()
new_dataset$setValues(xValues = c(0, 1, 2, 4, 8), yValues = c(100, 80, 60, 40, 20))
new_dataset$name <- "New Study Data"
new_dataset$xDimension <- "Time"
new_dataset$xUnit <- "h" 
new_dataset$yDimension <- "Concentration"
new_dataset$yUnit <- "mg/l"

# Add to snapshot
add_observed_data(snapshot, new_dataset)

# Remove observed data by name
remove_observed_data(snapshot, "New Study Data")
```

#### Removing Other Building Blocks

All building block types can be removed by name:

``` r
# Remove individuals
remove_individual(snapshot, "Patient_001")
remove_individual(snapshot, c("Patient_001", "Patient_002"))  # Multiple at once

# Remove formulations
remove_formulation(snapshot, "Standard Tablet")

# Remove populations
remove_population(snapshot, "Population_1")

# Remove expression profiles (by ID: molecule|species|category)
remove_expression_profile(snapshot, "CYP3A4|Human|Healthy")
```

## Exporting Modified Snapshots

After making modifications to a snapshot, you can export it back to a
JSON file using the `export_snapshot()` function. It can then be
imported back to PK-Sim.

``` r
export_snapshot(snapshot, "path/to/modified_snapshot.json")
```

## Converting to Data Frames

You can convert snapshot elements to data frames for easier analysis,
visualization, and integration with other R tools.

### Converting Individuals

You can convert all individuals in a snapshot to combined data frames:

``` r
# Get data frames for all individuals in the snapshot
dfs <- get_individuals_dfs(snapshot)
dfs
```

| individual_id | name | seed | species | population | gender | age | age_unit | gestational_age | gestational_age_unit | weight | weight_unit | height | height_unit | disease_state | calculation_methods | disease_state_parameters |
|:---|:---|---:|:---|:---|:---|---:|:---|---:|:---|---:|:---|---:|:---|:---|:---|:---|
| European (P-gp modified, CYP3A4 36 h) | European (P-gp modified, CYP3A4 36 h) | 17189110 | Human | European_ICRP_2002 | MALE | 35.0 | year(s) | NA | NA | NA | NA | NA | NA | NA | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | NA |
| Korean (Yu 2004 study) | Korean (Yu 2004 study) | 52995890 | Human | Asian_Tanaka_1996 | MALE | 23.3 | year(s) | NA | NA | 66.9 | kg | 172.9 | cm | NA | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | NA |
| ind_modified | ind_modified | 487796515 | Human | BlackAmerican_NHANES_1997 | MALE | 56.0 | year(s) | NA | NA | NA | NA | 180.0 | cm | NA | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | NA |
| Asian | Asian | 918371890 | Human | Asian_Tanaka_1996 | MALE | 26.0 | year(s) | NA | NA | 67.0 | kg | NA | NA | NA | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | NA |
| CKD | CKD | 1515438109 | Human | European_ICRP_2002 | MALE | 50.0 | year(s) | NA | NA | 70.0 | kg | 178.0 | cm | CKD | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | eGFR: 45 ml/min/1.73m² |
| Patient_001 | Patient_001 | NA | Human | European_ICRP_2002 | MALE | 45.0 | year(s) | NA | NA | 85.0 | kg | 180.0 | cm | NA | NA | NA |

| individual_id | path | value | unit | source | description | source_id |
|:---|:---|---:|:---|:---|:---|---:|
| European (P-gp modified, CYP3A4 36 h) | Organism\|Gallbladder\|Gallbladder ejection fraction | 0.60 | NA | Publication | R24-4081 | NA |
| European (P-gp modified, CYP3A4 36 h) | Organism\|Liver\|EHC continuous fraction | 1.00 | NA | Publication | R24-4081 | NA |
| Korean (Yu 2004 study) | Organism\|Liver\|EHC continuous fraction | 1.00 | NA | Unknown | NA | NA |
| Korean (Yu 2004 study) | Organism\|Ontogeny factor (albumin) | 0.89 | NA | Publication | R24-4081 | NA |
| ind_modified | Organism\|Kidney\|GFR (specific) | 33.00 | ml/min/100g organ | Other | Assumed | 15 |

| individual_id | profile |
|:---|:---|
| European (P-gp modified, CYP3A4 36 h) | CYP3A4\|Human\|Healthy |
| European (P-gp modified, CYP3A4 36 h) | AADAC\|Human\|Healthy |
| European (P-gp modified, CYP3A4 36 h) | P-gp\|Human\|Healthy |
| European (P-gp modified, CYP3A4 36 h) | OATP1B1\|Human\|Healthy |
| European (P-gp modified, CYP3A4 36 h) | ATP1A2\|Human\|Healthy |
| European (P-gp modified, CYP3A4 36 h) | UGT1A4\|Human\|Healthy |
| European (P-gp modified, CYP3A4 36 h) | GABRG2\|Human\|Healthy |
| Korean (Yu 2004 study) | CYP3A4\|Human\|Korean (Yu 2004 study) |
| Korean (Yu 2004 study) | AADAC\|Human\|Korean (Yu 2004 study) |
| Korean (Yu 2004 study) | P-gp\|Human\|Korean (Yu 2004 study) |
| Korean (Yu 2004 study) | OATP1B1\|Human\|Korean (Yu 2004 study) |
| Korean (Yu 2004 study) | ATP1A2\|Human\|Korean (Yu 2004 study) |
| Korean (Yu 2004 study) | UGT1A4\|Human\|Korean (Yu 2004 study) |
| Korean (Yu 2004 study) | GABRG2\|Human\|Korean (Yu 2004 study) |
| Asian | CYP3A4\|Human\|Healthy |
| CKD | CYP3A4\|Human\|Korean (Yu 2004 study) |

It is also possible to get dataframe for a specific individual using
`to_df()` method on an individual object:

``` r
individual_df <- snapshot$individuals[[1]]$to_df()
individual_df
```

| individual_id | name | seed | species | population | gender | age | age_unit | gestational_age | gestational_age_unit | weight | weight_unit | height | height_unit | disease_state | calculation_methods | disease_state_parameters |
|:---|:---|---:|:---|:---|:---|---:|:---|---:|:---|---:|:---|---:|:---|:---|:---|:---|
| European (P-gp modified, CYP3A4 36 h) | European (P-gp modified, CYP3A4 36 h) | 17189110 | Human | European_ICRP_2002 | MALE | 35 | year(s) | NA | NA | NA | NA | NA | NA | NA | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | NA |

| individual_id | path | value | unit | source | description | source_id |
|:---|:---|---:|:---|:---|:---|---:|
| European (P-gp modified, CYP3A4 36 h) | Organism\|Gallbladder\|Gallbladder ejection fraction | 0.6 | NA | Publication | R24-4081 | NA |
| European (P-gp modified, CYP3A4 36 h) | Organism\|Liver\|EHC continuous fraction | 1.0 | NA | Publication | R24-4081 | NA |

| individual_id                         | profile                 |
|:--------------------------------------|:------------------------|
| European (P-gp modified, CYP3A4 36 h) | CYP3A4\|Human\|Healthy  |
| European (P-gp modified, CYP3A4 36 h) | AADAC\|Human\|Healthy   |
| European (P-gp modified, CYP3A4 36 h) | P-gp\|Human\|Healthy    |
| European (P-gp modified, CYP3A4 36 h) | OATP1B1\|Human\|Healthy |
| European (P-gp modified, CYP3A4 36 h) | ATP1A2\|Human\|Healthy  |
| European (P-gp modified, CYP3A4 36 h) | UGT1A4\|Human\|Healthy  |
| European (P-gp modified, CYP3A4 36 h) | GABRG2\|Human\|Healthy  |

### Converting Formulations

Similar to individuals, you can convert formulations to data frames:

``` r
# Get data frames for all formulations in the snapshot
formulation_dfs <- get_formulations_dfs(snapshot)
formulation_dfs
```

| formulation_id | name | formulation | formulation_type |
|:---|:---|:---|:---|
| Tablet (Dormicum) | Tablet (Dormicum) | Formulation_Tablet_Weibull | Weibull |
| Oral solution | Oral solution | Formulation_Dissolved | Dissolved |
| form_dissolved | form_dissolved | Formulation_Dissolved | Dissolved |
| form_Lint80 | form_Lint80 | Formulation_Tablet_Lint80 | Lint80 |
| form-particle-dissolution | form-particle-dissolution | Formulation_Particles | Particle |
| form-table | form-table | Formulation_Table | Table |
| form-ZO | form-ZO | Formulation_ZeroOrder | Zero Order |
| form-FO | form-FO | Formulation_FirstOrder | First Order |
| form-particle-dissolution-2 | form-particle-dissolution-2 | Formulation_Particles | Particle |
| Standard Tablet | Standard Tablet | Formulation_Tablet_Weibull | Weibull |

| formulation_id | name | value | unit | is_table_point | x_value | y_value | table_name | source | description | source_id |
|:---|:---|---:|:---|:---|---:|---:|:---|:---|:---|---:|
| Tablet (Dormicum) | Dissolution time (50% dissolved) | 0.0107481 | min | FALSE | NA | NA | NA | ParameterIdentification | Value updated from ‘PI Tablet 7.5 mg’ on 2019-04-09 16:30 | NA |
| Tablet (Dormicum) | Lag time | 12.0000000 | min | FALSE | NA | NA | NA | Publication | c01835608 | NA |
| Tablet (Dormicum) | Dissolution shape | 4.3802943 | NA | FALSE | NA | NA | NA | ParameterIdentification | Value updated from ‘PI Tablet 7.5 mg’ on 2019-04-09 16:30 | NA |
| Tablet (Dormicum) | Use as suspension | 1.0000000 | NA | FALSE | NA | NA | NA | Other | Assumed | NA |
| form_Lint80 | Dissolution time (80% dissolved) | 240.0000000 | min | FALSE | NA | NA | NA | Publication | R13-5357 | NA |
| form_Lint80 | Lag time | 0.0000000 | min | FALSE | NA | NA | NA | Publication | R13-5357 | NA |
| form_Lint80 | Use as suspension | 1.0000000 | NA | FALSE | NA | NA | NA | Other | Assumed | NA |
| form-particle-dissolution | Thickness (unstirred water layer) | 30.0000000 | µm | FALSE | NA | NA | NA | NA | NA | NA |
| form-particle-dissolution | Type of particle size distribution | 0.0000000 | NA | FALSE | NA | NA | NA | Other | Assumed | NA |
| form-particle-dissolution | Particle radius (mean) | 10.0000000 | µm | FALSE | NA | NA | NA | Publication | c01835608 | NA |
| form-table | Fraction (dose) | 0.0000000 | NA | FALSE | NA | NA | NA | NA | NA | NA |
| form-table | Fraction (dose) | NA | NA | TRUE | 0.0 | 0.0 | Time | NA | NA | NA |
| form-table | Fraction (dose) | NA | NA | TRUE | 0.1 | 0.1 | Time | NA | NA | NA |
| form-table | Fraction (dose) | NA | NA | TRUE | 0.5 | 0.6 | Time | NA | NA | NA |
| form-table | Fraction (dose) | NA | NA | TRUE | 1.0 | 0.7 | Time | NA | NA | NA |
| form-table | Fraction (dose) | NA | NA | TRUE | 3.0 | 0.8 | Time | NA | NA | NA |
| form-table | Fraction (dose) | NA | NA | TRUE | 7.0 | 0.9 | Time | NA | NA | NA |
| form-table | Use as suspension | 1.0000000 | NA | FALSE | NA | NA | NA | Publication | c26475781 | NA |
| form-ZO | End time | 60.0000000 | min | FALSE | NA | NA | NA | NA | NA | NA |
| form-FO | t1/2 | 0.0100000 | min | FALSE | NA | NA | NA | NA | NA | NA |
| form-particle-dissolution-2 | Thickness (unstirred water layer) | 23.0000000 | µm | FALSE | NA | NA | NA | Publication | Assumed | 32 |
| form-particle-dissolution-2 | Particle size distribution | 0.0000000 | NA | FALSE | NA | NA | NA | Other | Assumed | NA |
| form-particle-dissolution-2 | Type of particle size distribution | 1.0000000 | NA | FALSE | NA | NA | NA | Other | Assumed | NA |
| form-particle-dissolution-2 | Particle radius (mean) | 10.0000000 | µm | FALSE | NA | NA | NA | ParameterIdentification | NA | NA |
| form-particle-dissolution-2 | Particle radius (SD) | 3.0000000 | µm | FALSE | NA | NA | NA | Publication | c01835608 | NA |
| form-particle-dissolution-2 | Number of bins | 3.0000000 | NA | FALSE | NA | NA | NA | Other | Assumed | NA |
| form-particle-dissolution-2 | Particle radius (min) | 1.0000000 | µm | FALSE | NA | NA | NA | Publication | c01835608 | NA |
| form-particle-dissolution-2 | Particle radius (max) | 19.0000000 | µm | FALSE | NA | NA | NA | Publication | c01835608 | NA |
| Standard Tablet | Dissolution time (50% dissolved) | 60.0000000 | min | FALSE | NA | NA | NA | NA | NA | NA |
| Standard Tablet | Lag time | 10.0000000 | min | FALSE | NA | NA | NA | NA | NA | NA |
| Standard Tablet | Dissolution shape | 0.9200000 | NA | FALSE | NA | NA | NA | NA | NA | NA |
| Standard Tablet | Use as suspension | 1.0000000 | NA | FALSE | NA | NA | NA | NA | NA | NA |

You can also convert a specific formulation to a data frame:

``` r
# Convert a specific formulation to data frame
form_df <- snapshot$formulations$`Standard Tablet`$to_df()
```

| formulation_id  | name            | formulation                | formulation_type |
|:----------------|:----------------|:---------------------------|:-----------------|
| Standard Tablet | Standard Tablet | Formulation_Tablet_Weibull | Weibull          |

| formulation_id | name | value | unit | is_table_point | x_value | y_value | table_name | source | description | source_id |
|:---|:---|---:|:---|:---|---:|---:|:---|:---|:---|---:|
| Standard Tablet | Dissolution time (50% dissolved) | 60.00 | min | FALSE | NA | NA | NA | NA | NA | NA |
| Standard Tablet | Lag time | 10.00 | min | FALSE | NA | NA | NA | NA | NA | NA |
| Standard Tablet | Dissolution shape | 0.92 | NA | FALSE | NA | NA | NA | NA | NA | NA |
| Standard Tablet | Use as suspension | 1.00 | NA | FALSE | NA | NA | NA | NA | NA | NA |

### Converting Observed Data

Observed data can be easily converted to data frames for analysis and
visualization:

``` r
# Get data frames for all observed data in the snapshot
obs_data_dfs <- get_observed_data_dfs(snapshot)
obs_data_dfs
```

| name | xValues | yValues | yErrorValues | xDimension | xUnit | yDimension | yUnit | yErrorType | yErrorUnit | molWeight | lloq | DB Version | ID | Study Id | Reference | Source | Grouping | Data type | N | Molecule | Species | Organ | Compartment | Route | Dose | Times of Administration \[h\] | Formulation | Food state | Comment |
|:---|---:|---:|---:|:---|:---|:---|:---|:---|:---|---:|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 0.5 | 0.0085872 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 1.0 | 0.0465688 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 1.5 | 0.0434862 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 2.0 | 0.0374312 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 3.0 | 0.0236697 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 4.0 | 0.0170642 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 5.0 | 0.0104587 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 6.0 | 0.0074862 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 8.0 | 0.0050642 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |
| Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg - Plasma - agg. (n=10) | 10.0 | 0.0033028 | NA | Time | h | Concentration (mass) | mg/l | NA | NA | NA | NA | OSP DATABASE | 53 | Backman 1996 | <https://www.ncbi.nlm.nih.gov/pubmed/8549036> | Fig. 1 | Control (Perpetrator Placebo) | aggregated | 10 | BI 123456 | Human | Peripheral Venous Blood | Plasma | PO | 15 mg | 0 | Dormicum, tablet | fasted | Arith. SEM converted to arith. SD |

The observed data data frame contains all the time-series data with
metadata, making it easy to work with in R for analysis and plotting.

### Converting Other Collections

All other snapshot collections can also be converted to data frames:

``` r
# Convert compounds to data frame
compounds_df <- get_compounds_dfs(snapshot)

# Convert populations to data frame  
populations_df <- get_populations_dfs(snapshot)

# Convert events to data frame
events_df <- get_events_dfs(snapshot)

# Convert protocols to data frame
protocols_df <- get_protocols_dfs(snapshot)

# Convert expression profiles to data frame
expression_profiles_df <- get_expression_profiles_dfs(snapshot)
```

These functions follow the same pattern as the examples above, providing
structured data frames that make it easy to analyze, filter, and
visualize the snapshot contents using standard R data manipulation
tools.
