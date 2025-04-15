# Test for compound_collection print method
test_that("print.compound_collection works with compounds", {
  # Test the print method
  expect_snapshot(print(test_snapshot$compounds))
})

test_that("print.compound_collection works with empty collection", {
  # Create an empty compound collection
  compounds_named <- list()
  class(compounds_named) <- c("compound_collection", "list")

  # Test the print method with empty collection
  expect_snapshot(print(compounds_named))
})

# Test for individual_collection print method
test_that("print.individual_collection works with individuals", {
  # Test the print method
  expect_snapshot(print(test_snapshot$individuals))
})

test_that("print.individual_collection works with empty collection", {
  # Create an empty individual collection
  individuals_named <- list()
  class(individuals_named) <- c("individual_collection", "list")

  # Test the print method with empty collection
  expect_snapshot(print(individuals_named))
})

# Test for formulation_collection print method
test_that("print.formulation_collection works with formulations", {
  # Test the print method
  expect_snapshot(print(test_snapshot$formulations))
})

test_that("print.formulation_collection works with empty collection", {
  # Create an empty formulation collection
  formulations_named <- list()
  class(formulations_named) <- c("formulation_collection", "list")

  # Test the print method with empty collection
  expect_snapshot(print(formulations_named))
})

# Test for parameter_collection print method
test_that("print.parameter_collection works with parameters", {
  # Create a parameter collection
  params <- list(
    Parameter$new(list(
      Path = "Test|Path1",
      Value = 123.45678,
      Unit = "mg"
    )),
    Parameter$new(list(
      Path = "Test|Path2|With|Very|Long|Name|That|Should|Be|Truncated",
      Value = 0.12345,
      Unit = "mg/ml"
    )),
    Parameter$new(list(Path = "Test|Path3", Value = 987.654))
  )

  # Set names to the paths
  names(params) <- sapply(params, function(p) p$name)

  # Set the class
  class(params) <- c("parameter_collection", "list")

  # Test the print method
  expect_snapshot(print(params))
})

test_that("print.parameter_collection works with empty collection", {
  # Create an empty parameter collection
  params <- list()
  class(params) <- c("parameter_collection", "list")

  # Test the print method
  expect_snapshot(print(params))
})

test_that("print.parameter_collection formats values correctly", {
  # Create parameters with different value types
  params <- list(
    Parameter$new(list(Path = "Test|Integer", Value = 123, Unit = "count")),
    Parameter$new(list(
      Path = "Test|Decimal",
      Value = 123.456789,
      Unit = "mg"
    )),
    Parameter$new(list(
      Path = "Test|Scientific",
      Value = 0.0000123,
      Unit = "mol"
    )),
    Parameter$new(list(
      Path = "Test|Large",
      Value = 12345678,
      Unit = "cells"
    ))
  )

  # Set names to the paths
  names(params) <- sapply(params, function(p) p$name)

  # Set the class
  class(params) <- c("parameter_collection", "list")

  # Test the print method
  expect_snapshot(print(params))

  # Verify output is a character representation
  output <- utils::capture.output(print(params))
  expect_type(output, "character")

  # Check that the proper headers are included
  expect_true(any(grepl("Name", output, fixed = TRUE)))
  expect_true(any(grepl("Value", output, fixed = TRUE)))
  expect_true(any(grepl("Unit", output, fixed = TRUE)))

  # Check that all parameters are included
  for (param in params) {
    expect_true(any(
      grepl(param$name, output, fixed = TRUE) |
        grepl(
          substr(
            param$name,
            nchar(param$name) - 36,
            nchar(param$name)
          ),
          output,
          fixed = TRUE
        )
    ))
  }
})
