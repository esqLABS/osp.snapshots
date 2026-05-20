test_that("CompoundProperties wraps fixture data", {
  raw <- list(
    Name = "Rifampicin",
    CalculationMethods = list(
      "Cellular partition coefficient method - Rodgers and Rowland"
    ),
    Alternatives = list(
      list(GroupName = "COMPOUND_SOLUBILITY", AlternativeName = "Aqueous")
    ),
    Processes = list(
      list(MoleculeName = "CYP3A4"),
      list(SystemicProcessType = "Hepatic")
    ),
    Protocol = list(
      Name = "Rifampicin Protocol",
      Formulations = list(
        list(Name = "Oral solution", Key = "Formulation")
      )
    )
  )
  props <- CompoundProperties$new(raw)

  expect_s3_class(props, "CompoundProperties")
  expect_equal(props$name, "Rifampicin")
  expect_length(props$calculation_methods, 1)
  expect_length(props$alternatives, 1)
  expect_s3_class(props$alternatives[[1]], "CompoundGroupSelection")
  expect_length(props$processes, 2)
  expect_s3_class(props$processes[[1]], "CompoundProcessSelection")
  expect_s3_class(props$protocol, "ProtocolSelection")
  expect_equal(props$protocol$name, "Rifampicin Protocol")
})

test_that("CompoundProperties$data round-trips raw input", {
  raw <- list(
    Name = "Rifampicin",
    Alternatives = list(
      list(GroupName = "COMPOUND_SOLUBILITY", AlternativeName = "Aqueous")
    ),
    Processes = list(list(MoleculeName = "CYP3A4")),
    Protocol = list(
      Name = "Rifampicin Protocol",
      Formulations = list(
        list(Name = "Oral solution", Key = "Formulation")
      )
    )
  )
  props <- CompoundProperties$new(raw)
  expect_identical(props$data, raw)
})

test_that("CompoundProperties without nested arrays works", {
  props <- CompoundProperties$new(list(Name = "Drug X"))
  expect_length(props$alternatives, 0)
  expect_length(props$processes, 0)
  expect_null(props$protocol)
  expect_identical(props$data, list(Name = "Drug X"))
})

test_that("CompoundProperties protocol setter accepts NULL and ProtocolSelection", {
  props <- CompoundProperties$new(list(
    Name = "X",
    Protocol = list(Name = "Old")
  ))
  props$protocol <- create_protocol_selection(name = "New")
  expect_equal(props$data$Protocol$Name, "New")

  props$protocol <- NULL
  expect_null(props$data$Protocol)
})
