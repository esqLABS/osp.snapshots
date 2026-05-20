test_that("create_compound_group_selection happy path", {
  sel <- create_compound_group_selection(
    group_name = "COMPOUND_SOLUBILITY",
    alternative_name = "Aqueous"
  )

  expect_s3_class(sel, "CompoundGroupSelection")
  expect_equal(sel$group_name, "COMPOUND_SOLUBILITY")
  expect_equal(sel$alternative_name, "Aqueous")
})

test_that("create_compound_group_selection validates arguments", {
  expect_snapshot(error = TRUE, create_compound_group_selection())
  expect_snapshot(
    error = TRUE,
    create_compound_group_selection(group_name = "G")
  )
})
