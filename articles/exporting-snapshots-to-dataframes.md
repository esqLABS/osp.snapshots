# Exporting snapshots to data frames

``` r

library(osp.snapshots)
library(dplyr)
library(gt)
```

## Reporting the inputs that drive a simulation

A PK-Sim snapshot is mostly *configuration*: the compounds, individuals,
formulations, protocols, and other building blocks that define how a
simulation is set up. Observed data and simulation results are already
easy to report with the wider R ecosystem; what has been awkward is
reporting the **inputs**, because they live deep inside a nested JSON
tree.

[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
flattens those building blocks into tidy tibbles, one concept per table,
so you can filter them with `dplyr` and render them as
publication-quality tables. This vignette pairs
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
with [`gt`](https://gt.rstudio.com/) to turn the configuration of a
model into report-ready HTML tables.

``` r

snapshot <- load_snapshot("Midazolam")
```

## The `as_tibbles()` entry point

[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
takes the snapshot plus an optional `kind` naming the collection(s) to
convert, and returns either a tibble or a named list of tibbles for
collections that split into related tables. `kind` is optional: omit it
(or pass `NULL`) to convert every kind at once, returned as a named list
keyed by kind; pass a single kind to get that kind’s tibble or list of
tibbles directly; or pass a vector of kinds to get a named list keyed by
just the requested kinds.

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

The sections below feature four kinds chosen because each has a
different *shape*: a single flat table (protocols), a header split from
a long-form parameter table (compounds, formulations), and several
related tables keyed by an id (individuals). Every other kind follows
one of these same shapes, so the same reporting recipe applies to all of
them.

## Compounds: a flat table and a long-form table

`as_tibbles(snapshot, "compounds")` returns a list of two tibbles:

- `$properties` carries one row per (compound, parameter) pair across
  the *Compound* physicochemical properties.
- `$processes` is the long-form view: one row per (compound, process,
  parameter) triple across every biological *Process* (metabolism,
  transport, clearance, binding, …).

The physicochemical properties render directly as a report table:

``` r

compound_dfs$properties |>
  gt() |>
  tab_header(title = "Compound physicochemical properties")
```

| Compound physicochemical properties |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|
| compound | category | type | parameter | value | unit | data_source | source |
| Midazolam | physicochemical_property | lipophilicity | Optimized | 2.8972038771 | Log Units | NA | Parameter optimization |
| Midazolam | physicochemical_property | fraction_unbound | Gertz et al. 2010 | 0.031 | NA | NA | Parameter optimization |
| Midazolam | physicochemical_property | molecular_weight | NA | 325.78 | g/mol | NA | NA |
| Midazolam | physicochemical_property | halogens | Cl | 1 | NA | NA | NA |
| Midazolam | physicochemical_property | halogens | F | 1 | NA | NA | NA |
| Midazolam | physicochemical_property | pKa | base | 6.2 | NA | NA | NA |
| Midazolam | physicochemical_property | pKa | acid | 10.95 | NA | NA | NA |
| Midazolam | physicochemical_property | solubility | Aqueous solubility, pH 5 | 0.13 | mg/ml | NA | Heikkinen 2012 |
| Midazolam | physicochemical_property | solubility | FaSSIF, pH 6.5 | 0.049 | mg/ml | NA | Heikkinen 2012 |
| Midazolam | physicochemical_property | solubility | FeSSIF, pH 5 | 0.09 | mg/ml | NA | Heikkinen 2012 |
| Midazolam | physicochemical_property | intestinal_permeability | Optimized | 0.00015549970673 | cm/min | NA | Parameter optimization |
| Midazolam | protein_binding_partners | SpecificBinding | koff, GABRG2 | 1 | 1/min | Buhr 1997 | Parameter optimization |
| Midazolam | protein_binding_partners | SpecificBinding | Kd, GABRG2 | 1.8 | nmol/l | Buhr 1997 | NA |
| Midazolam | metabolizing_enzymes | MetabolizationLiverMicrosomes_MM | In vitro Vmax for liver microsomes, CYP3A4 | 850 | pmol/min/mg mic. protein | Optimized | NA |
| Midazolam | metabolizing_enzymes | MetabolizationLiverMicrosomes_MM | Km, CYP3A4 | 4 | µmol/l | Optimized | aggregated from literature |
| Midazolam | metabolizing_enzymes | MetabolizationLiverMicrosomes_MM | kcat, CYP3A4 | 8.7607941215 | 1/min | Optimized | Parameter optimization |
| Midazolam | metabolizing_enzymes | MetabolizationLiverMicrosomes_MM | In vitro Vmax for liver microsomes, UGT1A4 | 276 | pmol/min/mg mic. protein | Optimized | Klieber 2008 |
| Midazolam | metabolizing_enzymes | MetabolizationLiverMicrosomes_MM | Content of CYP proteins in liver microsomes, UGT1A4 | 58 | pmol/mg mic. protein | Optimized | Achour 2014 |
| Midazolam | metabolizing_enzymes | MetabolizationLiverMicrosomes_MM | Km, UGT1A4 | 37.8 | µmol/l | Optimized | Klieber 2008 |
| Midazolam | metabolizing_enzymes | MetabolizationLiverMicrosomes_MM | kcat, UGT1A4 | 3.5911771641 | 1/min | Optimized | Parameter optimization |
| Midazolam | renal_clearance | GlomerularFiltration | GFR fraction | 0.6401025724 | NA | Optimized | Parameter optimization |

### Filtering before you render

The `$processes` tibble carries a `category` column that mirrors
`process$category` on the R6 side. Filtering by category with
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
gives the same view as the per-category groups on a compound, and the
filtered result flows straight into `gt`:

``` r

compound_dfs$processes |>
  filter(category == "metabolizing_enzymes") |>
  select(process_name, molecule, parameter, value, unit) |>
  gt() |>
  tab_header(title = "Metabolizing enzymes")
```

| Metabolizing enzymes |  |  |  |  |
|----|----|----|----|----|
| process_name | molecule | parameter | value | unit |
| MetabolizationLiverMicrosomes_MM | CYP3A4 | In vitro Vmax for liver microsomes | 850 | pmol/min/mg mic. protein |
| MetabolizationLiverMicrosomes_MM | CYP3A4 | Km | 4 | µmol/l |
| MetabolizationLiverMicrosomes_MM | CYP3A4 | kcat | 8.7607941215 | 1/min |
| MetabolizationLiverMicrosomes_MM | UGT1A4 | In vitro Vmax for liver microsomes | 276 | pmol/min/mg mic. protein |
| MetabolizationLiverMicrosomes_MM | UGT1A4 | Content of CYP proteins in liver microsomes | 58 | pmol/mg mic. protein |
| MetabolizationLiverMicrosomes_MM | UGT1A4 | Km | 37.8 | µmol/l |
| MetabolizationLiverMicrosomes_MM | UGT1A4 | kcat | 3.5911771641 | 1/min |

## Individuals: several related tables

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

A focused selection of the demographic columns makes a compact subject
table:

``` r

individual_dfs <- as_tibbles(snapshot, "individuals")
names(individual_dfs)
#> [1] "individuals"             "individuals_parameters" 
#> [3] "individuals_expressions"

individual_dfs$individuals |>
  select(name, species, population, gender, age, age_unit, weight, weight_unit) |>
  gt() |>
  tab_header(title = "Individuals")
```

| Individuals |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|
| name | species | population | gender | age | age_unit | weight | weight_unit |
| European (P-gp modified, CYP3A4 36 h) | Human | European_ICRP_2002 | MALE | 30.0 | year(s) | NA | NA |
| Korean (Yu 2004 study) | Human | Asian_Tanaka_1996 | MALE | 23.3 | year(s) | 66.9 | kg |

## Formulations: a header split from its parameters

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

formulation_dfs$formulations |>
  gt() |>
  tab_header(title = "Formulations")
```

| Formulations |  |  |  |
|----|----|----|----|
| formulation_id | name | formulation | formulation_type |
| Oral solution | Oral solution | Formulation_Dissolved | Dissolved |
| Tablet (Dormicum) | Tablet (Dormicum) | Formulation_Tablet_Weibull | Weibull |

``` r


formulation_dfs$formulations_parameters |>
  select(name, value, unit) |>
  gt() |>
  tab_header(title = "Formulation release parameters")
```

| Formulation release parameters   |            |      |
|----------------------------------|------------|------|
| name                             | value      | unit |
| Dissolution time (50% dissolved) | 0.01074815 | min  |
| Lag time                         | 0.00000000 | min  |
| Dissolution shape                | 4.38029432 | NA   |
| Use as suspension                | 1.00000000 | NA   |

## Protocols: a single flat table

`as_tibbles(snapshot, "protocols")` returns a single tibble whether the
snapshot has any protocols or not. *Advanced Protocols* contribute one
row per *Schema* item, with the protocol-level, schema-level, and
item-level parameters joined by name. This is the simplest shape: one
kind, one table, ready to render.

``` r

as_tibbles(snapshot, "protocols") |>
  select(protocol_name, dose, dose_unit, start_time, start_time_unit, dosing_interval) |>
  gt() |>
  tab_header(title = "Dosing protocols")
```

| Dosing protocols |  |  |  |  |  |
|----|----|----|----|----|----|
| protocol_name | dose | dose_unit | start_time | start_time_unit | dosing_interval |
| iv 0.075 mg/kg (1 min) | 0.075 | mg/kg | 0 | h | Once |
| iv 0.05 mg/kg (30 min) | 0.050 | mg/kg | 0 | h | Once |
| iv 1 mg (5 min) | 1.000 | mg | 0 | h | Once |
| iv 0.001 mg (5 min) | 0.001 | mg | 0 | h | Once |
| iv 1 mg (bolus) | 1.000 | mg | 0 | h | Once |
| iv 2 mg (2 min) | 2.000 | mg | 0 | h | Once |
| iv 2 mg (bolus) | 2.000 | mg | 0 | h | Once |
| iv 0.05 mg/kg (2 min) | 0.050 | mg/kg | 0 | h | Once |
| iv 5 mg (30 sec) | 5.000 | mg | 0 | h | Once |
| iv 5 mg (bolus) | 5.000 | mg | 0 | h | Once |
| iv 0.05 mg/kg (bolus) | 0.050 | mg/kg | 0 | h | Once |
| iv 0.15 mg/kg (bolus) | 0.150 | mg/kg | 0 | h | Once |
| po 1 mg | 1.000 | mg | 0 | h | Once |
| po 5 mg | 5.000 | mg | 0 | h | Once |
| po 7.5 mg | 7.500 | mg | 0 | h | Once |
| po 0.075 mg | 0.075 | mg | 0 | h | Once |
| po 3 mg | 3.000 | mg | 0 | h | Once |
| po 4 mg | 4.000 | mg | 0 | h | Once |
| po 6 mg | 6.000 | mg | 0 | h | Once |
| po 8 mg | 8.000 | mg | 0 | h | Once |
| po 15 mg | 15.000 | mg | 0 | h | Once |
| po 2 mg | 2.000 | mg | 0 | h | Once |
| po 0.075 mg/kg | 0.075 | mg/kg | 0 | h | Once |
| po 10 mg | 10.000 | mg | 0 | h | Once |
| po 20 mg | 20.000 | mg | 0 | h | Once |
| po 40 mg | 40.000 | mg | 0 | h | Once |
| po 0.003 mg | 0.003 | mg | 0 | h | Once |
| po 15 mg (1 h delayed) | 15.000 | mg | 1 | h | Once |
| po 2.5 mg | 2.500 | mg | 0 | h | Once |
| po 0.01 mg | 0.010 | mg | 0 | h | Once |
| po 3.5 mg | 3.500 | mg | 0 | h | Once |
| Mikus 2017 | 2.000 | mg | 6 | h | Once |
| Mikus 2017 | 4.000 | mg | 0 | h | Once |
| iv 1 mg (2 min) | 1.000 | mg | 0 | h | Once |

## Every building block exports the same way

The four kinds above cover every shape
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
produces. The same call works for `"events"`, `"expression_profiles"`,
`"populations"`, and `"observer_sets"`: each returns either a single
flat tibble or a header split from a long-form parameter table, ready
for the same
[`filter()`](https://dplyr.tidyverse.org/reference/filter.html) +
[`gt()`](https://gt.rstudio.com/reference/gt.html) recipe. Kinds a
snapshot does not define come back as empty (0-row) tibbles with the
same columns, so reporting code never has to special-case a missing
building block.

Passing no `kind` converts everything at once, keyed by kind name, which
is handy when assembling a multi-table report:

``` r

all_kinds <- as_tibbles(snapshot)
names(all_kinds)
#> [1] "compounds"           "individuals"         "formulations"       
#> [4] "populations"         "events"              "expression_profiles"
#> [7] "protocols"           "observer_sets"       "observed_data"
```

`"observed_data"` is also available and flattens every observed-data
series into a long-form tibble, though it is measurement data rather
than a configuration input.

## Next steps

- [`vignette("creating-building-blocks")`](https://esqlabs.github.io/osp.snapshots/articles/creating-building-blocks.md)
  covers the `create_*()` functions for building new snapshots.
- The full API reference is at
  <https://esqlabs.github.io/osp.snapshots/reference/>.
