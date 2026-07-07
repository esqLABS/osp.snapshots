osp.snapshots provides an R interface for working with PK-Sim project
snapshots: import, navigate, modify, and export the nested JSON
structure as R objects and data frames.

## Installation

You can install the development version of osp.snapshots from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("esqLABS/osp.snapshots")
```

## Usage

``` r

library(osp.snapshots)

# Load a snapshot from a template name, a local .json path, or a URL
snapshot <- load_snapshot("Midazolam")
snapshot
#> 
#> ── PKSIM Snapshot ──────────────────────────────────────────────────────────────
#> ℹ Version: 80 (PKSIM 12.0)
#> • Compounds: 1
#> • Events: 1
#> • ExpressionProfiles: 8
#> • Formulations: 2
#> • Individuals: 2
#> • ObservedData: 115
#> • ObservedDataClassifications: 47
#> • ParameterIdentifications: 3
#> • Protocols: 33
#> • SimulationClassifications: 4
#> • Simulations: 37

# Navigate the building blocks
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
#> • Organism|Liver|EHC continuous fraction: 1
#> 
#> ── Expression Profiles ──
#> 
#> • CYP3A4|Human|European (P-gp modified, CYP3A4 36 h)
#> • AADAC|Human|European (P-gp modified, CYP3A4 36 h)
#> • P-gp|Human|European (P-gp modified, CYP3A4 36 h)
#> • OATP1B1|Human|European (P-gp modified, CYP3A4 36 h)
#> • ATP1A2|Human|European (P-gp modified, CYP3A4 36 h)
#> • UGT1A4|Human|European (P-gp modified, CYP3A4 36 h)
#> • GABRG2|Human|European (P-gp modified, CYP3A4 36 h)

# Convert a collection to tibbles for analysis
as_tibbles(snapshot, "individuals")
#> $individuals
#> # A tibble: 2 × 18
#>   individual_id         name  description   seed species population gender   age
#>   <chr>                 <chr> <chr>        <int> <chr>   <chr>      <chr>  <dbl>
#> 1 European (P-gp modif… Euro… <NA>        1.72e7 Human   European_… MALE    30  
#> 2 Korean (Yu 2004 stud… Kore… <NA>        5.30e7 Human   Asian_Tan… MALE    23.3
#> # ℹ 10 more variables: age_unit <chr>, gestational_age <dbl>,
#> #   gestational_age_unit <chr>, weight <dbl>, weight_unit <chr>, height <dbl>,
#> #   height_unit <chr>, disease_state <chr>, calculation_methods <glue>,
#> #   disease_state_parameters <chr>
#> 
#> $individuals_parameters
#> # A tibble: 2 × 7
#>   individual_id                   path  value unit  source description source_id
#>   <chr>                           <chr> <dbl> <chr> <chr>  <chr>           <int>
#> 1 European (P-gp modified, CYP3A… Orga…     1 <NA>  Unkno… <NA>               NA
#> 2 Korean (Yu 2004 study)          Orga…     1 <NA>  Unkno… <NA>               NA
#> 
#> $individuals_expressions
#> # A tibble: 14 × 2
#>    individual_id                         profile                                
#>    <chr>                                 <chr>                                  
#>  1 European (P-gp modified, CYP3A4 36 h) CYP3A4|Human|European (P-gp modified, …
#>  2 European (P-gp modified, CYP3A4 36 h) AADAC|Human|European (P-gp modified, C…
#>  3 European (P-gp modified, CYP3A4 36 h) P-gp|Human|European (P-gp modified, CY…
#>  4 European (P-gp modified, CYP3A4 36 h) OATP1B1|Human|European (P-gp modified,…
#>  5 European (P-gp modified, CYP3A4 36 h) ATP1A2|Human|European (P-gp modified, …
#>  6 European (P-gp modified, CYP3A4 36 h) UGT1A4|Human|European (P-gp modified, …
#>  7 European (P-gp modified, CYP3A4 36 h) GABRG2|Human|European (P-gp modified, …
#>  8 Korean (Yu 2004 study)                CYP3A4|Human|Korean (Yu 2004 study)    
#>  9 Korean (Yu 2004 study)                AADAC|Human|European (P-gp modified, C…
#> 10 Korean (Yu 2004 study)                P-gp|Human|European (P-gp modified, CY…
#> 11 Korean (Yu 2004 study)                OATP1B1|Human|European (P-gp modified,…
#> 12 Korean (Yu 2004 study)                ATP1A2|Human|European (P-gp modified, …
#> 13 Korean (Yu 2004 study)                UGT1A4|Human|European (P-gp modified, …
#> 14 Korean (Yu 2004 study)                GABRG2|Human|European (P-gp modified, …
```

## Key features

- **Import and export**: Load snapshots from JSON files, URLs, or
  templates, and export the modified snapshot back to JSON.
- **Navigate**: Reach every building block (individuals, compounds,
  formulations, and the rest) with R syntax.
- **Modify**: Change parameters and add or remove building blocks in
  place.
- **Convert**: Turn any building block collection into structured
  tibbles with
  [`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md).
- **Integrate**: Bridge PK-Sim observed data to
  [`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
  objects.

## Learn more

- [`vignette("osp-snapshots")`](https://esqlabs.github.io/osp.snapshots/dev/articles/osp-snapshots.md):
  getting started
- [`vignette("creating-building-blocks")`](https://esqlabs.github.io/osp.snapshots/dev/articles/creating-building-blocks.md):
  creating and managing building blocks
- [`vignette("exporting-snapshots-to-dataframes")`](https://esqlabs.github.io/osp.snapshots/dev/articles/exporting-snapshots-to-dataframes.md):
  exporting snapshots to data frames
- [`vignette("simulations")`](https://esqlabs.github.io/osp.snapshots/dev/articles/simulations.md):
  building simulations from scratch

## Getting help

- [Function
  reference](https://esqlabs.github.io/osp.snapshots/reference/)
- [Report bugs](https://github.com/esqLABS/osp.snapshots/issues)
