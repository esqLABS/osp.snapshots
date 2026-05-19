# Exporting snapshots to data frames

``` r

library(osp.snapshots)
library(dplyr)
```

## Overview

osp.snapshots can flatten the nested PK-Sim snapshot tree into tibbles
ready for downstream analysis with `dplyr`. This vignette covers the
entry point, the per-kind shapes, and a few common analysis patterns.

``` r

snapshot <- load_snapshot("Midazolam")
```

## The `as_tibbles()` entry point

[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
takes the snapshot plus a `kind` naming the collection to convert, and
returns either a tibble or a named list of tibbles for collections that
split into related tables.

Valid values of `kind`:

- `"compounds"`
- `"events"`
- `"expression_profiles"`
- `"formulations"`
- `"individuals"`
- `"observed_data"`
- `"observer_sets"`
- `"populations"`
- `"protocols"`

``` r

compound_dfs <- as_tibbles(snapshot, "compounds")
names(compound_dfs)
#> [1] "properties" "processes"
```

The tibble layer is read-only: mutating a returned tibble does not feed
changes back into the snapshot.

## Compounds: `$properties` and `$processes`

`as_tibbles(snapshot, "compounds")` returns a list of two tibbles:

- `$properties` carries one row per (compound, parameter) pair across
  the *Compound* physicochemical properties.
- `$processes` is the long-form view: one row per (compound, process,
  parameter) triple across every biological *Process* (metabolism,
  transport, clearance, binding, …).

``` r

head(compound_dfs$properties)
#> # A tibble: 6 × 8
#>   compound  category              type  parameter value unit  data_source source
#>   <chr>     <chr>                 <chr> <chr>     <chr> <chr> <chr>       <chr> 
#> 1 Midazolam physicochemical_prop… lipo… Optimized 2.89… Log … NA          Param…
#> 2 Midazolam physicochemical_prop… frac… Gertz et… 0.031 NA    NA          Param…
#> 3 Midazolam physicochemical_prop… mole… NA        325.… g/mol NA          NA    
#> 4 Midazolam physicochemical_prop… halo… Cl        1     NA    NA          NA    
#> 5 Midazolam physicochemical_prop… halo… F         1     NA    NA          NA    
#> 6 Midazolam physicochemical_prop… pKa   base      6.2   NA    NA          NA
head(compound_dfs$processes)
#> # A tibble: 6 × 11
#>   compound  category       process_name parameter value unit  data_source source
#>   <chr>     <chr>          <chr>        <chr>     <chr> <chr> <chr>       <chr> 
#> 1 Midazolam protein_bindi… SpecificBin… koff      1     1/min Buhr 1997   Param…
#> 2 Midazolam protein_bindi… SpecificBin… Kd        1.8   nmol… Buhr 1997   NA    
#> 3 Midazolam renal_clearan… GlomerularF… GFR frac… 0.64… NA    Optimized   Param…
#> 4 Midazolam metabolizing_… Metabolizat… In vitro… 850   pmol… Optimized   NA    
#> 5 Midazolam metabolizing_… Metabolizat… Km        4     µmol… Optimized   aggre…
#> 6 Midazolam metabolizing_… Metabolizat… kcat      8.76… 1/min Optimized   Param…
#> # ℹ 3 more variables: molecule <chr>, metabolite <chr>, species <chr>
```

The `$processes` tibble carries a `category` column that mirrors
`process$category` on the R6 side. Filtering by category gives the same
view as the per-category groups on a compound:

``` r

compound_dfs$processes |>
  filter(category == "metabolizing_enzymes")
```

## Individuals: three related tibbles

`as_tibbles(snapshot, "individuals")` returns three tibbles joinable on
`individual_id`:

- `$individuals` has one row per *Individual* with its demographic
  fields (species, population, gender, age, weight, height, gestational
  age, disease state, calculation methods).
- `$individuals_parameters` is the long-form view of the individual’s
  parameter tree: one row per (individual, parameter path) pair, with
  value, unit, source, and value-origin metadata.
- `$individuals_expressions` lists the expression profiles attached to
  each individual: one row per (individual, profile) pair.

``` r

individual_dfs <- as_tibbles(snapshot, "individuals")
names(individual_dfs)
#> [1] "individuals"             "individuals_parameters" 
#> [3] "individuals_expressions"

head(individual_dfs$individuals)
#> # A tibble: 2 × 17
#>   individual_id            name    seed species population gender   age age_unit
#>   <chr>                    <chr>  <int> <chr>   <chr>      <chr>  <dbl> <chr>   
#> 1 European (P-gp modified… Euro… 1.72e7 Human   European_… MALE    30   year(s) 
#> 2 Korean (Yu 2004 study)   Kore… 5.30e7 Human   Asian_Tan… MALE    23.3 year(s) 
#> # ℹ 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
#> #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
#> #   disease_state <chr>, calculation_methods <glue>,
#> #   disease_state_parameters <chr>
head(individual_dfs$individuals_parameters)
#> # A tibble: 2 × 7
#>   individual_id                   path  value unit  source description source_id
#>   <chr>                           <chr> <dbl> <chr> <chr>  <chr>           <int>
#> 1 European (P-gp modified, CYP3A… Orga…     1 NA    Unkno… NA                 NA
#> 2 Korean (Yu 2004 study)          Orga…     1 NA    Unkno… NA                 NA
head(individual_dfs$individuals_expressions)
#> # A tibble: 6 × 2
#>   individual_id                         profile                                 
#>   <chr>                                 <chr>                                   
#> 1 European (P-gp modified, CYP3A4 36 h) CYP3A4|Human|European (P-gp modified, C…
#> 2 European (P-gp modified, CYP3A4 36 h) AADAC|Human|European (P-gp modified, CY…
#> 3 European (P-gp modified, CYP3A4 36 h) P-gp|Human|European (P-gp modified, CYP…
#> 4 European (P-gp modified, CYP3A4 36 h) OATP1B1|Human|European (P-gp modified, …
#> 5 European (P-gp modified, CYP3A4 36 h) ATP1A2|Human|European (P-gp modified, C…
#> 6 European (P-gp modified, CYP3A4 36 h) UGT1A4|Human|European (P-gp modified, C…
```

## Formulations: `$formulations` and `$formulations_parameters`

`as_tibbles(snapshot, "formulations")` returns two tibbles joinable on
`formulation_id`:

- `$formulations` has one row per *Formulation* with its name and
  release type.
- `$formulations_parameters` is the long-form view of the type-specific
  release parameters: one row per (formulation, parameter) pair, with
  value and unit.

``` r

formulation_dfs <- as_tibbles(snapshot, "formulations")
names(formulation_dfs)
#> [1] "formulations"            "formulations_parameters"
head(formulation_dfs$formulations)
#> # A tibble: 2 × 4
#>   formulation_id    name              formulation               formulation_type
#>   <chr>             <chr>             <chr>                     <chr>           
#> 1 Oral solution     Oral solution     Formulation_Dissolved     Dissolved       
#> 2 Tablet (Dormicum) Tablet (Dormicum) Formulation_Tablet_Weibu… Weibull
head(formulation_dfs$formulations_parameters)
#> # A tibble: 4 × 11
#>   formulation_id    name   value unit  is_table_point x_value y_value table_name
#>   <chr>             <chr>  <dbl> <chr> <lgl>            <dbl>   <dbl> <chr>     
#> 1 Tablet (Dormicum) Diss… 0.0107 min   FALSE               NA      NA NA        
#> 2 Tablet (Dormicum) Lag … 0      min   FALSE               NA      NA NA        
#> 3 Tablet (Dormicum) Diss… 4.38   NA    FALSE               NA      NA NA        
#> 4 Tablet (Dormicum) Use … 1      NA    FALSE               NA      NA NA        
#> # ℹ 3 more variables: source <chr>, description <chr>, source_id <int>
```

## Populations: `$populations` and `$populations_parameters`

`as_tibbles(snapshot, "populations")` returns two tibbles joinable on
`population_id`:

- `$populations` has one row per *Population* with the sampling-recipe
  header: source population, individual name, sample size, proportion of
  females, seed, and the age, weight, height, BMI, and eGFR bound
  columns.
- `$populations_parameters` is the long-form view of the sampling
  distributions PK-Sim will draw from: one row per (population,
  parameter) pair, with `distribution_type`, `statistic`, value, and
  unit.

``` r

population_dfs <- as_tibbles(snapshot, "populations")
names(population_dfs)
#> [1] "populations"            "populations_parameters"
head(population_dfs$populations)
#> # A tibble: 0 × 22
#> # ℹ 22 variables: population_id <chr>, name <chr>, seed <int>,
#> #   number_of_individuals <int>, proportion_of_females <dbl>,
#> #   source_population <chr>, individual_name <chr>, age_min <dbl>,
#> #   age_max <dbl>, age_unit <chr>, weight_min <dbl>, weight_max <dbl>,
#> #   weight_unit <chr>, height_min <dbl>, height_max <dbl>, height_unit <chr>,
#> #   bmi_min <dbl>, bmi_max <dbl>, bmi_unit <chr>, egfr_min <dbl>,
#> #   egfr_max <dbl>, egfr_unit <chr>
```

## Protocols: `Schema` and `SchemaItem` rows

`as_tibbles(snapshot, "protocols")` returns a single 13-column tibble
whether the snapshot has any protocols or not. *Advanced Protocols*
contribute one row per *Schema* item, with the protocol-level,
schema-level, and item-level parameters joined by name.

``` r

protocols_df <- as_tibbles(snapshot, "protocols")
head(protocols_df)
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
```

## Observer sets: `$observer_sets` and `$observers`

`as_tibbles(snapshot, "observer_sets")` returns a list of two tibbles
joinable on `observer_set_id` (or `observer_set_name`):

- `$observer_sets` has one row per *ObserverSet* with its name and the
  count of observers it contains.
- `$observers` has one row per *Observer* with its name, type,
  dimension, formula, and `container_tags` (the `|`-joined `Tag` values
  from the underlying `ContainerCriteria`).

``` r

observer_dfs <- as_tibbles(snapshot, "observer_sets")
names(observer_dfs)
head(observer_dfs$observers)
```

## Observed data

`as_tibbles(snapshot, "observed_data")` flattens every observed-data
series into a long-form tibble ready for plotting.

``` r

obs_data_df <- as_tibbles(snapshot, "observed_data")
head(obs_data_df)
#> # A tibble: 6 × 30
#>   name            xValues yValues yErrorValues xDimension xUnit yDimension yUnit
#>   <chr>             <dbl>   <dbl>        <dbl> <chr>      <chr> <chr>      <chr>
#> 1 Ahonen 1995 - …     0.5 0.0156        0.0231 Time       h     Concentra… mg/l 
#> 2 Ahonen 1995 - …     1   0.0280        0.0160 Time       h     Concentra… mg/l 
#> 3 Ahonen 1995 - …     1.5 0.0235        0.0108 Time       h     Concentra… mg/l 
#> 4 Ahonen 1995 - …     2   0.0185      NaN      Time       h     Concentra… mg/l 
#> 5 Ahonen 1995 - …     3   0.0118      NaN      Time       h     Concentra… mg/l 
#> 6 Ahonen 1995 - …     4   0.00848     NaN      Time       h     Concentra… mg/l 
#> # ℹ 22 more variables: yErrorType <chr>, yErrorUnit <chr>, molWeight <dbl>,
#> #   lloq <dbl>, `DB Version` <chr>, ID <chr>, `Study Id` <chr>,
#> #   Reference <chr>, Source <chr>, Grouping <chr>, `Data type` <chr>, N <chr>,
#> #   Molecule <chr>, Species <chr>, Organ <chr>, Compartment <chr>, Route <chr>,
#> #   Dose <chr>, `Times of Administration [h]` <chr>, Formulation <chr>,
#> #   `Food state` <chr>, Comment <chr>
```

## Next steps

- [`vignette("creating-building-blocks")`](https://esqlabs.github.io/osp.snapshots/dev/articles/creating-building-blocks.md)
  covers the `create_*()` functions for building new snapshots.
- The full API reference is at
  <https://esqlabs.github.io/osp.snapshots/reference/>.
