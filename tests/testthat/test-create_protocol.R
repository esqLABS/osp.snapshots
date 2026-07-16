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

test_that("create_protocol keeps `parameters` in the sixth positional slot", {
  # Pre-existing positional calls pass the sixth argument as `parameters`.
  # The promoted dosing arguments are appended after `time_unit`, so the
  # sixth positional slot must still land on `parameters`, not `dose`.
  protocol <- create_protocol(
    "P",
    "Oral",
    "Single",
    NULL,
    NULL,
    list(create_parameter(name = "InputDose", value = 5, unit = "mg"))
  )

  expect_s3_class(protocol, "Protocol")
  input_dose <- Filter(
    function(p) identical(p$Name, "InputDose"),
    protocol$data$Parameters
  )
  expect_length(input_dose, 1)
  expect_equal(input_dose[[1]]$Value, 5)
  expect_equal(input_dose[[1]]$Unit, "mg")
  # The value landed via `parameters`, not via `dose` promotion, so there is
  # exactly one parameter and no promoted duplicate.
  expect_length(protocol$data$Parameters, 1)
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
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", application_type = "Subcutaneous")
  )
})

test_that("create_protocol accepts UserDefined with target fields", {
  protocol <- create_protocol(
    name = "P",
    application_type = "UserDefined",
    target_organ = "Liver",
    target_compartment = "Plasma"
  )
  expect_s3_class(protocol, "Protocol")
  expect_equal(protocol$application_type, "UserDefined")
  expect_equal(protocol$data$TargetOrgan, "Liver")
  expect_equal(protocol$data$TargetCompartment, "Plasma")
})

test_that("create_protocol gates target fields to UserDefined", {
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      application_type = "Oral",
      target_organ = "Liver"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      application_type = "IntravenousBolus",
      target_compartment = "Plasma"
    )
  )
})

test_that("create_protocol rejects target fields when application_type is NULL", {
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", target_organ = "Liver")
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

test_that("create_protocol validates dosing_interval against the DosingIntervalId enum", {
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      application_type = "Oral",
      dosing_interval = "typo"
    )
  )
})

test_that("create_protocol accepts a valid dosing_interval and omits the check when NULL", {
  valid <- create_protocol(name = "P", dosing_interval = "DI_24")
  expect_s3_class(valid, "Protocol")
  expect_equal(valid$dosing_interval, "DI_24")

  no_interval <- create_protocol(name = "P")
  expect_null(no_interval$dosing_interval)

  null_interval <- create_protocol(name = "P", dosing_interval = NULL)
  expect_null(null_interval$dosing_interval)
})

test_that("create_protocol validates time_unit against the Time dimension", {
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", time_unit = "banana")
  )
  valid <- create_protocol(name = "P", time_unit = "h")
  expect_equal(valid$time_unit, "h")
})

test_that("create_protocol promotes dose, start_time, and end_time to parameters", {
  protocol <- create_protocol(
    name = "Single dose",
    application_type = "Oral",
    dosing_interval = "Single",
    dose = 10,
    dose_unit = "mg",
    start_time = 0,
    end_time = 24,
    time_unit = "h"
  )

  expect_s3_class(protocol, "Protocol")
  expect_snapshot(protocol$data$Parameters)
})

test_that("create_protocol emits a single InputDose for any dose-family unit", {
  for (unit in c("mg", "mmol", "mg/kg", "mg/m²")) {
    protocol <- create_protocol(
      name = "Dose",
      application_type = "Oral",
      dosing_interval = "Single",
      dose = 5,
      dose_unit = unit
    )
    input_dose <- Filter(
      function(p) identical(p$Name, "InputDose"),
      protocol$data$Parameters
    )
    other_dose <- Filter(
      function(p) {
        p$Name %in%
          c("Dose", "DosePerBodyWeight", "DosePerBodySurfaceArea")
      },
      protocol$data$Parameters
    )
    expect_length(input_dose, 1)
    expect_length(other_dose, 0)
    expect_equal(input_dose[[1]]$Value, 5)
    expect_equal(input_dose[[1]]$Unit, unit)
  }
})

