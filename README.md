
# osp.snapshots

<!-- badges: start -->

[![](https://img.shields.io/github/actions/workflow/status/esqlabs/osp.snapshots/main-workflow.yaml?branch=main&label=Build)](https://github.com/esqlabs/osp.snapshots/actions/workflows/main-workflow.yaml)
<!-- [![Codecov test coverage](https://codecov.io/gh/esqlabs/osp.snapshots/branch/main/graph/badge.svg)](https://app.codecov.io/gh/esqlabs/osp.snapshots?branch=main) -->

<!-- badges: end -->

osp.snapshots provides a convenient R interface for working with PKSIM
project snapshots. Import, navigate, modify, and export snapshot data
with ease, making complex nested JSON structures accessible for analysis
within the R ecosystem.

## Installation

You can install the development version of osp.snapshots from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("esqLABS/osp.snapshots")
```

## Quick Start

``` r
library(osp.snapshots)

# Load a snapshot
snapshot_path <- system.file(
  "extdata",
  "test_snapshot.json",
  package = "osp.snapshots"
)
snapshot <- load_snapshot(snapshot_path)

# Explore the snapshot
snapshot
#> 
#> ── PKSIM Snapshot ──────────────────────────────────────────────────────────────
#> ℹ Version: 79 (PKSIM 11.2)
#> ℹ Path: '../../../../private/var/folders/_6/hdp78hfx2qg6415svlx5rb680000gn/T/RtmpxzUpSR/temp_libpath44103c33cc80/osp.snapshots/extdata/test_snapshot.json'
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

# Access building blocks
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

# Modify parameters
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$age <- 40

# Convert to data frames for analysis
individual_dfs <- get_individuals_dfs(snapshot)
```

## Key Features

- **Import/Export**: Load snapshots from JSON files, URLs, or templates;
  export back to JSON
- **Navigate**: Access all building blocks (individuals, compounds,
  formulations, etc.) with intuitive R syntax
- **Modify**: Change parameters, add/remove building blocks in place
- **Convert**: Transform any building block collection to structured
  data frames
- **Integrate**: Full compatibility with `ospsuite::DataSet` objects

## Learn More

Get started with osp.snapshots:

- `vignette("osp-snapshots")` - Getting started guide
- `vignette("working-with-dataframes")` - Converting snapshots to data
  frames
- `vignette("creating-building-blocks")` - Creating and managing
  building blocks

## Getting Help

- [Function
  reference](https://esqlabs.github.io/osp.snapshots/reference/)
- [Report bugs](https://github.com/esqLABS/osp.snapshots/issues)
