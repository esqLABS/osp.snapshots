# Test for compound_collection dispatch via print.snapshot_collection
test_that("print.snapshot_collection dispatches on compound_collection", {
  # Test the print method
  expect_snapshot(print(test_snapshot$compounds))
})

test_that("print.snapshot_collection dispatches on empty compound_collection", {
  # Create an empty compound collection
  compounds_named <- list()
  class(compounds_named) <- c(
    "compound_collection",
    "snapshot_collection",
    "list"
  )

  # Test the print method with empty collection
  expect_snapshot(print(compounds_named))
})

# Test for individual_collection dispatch via print.snapshot_collection
test_that("print.snapshot_collection dispatches on individual_collection", {
  # Test the print method
  expect_snapshot(print(test_snapshot$individuals))
})

test_that("print.snapshot_collection dispatches on empty individual_collection", {
  # Create an empty individual collection
  individuals_named <- list()
  class(individuals_named) <- c(
    "individual_collection",
    "snapshot_collection",
    "list"
  )

  # Test the print method with empty collection
  expect_snapshot(print(individuals_named))
})

# Test for formulation_collection dispatch via print.snapshot_collection
test_that("print.snapshot_collection dispatches on formulation_collection", {
  # Test the print method
  expect_snapshot(print(test_snapshot$formulations))
})

test_that("print.snapshot_collection dispatches on empty formulation_collection", {
  # Create an empty formulation collection
  formulations_named <- list()
  class(formulations_named) <- c(
    "formulation_collection",
    "snapshot_collection",
    "list"
  )

  # Test the print method with empty collection
  expect_snapshot(print(formulations_named))
})

test_that("print.snapshot_collection errors when no collection_kind_info method exists", {
  unknown <- list(a = 1L, b = 2L)
  class(unknown) <- c("future_collection", "snapshot_collection", "list")
  expect_snapshot(print(unknown), error = TRUE)
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

# Test for expression_profile_collection dispatch via print.snapshot_collection
test_that("print.snapshot_collection dispatches on expression_profile_collection", {
  # Create a collection of expression profiles
  profiles <- list(
    complete_expression_profile,
    minimal_expression_profile,
    without_category_expression_profile
  )
  names(profiles) <- c(
    "CYP3A4|Human|Healthy",
    "P-gp|Human|Healthy",
    "OATP1B1|Rat|NA"
  )
  class(profiles) <- c(
    "expression_profile_collection",
    "snapshot_collection",
    "list"
  )

  # Test the print method
  expect_snapshot(print(profiles))
})

test_that("print.snapshot_collection dispatches on empty expression_profile_collection", {
  # Create an empty expression profile collection
  profiles_named <- list()
  class(profiles_named) <- c(
    "expression_profile_collection",
    "snapshot_collection",
    "list"
  )

  # Test the print method with empty collection
  expect_snapshot(print(profiles_named))
})

test_that("print.physicochemical_property flags the default alternative", {
  # The default is the second element, so the snapshot confirms `(Default)`
  # marks the explicitly chosen alternative rather than the first or last.
  compound <- create_compound(
    name = "Drug X",
    lipophilicity = list(
      lipophilicity(2.5, name = "Measured", default = TRUE),
      lipophilicity(3.1, name = "Predicted")
    )
  )

  expect_snapshot(print(compound$lipophilicity))
})

test_that("print.physicochemical_property omits the flag for a single alternative", {
  compound <- create_compound(
    name = "Drug X",
    lipophilicity = lipophilicity(2.5)
  )

  expect_snapshot(print(compound$lipophilicity))
})
