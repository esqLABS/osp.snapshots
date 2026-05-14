## Project docs

When working on this repo, consult these documents before diving into code or making decisions about naming, design, or workflow:

- **`.claude/CONTEXT.md`** — domain glossary. The canonical vocabulary for **PK-Sim**, **Snapshots**, **Building blocks**, **Processes**, **Parameters**, etc., plus flagged ambiguities (e.g. `Events[]` vs `Events|...`). Use these terms in code, comments, issues, PRs, and prose; avoid the listed synonyms.
- **`.claude/architecture.md`** — architectural overview of the `osp.snapshots` package: the R6 class tree, data flow (load → mutate → export), tibble layer, ospsuite integration, and cross-cutting concerns like round-trip fidelity. Includes a file map and code-reference table.
- **`.claude/snapshot-spec.md`** — authoritative reference for the PK-Sim JSON snapshot schema. Field-by-field domain mappings of every top-level section and supporting type. Treat as source of truth when the JSON shape is in question.
- **`.claude/agents/issue-tracker.md`** — how to work with GitHub Issues for this repo (commands, conventions, triage opt-out).
- **`.claude/agents/domain.md`** — how engineering skills consume the documents above (read order, glossary discipline, ADR conflict handling).

If a `.claude/adr/` directory appears later, read ADRs that touch the area you are about to change.

## R package development

### Key commands

```
# To run code
Rscript -e "devtools::load_all(); code"

# To run all tests
Rscript -e "devtools::test()"

# To run all tests for files starting with {name}
Rscript -e "devtools::test(filter = '^{name}')"

# To run all tests for R/{name}.R
Rscript -e "devtools::test_active_file('R/{name}.R')"

# To run a single test "blah" for R/{name}.R
Rscript -e "devtools::test_active_file('R/{name}.R', desc = 'blah')"

# To redocument the package
Rscript -e "devtools::document()"

# To check pkgdown documentation
Rscript -e "pkgdown::check_pkgdown()"

# To check the package with R CMD check
Rscript -e "devtools::check()"

# To format code
air format .
```

### Coding

* Always run `air format .` after generating code
* Use the base pipe operator (`|>`) not the magrittr pipe (`%>%`)
* Don't use `_$x` or `_$[["x"]]` since this package must work on R 4.1.
* Use `\() ...` for single-line anonymous functions. For all other cases, use `function() {...}`

### Testing

- Tests for `R/{name}.R` go in `tests/testthat/test-{name}.R`.
- All new code should have an accompanying test.
- If there are existing tests, place new tests next to similar existing tests.
- Strive to keep your tests minimal with few comments.
- Never put code in a `test-{name}.R` file outside of a `test_that()` block. Instead, use `tests/testthat/helper.R` or `tests/testthat/helper-{name}.R`.
- Avoid `expect_true()` and `expect_false()` in favour of a specific expectation which will give a better failure message. A few expectations in newer releases that you might not know about are `expect_all_true()`, `expect_all_equal()`, and `expect_r6_class()`.
- When testing errors and warnings, don't use `expect_error()` or `expect_warning()`. Instead, use `expect_snapshot(error = TRUE)` for errors and `expect_snapshot()` for warnings because these allow the user to review the full text of the output.
- Avoid the `.package` argument to `local_mocked_bindings()`; this modifies the namespace of another package which is not good practice. Instead create a mockable version of the function in the current package. See `?local_mocked_bindings` for more details.

### Documentation

- Every user-facing function should be exported and have roxygen2 documentation.
- Wrap roxygen comments at 80 characters.
- Internal functions should not have roxygen documentation.
- Whenever you add a new (non-internal) documentation topic, also add the topic to `_pkgdown.yml`.
- Always re-document the package after changing a roxygen2 comment.
- Use `pkgdown::check_pkgdown()` to check that all topics are included in the reference index.

### `NEWS.md`

- Every user-facing change should be given a bullet in `NEWS.md`. Do not add bullets for small documentation changes or internal refactorings.
- Each bullet should briefly describe the change to the end user and mention the related issue in parentheses.
- A bullet can consist of multiple sentences but should not contain any new lines (i.e. DO NOT line wrap).
- If the change is related to a function, put the name of the function early in the bullet.
- Order bullets alphabetically by function name. Put all bullets that don't mention function names at the beginning.

### GitHub

- If you use `gh` to retrieve information about an issue, always use `--comments` to read all the comments.

### Writing

- Use sentence case for headings.
- Use US English.

### Proofreading

If the user asks you to proofread a file, act as an expert proofreader and editor with a deep understanding of clear, engaging, and well-structured writing.

Work paragraph by paragraph, always starting by making a TODO list that includes individual items for each top-level heading.

Fix spelling, grammar, and other minor problems without asking the user. Label any unclear, confusing, or ambiguous sentences with a FIXME comment.

Only report what you have changed.

## Agent skills

### Issue tracker

Issues live in GitHub Issues at `esqLABS/osp.snapshots`. Use the `gh` CLI. See `.claude/agents/issue-tracker.md`.

### Triage labels

This repo does not use the five-role triage label system from the `triage` skill. Skills that would otherwise apply `needs-triage`, `needs-info`, `ready-for-agent`, or `ready-for-human` should skip the label step on this repo; only `wontfix` exists and may be used as-is.

### Domain docs

Single-context, with documents under `.claude/` instead of the repo root: `.claude/CONTEXT.md` (glossary), `.claude/architecture.md` (architectural overview), `.claude/snapshot-spec.md` (PK-Sim JSON schema), and `.claude/adr/` (ADRs, once any exist). See the "Project docs" section above for what each contains, and `.claude/agents/domain.md` for how skills should consume them.
