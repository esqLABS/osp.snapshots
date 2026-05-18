test_that("build_parameters_from_raw handles NULL input", {
  result <- build_parameters_from_raw(NULL)
  expect_length(result, 0)
  expect_s3_class(result, "parameter_collection")
})

test_that("build_parameters_from_raw handles empty list", {
  result <- build_parameters_from_raw(list())
  expect_length(result, 0)
  expect_s3_class(result, "parameter_collection")
})

test_that("build_parameters_from_raw key_by = 'path' falls back to 'Unknown'", {
  raw <- list(
    list(Value = 1),
    list(Path = "Organism|Liver|Volume", Value = 2)
  )
  result <- build_parameters_from_raw(raw, key_by = "path")
  expect_named(result, c("Unknown", "Organism|Liver|Volume"))
  expect_s3_class(result, "parameter_collection")
})

test_that("build_parameters_from_raw key_by = 'name' keys by parameter name", {
  raw <- list(
    list(Name = "dose", Value = 1),
    list(Name = "rate", Value = 2)
  )
  result <- build_parameters_from_raw(raw, key_by = "name")
  expect_named(result, c("dose", "rate"))
})

test_that("build_parameters_from_raw key_by = 'name' falls back to 'Unknown'", {
  raw <- list(list(Value = 1))
  result <- build_parameters_from_raw(raw, key_by = "name")
  expect_named(result, "Unknown")
})

test_that("build_parameters_from_raw key_by = 'none' returns unnamed list", {
  raw <- list(
    list(Name = "dose", Value = 1),
    list(Name = "rate", Value = 2)
  )
  result <- build_parameters_from_raw(raw, key_by = "none")
  expect_null(names(result))
  expect_length(result, 2)
})

test_that("build_parameters_from_raw always tags result with parameter_collection", {
  empty <- build_parameters_from_raw(list())
  expect_s3_class(empty, "parameter_collection")

  populated <- build_parameters_from_raw(list(list(Path = "x", Value = 1)))
  expect_s3_class(populated, "parameter_collection")
})

test_that("build_parameters_from_raw with name_as_path copies Name to Path", {
  raw <- list(list(Name = "dose", Value = 1))
  result <- build_parameters_from_raw(
    raw,
    key_by = "path",
    name_as_path = TRUE
  )
  expect_named(result, "dose")
  expect_equal(result[[1]]$path, "dose")
})

test_that("ensure_path_from_name copies Name to Path when Path missing", {
  result <- ensure_path_from_name(list(Name = "dose", Value = 1))
  expect_equal(result$Path, "dose")
})

test_that("ensure_path_from_name preserves existing Path", {
  result <- ensure_path_from_name(
    list(Name = "dose", Path = "Organism|Dose", Value = 1)
  )
  expect_equal(result$Path, "Organism|Dose")
})
