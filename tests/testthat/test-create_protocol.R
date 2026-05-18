test_that("create_protocol creates a simple protocol", {
  protocol <- create_protocol(
    name = "Single dose 10mg",
    application_type = "Oral",
    dosing_interval = "Single",
    parameters = list(
      create_parameter(name = "Start time", value = 0, unit = "h"),
      create_parameter(name = "InputDose", value = 10, unit = "mg")
    )
  )

  expect_s3_class(protocol, "Protocol")
  expect_equal(protocol$name, "Single dose 10mg")
  expect_equal(protocol$application_type, "Oral")
  expect_equal(protocol$dosing_interval, "Single")
  expect_false(protocol$is_advanced)
  expect_length(protocol$parameters, 2)
})

test_that("create_protocol creates an advanced protocol from schemas", {
  schemas <- list(list(
    Name = "Schema 1",
    Parameters = list(
      list(Name = "NumberOfRepetitions", Value = 1),
      list(Name = "TimeBetweenRepetitions", Value = 0, Unit = "h")
    ),
    SchemaItems = list(list(
      Name = "Item 1",
      ApplicationType = "Oral",
      Parameters = list(
        list(Name = "InputDose", Value = 5, Unit = "mg")
      )
    ))
  ))

  protocol <- create_protocol(
    name = "Advanced",
    schemas = schemas,
    time_unit = "h"
  )

  expect_s3_class(protocol, "Protocol")
  expect_true(protocol$is_advanced)
  expect_length(protocol$schemas, 1)
  expect_equal(protocol$time_unit, "h")
})

test_that("create_protocol validates required arguments", {
  expect_snapshot(error = TRUE, create_protocol())
  expect_snapshot(error = TRUE, create_protocol(name = ""))
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      application_type = "Oral",
      schemas = list()
    )
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", parameters = "not a list")
  )
})
