test_that("LocalizedParameter inherits from Parameter and exposes path", {
  param <- LocalizedParameter$new(list(
    Path = "Organism|Liver|Volume",
    Value = 1.5,
    Unit = "L"
  ))

  expect_s3_class(param, "LocalizedParameter")
  expect_s3_class(param, "Parameter")
  expect_equal(param$path, "Organism|Liver|Volume")
  expect_equal(param$value, 1.5)
  expect_equal(param$unit, "L")
})

test_that("LocalizedParameter accepts Name as a legacy path fallback", {
  param <- LocalizedParameter$new(list(
    Name = "Dose",
    Value = 100
  ))

  expect_equal(param$path, "Dose")
})

test_that("LocalizedParameter errors when no path is supplied", {
  expect_snapshot(
    LocalizedParameter$new(list(Value = 1.5)),
    error = TRUE
  )
})

test_that("LocalizedParameter errors when path is empty", {
  expect_snapshot(
    LocalizedParameter$new(list(Path = "", Value = 1.5)),
    error = TRUE
  )
})

test_that("LocalizedParameter migrates Applications path segments to Events", {
  param <- LocalizedParameter$new(list(
    Path = "Applications|Schedule|Application_1|Volume",
    Value = 3.5,
    Unit = "ml/kg"
  ))

  expect_equal(
    param$path,
    "Events|Schedule|Application_1|Volume"
  )
})

test_that("LocalizedParameter does not migrate Applications inside other segments", {
  # Only whole segments named "Applications" should be migrated; substrings
  # such as "MyApplicationsX" must be left untouched.
  param <- LocalizedParameter$new(list(
    Path = "MyApplicationsX|Sub|Item",
    Value = 1.0
  ))

  expect_equal(param$path, "MyApplicationsX|Sub|Item")
})

test_that("create_parameter routes to LocalizedParameter when path is given", {
  localized <- create_parameter(
    path = "Organism|Liver|Volume",
    value = 1.5,
    unit = "L"
  )

  expect_s3_class(localized, "LocalizedParameter")
  expect_equal(localized$path, "Organism|Liver|Volume")
})

test_that("create_parameter returns plain Parameter when no path is given", {
  plain <- create_parameter(
    name = "Dose",
    value = 100
  )

  expect_s3_class(plain, "Parameter")
  expect_false(inherits(plain, "LocalizedParameter"))
})

test_that("create_parameter migrates Applications when path is given", {
  param <- create_parameter(
    path = "Applications|Schedule|Application_1|Volume",
    value = 3.5,
    unit = "ml/kg"
  )

  expect_s3_class(param, "LocalizedParameter")
  expect_equal(
    param$path,
    "Events|Schedule|Application_1|Volume"
  )
})

test_that("Individual parameters load as LocalizedParameter", {
  ind <- Individual$new(complete_individual_data)
  first_param <- ind$parameters[[1]]

  expect_s3_class(first_param, "LocalizedParameter")
  expect_s3_class(first_param, "Parameter")
})

test_that("Snapshot round-trip preserves localized parameters in Individuals", {
  snapshot <- test_snapshot$clone()
  temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(temp_file)
  snapshot2 <- Snapshot$new(temp_file)

  individuals <- snapshot$data$Individuals
  individuals2 <- snapshot2$data$Individuals
  expect_equal(length(individuals), length(individuals2))

  for (i in seq_along(individuals)) {
    params <- individuals[[i]]$Parameters
    params2 <- individuals2[[i]]$Parameters
    expect_equal(length(params), length(params2))
    for (j in seq_along(params)) {
      expect_equal(params2[[j]]$Path, params[[j]]$Path)
      expect_equal(params2[[j]]$Value, params[[j]]$Value)
    }
  }
})

test_that("Snapshot round-trip preserves localized parameters in Simulations", {
  # Simulations are passed through as raw data; round-trip fidelity is the
  # cross-cutting guarantee we rely on for path-bearing simulation parameters.
  snapshot <- test_snapshot$clone()
  temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(temp_file)
  snapshot2 <- Snapshot$new(temp_file)

  sims <- snapshot$data$Simulations
  sims2 <- snapshot2$data$Simulations

  skip_if(length(sims) == 0, "no simulations in fixture")
  for (i in seq_along(sims)) {
    params <- sims[[i]]$Parameters %||% list()
    params2 <- sims2[[i]]$Parameters %||% list()
    expect_equal(length(params), length(params2))
    for (j in seq_along(params)) {
      expect_equal(params2[[j]]$Path, params[[j]]$Path)
      expect_equal(params2[[j]]$Value, params[[j]]$Value)
    }
  }
})
