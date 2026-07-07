test_that("create_descriptor_condition accepts an open Type string", {
  expect_equal(
    create_descriptor_condition("Brain", "MatchTag"),
    list(Tag = "Brain", Type = "MatchTag")
  )
})

test_that("create_descriptor_condition omits Type when NULL", {
  expect_equal(
    create_descriptor_condition("Brain"),
    list(Tag = "Brain")
  )
})

test_that("create_descriptor_condition aborts on missing or empty tag", {
  expect_snapshot(create_descriptor_condition(), error = TRUE)
  expect_snapshot(create_descriptor_condition(""), error = TRUE)
})
