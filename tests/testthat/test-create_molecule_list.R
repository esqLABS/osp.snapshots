test_that("create_molecule_list stores ForAll as a scalar logical", {
  expect_equal(create_molecule_list(for_all = TRUE), list(ForAll = TRUE))
})

test_that("create_molecule_list stores include and exclude as list arrays", {
  expect_equal(
    create_molecule_list(include = c("A", "B"), exclude = "C"),
    list(
      MoleculeNamesToInclude = list("A", "B"),
      MoleculeNamesToExclude = list("C")
    )
  )
})

test_that("create_molecule_list returns an empty named list for all NULL", {
  result <- create_molecule_list()
  expect_length(result, 0)
  expect_named(result, character(0))
})

test_that("create_molecule_list aborts on a non-logical for_all", {
  expect_snapshot(create_molecule_list(for_all = "yes"), error = TRUE)
})
