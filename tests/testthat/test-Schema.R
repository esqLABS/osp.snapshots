test_that("Schema constructs from a raw snapshot list", {
  raw <- list(
    Name = "Schema 1",
    SchemaItems = list(
      list(
        Name = "Schema Item 1",
        ApplicationType = "Oral",
        FormulationKey = "Tablet",
        Parameters = list(
          list(Name = "InputDose", Value = 15, Unit = "mg")
        )
      )
    ),
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "NumberOfRepetitions", Value = 3),
      list(Name = "TimeBetweenRepetitions", Value = 8, Unit = "h")
    )
  )
  schema <- Schema$new(raw)
  expect_r6_class(schema, "Schema")
  expect_equal(schema$name, "Schema 1")
  expect_length(schema$items, 1)
  expect_r6_class(schema$items[[1]], "SchemaItem")
  expect_length(schema$parameters, 3)
})

test_that("Schema handles NULL and empty input", {
  expect_no_error(Schema$new())
  expect_no_error(Schema$new(NULL))
  expect_no_error(Schema$new(list()))
  empty <- Schema$new()
  expect_null(empty$name)
  expect_length(empty$items, 0)
  expect_length(empty$parameters, 0)
})

test_that("Schema$data refreshes SchemaItems from the wrapped list", {
  raw <- list(
    Name = "Schema 1",
    SchemaItems = list(
      list(
        Name = "Schema Item 1",
        ApplicationType = "Oral",
        Parameters = list(
          list(Name = "InputDose", Value = 15, Unit = "mg")
        )
      )
    )
  )
  schema <- Schema$new(raw)
  schema$items[[1]]$application_type <- "IntravenousBolus"
  expect_equal(schema$data$SchemaItems[[1]]$ApplicationType, "IntravenousBolus")
})

test_that("Schema$data refreshes Parameters from the wrapped list", {
  raw <- list(
    Name = "Schema 1",
    Parameters = list(
      list(Name = "NumberOfRepetitions", Value = 3)
    )
  )
  schema <- Schema$new(raw)
  schema$parameters[[1]]$value <- 5
  expect_equal(schema$data$Parameters[[1]]$Value, 5)
  expect_equal(schema$data$Parameters[[1]]$Name, "NumberOfRepetitions")
  expect_null(schema$data$Parameters[[1]]$Path)
})

test_that("Schema round-trips a raw snapshot list", {
  raw <- list(
    Name = "Schema 1",
    SchemaItems = list(
      list(
        Name = "Schema Item 1",
        ApplicationType = "Oral",
        FormulationKey = "Tablet",
        Parameters = list(
          list(Name = "Start time", Value = 0, Unit = "h"),
          list(Name = "InputDose", Value = 15, Unit = "mg")
        )
      )
    ),
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "NumberOfRepetitions", Value = 1),
      list(Name = "TimeBetweenRepetitions", Value = 0, Unit = "h")
    )
  )
  schema <- Schema$new(raw)
  expect_equal(schema$data, raw)
})

test_that("Schema accepts a fresh list of SchemaItem objects", {
  schema <- Schema$new(list(Name = "Schema 1"))
  new_items <- list(
    SchemaItem$new(list(Name = "Schema Item 1", ApplicationType = "Oral"))
  )
  schema$items <- new_items
  expect_length(schema$items, 1)
  expect_equal(schema$items[[1]]$name, "Schema Item 1")
})

test_that("Schema rejects non-SchemaItem entries in items", {
  schema <- Schema$new(list(Name = "Schema 1"))
  expect_snapshot(error = TRUE, {
    schema$items <- list("not a schema item")
  })
})

test_that("Schema$data is read-only", {
  schema <- Schema$new(list(Name = "Schema 1"))
  expect_snapshot(error = TRUE, {
    schema$data <- list()
  })
})

test_that("Schema$name requires a non-empty scalar string", {
  schema <- Schema$new(list(Name = "Schema 1"))
  schema$name <- "Renamed"
  expect_equal(schema$name, "Renamed")
  expect_snapshot(error = TRUE, schema$name <- "")
  expect_snapshot(error = TRUE, schema$name <- 5)
})

test_that("Schema$parameters requires a list", {
  schema <- Schema$new(list(Name = "Schema 1"))
  expect_snapshot(error = TRUE, schema$parameters <- 5)
  expect_snapshot(error = TRUE, schema$parameters <- "x")
  schema$parameters <- list(create_parameter(name = "Start time", value = 0))
  expect_length(schema$parameters, 1)
  schema$parameters <- NULL
  expect_length(schema$parameters, 0)
})

test_that("Schema prints a summary", {
  schema <- Schema$new(list(
    Name = "Schema 1",
    SchemaItems = list(
      list(
        Name = "Schema Item 1",
        ApplicationType = "Oral"
      )
    ),
    Parameters = list(
      list(Name = "NumberOfRepetitions", Value = 3)
    )
  ))
  expect_snapshot(print(schema))
})

test_that("Protocol exposes schemas as named Schema objects", {
  protocol_data <- list(
    Name = "Test Advanced Protocol",
    Schemas = list(
      list(
        Name = "Schema 1",
        SchemaItems = list(
          list(Name = "Schema Item 1", ApplicationType = "Oral")
        ),
        Parameters = list()
      ),
      list(
        Name = "Schema 2",
        SchemaItems = list(
          list(Name = "Schema Item 1", ApplicationType = "IntravenousBolus")
        ),
        Parameters = list()
      )
    )
  )
  protocol <- Protocol$new(protocol_data)
  expect_named(protocol$schemas, c("Schema 1", "Schema 2"))
  expect_r6_class(protocol$schemas[["Schema 1"]], "Schema")
  expect_equal(
    protocol$schemas[["Schema 2"]]$items[[1]]$application_type,
    "IntravenousBolus"
  )
})

test_that("Simple Protocol exposes empty schemas list", {
  protocol_data <- list(
    Name = "Simple",
    ApplicationType = "Oral",
    DosingInterval = "Single"
  )
  protocol <- Protocol$new(protocol_data)
  expect_length(protocol$schemas, 0)
})

test_that("Mutating a Schema flows back through Protocol$data", {
  protocol_data <- list(
    Name = "Advanced",
    Schemas = list(
      list(
        Name = "Schema 1",
        SchemaItems = list(
          list(Name = "Schema Item 1", ApplicationType = "Oral")
        ),
        Parameters = list()
      )
    )
  )
  protocol <- Protocol$new(protocol_data)
  protocol$schemas[["Schema 1"]]$items[[
    1
  ]]$application_type <- "IntravenousBolus"
  expect_equal(
    protocol$data$Schemas[[1]]$SchemaItems[[1]]$ApplicationType,
    "IntravenousBolus"
  )
})