test_that("create_protocol rejects an invalid dose_unit", {
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", dose = 5, dose_unit = "banana")
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", dose = 5, dose_unit = "h")
  )
})

test_that("create_protocol rejects a NULL or non-scalar dose_unit", {
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      application_type = "Oral",
      dosing_interval = "Single",
      dose = 5,
      dose_unit = NULL
    )
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      application_type = "Oral",
      dosing_interval = "Single",
      dose = 5,
      dose_unit = c("mg", "mmol")
    )
  )
})

test_that("create_protocol rejects non-finite or non-scalar dose values", {
  expect_snapshot(error = TRUE, create_protocol(name = "P", dose = NA))
  expect_snapshot(error = TRUE, create_protocol(name = "P", dose = c(1, 2)))
  expect_snapshot(error = TRUE, create_protocol(name = "P", dose = Inf))
  expect_snapshot(error = TRUE, create_protocol(name = "P", start_time = "0"))
})

test_that("create_protocol errors when a promoted argument conflicts with parameters", {
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      dose = 10,
      parameters = list(
        create_parameter(name = "InputDose", value = 5, unit = "mg")
      )
    )
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      start_time = 0,
      parameters = list(
        create_parameter(name = "Start time", value = 1, unit = "h")
      )
    )
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      end_time = 24,
      parameters = list(
        create_parameter(name = "End time", value = 12, unit = "h")
      )
    )
  )
})

test_that("create_protocol reports every conflicting promoted argument in one error", {
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      dose = 10,
      start_time = 0,
      end_time = 24,
      parameters = list(
        create_parameter(name = "InputDose", value = 5, unit = "mg"),
        create_parameter(name = "Start time", value = 1, unit = "h"),
        create_parameter(name = "End time", value = 12, unit = "h")
      )
    )
  )
})

test_that("create_protocol detects a Path-keyed conflict after Name normalisation", {
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      dose = 10,
      parameters = list(
        create_parameter(path = "InputDose", value = 5, unit = "mg")
      )
    )
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(
      name = "P",
      dose = 10,
      parameters = list(list(Path = "InputDose", Value = 5, Unit = "mg"))
    )
  )
})

test_that("create_protocol resolves the end_time unit from time_unit", {
  with_time_unit <- create_protocol(
    name = "P",
    end_time = 24,
    time_unit = "min"
  )
  end_entry <- Filter(
    function(p) identical(p$Name, "End time"),
    with_time_unit$data$Parameters
  )
  expect_equal(end_entry[[1]]$Unit, "min")
  expect_equal(with_time_unit$data$TimeUnit, "min")

  without_time_unit <- create_protocol(name = "P", end_time = 24)
  end_entry <- Filter(
    function(p) identical(p$Name, "End time"),
    without_time_unit$data$Parameters
  )
  expect_equal(end_entry[[1]]$Unit, "h")
  expect_null(without_time_unit$data$TimeUnit)
})

test_that("create_protocol rejects the promoted arguments combined with schemas", {
  schemas <- list(list(
    Name = "Schema 1",
    SchemaItems = list(list(Name = "Item 1", ApplicationType = "Oral"))
  ))
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", dose = 10, schemas = schemas)
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", start_time = 0, schemas = schemas)
  )
  expect_snapshot(
    error = TRUE,
    create_protocol(name = "P", end_time = 24, schemas = schemas)
  )

  # Default unit arguments must not trip the mutual-exclusivity check.
  advanced <- create_protocol(name = "P", schemas = schemas)
  expect_s3_class(advanced, "Protocol")
})

test_that("create_protocol leaves output unchanged when no promoted argument is supplied", {
  promoted <- create_protocol(
    name = "P",
    application_type = "Oral",
    dosing_interval = "Single",
    parameters = list(
      create_parameter(name = "Start time", value = 0, unit = "h"),
      create_parameter(name = "InputDose", value = 10, unit = "mg")
    )
  )
  hand_built <- list(
    Name = "P",
    ApplicationType = "Oral",
    DosingInterval = "Single",
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "InputDose", Value = 10, Unit = "mg")
    )
  )
  expect_equal(promoted$data, hand_built)

  bare <- create_protocol(name = "P")
  expect_null(bare$data$Parameters)
})
