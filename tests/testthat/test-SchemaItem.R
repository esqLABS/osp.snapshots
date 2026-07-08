test_that("SchemaItem constructs from a raw snapshot list", {
  raw <- list(
    Name = "Schema Item 1",
    ApplicationType = "Oral",
    FormulationKey = "Tablet",
    TargetOrgan = "Lumen",
    TargetCompartment = "Duodenum",
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "InputDose", Value = 15, Unit = "mg")
    )
  )
  item <- SchemaItem$new(raw)
  expect_r6_class(item, "SchemaItem")
  expect_equal(item$name, "Schema Item 1")
  expect_equal(item$application_type, "Oral")
  expect_equal(item$formulation_key, "Tablet")
  expect_equal(item$target_organ, "Lumen")
  expect_equal(item$target_compartment, "Duodenum")
  expect_length(item$parameters, 2)
  expect_s3_class(item$parameters[[1]], "Parameter")
})

test_that("SchemaItem handles NULL and empty input", {
  expect_no_error(SchemaItem$new())
  expect_no_error(SchemaItem$new(NULL))
  expect_no_error(SchemaItem$new(list()))
  empty <- SchemaItem$new()
  expect_null(empty$name)
  expect_null(empty$application_type)
  expect_length(empty$parameters, 0)
})

test_that("SchemaItem active bindings mutate the underlying data", {
  item <- SchemaItem$new(list(
    Name = "Schema Item 1",
    ApplicationType = "Oral"
  ))
  item$name <- "Renamed"
  item$application_type <- "IntravenousBolus"
  item$formulation_key <- "new-key"
  expect_equal(item$name, "Renamed")
  expect_equal(item$application_type, "IntravenousBolus")
  expect_equal(item$formulation_key, "new-key")
  expect_equal(item$data$Name, "Renamed")
  expect_equal(item$data$ApplicationType, "IntravenousBolus")
  expect_equal(item$data$FormulationKey, "new-key")
})

test_that("SchemaItem$name requires a non-empty scalar string", {
  item <- SchemaItem$new(list(Name = "Schema Item 1"))
  expect_snapshot(error = TRUE, item$name <- "")
  expect_snapshot(error = TRUE, item$name <- 5)
})

test_that("SchemaItem$application_type is validated against the enum", {
  item <- SchemaItem$new(list(Name = "Schema Item 1"))
  expect_snapshot(error = TRUE, item$application_type <- "nonsense")
})

test_that("SchemaItem$data refreshes Parameters from the wrapped list", {
  raw <- list(
    Name = "Schema Item 1",
    ApplicationType = "Oral",
    Parameters = list(
      list(Name = "InputDose", Value = 15, Unit = "mg")
    )
  )
  item <- SchemaItem$new(raw)
  item$parameters[[1]]$value <- 30
  expect_equal(item$data$Parameters[[1]]$Value, 30)
  expect_equal(item$data$Parameters[[1]]$Name, "InputDose")
  expect_null(item$data$Parameters[[1]]$Path)
})

test_that("SchemaItem round-trips a raw snapshot list", {
  raw <- list(
    Name = "Schema Item 1",
    ApplicationType = "Oral",
    FormulationKey = "Tablet",
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "InputDose", Value = 15, Unit = "mg")
    )
  )
  item <- SchemaItem$new(raw)
  expect_equal(item$data, raw)
})

test_that("SchemaItem$data is read-only", {
  item <- SchemaItem$new(list(Name = "Schema Item 1"))
  expect_snapshot(error = TRUE, {
    item$data <- list()
  })
})

test_that("SchemaItem prints a summary", {
  item <- SchemaItem$new(list(
    Name = "Schema Item 1",
    ApplicationType = "Oral",
    FormulationKey = "Tablet",
    Parameters = list(
      list(Name = "InputDose", Value = 15, Unit = "mg")
    )
  ))
  expect_snapshot(print(item))
})
