# Building simulations from scratch

``` r

library(osp.snapshots)
```

## Overview

This vignette shows how to assemble a *Simulation* from named arguments
and attach it to a *Snapshot*. A simulation binds together other
building blocks (an individual or a population, compounds, events,
observer sets, observed data, protocols, formulations) plus a solver, an
output schema, and parameter overrides.

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

## `create_simulation()` arguments at a glance

Every argument falls into one of three kinds: a plain scalar, a
character vector of names that reference existing building blocks, or a
structured object built by a matching `create_*()` sub-factory. The
sections that follow walk through each sub-factory; this table is the
map.

| Argument | Type | Required? |
|----|----|----|
| `name` | string | yes |
| `individual` | string (name of an Individual building block) | XOR with `population` |
| `population` | string (name of a Population building block) | XOR with `individual` |
| `model` | string (defaults to `"4Comp"`) | no |
| `description` | string | no |
| `allow_aging` | logical | no |
| `observed_data_names` | character vector of observed-data names | no |
| `output_selections` | character vector of output-quantity paths | no |
| `solver` | [`create_solver_settings()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_solver_settings.md) output | no |
| `output_schema` | [`create_output_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_schema.md) output | no |
| `compounds` | list of [`create_compound_properties()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_properties.md) outputs | no |
| `events` | list of [`create_event_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event_selection.md) outputs | no |
| `observer_sets` | list of [`create_observer_set_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set_selection.md) outputs | no |
| `output_mappings` | list of [`create_output_mapping()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_mapping.md) outputs | no |
| `parameters` | list of `create_parameter(path = ...)` outputs | no |
| `advanced_parameters` | list of `AdvancedParameter` objects (population sims only) | no |

**Exactly one** of `individual` or `population` must be supplied
(passing both, or neither, errors).

### What PK-Sim does when an optional argument is omitted

- `model`: defaults to `"4Comp"` (the standard four-compartment model).
- `description`: stays empty; no functional effect on the simulation.
- `allow_aging`: defaults to `FALSE` on load (no ageing during the
  simulation window).
- `observed_data_names`: no observed-data sets are attached to the
  simulation.
- `output_selections`: no quantities are explicitly marked for reporting
  beyond whatever the model defaults to. Supply at least one path to
  control what the simulation outputs.
- `solver`: PK-Sim builds a `SolverSettings` from
  `ISolverSettingsFactory.CreateDefault()` (built-in CVODE defaults).
- `output_schema`: PK-Sim builds an empty schema via
  `IOutputSchemaFactory.CreateEmpty()`; the simulation reports no time
  points. Supply at least one interval to get output.
- `compounds`: the simulation has no compound configuration. Compounds
  referenced indirectly (e.g. via a protocol) still need a
  `CompoundProperties` entry to be runnable.
- `events`: no events are attached.
- `observer_sets`: no observer sets are attached.
- `output_mappings`: no observed-data-to-output bindings are recorded.
  Parameter identification and downstream comparison tools will have
  nothing to compare.
- `parameters`: no parameter overrides are applied; every quantity uses
  the value derived from its building block.
- `advanced_parameters`: no variability overrides on population
  sampling; default distributions apply.

## Solver settings

[`create_solver_settings()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_solver_settings.md)
produces a sparse solver configuration.

**All arguments are optional**, with the PK-Sim fallback when omitted:

- `abs_tol`, `rel_tol`, `use_jacobian`, `h0`, `h_min`, `h_max`,
  `mx_step`: each field omitted from the snapshot is filled by
  `ISolverSettingsFactory.CreateDefault()` on load, so the simulation
  runs with PK-Sim’s built-in CVODE defaults. Calling
  [`create_solver_settings()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_solver_settings.md)
  with no arguments is the same as not supplying `solver` to
  [`create_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_simulation.md)
  at all.

``` r

solver <- create_solver_settings(
  abs_tol = 1e-9,
  rel_tol = 1e-9,
  mx_step = 100000
)
```

## Output schema

[`create_output_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_schema.md)
collects one or more *Output intervals*.

- **Required:** none.
- **Optional**, with the PK-Sim fallback when omitted:
  - `intervals`: defaults to an empty list. An output schema with no
    intervals means the simulation reports no time points; supply at
    least one interval if you want any output.

For
[`create_output_interval()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_interval.md):

- **Required:** `start_time`, `end_time`, `resolution`, all numeric
  scalars in PK-Sim’s default units (`h`, `h`, `pts/h`).
- **Optional**, with the PK-Sim fallback when omitted:
  - `name`: PK-Sim assigns a generated unique name through
    `IContainerTask.CreateUniqueName()`.

``` r

schema <- create_output_schema(
  intervals = list(
    create_output_interval(start_time = 0, end_time = 2, resolution = 20),
    create_output_interval(start_time = 2, end_time = 24, resolution = 20)
  )
)
```

## Compound properties

[`create_compound_properties()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_properties.md)
configures one compound for the simulation.

### Compound vs CompoundProperties

A `Compound` building block (the kind you find in `snapshot$compounds`)
is the project-level definition of a drug: its physicochemical
properties, the full menu of available alternatives, the process
templates it ships, and so on. The same compound can be referenced by
many simulations.

`CompoundProperties` is the *per-simulation overlay* that picks one path
through that menu. For each simulation that uses the compound you
record:

- which `calculation_methods` override the compound’s defaults,
- which `alternatives` (e.g. solubility, permeability) are selected,
- which `processes` are enabled, and how each is wired to molecules or
  systemic types,
- which `protocol` is used and which formulation fills each application
  slot.

