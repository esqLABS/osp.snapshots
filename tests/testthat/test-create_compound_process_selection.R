test_that("create_compound_process_selection happy path", {
  sel <- create_compound_process_selection(
    name = "P-gp-Collett 2004",
    molecule_name = "P-gp"
  )

  expect_s3_class(sel, "CompoundProcessSelection")
  expect_equal(sel$name, "P-gp-Collett 2004")
  expect_equal(sel$molecule_name, "P-gp")
  expect_null(sel$systemic_process_type)
})

test_that("create_compound_process_selection serializes only supplied args", {
  sel <- create_compound_process_selection(systemic_process_type = "Hepatic")
  expect_named(sel$data, "SystemicProcessType")
})

test_that("create_compound_process_selection validates strings", {
  expect_snapshot(error = TRUE, create_compound_process_selection(name = ""))
})
