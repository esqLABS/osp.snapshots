# osp.snapshots

Domain glossary for the `osp.snapshots` R package: the language of **PK-Sim** project **Snapshots** and the package abstractions used to import, manipulate, and export them.

## Language

### Ecosystem

**OSP** (Open Systems Pharmacology):
The open-source initiative and software ecosystem for pharmacometrics modelling that produces both **PK-Sim** and **ospsuite**.
_Avoid_: OSP suite (the umbrella), Open-Systems-Pharmacology (in prose; OK in URLs and repo names).

**PK-Sim**:
The PBPK desktop application within **OSP** that exports projects as **Snapshots**.
_Avoid_: PKSim, PKSIM, pksim, PK Sim.

**ospsuite**:
The R package that provides programmatic access to the **OSP** simulation engine; `osp.snapshots` integrates with it for **Observed data** and for validating species, gender, and units.
_Avoid_: OSPSuite (in prose; the form "OSPSuite-R" is acceptable when naming the GitHub repo).

### Snapshot

**Snapshot**:
The exported representation of a **PK-Sim** project: a tree of **Building blocks**, **Simulations**, and **Observed data**, identified regardless of medium (on disk as JSON, parsed in memory as a list, or wrapped in the `Snapshot` R6 class).
_Avoid_: Project (PK-Sim's term for the same concept), snapshot file (when the in-memory form is also meant), PKSim snapshot.

### Building blocks

**Building block**:
A reusable, named PK-Sim project entity that can be referenced from a **Simulation**. The eight kinds, per `snapshot-spec.md`, are **ExpressionProfile**, **Individual**, **Population**, **Compound**, **Formulation**, **Protocol**, **ObserverSet**, and **Event**. A **Simulation**, **Observed data**, **ParameterIdentification**, **SimulationComparison**, and any **Classification** are NOT building blocks.
_Avoid_: component, entity, element (when meaning specifically one of the eight named types).

**Individual**:
A single virtual subject with demographic traits (age, weight, height, gender, species), a fully realised physiological parameter tree, and references to **Expression profiles**. Produced in PK-Sim by `IIndividualFactory.CreateAndOptimizeFor(originData, seed)`. Also used informally for a sampled member of a **Population** (see Flagged ambiguities).
_Avoid_: subject (too generic), patient (implies a real person).

**Population**:
A named **Building block** that specifies how to generate a cohort of synthetic subjects: random seed, **Population settings** (count and parameter ranges), and **Advanced parameters** that override default variability distributions. A recipe, not a realised cohort: subjects are produced by PK-Sim at simulation time, not stored in the **Snapshot**.
_Avoid_: cohort (when meaning the building block itself rather than its realised output), group.

**Expression profile**:
A named **Building block** describing where and how strongly an enzyme, transporter, or other protein is expressed in a given **Species**, including category, localization, ontogeny, and per-organ relative expression. Its name is a composite identifier of the form `Molecule|Species|Category` (e.g. `CYP3A4|Human|Variability`). Referenced by name from an **Individual**.
_Avoid_: molecule profile, expression record.

**Compound**:
A named **Building block** representing a drug molecule: physicochemical properties (lipophilicity, fraction unbound, solubility, permeability, pKa), plasma protein binding partner, **Calculation methods**, and biological **Processes** (metabolism, transport, induction, inhibition, clearance, binding).
_Avoid_: drug, molecule, substance.

**Process** (compound process):
A biological pathway attached to a **Compound** that describes how the compound is acted on or interacts with the body's machinery. Subtypes include hepatic / renal / biliary clearance, metabolising enzymes, induction, inhibition, transporter proteins, and plasma protein binding partners.
_Avoid_: pathway, mechanism, reaction (when the specific PK-Sim sense is meant).

**Formulation**:
A named **Building block** representing a drug release profile, created in PK-Sim by cloning a template identified by **Formulation type** (Weibull, Lint80, Particles, Table, ZeroOrder, FirstOrder, ...) and overriding parameters on the clone.
_Avoid_: dosage form (overloaded with pharmaceutics terminology), release profile (the type, not the building block).

**Protocol**:
A named **Building block** describing a dosing schedule. A **Simple Protocol** has a single application type, dosing interval, target organ/compartment, and dose. An **Advanced Protocol** has one or more **Schemas**, each with its own time unit and **Schema items**. The two forms are disambiguated by whether `ApplicationType` is present in the snapshot.
_Avoid_: dosing regimen, schedule (when the building block is meant), administration plan.

**Event** (building block):
A named **Building block** representing a discrete non-administration perturbation that happens at a specific simulation time (e.g. enzyme induction, organ removal, disease onset). Created in PK-Sim from a named **Event template** with parameter overrides on the clone. Distinct from the simulation parameter container also called "Events" (see Flagged ambiguities).
_Avoid_: trigger, perturbation (too generic).

**ObserverSet**:
A named **Building block** that bundles a collection of **Observers** for reuse in simulations.
_Avoid_: observer collection, observer group.

**Observer**:
A simulation-time formula that computes a derived quantity from the underlying model (e.g. an amount observer or a container observer), used to expose values that are not natural model outputs. An Observer is NOT itself a building block; it lives inside an **ObserverSet**.
_Avoid_: probe, watcher, metric.

### Other top-level snapshot sections

**Simulation**:
A named PK-Sim project entity that combines **Building blocks** into a runnable model. References either an **Individual** (then it is an **Individual simulation**) or a **Population** (then it is a **Population simulation**), plus **Compounds**, **Events**, **ObserverSets**, **Observed data**, a solver configuration, an output schema, and output selections. Not itself a building block; not currently wrapped in an R6 class by `osp.snapshots` (passes through as raw JSON).
_Avoid_: model, run.

**Observed data**:
Experimental measurement series (time + value + error) attached to a **Snapshot**. Each entry maps to a PK-Sim `DataRepository` and is loaded by `osp.snapshots` into an `ospsuite::DataSet`. Referenced by name from a **Simulation**. Not a **Building block**.
_Avoid_: observation, dataset (unqualified), experimental data.

### Leaves and shared types

**Parameter**:
A named value with a unit, optional **Value origin** (provenance), and optional formula. The most-used leaf type in a snapshot. May be scalar or backed by a **Table formula**.
_Avoid_: setting, property, attribute (when the snapshot-level Parameter shape is meant).

**Localized parameter**:
A **Parameter** identified by its full path within a target's parameter tree (typically a **Simulation** or **Individual**). The path locates where the override applies. In v11+ snapshots, path segments named `Applications` are migrated to `Events`. Exported by `osp.snapshots` as the R6 class `LocalizedParameter`, which inherits from `Parameter`; `create_parameter(path = ...)` routes to it. `inherits(x, "Parameter")` is `TRUE` for `LocalizedParameter` instances.
_Avoid_: pathed parameter, parameter override (too generic).

**Advanced parameter**:
A **Population**-specific parameter that overrides a default variability distribution used during random subject sampling. Exported by `osp.snapshots` as the R6 class `AdvancedParameter`.
_Avoid_: variability parameter, distribution override.

**Value origin**:
Metadata on a **Parameter** describing where its value came from (source, description). Preserved through snapshot round-trips.
_Avoid_: provenance (acceptable in prose), source (too generic).

**Range**:
A min/max pair with a unit, used for physiological bounds (age, weight, height, BMI) inside an **Origin data** entry. A leaf utility type.
_Avoid_: bounds, interval.

**Origin data**:
The demographic and physiological starting point used to generate an **Individual**: species, gender, population, age, weight, height, and BMI **Ranges**.
_Avoid_: demographics, subject data.

### Protocol internals

**Schema** (Advanced Protocol schema):
A repeatable block inside an **Advanced Protocol** consisting of schema-level **Parameters** (e.g. number of repetitions, time between repetitions) and an ordered list of **Schema items**.
_Avoid_: schedule block, dosing block.

**Schema item**:
One application within a **Schema**: application type, an optional **Formulation key**, target organ/compartment, and parameters (dose, start time, ...). Each schema item is one administration.
_Avoid_: dose entry, application entry.

### Compound internals

**Calculation methods**:
A named set of methods that PK-Sim uses to derive **Compound** quantities (e.g. partition coefficient calculation method). Stored on a Compound as a `CalculationMethodCache`.
_Avoid_: methods (unqualified), formulas.

### Templates

**Building-block template** (also: snapshot template):
A named, publicly published example **Snapshot** hosted in the `OSPSuite.BuildingBlockTemplates` GitHub repository, resolvable by name. Used by `load_snapshot("Midazolam")` and listed by `osp_models()`.
_Avoid_: example snapshot, sample project.

## Relationships

- A **Snapshot** owns zero or more of each **Building block** kind, plus zero or more **Simulations** and **Observed data** entries.
- A **Simulation** references exactly one of {an **Individual**, a **Population**}, zero or more **Compounds**, zero or more **Events** (building blocks), zero or more **ObserverSets**, and zero or more **Observed data** entries, all by name.
- An **Individual** references zero or more **Expression profiles** by their composite name (`Molecule|Species|Category`).
- An **Expression profile**'s name is `Molecule|Species|Category`; this is its identity in the project.
- A **Population** owns zero or more **Advanced parameters**; subjects are not stored in the snapshot.
- A **Compound** owns zero or more **Processes** and a set of **Calculation methods**.
- A **Protocol** is either a **Simple Protocol** (one application) or an **Advanced Protocol** (zero or more **Schemas**, each owning zero or more **Schema items**).
- A **Schema item** can reference a **Formulation** via a `FormulationKey` (resolved within a **Simulation**'s formulation selections).
- An **ObserverSet** owns zero or more **Observers**.
- A **Parameter** may be plain, **Localized** (pathed), or **Advanced** (variability override for a **Population**).
- "Events" appears in two distinct positions: the `Events[]` array of **Event** building blocks, and the `Events|...` container in a **Simulation**'s parameter tree (renamed from `Applications|...` in v11).

## Example dialogue

> **Dev:** "I loaded a **Snapshot** with `load_snapshot()` and the `individuals` list has one entry. The user said this is a population study. Where are the other subjects?"
> **Domain expert:** "An **Individual** is a separate **Building block**. If it is a population study, the **Snapshot** should also have a **Population**, which is a recipe for generating subjects. The subjects themselves are not stored; PK-Sim samples them at simulation time."

> **Dev:** "The **Compound** has a process I have not seen, marked `metabolizing_enzymes`. Is that a **Building block**?"
> **Domain expert:** "No. It is a **Process** on the **Compound**. **Processes** are sub-structures inside a **Compound**, not building blocks of their own."

> **Dev:** "I see a parameter at path `Events|MyEvent|Dose`. Is `MyEvent` an entry in the `Events[]` array?"
> **Domain expert:** "Probably not, that is the overloaded sense. In a **Simulation**'s parameter tree, `Events|...` is where dose-application parameters live, fed by a **Protocol** schema. The `Events[]` array holds **Event** building blocks, which are non-administration perturbations. Different things."

> **Dev:** "Two **Expression profiles** seem to have the same `Molecule` and `Species`. Is that allowed?"
> **Domain expert:** "Yes, as long as the `Category` differs, because an **Expression profile**'s identity is the composite `Molecule|Species|Category`. If even that collides, PK-Sim skips the duplicate on load."

## Flagged ambiguities

- The desktop application is spelled inconsistently across the codebase: "PKSim" in `snapshot-spec.md`, "PKSIM" in CLI output (`R/Snapshot.R`) and `DESCRIPTION`. Resolved: **PK-Sim** is canonical; the in-code forms are not being rewritten retroactively but new prose should use "PK-Sim".
- The R package is sometimes written "OSPSuite" (e.g. the GitHub repo `OSPSuite-R`) and sometimes "ospsuite" (R imports). Resolved: **ospsuite** is canonical for the package; "OSPSuite-R" is acceptable only when naming the GitHub repository.
- "Snapshot" was used to mean a JSON file, an in-memory list, an R6 object, and (in `snapshot-spec.md`) a PK-Sim Project. Resolved: **Snapshot** names the logical export regardless of medium; "Project" is the PK-Sim-internal synonym to avoid.
- "Individual" is overloaded: (a) a named **Building block** with its own slot in `Snapshot$individuals`, and (b) informally, a sampled member of a **Population**. Both senses stay in use; the building-block sense is primary. When precision matters, prefer "Individual building block" vs "population member" / "sampled subject".
- "Event" / "Events" is overloaded: (a) the `Events[]` **Building block** array (template-instantiated non-administration perturbations), and (b) a container in a simulation's parameter tree named `Events|...` where dose-application parameters live (renamed from `Applications|...` in v11). Sense (a) is the building block; sense (b) is a path segment in the simulation's parameter tree fed by **Protocol** schemas. Don't confuse "Events[]" with "Events|...".
