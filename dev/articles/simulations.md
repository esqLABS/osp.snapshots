# Building simulations from scratch

``` r

library(osp.snapshots)
```

## Overview

A *Simulation* is almost pure references into a *Snapshot*: it names an
individual (or a population), one or more compounds, and optionally
events, observed data, and parameter overrides, all of which already
live in the snapshot as building blocks. Because the snapshot holds
every block a simulation points at, it is the entry point:
[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
builds the simulation from named arguments, resolves those references,
derives sensible defaults, and attaches the result, all in one call.

This vignette starts with a complete
[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
call, then explains each piece.

## Load the template

We start with the `Midazolam` template, which already ships individuals,
compounds, protocols, formulations, and events that we can reference by
name.

``` r

snapshot <- load_snapshot("Midazolam")
names(snapshot$compounds)
#> [1] "Midazolam"
names(snapshot$individuals)
#> [1] "European (P-gp modified, CYP3A4 36 h)"
#> [2] "Korean (Yu 2004 study)"
names(snapshot$protocols)
#>  [1] "iv 0.075 mg/kg (1 min)" "iv 0.05 mg/kg (30 min)" "iv 1 mg (5 min)"       
#>  [4] "iv 0.001 mg (5 min)"    "iv 1 mg (bolus)"        "iv 2 mg (2 min)"       
#>  [7] "iv 2 mg (bolus)"        "iv 0.05 mg/kg (2 min)"  "iv 5 mg (30 sec)"      
#> [10] "iv 5 mg (bolus)"        "iv 0.05 mg/kg (bolus)"  "iv 0.15 mg/kg (bolus)" 
#> [13] "po 1 mg"                "po 5 mg"                "po 7.5 mg"             
#> [16] "po 0.075 mg"            "po 3 mg"                "po 4 mg"               
#> [19] "po 6 mg"                "po 8 mg"                "po 15 mg"              
#> [22] "po 2 mg"                "po 0.075 mg/kg"         "po 10 mg"              
#> [25] "po 20 mg"               "po 40 mg"               "po 0.003 mg"           
#> [28] "po 15 mg (1 h delayed)" "po 2.5 mg"              "po 0.01 mg"            
#> [31] "po 3.5 mg"              "Mikus 2017"             "iv 1 mg (2 min)"
names(snapshot$formulations)
#> [1] "Oral solution"     "Tablet (Dormicum)"
names(snapshot$events)
#> [1] "High-fat breakfast"
```

## Build and attach a simulation

Here is the whole workflow in one call. Pass the `snapshot`, a `name`,
exactly one of `individual` or `population`, and configure each compound
inline with the protocol and formulation it should use. Everything else
is optional.

``` r

snapshot <- snapshot |>
  add_simulation(
    name = "Midazolam oral dose",
    individual = "Korean (Yu 2004 study)",
    compounds = list(
      list(
        name = "Midazolam",
        protocol = "po 15 mg",
        formulation = "Oral solution",
        processes = c("Hepatic")
      )
    ),
    events = list(
      create_event_selection(name = "High-fat breakfast", start_time = 12)
    )
  )

snapshot$simulations[["Midazolam oral dose"]]
#> 
#> ── Simulation: Midazolam oral dose ─────────────────────────────────────────────
#> • Model: 4Comp
#> • Individual: Korean (Yu 2004 study)
#> 
#> ── Compounds (1) ──
#> 
#> • Midazolam
#> 
#> ── Events (1) ──
#> 
#> • High-fat breakfast
```

[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
reported which defaults it derived from the snapshot (here, Midazolam’s
calculation methods and alternatives) and attached the simulation. If
any name had not resolved to a known building block, you would also get
one informational warning per simulation; the add proceeds either way.

The rest of this vignette explains the arguments you just used, then the
optional inputs you did not.

## Configuring compounds

Each entry of `compounds` configures one compound for the simulation.
The common path is an inline config list, as above; the escape-hatch
factories are still accepted through the same slot (see below).

### Compound vs compound configuration

A `Compound` building block (the kind you find in `snapshot$compounds`)
is the project-level definition of a drug: its physicochemical
properties, the full menu of available alternatives, the process
templates it ships, and so on. The same compound can be referenced by
many simulations.

A compound *configuration* is the per-simulation overlay that picks one
path through that menu:

- which `calculation_methods` override the compound’s defaults,
- which `alternatives` (e.g. solubility, permeability) are selected,
- which `processes` are enabled, and how each is wired to molecules or
  systemic types,
- which `protocol` is used and which `formulation` fills each
  application slot.

Because the snapshot is the entry point,
[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
derives most of these from the referenced building block when you leave
them out. You point at the compound by `name` and the resolver fills in
the rest:

- `calculation_methods`: derived from the calculation methods defined on
  the referenced `Compound` building block.
- `alternatives`: each alternative group is defaulted to that group’s
  default alternative (the one marked `IsDefault`, or `"User defined"`
  as a fallback).
- `formulation` (together with `protocol`): the resolver infers the
  formulation key from the referenced protocol’s application slot,
  falling back to the literal `"Formulation"` key for simple protocols.
- `processes`: **never defaulted.** Omitting `processes` produces no
  process array, which deselects the compound’s processes in PK-Sim (it
  materialises the right placeholder so the simulation runs as if you
  had explicitly disabled them). List the processes you want to keep. A
  name is classified as a systemic-process type when it is one of
  `"Hepatic"`, `"Renal"`, or `"Biliary"`; every other name is treated as
  a molecule name.
- `protocol`: when omitted, the compound is included with no dosing
  protocol attached, so it will not be administered during the
  simulation (useful for compounds that are only produced
  metabolically).

The only required field is `name`, which must match a compound in the
snapshot.

### The escape hatch

For a multi-slot protocol, or any hand-built configuration you want full
control over, build the compound entry with the factory functions and
pass the resulting `CompoundProperties` object through the same
`compounds` slot. When you do, the resolver leaves it untouched (no
defaulting):

``` r

compound <- create_compound_properties(
  name = "Midazolam",
  calculation_methods = c(
    "Cellular partition coefficient method - Rodgers and Rowland",
    "Cellular permeability - PK-Sim Standard"
  ),
  processes = list(
    create_compound_process_selection(systemic_process_type = "Hepatic")
  ),
  protocol = create_protocol_selection(
    name = "po 15 mg",
    formulations = list(
      create_formulation_selection(
        name = "Oral solution",
        key = "Formulation"
      )
    )
  )
)

snapshot <- snapshot |>
  add_simulation(
    name = "Midazolam (hand-built compound)",
    individual = "Korean (Yu 2004 study)",
    compounds = list(compound)
  )
```

The supporting factories follow the same convention:

- [`create_compound_process_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_process_selection.md):
  every field is optional; PK-Sim resolves the right placeholder from
  whichever combination of `name`, `molecule_name`, `metabolite_name`,
  `compound_name`, and `systemic_process_type` is supplied. Does not
  reference a building block; the `name` field here is a process name
  internal to the parent compound.
- [`create_compound_group_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_group_selection.md):
  `group_name` and `alternative_name` are both required. Does not
  reference a building block; it picks an alternative inside an
  alternative group defined on the parent compound.
- [`create_protocol_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol_selection.md):
  points at one protocol in `snapshot$protocols` by `name` and records
  which `Formulation` fills each of the protocol’s application slots
  through `formulations`. Supply a `formulations` entry for every slot
  the protocol requires; PK-Sim rejects the simulation at load time if a
  required slot is unbound.
- [`create_formulation_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation_selection.md):
  binds one formulation in `snapshot$formulations` (by `name`) to one
  application slot inside the chosen protocol (by `key`). Both are
  required.

## Optional inputs

The simulation above used only compounds and one event. The remaining
arguments are all optional; supply them the same way, as extra named
arguments to the same
[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
call.

### Events and observer sets

An `Event` building block (in `snapshot$events`) is the project-level
event definition.
[`create_event_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event_selection.md)
picks one by `name` and supplies its `start_time` (hours) for this
simulation; aside from `start_time`, events carry no per-simulation
overlay.

``` r

event <- create_event_selection(name = "High-fat breakfast", start_time = 12)
```

An `ObserverSet` building block (in `snapshot$observer_sets`) is a
project-level observer bundle.
[`create_observer_set_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set_selection.md)
picks one by `name`, with no per-simulation overlay at all, which is why
the factory takes only that one argument. The `Midazolam` template ships
no observer sets, but with a template that does the call would look
like:

``` r

observer_set <- create_observer_set_selection(name = "BrainPlasmaConcentration")
```

### Solver settings

[`create_solver_settings()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_solver_settings.md)
produces a sparse solver configuration; every argument is optional. Each
field you omit is filled by PK-Sim’s built-in CVODE defaults on load, so
calling it with no arguments is the same as not supplying `solver` at
all.

``` r

solver <- create_solver_settings(
  abs_tol = 1e-9,
  rel_tol = 1e-9,
  mx_step = 100000
)
```

### Output schema

[`create_output_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_schema.md)
collects one or more *output intervals*. An output schema with no
intervals means the simulation reports no time points, so supply at
least one interval if you want output. Each
[`create_output_interval()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_interval.md)
requires `start_time`, `end_time`, and `resolution` (in PK-Sim’s default
units `h`, `h`, `pts/h`).

``` r

schema <- create_output_schema(
  intervals = list(
    create_output_interval(start_time = 0, end_time = 2, resolution = 20),
    create_output_interval(start_time = 2, end_time = 24, resolution = 20)
  )
)
```

Use `output_selections` (a character vector of full output-quantity
paths) to control which quantities the simulation reports.

### Parameter overrides

Simulation parameter overrides are *localized parameters*, identified by
their full container path inside the simulation’s parameter tree. Use
`create_parameter(path = ...)` to obtain one.

``` r

overrides <- list(
  create_parameter(
    path = "Organism|Liver|Volume",
    value = 1.8,
    unit = "L"
  )
)
```

### Putting the optional inputs together

The prepared inputs slot straight into the same call:

``` r

snapshot <- snapshot |>
  add_simulation(
    name = "Midazolam oral dose (full)",
    individual = "Korean (Yu 2004 study)",
    compounds = list(
      list(name = "Midazolam", protocol = "po 15 mg", formulation = "Oral solution", processes = c("Hepatic"))
    ),
    events = list(event),
    solver = solver,
    output_schema = schema,
    output_selections = c(
      "Organism|PeripheralVenousBlood|Midazolam|Plasma (Peripheral Venous Blood)"
    ),
    parameters = overrides
  )
```

## Export

Export with
[`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
and PK-Sim will load the resulting JSON.

``` r

export_snapshot(snapshot, "midazolam-with-new-sim.json")
```

## Run the simulation

`osp.snapshots` builds and edits snapshots; running them belongs to
[`ospsuite`](https://www.open-systems-pharmacology.org/OSPSuite-R/).
Once the snapshot is on disk, hand the JSON to
[`ospsuite::runSimulationsFromSnapshot()`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/runSimulationsFromSnapshot.html),
which loads every simulation it contains and writes the results to an
output directory.

``` r

library(ospsuite)

runSimulationsFromSnapshot(
  "midazolam-with-new-sim.json",
  output = "results"
)
```

## Removing a simulation

``` r

snapshot <- snapshot |>
  remove_simulation("Midazolam oral dose")
```
