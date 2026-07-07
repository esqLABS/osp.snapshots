test_that("create_formula_reference builds Alias and Path", {
  expect_equal(
    create_formula_reference("a", "p"),
    list(Alias = "a", Path = "p")
  )
})

test_that("create_formula_reference adds Dimension when supplied", {
  expect_equal(
    create_formula_reference("a", "p", "D"),
    list(Alias = "a", Path = "p", Dimension = "D")
  )
})

test_that("create_formula_reference aborts on missing alias or path", {
  expect_snapshot(create_formula_reference(path = "p"), error = TRUE)
  expect_snapshot(create_formula_reference("a"), error = TRUE)
  expect_snapshot(create_formula_reference("", "p"), error = TRUE)
})
