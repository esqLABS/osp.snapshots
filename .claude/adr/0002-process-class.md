# ADR-0002: Extract Process as a flat domain class with a `category` field

**Status:** Accepted, 2026-05-18.

**Related:** issue #28 (decides), unblocks implementation issue #40.

## Context

`R/Compound.R` is around 1774 lines. Roughly two-thirds of that is eight private fields, each decomposing one subtype of compound process: `.protein_binding_partners`, `.metabolizing_enzymes`, `.hepatic_clearance`, `.transporter_proteins`, `.renal_clearance`, `.biliary_clearance`, `.inhibition`, `.induction`. Each has its own `.extract_*()` and `.*_to_table()` method.

The snapshot JSON itself does not bucket Processes this way. Per `snapshot-spec.md`, a `Compound` carries a single `Processes: CompoundProcess[]` array. Every entry shares the same shape: `InternalName`, `DataSource`, optional `Molecule` / `Metabolite` / `Species`, `Parameters[]`. The eight subtypes are discriminated only by the value of `InternalName` (resolved against PK-Sim's compound process repository); they are an R-side bucketing, not a JSON-side one.

`CONTEXT.md` names **Process** as a single domain noun whose subtypes "include hepatic / renal / biliary clearance, metabolising enzymes, induction, inhibition, transporter proteins, and plasma protein binding partners." That phrasing fits a flat class with a discriminator field.

External users currently consume the eight per-category tibbles returned by `get_compounds_dfs()`. Breaking that shape outright would silently break their pipelines.

## Decision

**Class shape.** Introduce a single exported `Process` R6 class in `R/Process.R`. Fields exposed via active bindings, mirroring `CompoundProcess` from `snapshot-spec.md`: `internal_name`, `data_source`, `molecule`, `metabolite`, `species`, `parameters`, plus a derived `category` field (string: `"hepatic_clearance"`, `"metabolizing_enzymes"`, etc.) computed from `internal_name`. No subtype hierarchy. The eight `*_to_table()` and `.extract_*()` methods on `Compound` collapse into one `Process$to_df()` and one walk over `Processes[]` during `Compound$initialize`.

**Compound surface.** `compound$processes` returns a flat named list of `Process` objects, with the disambiguation suffix rule already used elsewhere in the package. No `processes_by_category` accessor; users filter by `category` field or via the tibble layer. Eight private `Compound` fields and their extract/to-table methods are removed.

**Tibble exporter.** `get_compounds_dfs()` gains a new long-form `processes` tibble: one row per (process, parameter) pair, with columns including `compound`, `category`, `process_name`, `parameter`, `value`, `unit`, `data_source`, `source`, and the optional `molecule` / `metabolite` / `species` columns (NA where not applicable). The eight existing category-keyed tibbles (`protein_binding_partners`, `metabolizing_enzymes`, `hepatic_clearance`, `transporter_proteins`, `renal_clearance`, `biliary_clearance`, `inhibition`, `induction`) are kept as a backwards-compat shim and marked with `lifecycle::deprecate_soft()`. `NEWS.md` announces the long form as preferred. Removal is scheduled for a later major version.

**Factory.** `create_process()` ships in the same slice, exported, with roxygen and a `_pkgdown.yml` entry, matching the trajectory of issue #27.

**Round-trip fidelity.** Preserved as the implementation constraint. The flat list of `Process` objects must serialise back to the same `Compound.Processes: CompoundProcess[]` shape it was loaded from.

## Consequences

**For `R/Compound.R`:** expected to drop from ~1774 lines to under 1000 once the eight private fields and their methods are removed and process handling lives in `Process`.

**For users:** the eight existing tibbles keep working but their docs gain a "preferred: use `processes`" badge. `compound$processes` becomes a flat named list; anyone previously doing `compound$protein_binding_partners` (if any such access existed via active binding) needs to filter by category. The `creating-building-blocks.Rmd` vignette gains a section on `create_process()`.

**For follow-ups:** when ObserverSet (issue #38) ships, it does not need to consider Process. When `compound$add_process()` / `remove_process()` becomes a desired feature, the class is ready for it (file separately when needed).

**For `architecture.md`:** the Compound row in the file map gets updated, and a `Process` row is added. The change happens in the implementation slice that delivers the class, not here.
