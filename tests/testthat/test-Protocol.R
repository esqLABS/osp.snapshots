# Load test data for protocols
load_test_protocols <- function() {
  test_snapshot <- jsonlite::fromJSON(
    test_path("data", "test_snapshot.json"),
    simplifyDataFrame = FALSE
  )
  return(test_snapshot$Protocols)
}

# Create test protocol data (simple protocol)
simple_protocol_data <- list(
  Name = "Test Simple Protocol",
  ApplicationType = "Oral",
  DosingInterval = "DI_12_12",
  Parameters = list(
    list(
      Name = "Start time",
      Value = 0.0,
      Unit = "h"
    ),
    list(
      Name = "InputDose",
      Value = 10.0,
      Unit = "mg"
    ),
    list(
      Name = "End time",
      Value = 24.0,
      Unit = "h"
    )
  ),
  TimeUnit = "h"
)

# Create test protocol data (advanced protocol with schemas)
advanced_protocol_data <- list(
  Name = "Test Advanced Protocol",
  DosingInterval = "Single",
  Schemas = list(
    list(
      Name = "Schema 1",
      SchemaItems = list(
        list(
          Name = "Schema Item 1",
          ApplicationType = "Oral",
          FormulationKey = "Test Formulation",
          Parameters = list(
            list(
              Name = "Start time",
              Value = 0.0,
              Unit = "h"
            ),
            list(
              Name = "InputDose",
              Value = 15.0,
              Unit = "mg"
            )
          )
        )
      ),
      Parameters = list(
        list(
          Name = "Start time",
          Value = 0.0,
          Unit = "h"
        ),
        list(
          Name = "NumberOfRepetitions",
          Value = 1.0
        ),
        list(
          Name = "TimeBetweenRepetitions",
          Value = 0.0,
          Unit = "h"
        )
      )
    )
  ),
  TimeUnit = "h"
)

# ---- Protocol class logic tests ----
test_that("Protocol class initialization works", {
  # Test simple protocol
  simple_protocol <- Protocol$new(simple_protocol_data)
  expect_s3_class(simple_protocol, "R6")
  expect_true("Protocol" %in% class(simple_protocol))
  expect_equal(simple_protocol$data, simple_protocol_data)
  expect_false(simple_protocol$is_advanced)

  # Test advanced protocol
  advanced_protocol <- Protocol$new(advanced_protocol_data)
  expect_s3_class(advanced_protocol, "R6")
  expect_true("Protocol" %in% class(advanced_protocol))
  expect_equal(advanced_protocol$data, advanced_protocol_data)
  expect_true(advanced_protocol$is_advanced)
})

test_that("Protocol active bindings work correctly", {
  # Test simple protocol
  simple_protocol <- Protocol$new(simple_protocol_data)
  expect_equal(simple_protocol$name, "Test Simple Protocol")
  expect_equal(simple_protocol$application_type, "Oral")
  expect_equal(simple_protocol$dosing_interval, "DI_12_12")
  expect_equal(simple_protocol$time_unit, "h")
  expect_false(simple_protocol$is_advanced)
  expect_length(simple_protocol$parameters, 3)
  expect_length(simple_protocol$schemas, 0)

  # Test advanced protocol
  advanced_protocol <- Protocol$new(advanced_protocol_data)
  expect_equal(advanced_protocol$name, "Test Advanced Protocol")
  expect_null(advanced_protocol$application_type)
  expect_equal(advanced_protocol$dosing_interval, "Single")
  expect_equal(advanced_protocol$time_unit, "h")
  expect_true(advanced_protocol$is_advanced)
  expect_length(advanced_protocol$parameters, 0)
  expect_length(advanced_protocol$schemas, 1)
})

test_that("Protocol print method returns formatted output", {
  simple_protocol <- Protocol$new(simple_protocol_data)
  advanced_protocol <- Protocol$new(advanced_protocol_data)

  expect_snapshot(print(simple_protocol))
  expect_snapshot(print(advanced_protocol))
})

