test_that("create_snapshot creates an empty snapshot", {
  s <- create_snapshot()

  expect_s3_class(s, "Snapshot")
  expect_named(s$data, "Version")
  expect_equal(s$data$Version, 80)
  expect_equal(s$pksim_version, "12.0")
})

test_that("create_snapshot injects Name when supplied", {
  s <- create_snapshot(name = "My Project")

  expect_equal(s$data$Name, "My Project")
  expect_null(s$data$Description)
})

test_that("create_snapshot injects Description when supplied", {
  s <- create_snapshot(description = "notes")

  expect_equal(s$data$Description, "notes")
  expect_null(s$data$Name)
})

test_that("create_snapshot injects both Name and Description", {
  s <- create_snapshot(name = "P", description = "d")

  expect_equal(s$data$Name, "P")
  expect_equal(s$data$Description, "d")
  expect_equal(s$data$Version, 80)
})

test_that("create_snapshot writes empty strings verbatim", {
  s <- create_snapshot(name = "", description = "")

  expect_equal(s$data$Name, "")
  expect_equal(s$data$Description, "")
})

test_that("create_snapshot result round-trips through export and load", {
  path <- withr::local_tempfile(fileext = ".json")

  export_snapshot(create_snapshot(), path)
  reloaded <- load_snapshot(path)

  expect_s3_class(reloaded, "Snapshot")
  expect_equal(reloaded$data$Version, 80)
})

test_that("create_snapshot result composes with add_*() mutators", {
  s <- add_compound(create_snapshot(), create_compound(name = "Drug X"))

  expect_length(s$compounds, 1)
  expect_true("Drug X" %in% names(s$compounds))
})

test_that("validate_snapshot accepts a snapshot with a fraction-unbound compound", {
  compound <- create_compound(
    name = "Drug X",
    fraction_unbound = fraction_unbound(1)
  )
  s <- add_compound(create_snapshot(), compound)

  expect_true(validate_snapshot(s))
  # validate_snapshot() passes even when Species is absent, so assert the
  # emitted fraction-unbound alternative actually carries the species.
  expect_equal(compound$data$FractionUnbound[[1]]$Species, "Human")
})

test_that("create_snapshot rejects non-scalar or non-character arguments", {
  expect_snapshot(error = TRUE, create_snapshot(name = 1))
  expect_snapshot(error = TRUE, create_snapshot(name = c("a", "b")))
  expect_snapshot(error = TRUE, create_snapshot(description = 1))
  expect_snapshot(error = TRUE, create_snapshot(description = c("a", "b")))
})
