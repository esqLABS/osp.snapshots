test_that("create_protocol_selection happy path", {
  sel <- create_protocol_selection(
    name = "Protocol-A",
    formulations = list(
      create_formulation_selection(name = "Oral solution", key = "Formulation")
    )
  )

  expect_s3_class(sel, "ProtocolSelection")
  expect_equal(sel$name, "Protocol-A")
  expect_length(sel$formulations, 1)
  expect_equal(sel$formulations[[1]]$name, "Oral solution")
})

test_that("create_protocol_selection without formulations works", {
  sel <- create_protocol_selection(name = "Protocol-A")
  expect_length(sel$formulations, 0)
  expect_identical(sel$data, list(Name = "Protocol-A"))
})

test_that("create_protocol_selection validates arguments", {
  expect_snapshot(error = TRUE, create_protocol_selection())
  expect_snapshot(error = TRUE, create_protocol_selection(name = ""))
  expect_snapshot(
    error = TRUE,
    create_protocol_selection(name = "P", formulations = "nope")
  )
})
