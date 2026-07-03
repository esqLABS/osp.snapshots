test_that("use_claude_code() copies the template and stamps the version", {
  dir <- withr::local_tempdir()
  dest <- fs::path(dir, ".claude", "skills", "osp-snapshots", "SKILL.md")

  path <- suppressMessages(use_claude_code(dir))

  expect_equal(unname(fs::file_exists(dest)), TRUE)
  expect_equal(fs::path(path), dest)

  written <- readLines(dest)
  version <- as.character(utils::packageVersion("osp.snapshots"))
  expect_equal(
    written[grepl("^x-osp-snapshots-version:", written)],
    paste0("x-osp-snapshots-version: \"", version, "\"")
  )
  expect_equal(sum(grepl("@VERSION@", written, fixed = TRUE)), 0L)

  # Everything except the version line matches the bundled template.
  template <- readLines(system.file(
    "skill",
    "osp-snapshots",
    "SKILL.md",
    package = "osp.snapshots"
  ))
  version_line <- grepl("^x-osp-snapshots-version:", template)
  expect_equal(written[!version_line], template[!version_line])
})

test_that("use_claude_code() returns the destination path invisibly", {
  dir <- withr::local_tempdir()
  expect_invisible(suppressMessages(use_claude_code(dir)))
})

test_that("overwrite = TRUE re-stamps an existing file without prompting", {
  dir <- withr::local_tempdir()
  dest <- fs::path(dir, ".claude", "skills", "osp-snapshots", "SKILL.md")

  suppressMessages(use_claude_code(dir))
  # Corrupt the existing file to prove it is replaced.
  writeLines("stale content", dest)

  suppressMessages(use_claude_code(dir, overwrite = TRUE))

  written <- readLines(dest)
  version <- as.character(utils::packageVersion("osp.snapshots"))
  expect_equal(
    written[grepl("^x-osp-snapshots-version:", written)],
    paste0("x-osp-snapshots-version: \"", version, "\"")
  )
  expect_contains(written, "name: osp-snapshots")
})

test_that("interactive decline leaves the existing file unchanged", {
  dir <- withr::local_tempdir()
  dest <- fs::path(dir, ".claude", "skills", "osp-snapshots", "SKILL.md")

  suppressMessages(use_claude_code(dir))
  before <- readLines(dest)

  testthat::local_mocked_bindings(
    is_interactive = function() TRUE,
    confirm_overwrite = function(path) FALSE
  )
  path <- suppressMessages(use_claude_code(dir, overwrite = FALSE))

  expect_equal(fs::path(path), dest)
  expect_equal(readLines(dest), before)
})

test_that("interactive accept overwrites the existing file", {
  dir <- withr::local_tempdir()
  dest <- fs::path(dir, ".claude", "skills", "osp-snapshots", "SKILL.md")

  suppressMessages(use_claude_code(dir))
  writeLines("stale content", dest)

  testthat::local_mocked_bindings(
    is_interactive = function() TRUE,
    confirm_overwrite = function(path) TRUE
  )
  suppressMessages(use_claude_code(dir, overwrite = FALSE))

  written <- readLines(dest)
  expect_contains(written, "name: osp-snapshots")
})

test_that("non-interactive existing file without overwrite aborts", {
  dir <- withr::local_tempdir()
  suppressMessages(use_claude_code(dir))

  testthat::local_mocked_bindings(is_interactive = function() FALSE)
  expect_snapshot(
    use_claude_code(dir, overwrite = FALSE),
    error = TRUE,
    transform = \(lines) {
      gsub(
        "at '.*/(\\.claude/skills/osp-snapshots/SKILL\\.md)'",
        "at '<tempdir>/\\1'",
        lines
      )
    }
  )
})

test_that("a template missing the version placeholder aborts", {
  dir <- withr::local_tempdir()
  testthat::local_mocked_bindings(
    read_skill_template = function() "no placeholder here"
  )
  expect_snapshot(use_claude_code(dir), error = TRUE)
})

test_that("use_claude_code() validates its inputs", {
  expect_snapshot(use_claude_code(path = 1), error = TRUE)
  expect_snapshot(
    use_claude_code(withr::local_tempdir(), overwrite = "yes"),
    error = TRUE
  )
})
