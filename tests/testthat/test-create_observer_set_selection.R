test_that("create_observer_set_selection happy path", {
  sel <- create_observer_set_selection(name = "BrainPlasmaConcentration")
  expect_s3_class(sel, "ObserverSetSelection")
  expect_equal(sel$name, "BrainPlasmaConcentration")
})

test_that("create_observer_set_selection validates arguments", {
  expect_snapshot(error = TRUE, create_observer_set_selection())
  expect_snapshot(error = TRUE, create_observer_set_selection(name = ""))
})
