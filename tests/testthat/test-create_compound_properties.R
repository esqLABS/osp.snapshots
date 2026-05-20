test_that("create_compound_properties happy path", {
  props <- create_compound_properties(
    name = "Rifampicin",
    calculation_methods = c(
      "Cellular partition coefficient method - Rodgers and Rowland"
    ),
    alternatives = list(
      create_compound_group_selection(
        group_name = "COMPOUND_SOLUBILITY",
        alternative_name = "Aqueous"
      )
    ),
    processes = list(
      create_compound_process_selection(systemic_process_type = "Hepatic")
    ),
    protocol = create_protocol_selection(
      name = "Rifampicin Protocol",
      formulations = list(
        create_formulation_selection(
          name = "Oral solution",
          key = "Formulation"
        )
      )
    )
  )

  expect_s3_class(props, "CompoundProperties")
  expect_equal(props$name, "Rifampicin")
  expect_length(props$alternatives, 1)
  expect_length(props$processes, 1)
  expect_equal(props$protocol$name, "Rifampicin Protocol")
})

test_that("create_compound_properties without optional args", {
  props <- create_compound_properties(name = "Drug X")
  expect_equal(props$data, list(Name = "Drug X"))
})

test_that("create_compound_properties validates arguments", {
  expect_snapshot(error = TRUE, create_compound_properties())
  expect_snapshot(error = TRUE, create_compound_properties(name = ""))
  expect_snapshot(
    error = TRUE,
    create_compound_properties(name = "X", alternatives = "nope")
  )
  expect_snapshot(
    error = TRUE,
    create_compound_properties(name = "X", protocol = "nope")
  )
})
