test_that("create_formulation_selection happy path", {
  sel <- create_formulation_selection(
    name = "Oral solution",
    key = "Formulation"
  )

  expect_s3_class(sel, "FormulationSelection")
  expect_equal(sel$name, "Oral solution")
  expect_equal(sel$key, "Formulation")
})

test_that("create_formulation_selection validates arguments", {
  expect_snapshot(error = TRUE, create_formulation_selection())
  expect_snapshot(error = TRUE, create_formulation_selection(name = "F"))
  expect_snapshot(
    error = TRUE,
    create_formulation_selection(name = "", key = "K")
  )
})