test_that("Protocol human-readable methods work correctly", {
  simple_protocol <- Protocol$new(simple_protocol_data)

  # Test application type mapping
  expect_equal(simple_protocol$get_human_application_type(), "Oral")

  # Test dosing interval mapping
  expect_equal(simple_protocol$get_human_dosing_interval(), "2 times a day")

  # Test with different intervals
  test_data <- simple_protocol_data
  test_data$DosingInterval <- "Single"
  single_protocol <- Protocol$new(test_data)
  expect_equal(single_protocol$get_human_dosing_interval(), "Once")

  test_data$DosingInterval <- "DI_8_8_8"
  three_times_protocol <- Protocol$new(test_data)
  expect_equal(
    three_times_protocol$get_human_dosing_interval(),
    "3 times a day"
  )
})

test_that("Protocol to_df method works correctly", {
  # Test simple protocol
  simple_protocol <- Protocol$new(simple_protocol_data)
  simple_df <- simple_protocol$to_df()

  expect_snapshot(print(simple_df, width = Inf))

  # Test advanced protocol
  advanced_protocol <- Protocol$new(advanced_protocol_data)
  advanced_df <- advanced_protocol$to_df()

  expect_snapshot(print(advanced_df, width = Inf))
})

test_that("Protocol handles different types correctly", {
  # Test different application types
  iv_data <- simple_protocol_data
  iv_data$ApplicationType <- "IntravenousBolus"
  iv_protocol <- Protocol$new(iv_data)
  expect_equal(iv_protocol$get_human_application_type(), "Intravenous bolus")

  infusion_data <- simple_protocol_data
  infusion_data$ApplicationType <- "IntravenousInfusion"
  infusion_protocol <- Protocol$new(infusion_data)
  expect_equal(
    infusion_protocol$get_human_application_type(),
    "Intravenous infusion"
  )

  # Test different dosing intervals
  daily_data <- simple_protocol_data
  daily_data$DosingInterval <- "DI_24"
  daily_protocol <- Protocol$new(daily_data)
  expect_equal(daily_protocol$get_human_dosing_interval(), "Once a day")
})

test_that("Protocol parameters are converted to Parameter objects", {
  simple_protocol <- Protocol$new(simple_protocol_data)

  # Test that parameters are Parameter objects
  expect_true(all(vapply(
    simple_protocol$parameters,
    function(p) inherits(p, "Parameter"),
    logical(1)
  )))

  # Test parameter values
  param_names <- sapply(simple_protocol$parameters, function(p) p$name)
  expect_true("Start time" %in% param_names)
  expect_true("InputDose" %in% param_names)
  expect_true("End time" %in% param_names)
})

test_that("Protocol schema structure is correct", {
  advanced_protocol <- Protocol$new(advanced_protocol_data)

  # Test schema structure
  expect_length(advanced_protocol$schemas, 1)
  schema <- advanced_protocol$schemas[[1]]

  expect_equal(schema$name, "Schema 1")
  expect_length(schema$schema_items, 1)
  expect_length(schema$parameters, 3)

  # Test schema item structure
  schema_item <- schema$schema_items[[1]]
  expect_equal(schema_item$name, "Schema Item 1")
  expect_equal(schema_item$application_type, "Oral")
  expect_equal(schema_item$formulation_key, "Test Formulation")
  expect_length(schema_item$parameters, 2)
})

test_that("Protocol handles empty data gracefully", {
  # Test minimal protocol data
  minimal_data <- list(
    Name = "Minimal Protocol",
    DosingInterval = "Single"
  )

  minimal_protocol <- Protocol$new(minimal_data)
  expect_equal(minimal_protocol$name, "Minimal Protocol")
  expect_null(minimal_protocol$application_type)
  expect_null(minimal_protocol$time_unit)
  expect_length(minimal_protocol$parameters, 0)
  expect_length(minimal_protocol$schemas, 0)
  expect_false(minimal_protocol$is_advanced)

  # Test print output with minimal data
  expect_snapshot(print(minimal_protocol))
})

test_that("Protocol with real test data works", {
  # Load protocols from test snapshot
  protocols_data <- load_test_protocols()

  first_protocol <- Protocol$new(protocols_data[[1]])
  expect_s3_class(first_protocol, "R6")
  expect_true("Protocol" %in% class(first_protocol))

  # Test print output
  expect_snapshot(print(first_protocol))
})


test_that("Protocol collection print method works", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(print(snapshot$protocols))
})

