# Integration test for the real below-floor migration round trip
# (`load_snapshot(..., upgrade = TRUE)` -> `.migrate_snapshot()`).
#
# This exercises the live PK-Sim core, which is slow (minutes) and, on the v12
# core, segfaults during `loadProjectFromSnapshot()` on macOS (the whole
# OSPSuite-R snapshot-conversion suite is skipped on macOS for that reason).
# It therefore runs only where a compatible core exists: it is skipped on CI
# and skipped unless the installed core is at least the supported floor. In
# practice it runs on the maintainer's v13 macOS stack.

test_that("upgrade = TRUE migrates a below-floor snapshot through PK-Sim", {
  testthat::skip_on_cran()
  testthat::skip_on_ci()
  testthat::skip_if_offline()
  # The v12 core segfaults on macOS during snapshot conversion; only run
  # where the installed core sits within the supported band (v13 emits 81).
  testthat::skip_if(
    .installed_core_version() < SUPPORTED_VERSION_MAX,
    "requires a PK-Sim core that emits a supported snapshot version"
  )

  # A real below-floor snapshot: the Midazolam-Model v1.1 release is Version
  # 78. A hand-authored stub would not survive a real core load, so use the
  # published snapshot.
  url <- paste0(
    "https://raw.githubusercontent.com/Open-Systems-Pharmacology/",
    "Midazolam-Model/v1.1/Midazolam-Model.json"
  )
  input <- withr::local_tempfile(fileext = ".json")
  utils::download.file(url, input, quiet = TRUE)

  before <- list.files(getwd(), recursive = TRUE)
  snapshot <- load_snapshot(input, upgrade = TRUE)
  after <- list.files(getwd(), recursive = TRUE)

  expect_s3_class(snapshot, "Snapshot")
  # The upgraded version is whatever the installed core emits.
  expect_equal(
    as.integer(unlist(snapshot$data$Version)),
    .installed_core_version()
  )
  # Temp migration artifacts must not leak into the working tree.
  expect_setequal(before, after)
})
