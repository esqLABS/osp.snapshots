test_that("validate_unit accepts valid units", {
  # Test valid units for different dimensions
  expect_true(validate_unit("year(s)", "Age in years"))
  expect_true(validate_unit("kg", "Mass"))
  expect_true(validate_unit("cm", "Length"))
})

test_that("validate_unit rejects invalid units", {
  # Test invalid units for different dimensions
  expect_error(
    validate_unit("invalid_unit", "Age in years"),
    "Invalid unit: invalid_unit"
  )
  expect_error(
    validate_unit("invalid_unit", "Mass"),
    "Invalid unit: invalid_unit"
  )
  expect_error(
    validate_unit("invalid_unit", "Length"),
    "Invalid unit: invalid_unit"
  )
})

test_that("validate_species accepts a valid scalar species", {
  expect_true(validate_species("Human"))
})

test_that("validate_species rejects a non-scalar or empty species with a clear message", {
  expect_snapshot(error = TRUE, validate_species(c("Human", "Dog")))
  expect_snapshot(error = TRUE, validate_species(character(0)))
  expect_snapshot(error = TRUE, validate_species(NA_character_))
})

test_that("convert_ospsuite_time_unit_to_lubridate works correctly", {
  # Test mapping of ospsuite units to lubridate units
  expect_equal(convert_ospsuite_time_unit_to_lubridate("s"), "seconds")
  expect_equal(convert_ospsuite_time_unit_to_lubridate("min"), "minutes")
  expect_equal(convert_ospsuite_time_unit_to_lubridate("h"), "hours")
  expect_equal(convert_ospsuite_time_unit_to_lubridate("day(s)"), "days")
  expect_equal(convert_ospsuite_time_unit_to_lubridate("week(s)"), "weeks")
  expect_equal(convert_ospsuite_time_unit_to_lubridate("month(s)"), "months")
  expect_equal(convert_ospsuite_time_unit_to_lubridate("year(s)"), "years")
  expect_equal(convert_ospsuite_time_unit_to_lubridate("ks"), "seconds")

  # Test NULL and NA values
  expect_true(is.null(convert_ospsuite_time_unit_to_lubridate(NULL)))
  expect_true(is.na(convert_ospsuite_time_unit_to_lubridate(NA)))

  # Test unknown unit - should give warning and return as-is
  expect_warning(
    result <- convert_ospsuite_time_unit_to_lubridate("unknown_unit"),
    "Unknown time unit 'unknown_unit'"
  )
  expect_equal(result, "unknown_unit")
})

test_that("convert_ospsuite_time_to_duration works correctly", {
  # Test basic conversions
  expect_s4_class(convert_ospsuite_time_to_duration(1, "s"), "Duration")
  expect_s4_class(convert_ospsuite_time_to_duration(1, "h"), "Duration")
  expect_s4_class(convert_ospsuite_time_to_duration(1, "day(s)"), "Duration")

  # Test specific values
  duration_1_day <- convert_ospsuite_time_to_duration(1, "day(s)")
  expect_equal(as.numeric(duration_1_day), 86400) # 1 day = 86400 seconds

  duration_1_hour <- convert_ospsuite_time_to_duration(1, "h")
  expect_equal(as.numeric(duration_1_hour), 3600) # 1 hour = 3600 seconds

  # Test kiloseconds special case
  duration_3_ks <- convert_ospsuite_time_to_duration(3, "ks")
  expect_equal(as.numeric(duration_3_ks), 3000) # 3 kiloseconds = 3000 seconds

  # Test NULL and NA values
  expect_s4_class(convert_ospsuite_time_to_duration(NULL, "h"), "Duration")
  expect_equal(as.numeric(convert_ospsuite_time_to_duration(NULL, "h")), 0)

  expect_s4_class(convert_ospsuite_time_to_duration(NA, "h"), "Duration")
  expect_equal(as.numeric(convert_ospsuite_time_to_duration(NA, "h")), 0)

  # Test default unit when unit is NULL
  duration_default <- convert_ospsuite_time_to_duration(10, NULL)
  expect_equal(as.numeric(duration_default), 10) # Should default to seconds
})

test_that("disambiguate_names returns empty character on empty input", {
  expect_equal(disambiguate_names(character(0)), character(0))
})

test_that("disambiguate_names leaves all-unique keys unchanged", {
  expect_equal(
    disambiguate_names(c("a", "b", "c")),
    c("a", "b", "c")
  )
})

test_that("disambiguate_names suffixes duplicated keys with `_{n}` in order", {
  expect_equal(
    disambiguate_names(c("a", "a", "a")),
    c("a_1", "a_2", "a_3")
  )
})

test_that("disambiguate_names only suffixes the keys that actually collide", {
  expect_equal(
    disambiguate_names(c("a", "b", "a", "c")),
    c("a_1", "b", "a_2", "c")
  )
})

test_that("disambiguate_names numbers each duplicated key independently", {
  expect_equal(
    disambiguate_names(c("a", "b", "a", "b", "c")),
    c("a_1", "b_1", "a_2", "b_2", "c")
  )
})

test_that("disambiguate_names preserves single occurrence with no suffix", {
  expect_equal(
    disambiguate_names(c("only")),
    "only"
  )
})

test_that("disambiguate_names guarantees uniqueness when a generated suffix collides with an existing input name", {
  result <- disambiguate_names(c("a_1", "a", "a"))
  expect_equal(length(unique(result)), length(result))
  expect_equal(result, c("a_1", "a_2", "a_3"))
})

test_that("disambiguate_names handles a colliding suffix that appears after the duplicates", {
  result <- disambiguate_names(c("a", "a_1", "a"))
  expect_equal(length(unique(result)), length(result))
  expect_equal(result, c("a_2", "a_1", "a_3"))
})