test_that("get_protocols_dfs function works", {
  # Load test snapshot
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))

  # Get protocols dataframe
  protocols_df <- get_protocols_dfs(snapshot)

  expect_snapshot(print(protocols_df, width = Inf))
})

test_that("Protocol handles problematic time units correctly", {
  # Create a protocol with the problematic "day(s)" unit
  protocol_data_with_days <- list(
    Name = "Test Protocol with day(s) unit",
    ApplicationType = "Oral",
    DosingInterval = "DI_12_12",
    Parameters = list(
      list(
        Name = "Start time",
        Value = 0.0,
        Unit = "day(s)"
      ),
      list(
        Name = "End time",
        Value = 7.0,
        Unit = "day(s)"
      ),
      list(
        Name = "InputDose",
        Value = 10.0,
        Unit = "mg"
      )
    ),
    TimeUnit = "day(s)"
  )

  # This should not throw an error anymore
  protocol <- Protocol$new(protocol_data_with_days)
  expect_s3_class(protocol, "R6")
  expect_true("Protocol" %in% class(protocol))

  # Converting to data frame should work without errors
  expect_no_error(df <- protocol$to_df())
  expect_s3_class(df, "tbl_df")
  expect_true(nrow(df) > 0)
})

test_that("Protocol handles various ospsuite time units", {
  # Test different time units that ospsuite supports
  time_units_to_test <- c(
    "s",
    "min",
    "h",
    "day(s)",
    "week(s)",
    "month(s)",
    "year(s)",
    "ks"
  )

  for (unit in time_units_to_test) {
    protocol_data <- list(
      Name = paste("Test Protocol with", unit, "unit"),
      ApplicationType = "Oral",
      DosingInterval = "Single",
      Parameters = list(
        list(
          Name = "Start time",
          Value = 0.0,
          Unit = unit
        ),
        list(
          Name = "InputDose",
          Value = 10.0,
          Unit = "mg"
        )
      ),
      TimeUnit = unit
    )

    # Should not throw errors for any supported ospsuite time unit
    expect_no_error({
      protocol <- Protocol$new(protocol_data)
      df <- protocol$to_df()
    })
  }
})

test_that("Protocol get_dosing_interval_from_reps handles various time units", {
  # Create an advanced protocol to test get_dosing_interval_from_reps with different units
  create_advanced_protocol_with_time_unit <- function(time_val, time_unit) {
    list(
      Name = "Test Advanced Protocol",
      DosingInterval = "Single",
      Schemas = list(
        list(
          Name = "Schema 1",
          SchemaItems = list(
            list(
              Name = "Schema Item 1",
              ApplicationType = "Oral",
              FormulationKey = "Test Formulation",
              Parameters = list(
                list(
                  Name = "Start time",
                  Value = 0.0,
                  Unit = "h"
                ),
                list(
                  Name = "InputDose",
                  Value = 15.0,
                  Unit = "mg"
                )
              )
            )
          ),
          Parameters = list(
            list(
              Name = "Start time",
              Value = 0.0,
              Unit = "h"
            ),
            list(
              Name = "NumberOfRepetitions",
              Value = 3.0
            ),
            list(
              Name = "TimeBetweenRepetitions",
              Value = time_val,
              Unit = time_unit
            )
          )
        )
      ),
      TimeUnit = "h"
    )
  }

  # Test different time units for TimeBetweenRepetitions
  test_cases <- list(
    list(value = 8, unit = "h", expected_interval = "3 times a day"), # 8 hours = 3 times/day
    list(value = 12, unit = "h", expected_interval = "2 times a day"), # 12 hours = 2 times/day
    list(value = 0.5, unit = "day(s)", expected_interval = "2 times a day"), # 0.5 days = 12 hours = 2 times/day
    list(value = 480, unit = "min", expected_interval = "3 times a day"), # 480 minutes = 8 hours = 3 times/day
    list(value = 1, unit = "day(s)", expected_interval = "Once a day") # 1 day = once/day
  )

  for (test_case in test_cases) {
    protocol_data <- create_advanced_protocol_with_time_unit(
      test_case$value,
      test_case$unit
    )
    protocol <- Protocol$new(protocol_data)
    df <- protocol$to_df()

    expect_equal(df$dosing_interval[1], test_case$expected_interval)
  }
})
