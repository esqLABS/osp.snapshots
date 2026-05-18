# ADR-0001: Mutator API surface — exported functions are public, R6 methods are implementation

**Status:** Accepted, 2026-05-18.

**Related:** issue #26 (decides), blocks issues #38, #39.

## Context

Every mutator on `Snapshot` currently exists in two forms:

1. An R6 method on the class, e.g. `Snapshot$add_individual(individual)`.
2. An exported package function taking a `Snapshot`, e.g. `add_individual(snapshot, individual)`, which calls `validate_snapshot()` and delegates to the R6 method.

Both forms are documented (each carries a full roxygen block with `@description`, `@param`, `@examples`). The function variant is what the vignette `creating-building-blocks.Rmd` teaches; the test suite calls the R6 methods directly. The architecture doc records this as a deliberate "dual API."

Several follow-up issues (#38 ObserverSet, #39 mutator gap-fill, plus future blocks) will multiply this surface area: each new mutator is written twice, documented twice, and tested twice. Before picking those issues up, the policy needs to be settled once.

The user audience is pharmacometricians / modellers writing R scripts: they pipe (`snapshot |> add_individual(ind) |> add_formulation(form)`) and treat the R6 object as an implementation detail.

## Decision

The exported `add_*` / `remove_*` **functions are the public, documented API**. The R6 methods stay callable so existing tests and internal code keep working, but are demoted to **implementation details**:

- The exported function is the One True Way users are taught. It carries full roxygen (`@description`, `@param`, `@examples` using the pipeable form), `@export`, and a `_pkgdown.yml` entry under "Mutators."
- The R6 mutator method gets **no roxygen block at all**. It is a bare entry on the class. (Reference: `dplyr::mutate` carries the full docs; the S3 methods `mutate.data.frame` etc. have only `@rdname mutate` + method-specific params. We follow the same discipline, adapted to R6: the implementation entry carries no doc.)
- `validate_snapshot()` stays in the exported function. The R6 method does not re-validate `self`.
- No `lifecycle::deprecate_*` warning on the R6 methods. The methods were never the documented public API; demoting them is a documentation change, not a behaviour change.
- The test suite is not migrated. Tests can continue to call `snapshot$add_individual(...)`; new tests should still prefer this style because it is closer to the implementation under test.

A `NEWS.md` bullet documents the reclassification when the first dependent slice ships.

## Consequences

**For new mutators (#38, #39, and beyond):** ship one exported function with full roxygen + `_pkgdown.yml` entry, backed by a bare R6 method. Do not write a roxygen block on the method.

**For existing mutators:** strip the roxygen blocks from each R6 mutator method in `R/Snapshot.R`. The exported wrappers keep their docs. Method examples that referenced the `snapshot$add_…()` form are deleted (the exported function's examples take their place).

**For `architecture.md` line 159 ("Dual API"):** the paragraph is updated to describe the function form as the public API and the method as implementation. (The implementation slice that strips method roxygen also edits this paragraph.)

**For users:** no behaviour change. `snapshot$add_individual(...)` keeps working; it just no longer shows up in `?Snapshot` after the next documentation regeneration.

**For `validate_snapshot()`:** stays where it is. Whether it is independently useful is a separate question (see ADR-0004's optional follow-up).
