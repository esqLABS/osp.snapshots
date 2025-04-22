
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

# Load the test snapshot
snapshot_path <- system.file("extdata", "test_snapshot.json", package = "osp.snapshots")
snapshot <- load_snapshot(snapshot_path)
#> ℹ Reading snapshot from '/Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library/osp.snapshots/extdata/test_snapshot.json'
#> ✔ Snapshot loaded successfully

# View snapshot overview
snapshot
#> 
#> ── PKSIM Snapshot ──────────────────────────────────────────────────────────────
#> ℹ Version: 79 (PKSIM 11.2)
#> • Compounds: 6
#> • Events: 10
#> • ExpressionProfiles: 14
#> • Formulations: 9
#> • Individuals: 5
#> • ObservedData: 64
#> • ObservedDataClassifications: 20
#> • ObserverSets: 1
#> • ParameterIdentifications: 1
#> • Populations: 6
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
#> • CKD
#> • ind_modified
#> • baby

# Get a detailed view of a building block
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
#> 
#> ── Individual: European (P-gp modified, CYP3A4 36 h) | Seed: 17189110 ──────────
#> 
#> ── Origin Data ──
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
#> Path                                     | Value           | Unit
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

### Modifying Building Blocks

All these elements are mutable and can be modified in place.

``` r
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$age <- 35

snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$value <- 0.6

snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
#> 
#> ── Individual: European (P-gp modified, CYP3A4 36 h) | Seed: 17189110 ──────────
#> 
#> ── Origin Data ──
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
#> ── Origin Data ──
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
#> • CKD
#> • ind_modified
#> • baby
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
#> • form-partdiss (Particle)
#> • form-table (Table)
#> • form-ZO (Zero Order)
#> • form-FO (First Order)
#> • form-partdiss2 (Particle)
#> • Standard Tablet (Weibull)
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
| CKD | CKD | 391487890 | Human | European_ICRP_2002 | MALE | 50.0 | year(s) | NA | NA | 70.0 | kg | 178.0 | cm | CKD | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | eGFR: 45 ml/min/1.73m² |
| ind_modified | ind_modified | 487796515 | Human | BlackAmerican_NHANES_1997 | MALE | 56.0 | year(s) | NA | NA | NA | NA | 180.0 | cm | NA | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | NA |
| baby | baby | 1987729687 | Human | Preterm | MALE | 10.0 | day(s) | 30 | week(s) | NA | NA | NA | NA | NA | SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller | NA |
| Patient_001 | Patient_001 | NA | Human | European_ICRP_2002 | MALE | 45.0 | year(s) | NA | NA | 85.0 | kg | 180.0 | cm | NA | NA | NA |

| individual_id | path | value | unit | source | description | source_id |
|:---|:---|---:|:---|:---|:---|---:|
| European (P-gp modified, CYP3A4 36 h) | Organism\|Gallbladder\|Gallbladder ejection fraction | 0.6000 | NA | Publication | R24-4081 | NA |
| European (P-gp modified, CYP3A4 36 h) | Organism\|Liver\|EHC continuous fraction | 1.0000 | NA | Publication | R24-4081 | NA |
| Korean (Yu 2004 study) | Organism\|Liver\|EHC continuous fraction | 1.0000 | NA | Unknown | NA | NA |
| Korean (Yu 2004 study) | Organism\|Ontogeny factor (albumin) | 0.8900 | NA | Publication | R24-4081 | NA |
| CKD | Organism\|Liver\|Interstitial\|pH | 7.2456 | NA | Database | Assumed | NA |
| ind_modified | Organism\|Kidney\|GFR (specific) | 33.0000 | ml/min/100g organ | Other | Assumed | 15 |

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

| individual_id | path | value | unit | source | description |
|:---|:---|---:|:---|:---|:---|
| European (P-gp modified, CYP3A4 36 h) | Organism\|Gallbladder\|Gallbladder ejection fraction | 0.6 | NA | Publication | R24-4081 |
| European (P-gp modified, CYP3A4 36 h) | Organism\|Liver\|EHC continuous fraction | 1.0 | NA | Publication | R24-4081 |

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

| formulation_id | name | formulation_type | formulation_type_human |
|:---|:---|:---|:---|
| Tablet (Dormicum) | Tablet (Dormicum) | Formulation_Tablet_Weibull | Weibull |
| Oral solution | Oral solution | Formulation_Dissolved | Dissolved |
| form_dissolved | form_dissolved | Formulation_Dissolved | Dissolved |
| form_Lint80 | form_Lint80 | Formulation_Tablet_Lint80 | Lint80 |
| form-partdiss | form-partdiss | Formulation_Particles | Particle |
| form-table | form-table | Formulation_Table | Table |
| form-ZO | form-ZO | Formulation_ZeroOrder | Zero Order |
| form-FO | form-FO | Formulation_FirstOrder | First Order |
| form-partdiss2 | form-partdiss2 | Formulation_Particles | Particle |
| Standard Tablet | Standard Tablet | Formulation_Tablet_Weibull | Weibull |

| formulation_id    | name                               |       value | unit |
|:------------------|:-----------------------------------|------------:|:-----|
| Tablet (Dormicum) | Dissolution time (50% dissolved)   |   0.0107481 | min  |
| Tablet (Dormicum) | Lag time                           |  12.0000000 | min  |
| Tablet (Dormicum) | Dissolution shape                  |   4.3802943 | NA   |
| Tablet (Dormicum) | Use as suspension                  |   1.0000000 | NA   |
| form_Lint80       | Dissolution time (80% dissolved)   | 240.0000000 | min  |
| form_Lint80       | Lag time                           |   0.0000000 | min  |
| form_Lint80       | Use as suspension                  |   1.0000000 | NA   |
| form-partdiss     | Thickness (unstirred water layer)  |  30.0000000 | µm   |
| form-partdiss     | Type of particle size distribution |   0.0000000 | NA   |
| form-partdiss     | Particle radius (mean)             |  10.0000000 | µm   |
| form-table        | Fraction (dose)                    |   0.0000000 | NA   |
| form-table        | Use as suspension                  |   1.0000000 | NA   |
| form-ZO           | End time                           |  60.0000000 | min  |
| form-FO           | t1/2                               |   0.0100000 | min  |
| form-partdiss2    | Thickness (unstirred water layer)  |  23.0000000 | µm   |
| form-partdiss2    | Particle size distribution         |   0.0000000 | NA   |
| form-partdiss2    | Type of particle size distribution |   1.0000000 | NA   |
| form-partdiss2    | Particle radius (mean)             |  10.0000000 | µm   |
| form-partdiss2    | Particle radius (SD)               |   3.0000000 | µm   |
| form-partdiss2    | Number of bins                     |   3.0000000 | NA   |
| form-partdiss2    | Particle radius (min)              |   1.0000000 | µm   |
| form-partdiss2    | Particle radius (max)              |  19.0000000 | µm   |
| Standard Tablet   | Dissolution time (50% dissolved)   |  60.0000000 | min  |
| Standard Tablet   | Lag time                           |  10.0000000 | min  |
| Standard Tablet   | Dissolution shape                  |   0.9200000 | NA   |
| Standard Tablet   | Use as suspension                  |   1.0000000 | NA   |

You can also convert a specific formulation to a data frame:

``` r
# Convert a specific formulation to data frame
form_df <- snapshot$formulations$`Standard Tablet`$to_df()
```

| formulation_id | name | formulation_type | formulation_type_human |
|:---|:---|:---|:---|
| Standard Tablet | Standard Tablet | Formulation_Tablet_Weibull | Weibull |

| formulation_id  | name                             | value | unit |
|:----------------|:---------------------------------|------:|:-----|
| Standard Tablet | Dissolution time (50% dissolved) | 60.00 | min  |
| Standard Tablet | Lag time                         | 10.00 | min  |
| Standard Tablet | Dissolution shape                |  0.92 | NA   |
| Standard Tablet | Use as suspension                |  1.00 | NA   |
