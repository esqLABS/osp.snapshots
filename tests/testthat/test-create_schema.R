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

test_that("create_schema promotes number_of_repetitions without a Unit key", {
  schema <- create_schema(name = "S", number_of_repetitions = 3)

  expect_length(schema$data$Parameters, 1)
  entry <- schema$data$Parameters[[1]]
  expect_named(entry, c("Name", "Value"), ignore.order = TRUE)
  expect_null(entry$Unit)
  expect_snapshot(schema$data$Parameters)
})

test_that("create_schema promotes time_between_repetitions with a default unit", {
  schema <- create_schema(name = "S", time_between_repetitions = 24)

  expect_length(schema$data$Parameters, 1)
  expect_snapshot(schema$data$Parameters)
})

test_that("create_schema honours a custom time_between_repetitions_unit", {
  schema <- create_schema(
    name = "S",
    time_between_repetitions = 1,
    time_between_repetitions_unit = "day(s)"
  )

  expect_equal(schema$data$Parameters[[1]]$Unit, "day(s)")
  expect_snapshot(schema$data$Parameters)
})

test_that("create_schema promotes start_time with a default unit", {
  schema <- create_schema(name = "S", start_time = 0)

  expect_length(schema$data$Parameters, 1)
  expect_snapshot(schema$data$Parameters)
})

test_that("create_schema appends promoted entries after parameters in signature order", {
  schema <- create_schema(
    name = "S",
    parameters = list(
      create_parameter(name = "Foo", value = 1),
      list(Name = "Bar", Value = 2)
    ),
    number_of_repetitions = 3,
    time_between_repetitions = 24,
    start_time = 0
  )

  names_in_order <- vapply(
    schema$data$Parameters,
    function(p) p$Name,
    character(1)
  )
  expect_equal(
    names_in_order,
    c(
      "Foo",
      "Bar",
      "NumberOfRepetitions",
      "TimeBetweenRepetitions",
      "Start time"
    )
  )
})

test_that("create_schema rejects an invalid time_between_repetitions_unit", {
  expect_snapshot(
    error = TRUE,
    create_schema(
      name = "S",
      time_between_repetitions = 1,
      time_between_repetitions_unit = "furlong"
    )
  )
})

test_that("create_schema rejects a non-whole number_of_repetitions", {
  expect_snapshot(
    error = TRUE,
    create_schema(name = "S", number_of_repetitions = 3.5)
  )
})

test_that("create_schema rejects a non-scalar or non-finite number_of_repetitions", {
  expect_snapshot(
    error = TRUE,
    create_schema(name = "S", number_of_repetitions = c(1, 2))
  )
  expect_snapshot(
    error = TRUE,
    create_schema(name = "S", number_of_repetitions = NA)
  )
})

test_that("create_schema errors on a NumberOfRepetitions conflict", {
  expect_snapshot(
    error = TRUE,
    create_schema(
      name = "S",
      number_of_repetitions = 1,
      parameters = list(create_parameter(
        name = "NumberOfRepetitions",
        value = 2
      ))
    )
  )
})

test_that("create_schema errors on a TimeBetweenRepetitions conflict", {
  expect_snapshot(
    error = TRUE,
    create_schema(
      name = "S",
      time_between_repetitions = 24,
      parameters = list(
        create_parameter(name = "TimeBetweenRepetitions", value = 12)
      )
    )
  )
})

test_that("create_schema errors on a Start time conflict", {
  expect_snapshot(
    error = TRUE,
    create_schema(
      name = "S",
      start_time = 0,
      parameters = list(create_parameter(name = "Start time", value = 1))
    )
  )
})

test_that("create_schema resolves a conflict from a path-bearing parameter", {
  expect_snapshot(
    error = TRUE,
    create_schema(
      name = "S",
      start_time = 0,
      parameters = list(create_parameter(path = "Start time", value = 0))
    )
  )
})

test_that("create_schema reports every conflict in a single error", {
  expect_snapshot(
    error = TRUE,
    create_schema(
      name = "S",
      number_of_repetitions = 1,
      time_between_repetitions = 24,
      start_time = 0,
      parameters = list(
        create_parameter(name = "NumberOfRepetitions", value = 2),
        create_parameter(name = "TimeBetweenRepetitions", value = 12),
        create_parameter(name = "Start time", value = 1)
      )
    )
  )
})

test_that("create_schema does not conflict when the promoted argument is absent", {
  schema <- create_schema(
    name = "S",
    parameters = list(create_parameter(name = "NumberOfRepetitions", value = 1))
  )

  expect_length(schema$data$Parameters, 1)
  entry <- schema$data$Parameters[[1]]
  expect_equal(entry$Name, "NumberOfRepetitions")
  expect_equal(entry$Value, 1)
})
