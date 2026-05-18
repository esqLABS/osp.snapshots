test_that("create_schema builds from create_schema_item() and create_parameter()", {
  schema <- create_schema(
    name = "Schema 1",
    parameters = list(
      create_parameter(name = "NumberOfRepetitions", value = 1),
      create_parameter(name = "TimeBetweenRepetitions", value = 0, unit = "h")
    ),
    items = list(
      create_schema_item(
        name = "Item 1",
        application_type = "Oral",
        parameters = list(
          create_parameter(name = "InputDose", value = 5, unit = "mg")
        )
      )
    )
  )

  expect_r6_class(schema, "Schema")
  expect_equal(schema$name, "Schema 1")
  expect_length(schema$parameters, 2)
  expect_length(schema$items, 1)
  expect_r6_class(schema$items[[1]], "SchemaItem")
})

test_that("create_schema parameters use Name keys (not Path)", {
  schema <- create_schema(
    name = "Schema 1",
    parameters = list(
      create_parameter(name = "NumberOfRepetitions", value = 1)
    )
  )

  raw <- schema$data
  expect_named(raw$Parameters[[1]], c("Name", "Value"), ignore.order = TRUE)
  expect_null(raw$Parameters[[1]]$Path)
})

test_that("create_schema accepts raw list arguments", {
  schema <- create_schema(
    name = "Schema 1",
    parameters = list(
      list(Name = "NumberOfRepetitions", Value = 1)
    ),
    items = list(list(
      Name = "Item 1",
      ApplicationType = "Oral",
      Parameters = list(list(Name = "InputDose", Value = 5, Unit = "mg"))
    ))
  )

  expect_r6_class(schema, "Schema")
  expect_length(schema$items, 1)
  expect_equal(schema$items[[1]]$application_type, "Oral")
})

test_that("create_schema accepts a mix of R6 and raw items", {
  schema <- create_schema(
    name = "Schema 1",
    items = list(
      create_schema_item(name = "Item 1", application_type = "Oral"),
      list(Name = "Item 2", ApplicationType = "IntravenousBolus")
    )
  )

  expect_length(schema$items, 2)
  expect_equal(schema$items[[1]]$application_type, "Oral")
  expect_equal(schema$items[[2]]$application_type, "IntravenousBolus")
})

test_that("create_schema strips names from the items list", {
  schema <- create_schema(
    name = "Schema 1",
    items = list(
      first = create_schema_item(name = "Item 1", application_type = "Oral"),
      second = create_schema_item(
        name = "Item 2",
        application_type = "IntravenousBolus"
      )
    )
  )
  raw <- schema$data
  expect_null(names(raw$SchemaItems))
})

test_that("create_schema validates required arguments", {
  expect_snapshot(error = TRUE, create_schema())
  expect_snapshot(error = TRUE, create_schema(name = ""))
  expect_snapshot(
    error = TRUE,
    create_schema(name = "Schema 1", parameters = "not a list")
  )
  expect_snapshot(
    error = TRUE,
    create_schema(name = "Schema 1", items = "not a list")
  )
  expect_snapshot(
    error = TRUE,
    create_schema(name = "Schema 1", items = list("not a SchemaItem or list"))
  )
})
