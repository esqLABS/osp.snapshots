# Working with Data Frames

``` r
library(osp.snapshots)
library(dplyr)
library(ggplot2)
library(tidyr)
```

## Overview

One of the key features of osp.snapshots is the ability to convert
complex nested snapshot data into structured data frames that are easy
to work with in R. This vignette demonstrates how to extract, convert,
and analyze snapshot data using standard R data analysis tools.

## Setup

Let’s start by loading our test snapshot:

``` r
snapshot <- load_snapshot("Midazolam")
```

## Converting Building Blocks to Data Frames

Each building block type has a corresponding `get_*_dfs()` function that
converts the data to structured data frames.

### Converting Individuals

Individual data is converted into multiple related data frames:

``` r
individual_dfs <- get_individuals_dfs(snapshot)
names(individual_dfs)
#> [1] "individuals"             "individuals_parameters" 
#> [3] "individuals_expressions"
```

Let’s examine each data frame:

``` r
# Basic characteristics
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

# Parameters
head(individual_dfs$individuals_parameters)
#> # A tibble: 2 × 7
#>   individual_id                   path  value unit  source description source_id
#>   <chr>                           <chr> <dbl> <chr> <chr>  <chr>           <int>
#> 1 European (P-gp modified, CYP3A… Orga…     1 NA    Unkno… NA                 NA
#> 2 Korean (Yu 2004 study)          Orga…     1 NA    Unkno… NA                 NA

# Expression profiles
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

### Converting Single Individual

You can also convert a single individual to data frames:

``` r
# Get the first individual
individual <- snapshot$individuals[[1]]
single_individual_df <- individual$to_df()

names(single_individual_df)
#> [1] "individuals"             "individuals_parameters" 
#> [3] "individuals_expressions"
head(single_individual_df$individuals)
#> # A tibble: 1 × 17
#>   individual_id            name    seed species population gender   age age_unit
#>   <chr>                    <chr>  <int> <chr>   <chr>      <chr>  <dbl> <chr>   
#> 1 European (P-gp modified… Euro… 1.72e7 Human   European_… MALE      30 year(s) 
#> # ℹ 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
#> #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
#> #   disease_state <chr>, calculation_methods <glue>,
#> #   disease_state_parameters <chr>
```

### Converting Compounds

``` r
compounds_df <- get_compounds_dfs(snapshot)
head(compounds_df)
#> # A tibble: 6 × 8
#>   compound  category              type  parameter value unit  data_source source
#>   <chr>     <chr>                 <chr> <chr>     <chr> <chr> <chr>       <chr> 
#> 1 Midazolam physicochemical_prop… lipo… Optimized 2.89… Log … NA          Param…
#> 2 Midazolam physicochemical_prop… frac… Gertz et… 0.031 NA    NA          Param…
#> 3 Midazolam physicochemical_prop… mole… NA        325.… g/mol NA          NA    
#> 4 Midazolam physicochemical_prop… halo… Cl        1     NA    NA          NA    
#> 5 Midazolam physicochemical_prop… halo… F         1     NA    NA          NA    
#> 6 Midazolam physicochemical_prop… pKa   base      6.2   NA    NA          NA
```

### Converting Formulations

``` r
formulations_dfs <- get_formulations_dfs(snapshot)
names(formulations_dfs)
#> [1] "formulations"            "formulations_parameters"

# Basic formulation info
head(formulations_dfs$formulations)
#> # A tibble: 2 × 4
#>   formulation_id    name              formulation               formulation_type
#>   <chr>             <chr>             <chr>                     <chr>           
#> 1 Oral solution     Oral solution     Formulation_Dissolved     Dissolved       
#> 2 Tablet (Dormicum) Tablet (Dormicum) Formulation_Tablet_Weibu… Weibull

# Formulation parameters
head(formulations_dfs$parameters)
#> NULL
```

### Converting Populations

``` r
populations_dfs <- get_populations_dfs(snapshot)
names(populations_dfs)
#> [1] "populations"            "populations_parameters"

head(populations_dfs$populations)
#> # A tibble: 0 × 22
#> # ℹ 22 variables: population_id <chr>, name <chr>, seed <int>,
#> #   number_of_individuals <int>, proportion_of_females <dbl>,
#> #   source_population <chr>, individual_name <chr>, age_min <dbl>,
#> #   age_max <dbl>, age_unit <chr>, weight_min <dbl>, weight_max <dbl>,
#> #   weight_unit <chr>, height_min <dbl>, height_max <dbl>, height_unit <chr>,
#> #   bmi_min <dbl>, bmi_max <dbl>, bmi_unit <chr>, egfr_min <dbl>,
#> #   egfr_max <dbl>, egfr_unit <chr>
```

### Converting Observed Data

Observed data conversion creates a flat data frame perfect for analysis:

``` r
obs_data_df <- get_observed_data_dfs(snapshot)
head(obs_data_df)
#> # A tibble: 6 × 30
#>   name            xValues yValues yErrorValues xDimension xUnit yDimension yUnit
#>   <chr>             <dbl>   <dbl>        <dbl> <chr>      <chr> <chr>      <chr>
#> 1 Ahonen 1995 - …     0.5 0.0156            NA Time       h     Concentra… mg/l 
#> 2 Ahonen 1995 - …     1   0.0280            NA Time       h     Concentra… mg/l 
#> 3 Ahonen 1995 - …     1.5 0.0235            NA Time       h     Concentra… mg/l 
#> 4 Ahonen 1995 - …     2   0.0185            NA Time       h     Concentra… mg/l 
#> 5 Ahonen 1995 - …     3   0.0118            NA Time       h     Concentra… mg/l 
#> 6 Ahonen 1995 - …     4   0.00848           NA Time       h     Concentra… mg/l 
#> # ℹ 22 more variables: yErrorType <chr>, yErrorUnit <chr>, molWeight <dbl>,
#> #   lloq <dbl>, `DB Version` <chr>, ID <chr>, `Study Id` <chr>,
#> #   Reference <chr>, Source <chr>, Grouping <chr>, `Data type` <chr>, N <chr>,
#> #   Molecule <chr>, Species <chr>, Organ <chr>, Compartment <chr>, Route <chr>,
#> #   Dose <chr>, `Times of Administration [h]` <chr>, Formulation <chr>,
#> #   `Food state` <chr>, Comment <chr>
```

## Next Steps

- Learn how to create new building blocks in
  [`vignette("creating-building-blocks")`](https://esqlabs.github.io/osp.snapshots/dev/articles/creating-building-blocks.md)
- Explore the full API in the [function
  reference](https://esqlabs.github.io/osp.snapshots/reference/)
