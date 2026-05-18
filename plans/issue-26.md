# Issue #26: dual API policy for mutators

## Question

Should `Snapshot` mutators (e.g. `add_individual`) continue to exist in two
forms (an exported function and an R6 method), or collapse to one?

## Findings

Today, building-block mutators live in `R/Snapshot.R` in both forms:

- R6 methods on `Snapshot` (e.g. `add_individual` at `R/Snapshot.R:223`,
  `remove_individual` at `R/Snapshot.R:253`).
- Exported wrapper functions (e.g. `add_individual()` at `R/Snapshot.R:1341`)
  that call `validate_snapshot()`, then delegate to the R6 method, then return
  `invisible(snapshot)`.

The exported wrappers add only one piece of behaviour the R6 method lacks:
`validate_snapshot()`. The body is otherwise mechanical.

Coverage today is asymmetric (this is the subject of issue #39):

- Individual, Formulation, ExpressionProfile: both forms for `add_*` and
  `remove_*`.
- Population: function form for `remove_population` only.
- Compound, Protocol, Event: no exported mutators at all.
- ObservedData: R6 methods only (`R/Snapshot.R:505`, `R/Snapshot.R:530`); no
  exported function form.

So the "dual API" is already partial; the question is which direction to make
it consistent.

## Options

1. **Keep both forms.** Document the contract: every mutator has an exported
   function and an R6 method, function form validates then delegates. Pro:
   matches the dominant existing pattern. Con: each new mutator doubles the
   work and the public surface; #39's gap-fill multiplies the duplication.

2. **R6 methods only.** Drop the exported wrappers; users call
   `snapshot$add_individual(...)`. Validation moves into the R6 method (or is
   redundant, since the R6 method already operates on `self`). Pro: half the
   public surface; one source of truth. Con: breaking change; pipe-friendly
   `snapshot |> add_individual(ind)` form goes away.

3. **Exported functions only.** Drop public method access; users call
   `add_individual(snapshot, ...)`. Pro: pipe-friendly; single function entry
   point. Con: bigger refactor than #2; R6 methods are already documented as
   part of the public surface; removing them is a larger break.

## Recommendation

**Option 1 (keep both forms), with a strict contract going forward.** This is
the lowest-friction decision:

- The dominant existing pattern is dual API. Three building blocks (Individual,
  Formulation, ExpressionProfile) already ship both forms; reverting them is
  more churn than completing the set.
- R users expect pipe-friendly mutators: `snapshot |> add_individual(ind)` is
  more idiomatic than `snapshot$add_individual(ind)`. The function form pays
  its keep.
- The duplication is mechanical (validate, delegate, return invisibly). It can
  be reduced with a one-line helper if it becomes painful, but at six building
  blocks the cost is small.

**Contract:**

1. Every mutator that exists as an R6 method also has an exported function of
   the same name.
2. The exported function validates the snapshot via `validate_snapshot()`,
   delegates to the R6 method, and returns `invisible(snapshot)`.
3. The R6 method does the work and does not re-validate (the wrapper has
   already validated).
4. ObservedData is the lone exception today; its function wrappers will be
   added under issue #39.

This contract makes #39 (filling the `add_*` / `remove_*` gaps) mechanical and
unblocks #38 (ObserverSet end-to-end) and #43 (`create_observer_set`).

## Work items

- [ ] Add a `NEWS.md` bullet under `# osp.snapshots (development version)`
      recording the policy and a one-line rationale.
- [ ] Add a comment on issue #26 quoting the contract and linking to the PR
      (deferred until after the PR is opened).