None of those choices live on the `Compound` building block, which is
why
[`create_compound_properties()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_properties.md)
exists as a separate step even when the compound is already in
`snapshot$compounds`. The reference back to the building block is the
`name` argument; everything else is simulation-local.

By contrast,
[`create_event_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event_selection.md)
only takes `name` plus a `start_time`, and
[`create_observer_set_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set_selection.md)
only takes `name`, because events and observer sets have nothing
analogous to alternatives/processes/protocol to choose between at
simulation time.

### Arguments

- **Required:** `name`, which must match a compound in the snapshot.
- **Optional**, with the PK-Sim fallback when omitted:
  - `calculation_methods`: the simulation uses the calculation-method
    cache already defined on the `Compound` building block.
  - `alternatives`: each unspecified alternative group keeps the default
    alternative marked on the compound (typically the first or the one
    with `IsDefault = TRUE`).
  - `processes`: every compound process that is not listed is treated as
    deselected; PK-Sim materialises the right placeholder
    (`NotSelectedSystemicProcess`, `NoInteractionProcess`, …) so the
    simulation runs as if you had explicitly disabled it.
  - `protocol`: when omitted, the compound is included with no dosing
    protocol attached, which means it will not be administered during
    the simulation (useful for compounds that are only produced
    metabolically).

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
    name = "iv 1 mg (bolus)",
    formulations = list(
      create_formulation_selection(
        name = "Oral solution",
        key = "Formulation"
      )
    )
  )
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

### Protocol selection: Protocol vs ProtocolSelection

[`create_protocol_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol_selection.md)
mirrors the same split as compounds. A `Protocol` building block (in
`snapshot$protocols`) is the project-level dosing schedule with all its
parameters. `ProtocolSelection` is the per-simulation overlay that
points at one such protocol by `name` and records which `Formulation`
fills each of the protocol’s application slots through `formulations` (a
list of
[`create_formulation_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation_selection.md)
outputs).

- **Required:** `name` (must match a protocol in the snapshot).
- **Optional**, with the PK-Sim fallback when omitted:
  - `formulations`: protocol application slots that have no formulation
    binding stay empty; PK-Sim will reject the simulation at load time
    if the protocol requires a formulation for an unbound slot. Supply
    `formulations` for every slot that needs one (typically every slot
    in oral protocols).

### Formulation selection: Formulation vs FormulationSelection

Same idea again. A `Formulation` building block (in
`snapshot$formulations`) is the project-level dissolution profile.
`FormulationSelection` is the per-simulation entry that binds that
formulation to one application slot inside the chosen protocol.

- **Required:** `name` (must match a formulation in the snapshot) and
  `key` (the application slot identifier inside the protocol).

## Event and observer-set selections

### Event selection: Event vs EventSelection

An `Event` building block (in `snapshot$events`) is the project-level
event definition (template plus parameters). `EventSelection` is the
per-simulation reference that picks one event by `name` and supplies its
`start_time` for this simulation. Aside from `start_time`, events carry
no per-simulation overlay.

[`create_event_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event_selection.md):

- **Required:** `name` (must match an event building block) and
  `start_time` (numeric, hours).

### Observer-set selection: ObserverSet vs ObserverSetSelection

An `ObserverSet` building block (in `snapshot$observer_sets`) is the
project-level observer bundle. `ObserverSetSelection` is the
per-simulation reference that picks one observer set by `name`. There is
no per-simulation overlay at all, which is why the factory takes only a
single argument.

[`create_observer_set_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set_selection.md):

- **Required:** `name` (must match an observer-set building block).

``` r

event <- create_event_selection(name = "High-fat breakfast", start_time = 12)
```

The `Midazolam` template ships no observer sets, so we skip
[`create_observer_set_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set_selection.md)
in this walkthrough. With a template that does have one
(`snapshot$observer_sets`), the call would look like:

``` r

observer_set <- create_observer_set_selection(
  name = "BrainPlasmaConcentration"
)
```

## Optional parameter overrides

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

## Assemble the simulation

With every input prepared, the final
[`create_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_simulation.md)
call wires them together.

``` r

sim <- create_simulation(
  name = "Midazolam single dose",
  model = "4Comp",
  individual = "Korean (Yu 2004 study)",
  compounds = list(compound),
  events = list(event),
  solver = solver,
  output_schema = schema,
  output_selections = c(
    "Organism|PeripheralVenousBlood|Midazolam|Plasma (Peripheral Venous Blood)"
  ),
  parameters = overrides
)

sim
#> 
#> ── Simulation: Midazolam single dose ───────────────────────────────────────────
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
#> 
#> ── Output selections (1) ──
#> 
#> • Organism|PeripheralVenousBlood|Midazolam|Plasma (Peripheral Venous Blood)
#> 
#> ── Output schema ──
#> 
#> • 2 intervals
#> 
#> ── Solver ──
#> 
#> • AbsTol: 1e-09
#> • RelTol: 1e-09
#> • MxStep: 100000
#> 
#> ── Parameter overrides (1) ──
```

## Attach and export

[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
appends the simulation to a snapshot. If any name referenced by the
simulation does not resolve to a known building block, you get one
informational warning per simulation; the add proceeds either way.

``` r

snapshot <- snapshot |>
  add_simulation(sim)
```

Export with
[`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
and PK-Sim will load the resulting JSON.

``` r

export_snapshot(snapshot, "midazolam-with-new-sim.json")
```

## Removing a simulation

``` r

snapshot <- snapshot |>
  remove_simulation("Midazolam single dose")
```
