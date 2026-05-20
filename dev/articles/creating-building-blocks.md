# Creating and managing building blocks

``` r

library(osp.snapshots)
library(ospsuite)
```

## Overview

This vignette walks through the `create_*()` functions that build PK-Sim
*Building blocks* from named arguments, and the `add_*()` / `remove_*()`
mutators that attach them to a snapshot.

We use the `Midazolam` template throughout:

``` r

snapshot <- load_snapshot("Midazolam")
```

## Individuals

[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)
builds an *Individual* from demographic arguments. PK-Sim seeds the
underlying physiological tree at simulation time.

``` r

patient <- create_individual(
  name = "Patient_001",
  species = "Human",
  population = "European_ICRP_2002",
  gender = "FEMALE",
  age = 35,
  weight = 65,
  height = 165
)

patient
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

Extra demographics (e.g. `gestational_age`) are accepted as additional
named arguments:

``` r

pregnant_patient <- create_individual(
  name = "Pregnant_Patient",
  species = "Human",
  population = "European_ICRP_2002",
  gender = "FEMALE",
  age = 28,
  weight = 70,
  height = 168,
  gestational_age = 20 # weeks
)

pregnant_patient
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

Attach the result to a snapshot with
[`add_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_individual.md):

``` r

snapshot <- add_individual(snapshot, patient)
snapshot$individuals
#> 
#> ── Individuals (3) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)
#> • Patient_001
```

Parameters that sit on a specific path inside the individual’s
physiological tree are built with
[`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
using a `path` argument. PK-Sim writes the path as pipe-separated
segments (`Organism|Liver|...`):

``` r

ehc <- create_parameter(
  path = "Organism|Liver|EHC continuous fraction",
  value = 0.4
)

gfr <- create_parameter(
  path = "Organism|Kidney|GFR",
  value = 120,
  unit = "ml/min",
  source = "Literature",
  description = "Normal adult GFR",
  source_id = 123
)

gfr
#> 
#> ── Parameter: Organism|Kidney|GFR 
#> • Value: 120
#> • Unit: ml/min
#> • Source: Literature
#> • Description: Normal adult GFR
```

You can pass a list of such parameters straight to
`create_individual(parameters = ...)`, or assign them through
`individual$parameters` after the fact (see “Modifying existing building
blocks” below).

## Formulations

[`create_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation.md)
covers every PK-Sim release profile (`"Dissolved"`, `"Weibull"`,
`"First Order"`, `"Zero Order"`, `"Lint80"`, `"Particles"`, `"Table"`).
The accepted `parameters` depend on the chosen `type`: `"Dissolved"`
takes none; the kinetic profiles (`"Weibull"`, `"First Order"`,
`"Zero Order"`, `"Lint80"`, `"Particles"`, `"Table"`) accept the
release-kinetics parameters specific to that profile (for example a
`"Weibull"` formulation accepts `dissolution_time`, `dissolution_shape`,
`lag_time`, …). See
[`?create_formulation`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation.md)
for the parameter list per type.

``` r

oral_solution <- create_formulation(
  name = "Oral Solution 10mg/mL",
  type = "Dissolved"
)

oral_solution
#> 
#> ── Formulation: Oral Solution 10mg/mL ──────────────────────────────────────────
#> • Type: Dissolved

tablet <- create_formulation(
  name = "Immediate Release Tablet",
  type = "Weibull",
  parameters = list(
    dissolution_time = 30,
    dissolution_time_unit = "min",
    lag_time = 5,
    lag_time_unit = "min",
    dissolution_shape = 1.2,
    suspension = TRUE
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

``` r

snapshot <- add_formulation(snapshot, oral_solution)
snapshot <- add_formulation(snapshot, tablet)
```

## Compounds

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
builds a compound with validation on common fields such as
`molecular_weight_unit`. Compound-level parameters (clearances,
halogens, …) are passed as a list of
[`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
results: parameters named on a compound are identified by `name`, so
omit the `path` argument.

``` r

drug <- create_compound(name = "Drug X")

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

### Compound processes

[`create_process()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_process.md)
builds a compound process (plasma protein binding, metabolism,
clearance, …) from named arguments. The `internal_name` identifies the
process template in PK-Sim’s compound process repository (for example
`"SpecificBinding"`, `"MetabolizationSpecific_MM"`,
`"GlomerularFiltration"`); `data_source` labels the data origin. See
[`?create_process`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_process.md)
for usage and current examples; the canonical list of `internal_name`
values is maintained in PK-Sim and groups into the categories surfaced
by `process$category` (`protein_binding_partners`,
`metabolizing_enzymes`, `hepatic_clearance`, `transporter_proteins`,
`renal_clearance`, `biliary_clearance`, `inhibition`, `induction`).

``` r

binding <- create_process(
  internal_name = "SpecificBinding",
  data_source = "Buhr 1997",
  molecule = "GABRG2"
)

metabolism <- create_process(
  internal_name = "MetabolizationSpecific_MM",
  data_source = "Optimized",
  molecule = "CYP3A4",
  metabolite = "Hydroxy-Drug",
  parameters = list(
    create_parameter(name = "Km", value = 1.2, unit = "µmol/l"),
    create_parameter(name = "kcat", value = 9.865, unit = "1/min")
  )
)

metabolism$category
#> [1] "metabolizing_enzymes"
```

The `$category` active binding derives a domain label
(`"protein_binding_partners"`, `"metabolizing_enzymes"`,
`"hepatic_clearance"`, `"transporter_proteins"`, `"renal_clearance"`,
`"biliary_clearance"`, `"inhibition"`, or `"induction"`) from the
`internal_name`. Compound processes loaded from a snapshot are exposed
as a flat named list of *Process* objects via `compound$processes`, and
the long-form `processes` tibble returned by
[`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
surfaces every (process, parameter) pair as a row.

## Populations

[`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md)
builds a *Population* recipe: settings used by PK-Sim to sample a cohort
at simulation time. Use
[`range()`](https://esqlabs.github.io/osp.snapshots/dev/reference/range.md)
for age, weight, height, and BMI bounds.

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

## Expression profiles

[`create_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_expression_profile.md)
builds an *ExpressionProfile*. The identity of a profile is the
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

## Protocols

[`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md)
builds a *Protocol*. By default it creates a *Simple Protocol* (one
application type, one dose, optional dosing interval); pass `schemas` to
create an *Advanced Protocol*.

``` r

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

### Advanced protocols

For dosing schedules that do not fit a single application (a multi-day
course, or two compounds dosed on staggered schedules), use an *Advanced
Protocol*. An Advanced Protocol is built from one or more *Schemas*;
each schema describes a repeating block of applications (for example “10
mg orally every 24 hours for 5 days”). Inside a schema, each individual
application is a *SchemaItem*.

You build them with
[`create_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema.md)
(the repeating block) and
[`create_schema_item()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema_item.md)
(one application), then pass a list of schemas to
[`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md):

``` r

qd_oral <- create_protocol(
  name = "Once daily oral, 5 days",
  schemas = list(
    create_schema(
      name = "Schema 1",
      parameters = list(
        create_parameter(name = "NumberOfRepetitions", value = 5),
        create_parameter(name = "TimeBetweenRepetitions", value = 24, unit = "h")
      ),
      items = list(
        create_schema_item(
          name = "Item 1",
          application_type = "Oral",
          parameters = list(
            create_parameter(name = "Start time", value = 0, unit = "h"),
            create_parameter(name = "InputDose", value = 10, unit = "mg")
          )
        )
      )
    )
  ),
  time_unit = "h"
)

qd_oral
#> 
#> ── Protocol: Once daily oral, 5 days ───────────────────────────────────────────
#> • Type: Advanced (Schema-based)
#> • Time Unit: h
#> 
#> ── Schemas ──
#> 
#> • Schema: Schema 1
#>   • Item 1: Oral -
```

`application_type` on a schema item is validated against the canonical
PK-Sim application types (`"Oral"`, `"IntravenousBolus"`,
`"IntravenousInfusion"`, `"Intramuscular"`, `"Subcutaneous"`,
`"Dermal"`, `"Rectal"`, `"Inhalation"`, `"Intraperitoneal"`).

## Events

An *Event* is a discrete perturbation that is not a drug administration:
a meal, a change of posture, an enzyme inducer dose, an exercise bout.
[`create_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event.md)
builds one from a `template` (the name of an event recipe in PK-Sim’s
event database) plus optional parameter overrides. PK-Sim clones the
named template at simulation time and applies your overrides.

The set of available templates is defined inside PK-Sim (in particular
by the PK-Sim Events database that ships with the installation), so the
exact list of valid `template` names depends on your PK-Sim setup.
Templates that are commonly seen in published snapshots include the
“Meal: Standard (Human)” family for food effects; if you need a template
that is not on your installation, define it in PK-Sim first and
re-export.

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

## Observer sets

An *Observer* is a simulation-time formula that exposes a derived
quantity (for example a tissue concentration) that is not a natural
model output. Observers travel in groups called *Observer sets*.
[`create_observer_set()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set.md)
builds a set from a name and a list of observers.

Build each observer with `Observer$new()` (which validates the input and
gives you typed accessors `$name`, `$type`, `$dimension`, `$formula`,
`$container_tags`), then bundle them into a set and attach the set to a
snapshot:

``` r

brain_obs <- Observer$new(list(
  Name = "brain_plasma_conc",
  Type = "Container",
  Dimension = "Concentration (molar)",
  Formula = list(Formula = "Conc_Br")
))

brain_set <- create_observer_set(
  name = "BrainPlasmaConcentration",
  observers = list(brain_obs)
)

brain_set
#> 
#> ── ObserverSet: BrainPlasmaConcentration ───────────────────────────────────────
#> • 1 observer

snapshot <- add_observer_set(snapshot, brain_set)
```

## Observed data

[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)
builds an
[`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
from named arguments for the time grid, measurement values, units, and
optional error series. `value_dimension` is required and gates the unit
validation.

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

## Managing building blocks

Each building-block kind has paired `add_*()` and `remove_*()` mutators
that take the snapshot first and return it invisibly, so they chain with
the base pipe.

``` r

snapshot <- remove_individual(snapshot, "Patient_001")
snapshot <- remove_formulation(snapshot, "Oral Solution 10mg/mL")
```

You can pass several names to remove at once:

``` r

snapshot <- remove_individual(snapshot, c("Patient_001", "Patient_002"))
snapshot <- remove_expression_profile(snapshot, "CYP3A4|Human|Healthy")
```

### Adding several building blocks at once

`add_*()` accepts either a single building block or a list of them, so
you can attach many in one call. Each `add_*()` reports how many entries
were added.

``` r

patients <- list(
  create_individual("Patient_A", age = 25, gender = "MALE"),
  create_individual("Patient_B", age = 45, gender = "FEMALE"),
  create_individual("Patient_C", age = 65, gender = "MALE")
)

snapshot <- add_individual(snapshot, patients)

snapshot$individuals
#> 
#> ── Individuals (5) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)
#> • Patient_A
#> • Patient_B
#> • Patient_C
```

### Modifying existing building blocks

Most fields on an existing building block are mutable; assign to them
like any other R6 active binding. Reading the object before and after
shows the effect:

``` r

patient <- snapshot$individuals$Patient_A
patient
#> 
#> ── Individual: Patient_A ───────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Gender: MALE
#> • Age: 25 year(s)
```

``` r

patient$age <- 30
patient$weight <- 75
patient$gender <- "FEMALE"
patient
#> 
#> ── Individual: Patient_A ───────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Gender: FEMALE
#> • Age: 30 year(s)
#> • Weight: 75 kg
```

The same pattern works for nested objects. To bump a parameter on an
individual, look it up by path under `individual$parameters` and write
to its `value`:

``` r

korean <- snapshot$individuals$`Korean (Yu 2004 study)`
ehc <- korean$parameters$`Organism|Liver|EHC continuous fraction`
ehc
#> 
#> ── Parameter: Organism|Liver|EHC continuous fraction 
#> • Value: 1
#> • Source: Unknown
ehc$value <- 0.4
ehc
#> 
#> ── Parameter: Organism|Liver|EHC continuous fraction 
#> • Value: 0.4
#> • Source: Unknown
```

After every change, the parent snapshot exports the updated values:
`export_snapshot(snapshot, ...)` writes them straight back to JSON, no
extra step required.

### Validation

`create_*()` functions validate common inputs against the canonical
ospsuite enums and abort with informative messages on bad input:

``` r

tryCatch(
  {
    create_individual(
      name = "Invalid Patient",
      species = "InvalidSpecies",
      gender = "OTHER"
    )
  },
  error = function(e) cat("Error:", e$message, "\n")
)
#> Error: Invalid species: InvalidSpecies

tryCatch(
  {
    create_formulation(
      name = "Invalid Form",
      type = "NonexistentType"
    )
  },
  error = function(e) cat("Error:", e$message, "\n")
)
#> Error: subscript out of bounds
```

The same checks are also exported as standalone helpers
([`validate_species()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_species.md),
[`validate_gender()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_gender.md),
[`validate_unit()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_unit.md),
[`validate_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_population.md))
when you need them outside a `create_*()` call.

## Exporting

After your modifications, write the snapshot back to JSON:

``` r

export_snapshot(snapshot, "modified_snapshot.json")
```

## Next steps

- [`vignette("exporting-snapshots-to-dataframes")`](https://esqlabs.github.io/osp.snapshots/dev/articles/exporting-snapshots-to-dataframes.md)
  covers the tibble layer for analysis.
- The full API reference is at
  <https://esqlabs.github.io/osp.snapshots/reference/>.
