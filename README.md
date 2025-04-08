
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
#> ℹ Version: 80 (PKSIM 12.0)
#> • Compounds: 2
#> • ExpressionProfiles: 2
#> • Formulations: 2
#> • Individuals: 2
#> • Protocols: 2
#> • SimulationClassifications: 2
#> • Simulations: 2
```

### Exploring Snapshot Contents

``` r
# List all individuals in the snapshot
snapshot$individuals
#> 
#> ── Individuals (2) ─────────────────────────────────────────────────────────────
#> • Mouly2002
#> • European

# Get a detailed view of a building block
snapshot$individuals$Mouly2002
#> 
#> ── Individual: Mouly2002 | Seed: 1300547185 ────────────────────────────────────
#> 
#> ── Origin Data ──
#> 
#> • Species: Human
#> • Population: WhiteAmerican_NHANES_1997
#> • Gender: MALE
#> • Age: 29.9 year(s)
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
#> • CYP1A2|Human|Healthy
#> • CYP2B6|Human|Healthy

# All fields are accessible as list elements
snapshot$individuals$Mouly2002$age
#> [1] 29.9
snapshot$individuals$Mouly2002$gender
#> [1] "MALE"

# Parameters are also accessible as list element but they have their own nested structure and behavior
snapshot$individuals$Mouly2002$parameters
#> Parameter Collection with 2 parameters:
#> Path                                     | Value           | Unit
#> -----------------------------------------|-----------------|----------------
#> ...bladder|Gallbladder ejection fraction | 0.8             | 
#> Organism|Liver|EHC continuous fraction   | 1               |

# They can be accessed by path
snapshot$individuals$Mouly2002$parameters$`Organism|Gallbladder|Gallbladder ejection fraction`
#> 
#> ── Parameter: Organism|Gallbladder|Gallbladder ejection fraction 
#> • Value: 0.8
#> • Source: Publication
#> • Description: R24-4081
```

### Modifying Building Blocks

All these elements are mutable and can be modified in place.

``` r
snapshot$individuals$Mouly2002$age <- 35

snapshot$individuals$Mouly2002$parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$value <- 0.6

snapshot$individuals$Mouly2002
#> 
#> ── Individual: Mouly2002 | Seed: 1300547185 ────────────────────────────────────
#> 
#> ── Origin Data ──
#> 
#> • Species: Human
#> • Population: WhiteAmerican_NHANES_1997
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
#> • CYP1A2|Human|Healthy
#> • CYP2B6|Human|Healthy
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
#> ── Individual: Patient_001 | Seed:  ────────────────────────────────────────────
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
add_individual_to_snapshot(snapshot, new_individual)
#> ✔ Added individual 'Patient_001' to the snapshot

# Verify it was added
snapshot$individuals
#> 
#> ── Individuals (3) ─────────────────────────────────────────────────────────────
#> • Mouly2002
#> • European
#> • Patient_001
```
