# non-interactive existing file without overwrite aborts

    Code
      use_claude_code(dir, overwrite = FALSE)
    Condition
      Error:
      ! A skill already exists at '<tempdir>/.claude/skills/osp-snapshots/SKILL.md'.
      i Pass `overwrite = TRUE` to replace it.

# a template missing the version placeholder aborts

    Code
      use_claude_code(dir)
    Condition
      Error:
      ! The bundled skill template is missing its version placeholder.
      i Expected the `@VERSION@` token in the template frontmatter.

# use_claude_code() validates its inputs

    Code
      use_claude_code(path = 1)
    Condition
      Error:
      ! `path` must be a single non-missing string.

---

    Code
      use_claude_code(withr::local_tempdir(), overwrite = "yes")
    Condition
      Error:
      ! `overwrite` must be a single `TRUE` or `FALSE`.

