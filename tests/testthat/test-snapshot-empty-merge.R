# Regression coverage for issue #59: the `Snapshot$data` active field must
# honour user intent across the three lazy-cache states (NULL untouched,
# `list()` cleared, non-empty hydrated). PR #58 introduced the tri-state
# adapter contract that fixed the pre-existing merge bug; these tests guard
# against future regressions.

# Scenario A: load N items, remove every one via the matching mutator. The
# exported section must be empty (the user's clear intent), not the original
# items resurrected.

test_that("remove_compound clearing all entries drops the Compounds section on export", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))
  for (name in names(snapshot$compounds)) {
    snapshot$remove_compound(name)
  }

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)

  reloaded <- load_snapshot(out)
  expect_length(reloaded$compounds, 0)

  parsed <- jsonlite::fromJSON(
    out,
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  expect_length(parsed$Compounds, 0)
})

test_that("remove_individual clearing all entries drops the Individuals section on export", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))
  for (name in names(snapshot$individuals)) {
    snapshot$remove_individual(name)
  }

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)

  reloaded <- load_snapshot(out)
  expect_length(reloaded$individuals, 0)

  parsed <- jsonlite::fromJSON(
    out,
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  expect_length(parsed$Individuals, 0)
})

test_that("remove_observed_data clearing every dataset drops the ObservedData section on export", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))
  snapshot$remove_observed_data(names(snapshot$observed_data))

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)

  parsed <- jsonlite::fromJSON(
    out,
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  expect_null(parsed[["ObservedData"]])
})

# Scenario B: load a snapshot where the section is already empty (or absent),
# never touch the active binding. The exported payload must replay the
# original shape verbatim.

test_that("untouched empty Compounds section round-trips verbatim", {
  data <- list(
    Version = 80,
    Compounds = list(),
    Individuals = list(list(Name = "Alice"))
  )
  snapshot <- Snapshot$new(data)

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)

  parsed <- jsonlite::fromJSON(
    out,
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  expect_length(parsed$Compounds, 0)
  expect_named(parsed, c("Version", "Compounds", "Individuals"))
})

test_that("untouched missing Compounds section stays absent on export", {
  data <- list(
    Version = 80,
    Individuals = list(list(Name = "Alice"))
  )
  snapshot <- Snapshot$new(data)

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)

  parsed <- jsonlite::fromJSON(
    out,
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  expect_named(parsed, c("Version", "Individuals"))
})

# Scenario C: read a collection via the active binding without mutating, then
# export. The lazy cache transitions from NULL to a hydrated list of R6
# wrappers, but the exported names and count must match the original.

test_that("reading compounds without mutating preserves them on export", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))
  original_names <- names(snapshot$compounds)

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)

  reloaded <- load_snapshot(out)
  expect_equal(names(reloaded$compounds), original_names)
})

test_that("reading individuals without mutating preserves them on export", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))
  original_names <- names(snapshot$individuals)

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)

  reloaded <- load_snapshot(out)
  expect_equal(names(reloaded$individuals), original_names)
})
