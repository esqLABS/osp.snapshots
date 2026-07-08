# Getting started with osp.snapshots

``` r

library(osp.snapshots)
```

## Overview

osp.snapshots provides an R interface for working with PK-Sim project
snapshots. The package lets you:

- Import PK-Sim snapshots from JSON files, URLs, or predefined
  templates.
- Navigate and explore the nested snapshot structure as R6 objects.
- Modify building blocks and parameters in place.
- Export modified snapshots back to JSON for use in PK-Sim.
- Convert building-block collections to tibbles for analysis in R.

## Loading a snapshot

### From a file, a URL, or a template

[`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
dispatches on its input. A local `.json` path is read from disk; an
`https?://` URL is fetched; a bare name is resolved against the
`OSPSuite.BuildingBlockTemplates` repository.

``` r

# Local file
snapshot <- load_snapshot("path/to/your_snapshot.json")

# Remote URL
snapshot <- load_snapshot("https://example.com/snapshot.json")

# Named template (browse the catalogue with `osp_models()`)
snapshot <- load_snapshot("Midazolam")
```

For this guide we use the `Midazolam` template:

``` r

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
```

[`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
only accepts v11.2 PK-Sim snapshots and newer (`Version >= 79`); older
snapshots use pre-v11 conventions that this package does not model.
Re-export the project from PK-Sim before loading if needed.

## Exploring building blocks

A loaded snapshot is a navigable tree: each kind of building block
(individuals, compounds, formulations, populations, events, protocols,
expression profiles, observer sets) lives in a named list under
`snapshot$<kind>` that you can list, look up by name, and inspect
interactively. Printing any object prints a readable summary;
tab-completion works the whole way down.

### Walking one kind: individuals

`snapshot$individuals` is a named list. Print it for a short overview,
ask for [`names()`](https://rdrr.io/r/base/names.html) and
[`length()`](https://rdrr.io/r/base/length.html) to see what is there,
then index by name to get a single building block:

``` r

snapshot$individuals
#> 
#> ── Individuals (2) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)

names(snapshot$individuals)
#> [1] "European (P-gp modified, CYP3A4 36 h)"
#> [2] "Korean (Yu 2004 study)"
length(snapshot$individuals)
#> [1] 2

individual <- snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
individual
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
```

Once you have an individual, the fields you would type in PK-Sim are
available as active bindings on the object:

``` r

individual$age
#> [1] 30
individual$age_unit
#> [1] "year(s)"
individual$gender
#> [1] "MALE"
individual$species
#> [1] "Human"
individual$weight
#> NULL
```

Nested structures are objects themselves, so you can keep drilling. The
demographic starting point lives on `$origin_data`, and the calculation
methods PK-Sim will use to create the virtual individual sit one level
deeper:

``` r

individual$origin_data
#> 
#> ── OriginData ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: MALE
#> • Age: 30 year(s)
#> • Calculation methods:
#>   • SurfaceAreaPlsInt_VAR1
#>   • Body surface area - Mosteller

individual$origin_data$calculation_methods
#> CalculationMethods (2 methods)
#> • SurfaceAreaPlsInt_VAR1
#> • Body surface area - Mosteller
individual$origin_data$calculation_methods$names
#> [1] "SurfaceAreaPlsInt_VAR1"        "Body surface area - Mosteller"
```

Path-bearing parameters on the individual are exposed as a named list
keyed by their PK-Sim path, so you can list them and pull one out by
path:

``` r

korean <- snapshot$individuals$`Korean (Yu 2004 study)`
names(korean$parameters)
#> [1] "Organism|Liver|EHC continuous fraction"
korean$parameters$`Organism|Liver|EHC continuous fraction`
#> 
#> ── Parameter: Organism|Liver|EHC continuous fraction 
#> • Value: 1
#> • Source: Unknown
```

### The same shape for every other kind

Every other building-block collection works the same way: a named list
under `snapshot$<kind>` that you can list, index by name, and print. The
objects you get back have their own fields and nested structures, all
available through `$`. For example, compounds expose their
physicochemical properties, their calculation methods, and their
biological processes:

``` r

names(snapshot$compounds)
#> [1] "Midazolam"
midazolam <- snapshot$compounds$Midazolam
midazolam$molecular_weight
#> [1] 325.78
midazolam$is_small_molecule
#> [1] TRUE
midazolam$calculation_methods$names
#> [1] "Cellular partition coefficient method - Rodgers and Rowland"
#> [2] "Cellular permeability - PK-Sim Standard"
names(midazolam$processes)
#> [1] "SpecificBinding, Buhr 1997, GABRG2"                 
#> [2] "GlomerularFiltration, Optimized"                    
#> [3] "MetabolizationLiverMicrosomes_MM, Optimized, CYP3A4"
#> [4] "MetabolizationLiverMicrosomes_MM, Optimized, UGT1A4"
```

Other collections feel just as familiar. Asking for
[`names()`](https://rdrr.io/r/base/names.html) is usually the first
move:

``` r

names(snapshot$formulations)
#> [1] "Oral solution"     "Tablet (Dormicum)"
length(snapshot$protocols)
#> [1] 33
head(names(snapshot$protocols))
#> [1] "iv 0.075 mg/kg (1 min)" "iv 0.05 mg/kg (30 min)" "iv 1 mg (5 min)"       
#> [4] "iv 0.001 mg (5 min)"    "iv 1 mg (bolus)"        "iv 2 mg (2 min)"
names(snapshot$expression_profiles)
#> [1] "CYP3A4_Human_European (P-gp modified, CYP3A4 36 h)" 
#> [2] "AADAC_Human_European (P-gp modified, CYP3A4 36 h)"  
#> [3] "P-gp_Human_European (P-gp modified, CYP3A4 36 h)"   
#> [4] "OATP1B1_Human_European (P-gp modified, CYP3A4 36 h)"
#> [5] "ATP1A2_Human_European (P-gp modified, CYP3A4 36 h)" 
#> [6] "UGT1A4_Human_European (P-gp modified, CYP3A4 36 h)" 
#> [7] "GABRG2_Human_European (P-gp modified, CYP3A4 36 h)" 
#> [8] "CYP3A4_Human_Korean (Yu 2004 study)"
```

And every kind of building block can be printed for a readable summary:

``` r

snapshot$formulations$`Tablet (Dormicum)`
#> 
#> ── Formulation: Tablet (Dormicum) ──────────────────────────────────────────────
#> • Type: Weibull
#> 
#> ── Parameters ──
#> 
#> • Dissolution time (50% dissolved): 0.0107481462 min
#> • Lag time: 0 min
#> • Dissolution shape: 4.3802943225
#> • Use as suspension: 1
snapshot$protocols$`po 15 mg`
#> 
#> ── Protocol: po 15 mg ──────────────────────────────────────────────────────────
#> • Type: Simple
#> • Application Type: Oral
#> • Dosing Interval: Once
#> 
#> ── Parameters ──
#> 
#> • Start time: 0 h
#> • InputDose: 15 mg
#> • Volume of water/body weight: 3.5 ml/kg
```

## Mutating building blocks

Most fields on a building block are mutable, and every kind has a pair
of `add_*()` / `remove_*()` functions for inserting or pruning entries.
These functions are the public API; the matching R6 methods exist but
are an implementation detail.

### Changing fields on a building block

Assigning to a field on an existing object writes the change straight
back into the snapshot:

``` r

ind <- snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
ind$age <- 45
ind$weight <- 78
ind
#> 
#> ── Individual: European (P-gp modified, CYP3A4 36 h) | Seed: 17189110 ──────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: MALE
#> • Age: 45 year(s)
#> • Weight: 78 kg
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
```

Parameters that sit at a known path inside the individual’s parameter
tree are exposed as `LocalizedParameter` objects with a pipe-separated
path. v11+ snapshots already write `Events|...` segments; legacy
`Applications|...` segments are migrated on load.

``` r

korean <- snapshot$individuals$`Korean (Yu 2004 study)`
ehc <- korean$parameters$`Organism|Liver|EHC continuous fraction`
ehc$value <- 0.4
ehc
#> 
#> ── Parameter: Organism|Liver|EHC continuous fraction 
#> • Value: 0.4
#> • Source: Unknown
```

### Adding and removing building blocks

Build the new object with the matching `create_*()` function (see
[`vignette("creating-building-blocks")`](https://esqlabs.github.io/osp.snapshots/dev/articles/creating-building-blocks.md)),
then attach it with `add_*()`. Removal is by name.

``` r

patient <- create_individual("Patient_A", age = age(35), gender = "FEMALE")
add_individual(snapshot, patient)

remove_individual(snapshot, "Patient_A")
```

### Chaining with the base pipe

`add_*()` and `remove_*()` take the snapshot first and return it
invisibly, so you can chain them with the base pipe when you want to
make several changes in one expression:

``` r

snapshot |>
  add_individual(create_individual("Patient_A", age = age(35), gender = "FEMALE")) |>
  add_individual(create_individual("Patient_B", age = age(60), gender = "MALE")) |>
  remove_population("Healthy Adults")
```

## Converting collections to tibbles

[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
converts any building-block collection to a tibble (or a named list of
related tibbles for collections that split into more than one). It takes
the snapshot plus the `kind` to convert:

``` r

head(as_tibbles(snapshot, "protocols"))
#> # A tibble: 6 × 13
#>   protocol_name   schema_name schema_item_name type  formulation dosing_interval
#>   <chr>           <chr>       <chr>            <chr> <chr>       <chr>          
#> 1 iv 0.075 mg/kg… NA          NA               Intr… NA          Once           
#> 2 iv 0.05 mg/kg … NA          NA               Intr… NA          Once           
#> 3 iv 1 mg (5 min) NA          NA               Intr… NA          Once           
#> 4 iv 0.001 mg (5… NA          NA               Intr… NA          Once           
#> 5 iv 1 mg (bolus) NA          NA               Intr… NA          Once           
#> 6 iv 2 mg (2 min) NA          NA               Intr… NA          Once           
#> # ℹ 7 more variables: start_time <dbl>, start_time_unit <chr>, dose <dbl>,
#> #   dose_unit <chr>, rep_number <dbl>, rep_time <chr>, rep_time_unit <chr>

compound_dfs <- as_tibbles(snapshot, "compounds")
names(compound_dfs)
#> [1] "properties" "processes"
```

See
[`vignette("exporting-snapshots-to-dataframes")`](https://esqlabs.github.io/osp.snapshots/dev/articles/exporting-snapshots-to-dataframes.md)
for the per-kind shapes and analysis examples.

## Exporting

After mutating a snapshot, write it back to JSON with
[`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md):

``` r

export_snapshot(snapshot, "modified_snapshot.json")
```

The exported file imports back into PK-Sim. Top-level JSON sections that
osp.snapshots does not model (e.g. `Simulations`, `Classifications`,
`ParameterIdentifications`) pass through unchanged.

## Next steps

- [`vignette("creating-building-blocks")`](https://esqlabs.github.io/osp.snapshots/dev/articles/creating-building-blocks.md)
  walks through the `create_*()` functions for building new snapshots
  from scratch.
- [`vignette("exporting-snapshots-to-dataframes")`](https://esqlabs.github.io/osp.snapshots/dev/articles/exporting-snapshots-to-dataframes.md)
  covers the tibble layer in depth.
