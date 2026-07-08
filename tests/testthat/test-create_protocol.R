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

test_that("create_protocol accepts Schema R6 objects in `schemas`", {
  protocol <- create_protocol(
    name = "Advanced",
    schemas = list(
      create_schema(
        name = "Schema 1",
        parameters = list(
          create_parameter(name = "NumberOfRepetitions", value = 1),
          create_parameter(
            name = "TimeBetweenRepetitions",
            value = 0,
            unit = "h"
          )
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
    ),
    time_unit = "h"
  )

  expect_r6_class(protocol, "Protocol")
  expect_true(protocol$is_advanced)
  expect_length(protocol$schemas, 1)
  expect_equal(protocol$schemas[[1]]$items[[1]]$application_type, "Oral")
})

test_that("create_protocol Schema-object form round-trips to raw-list form", {
  from_objects <- create_protocol(
    name = "Advanced",
    schemas = list(
      create_schema(
        name = "Schema 1",
        parameters = list(
          create_parameter(name = "NumberOfRepetitions", value = 1),
          create_parameter(
            name = "TimeBetweenRepetitions",
            value = 0,
            unit = "h"
          )
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
    ),
    time_unit = "h"
  )

  from_raw <- create_protocol(
    name = "Advanced",
    schemas = list(list(
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
    )),
    time_unit = "h"
  )

  expect_equal(from_objects$data, from_raw$data)
  expect_identical(
    jsonlite::toJSON(from_objects$data, auto_unbox = TRUE, digits = NA),
    jsonlite::toJSON(from_raw$data, auto_unbox = TRUE, digits = NA)
  )
})

test_that("create_protocol accepts a mix of Schema objects and raw lists", {
  protocol <- create_protocol(
    name = "Mixed",
    schemas = list(
      create_schema(
        name = "Schema 1",
        items = list(
          create_schema_item(name = "Item 1", application_type = "Oral")
        )
      ),
      list(
        Name = "Schema 2",
        SchemaItems = list(list(
          Name = "Item 2",
          ApplicationType = "IntravenousBolus"
        ))
      )
    )
  )

  expect_length(protocol$schemas, 2)
  expect_equal(protocol$schemas[[1]]$name, "Schema 1")
  expect_equal(protocol$schemas[[2]]$name, "Schema 2")
})

test_that("create_protocol strips names from the schemas list", {
  protocol <- create_protocol(
    name = "Advanced",
    schemas = list(
      first = create_schema(
        name = "Schema 1",
        items = list(
          create_schema_item(name = "Item 1", application_type = "Oral")
        )
      ),
      second = list(
        Name = "Schema 2",
        SchemaItems = list(list(
          Name = "Item 2",
          ApplicationType = "IntravenousBolus"
        ))
      )
    )
  )
  expect_null(names(protocol$data$Schemas))
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
    create_protocol(
      name = "P",
      dosing_interval = "Single",
      target_organ = "Liver",
      schemas = list()
    )
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", parameters = "not a list")
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", application_type = "NotARealType")
  )
})

test_that("create_protocol accepts a valid application_type and omits the check when NULL", {
  valid <- create_protocol(name = "P", application_type = "Oral")
  expect_s3_class(valid, "Protocol")
  expect_equal(valid$application_type, "Oral")

  no_type <- create_protocol(name = "P")
  expect_s3_class(no_type, "Protocol")
  expect_null(no_type$application_type)

  null_type <- create_protocol(name = "P", application_type = NULL)
  expect_s3_class(null_type, "Protocol")
  expect_null(null_type$application_type)
})

test_that("create_protocol validates time_unit against the Time dimension", {
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", time_unit = "banana")
  )
  valid <- create_protocol(name = "P", time_unit = "h")
  expect_equal(valid$time_unit, "h")
})
