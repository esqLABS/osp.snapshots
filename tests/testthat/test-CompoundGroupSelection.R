test_that("CompoundGroupSelection exposes group_name and alternative_name", {
  raw <- list(
    GroupName = "COMPOUND_SOLUBILITY",
    AlternativeName = "Aqueous"
  )
  sel <- CompoundGroupSelection$new(raw)

  expect_s3_class(sel, "CompoundGroupSelection")
  expect_equal(sel$group_name, "COMPOUND_SOLUBILITY")
  expect_equal(sel$alternative_name, "Aqueous")
  expect_identical(sel$data, raw)
})

test_that("CompoundGroupSelection setters mutate raw data", {
  sel <- CompoundGroupSelection$new(
    list(GroupName = "G", AlternativeName = "A")
  )
  sel$group_name <- "G2"
  sel$alternative_name <- "A2"

  expect_equal(sel$data$GroupName, "G2")
  expect_equal(sel$data$AlternativeName, "A2")
})

test_that("CompoundGroupSelection setters require non-empty scalar strings", {
  sel <- CompoundGroupSelection$new(
    list(GroupName = "G", AlternativeName = "A")
  )
  expect_snapshot(error = TRUE, sel$group_name <- "")
  expect_snapshot(error = TRUE, sel$group_name <- 5)
  expect_snapshot(error = TRUE, sel$alternative_name <- "")
  expect_snapshot(error = TRUE, sel$alternative_name <- 5)
})
