#' Scaffold a companion skill for AI coding agents
#'
#' @description
#' Copies the bundled osp.snapshots companion skill into a project so an AI
#' coding agent (Claude Code or similar) can read it. The skill is written to
#' `<path>/.claude/skills/osp-snapshots/SKILL.md` and teaches an agent to
#' consume the osp.snapshots public API and avoid its known gotchas. The
#' written file is stamped with the installed osp.snapshots version in its
#' `x-osp-snapshots-version` frontmatter field, so an outdated copy is
#' detectable from version control.
#'
#' If the destination already exists and `overwrite` is `FALSE`, the behavior
#' depends on the session: an interactive session asks for confirmation, while
#' a non-interactive session (`R CMD check`, CI, `Rscript`) aborts and asks you
#' to pass `overwrite = TRUE`. This keeps automated runs deterministic.
#'
#' @param path Target project root. Defaults to the current working directory
#'   (`"."`). The skill is written under `path` at
#'   `.claude/skills/osp-snapshots/SKILL.md`, creating any missing parent
#'   directories.
#' @param overwrite Single logical. When `TRUE`, an existing skill file is
#'   replaced and re-stamped without prompting. When `FALSE` (the default) and
#'   the file exists, an interactive session asks for confirmation and a
#'   non-interactive session aborts.
#'
#' @return The destination `SKILL.md` path, invisibly. Returned in every case,
#'   including when an interactive user declines to overwrite an existing file.
#'
#' @examples
#' \dontrun{
#' # Scaffold the skill into the current project.
#' use_claude_code()
#'
#' # Refresh an existing skill after upgrading osp.snapshots.
#' use_claude_code(overwrite = TRUE)
#' }
#'
#' @export
use_claude_code <- function(path = ".", overwrite = FALSE) {
  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    cli::cli_abort(
      "{.arg path} must be a single non-missing string.",
      call = parent.frame()
    )
  }
  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    cli::cli_abort(
      "{.arg overwrite} must be a single {.code TRUE} or {.code FALSE}.",
      call = parent.frame()
    )
  }

  template <- read_skill_template()
  if (!any(grepl("@VERSION@", template, fixed = TRUE))) {
    cli::cli_abort(
      c(
        "The bundled skill template is missing its version placeholder.",
        i = "Expected the {.code @VERSION@} token in the template frontmatter."
      ),
      call = parent.frame()
    )
  }

  dest <- fs::path(path, ".claude", "skills", "osp-snapshots", "SKILL.md")

  if (fs::file_exists(dest) && !overwrite) {
    if (is_interactive()) {
      if (!confirm_overwrite(dest)) {
        cli::cli_alert_info("Left existing skill at {.file {dest}} unchanged.")
        return(invisible(dest))
      }
    } else {
      cli::cli_abort(
        c(
          "A skill already exists at {.file {dest}}.",
          i = "Pass {.code overwrite = TRUE} to replace it."
        ),
        call = parent.frame()
      )
    }
  }

  version <- as.character(utils::packageVersion("osp.snapshots"))
  stamped <- sub("@VERSION@", version, template, fixed = TRUE)

  fs::dir_create(fs::path_dir(dest))
  writeLines(stamped, dest)
  cli::cli_alert_success("Wrote osp.snapshots skill to {.file {dest}}.")

  invisible(dest)
}

# Internal: return the bundled skill template as a character vector of lines.
# Resolves the installed template and aborts on a broken install (an empty
# path) rather than writing an empty file. A top-level binding so tests can
# mock it via testthat::local_mocked_bindings() on this package's namespace.
read_skill_template <- function() {
  path <- system.file(
    "skill",
    "osp-snapshots",
    "SKILL.md",
    package = "osp.snapshots"
  )
  if (!nzchar(path)) {
    cli::cli_abort(
      c(
        "Could not find the bundled osp.snapshots skill template.",
        i = "This usually means osp.snapshots is not installed correctly."
      ),
      call = parent.frame()
    )
  }
  readLines(path)
}

# Internal: ask the interactive user whether to overwrite an existing skill.
# Returns a single logical. Only reached in the interactive, overwrite = FALSE,
# file-exists branch, so it is never executed under R CMD check or CI. A
# top-level binding so tests can mock it via local_mocked_bindings().
confirm_overwrite <- function(path) {
  choice <- utils::menu(
    c("Yes", "No"),
    title = paste0("A skill already exists at ", path, ". Replace it?")
  )
  identical(choice, 1L)
}

# Internal: thin wrapper over interactive() so the interactive gate is a
# top-level binding that tests can mock via local_mocked_bindings().
is_interactive <- function() {
  interactive()
}
