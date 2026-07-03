# Scaffold a companion skill for AI coding agents

Copies the bundled osp.snapshots companion skill into a project so an AI
coding agent (Claude Code or similar) can read it. The skill is written
to `<path>/.claude/skills/osp-snapshots/SKILL.md` and teaches an agent
to consume the osp.snapshots public API and avoid its known gotchas. The
written file is stamped with the installed osp.snapshots version in its
`x-osp-snapshots-version` frontmatter field, so an outdated copy is
detectable from version control.

If the destination already exists and `overwrite` is `FALSE`, the
behavior depends on the session: an interactive session asks for
confirmation, while a non-interactive session (`R CMD check`, CI,
`Rscript`) aborts and asks you to pass `overwrite = TRUE`. This keeps
automated runs deterministic.

## Usage

``` r
use_claude_code(path = ".", overwrite = FALSE)
```

## Arguments

- path:

  Target project root. Defaults to the current working directory
  (`"."`). The skill is written under `path` at
  `.claude/skills/osp-snapshots/SKILL.md`, creating any missing parent
  directories.

- overwrite:

  Single logical. When `TRUE`, an existing skill file is replaced and
  re-stamped without prompting. When `FALSE` (the default) and the file
  exists, an interactive session asks for confirmation and a
  non-interactive session aborts.

## Value

The destination `SKILL.md` path, invisibly. Returned in every case,
including when an interactive user declines to overwrite an existing
file.

## Examples

``` r
if (FALSE) { # \dontrun{
# Scaffold the skill into the current project.
use_claude_code()

# Refresh an existing skill after upgrading osp.snapshots.
use_claude_code(overwrite = TRUE)
} # }
```
