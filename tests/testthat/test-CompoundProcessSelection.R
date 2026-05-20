test_that("CompoundProcessSelection exposes every field", {
  raw <- list(
    Name = "P-gp-Collett 2004",
    MoleculeName = "P-gp",
    MetaboliteName = "M1",
    CompoundName = "Drug",
    SystemicProcessType = "Hepatic"
  )
  sel <- CompoundProcessSelection$new(raw)

  expect_s3_class(sel, "CompoundProcessSelection")
  expect_equal(sel$name, "P-gp-Collett 2004")
  expect_equal(sel$molecule_name, "P-gp")
  expect_equal(sel$metabolite_name, "M1")
  expect_equal(sel$compound_name, "Drug")
  expect_equal(sel$systemic_process_type, "Hepatic")
  expect_identical(sel$data, raw)
})

test_that("CompoundProcessSelection handles sparse raw data", {
  sel <- CompoundProcessSelection$new(list(SystemicProcessType = "Hepatic"))
  expect_null(sel$name)
  expect_null(sel$molecule_name)
  expect_equal(sel$systemic_process_type, "Hepatic")
})

test_that("CompoundProcessSelection setters mutate raw data", {
  sel <- CompoundProcessSelection$new(list(Name = "A"))
  sel$molecule_name <- "M"
  expect_equal(sel$data$MoleculeName, "M")
})
