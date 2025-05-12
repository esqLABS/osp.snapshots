# ---- ExpressionProfile logic tests ----
test_that("ExpressionProfile class initialization works", {
  # Test with complete data
  profile <- ExpressionProfile$new(complete_expression_profile_data)
  expect_s3_class(profile, "R6")
  expect_true("ExpressionProfile" %in% class(profile))
  expect_equal(profile$molecule, "CYP3A4")
  expect_equal(profile$type, "Enzyme")
  expect_equal(profile$species, "Human")
  expect_equal(profile$category, "Healthy")
  expect_equal(profile$localization, "Intracellular, BloodCellsIntracellular")
  expect_equal(profile$ontogeny$Name, "CYP3A4")
  expect_length(profile$parameters, 3)

  # Test with minimal data
  simple_profile <- ExpressionProfile$new(minimal_expression_profile_data)
  expect_s3_class(simple_profile, "R6")
  expect_equal(simple_profile$molecule, "P-gp")
  expect_equal(simple_profile$type, "Transporter")
  expect_equal(simple_profile$species, "Human")
  expect_equal(simple_profile$category, "Healthy")
  expect_null(simple_profile$localization)
  expect_null(simple_profile$ontogeny)
  expect_length(simple_profile$parameters, 0)

  # Test without category
  without_category <- ExpressionProfile$new(
    without_category_expression_profile_data
  )
  expect_s3_class(without_category, "R6")
  expect_equal(without_category$molecule, "OATP1B1")
  expect_equal(without_category$type, "Transporter")
  expect_equal(without_category$species, "Rat")
  expect_null(without_category$category)
  expect_length(without_category$parameters, 1)
})

test_that("ExpressionProfile getters work", {
  profile <- ExpressionProfile$new(complete_expression_profile_data)

  # Test getters
  expect_equal(profile$molecule, "CYP3A4")
  expect_equal(profile$type, "Enzyme")
  expect_equal(profile$species, "Human")
  expect_equal(profile$category, "Healthy")
  expect_equal(profile$localization, "Intracellular, BloodCellsIntracellular")
  expect_equal(profile$ontogeny$Name, "CYP3A4")
  expect_equal(profile$data, complete_expression_profile_data)

  # Test id generation
  expect_equal(profile$id, "CYP3A4_Human_Healthy")

  # Test id generation without category
  without_category <- ExpressionProfile$new(
    without_category_expression_profile_data
  )
  expect_equal(without_category$id, "OATP1B1_Rat_NA")
})

test_that("ExpressionProfile print method works", {
  # Test printing (output captured by testthat)
  expect_snapshot(print(complete_expression_profile))
  expect_snapshot(print(minimal_expression_profile))
  expect_snapshot(print(without_category_expression_profile))
})

test_that("print.expression_profile_collection works", {
  # Create a collection
  profiles <- list(
    complete_expression_profile,
    minimal_expression_profile,
    without_category_expression_profile
  )
  names(profiles) <- c(
    "CYP3A4|Human|Healthy",
    "P-gp|Human|Healthy",
    "OATP1B1|Rat|NA"
  )
  class(profiles) <- c("expression_profile_collection", "list")

  # Test printing
  expect_snapshot(print(profiles))

  # Test empty collection
  empty_profiles <- list()
  class(empty_profiles) <- c("expression_profile_collection", "list")
  expect_snapshot(print(empty_profiles))
})

test_that("to_df converts expression profile to tibble correctly", {
  # Test with a complete expression profile
  profile <- ExpressionProfile$new(complete_expression_profile_data)
  result <- profile$to_df()

  # Check structure
  expect_type(result, "list")
  expect_named(
    result,
    c("expression_profiles", "expression_profiles_parameters")
  )

  # Check basic dataframe
  expect_s3_class(result$expression_profiles, "tbl_df")
  expect_equal(nrow(result$expression_profiles), 1)
  expect_equal(result$expression_profiles$molecule, "CYP3A4")
  expect_equal(result$expression_profiles$type, "Enzyme")
  expect_equal(result$expression_profiles$species, "Human")
  expect_equal(result$expression_profiles$ontogeny, "CYP3A4")

  # Check parameters dataframe
  expect_s3_class(result$expression_profiles_parameters, "tbl_df")
  expect_equal(nrow(result$expression_profiles_parameters), 3)
  expect_true("parameter" %in% colnames(result$expression_profiles_parameters))
  expect_true("value" %in% colnames(result$expression_profiles_parameters))
  expect_true("unit" %in% colnames(result$expression_profiles_parameters))
  expect_true("source" %in% colnames(result$expression_profiles_parameters))

  # Check specific parameter
  ref_conc_row <- result$expression_profiles_parameters[
    result$expression_profiles_parameters$parameter ==
      "CYP3A4|Reference concentration",
  ]
  expect_equal(ref_conc_row$value, 4.32)
  expect_equal(ref_conc_row$unit, "µmol/l")
  expect_equal(ref_conc_row$source, "Other")

  # Test with a minimal expression profile (no parameters)
  minimal_profile <- ExpressionProfile$new(minimal_expression_profile_data)
  minimal_result <- minimal_profile$to_df()

  # Check structure
  expect_type(minimal_result, "list")
  expect_named(
    minimal_result,
    c("expression_profiles", "expression_profiles_parameters")
  )

  # Check basic dataframe
  expect_s3_class(minimal_result$expression_profiles, "tbl_df")
  expect_equal(nrow(minimal_result$expression_profiles), 1)
  expect_equal(minimal_result$expression_profiles$molecule, "P-gp")

  # Check parameters is NULL
  expect_null(minimal_result$expression_profiles_parameters)

  # Test with profile without category
  without_category <- ExpressionProfile$new(
    without_category_expression_profile_data
  )
  result_no_cat <- without_category$to_df()

  # Check basic dataframe
  expect_s3_class(result_no_cat$expression_profiles, "tbl_df")
  expect_equal(nrow(result_no_cat$expression_profiles), 1)
  expect_equal(result_no_cat$expression_profiles$molecule, "OATP1B1")
  expect_true(is.na(result_no_cat$expression_profiles$category))

  # Check parameters dataframe
  expect_s3_class(result_no_cat$expression_profiles_parameters, "tbl_df")
  expect_equal(nrow(result_no_cat$expression_profiles_parameters), 1)
})

test_that("expression_profile_collection from cloned test snapshot works", {
  # Clone the test snapshot to avoid mutating the shared object
  snapshot_clone <- Snapshot$new(test_snapshot$data)
  profiles <- snapshot_clone$expression_profiles

  # Check class and length
  expect_s3_class(profiles, "expression_profile_collection")
  expect_gt(length(profiles), 0)

  # Check that known profile names are present
  expect_true(
    "CYP3A4_Human_Healthy" %in%
      names(profiles) ||
      "CYP3A4|Human|Healthy" %in% names(profiles)
  )
  expect_true(
    "P-gp_Human_Healthy" %in%
      names(profiles) ||
      "P-gp|Human|Healthy" %in% names(profiles)
  )

  # Print for snapshot testing
  expect_snapshot(print(profiles))
})

test_that("Snapshot with empty expression profiles is handled correctly", {
  snapshot <- empty_snapshot$clone()
  expect_s3_class(snapshot$expression_profiles, "expression_profile_collection")
  expect_length(snapshot$expression_profiles, 0)

  # Dataframe transformation should return empty tibbles with correct columns
  dfs <- get_expression_profiles_dfs(snapshot)
  expect_type(dfs, "list")
  expect_named(dfs, c("expression_profiles", "expression_profiles_parameters"))
  expect_s3_class(dfs$expression_profiles, "tbl_df")
  expect_s3_class(dfs$expression_profiles_parameters, "tbl_df")
  expect_equal(nrow(dfs$expression_profiles), 0)
  expect_equal(nrow(dfs$expression_profiles_parameters), 0)
  expect_snapshot(knitr::kable(dfs$expression_profiles))
  expect_snapshot(knitr::kable(dfs$expression_profiles_parameters))
})

# ---- ExpressionProfile dataframe tests ----
# Copied from test-expression-profile-dataframe.R
# ... existing code ...

# ---- ExpressionProfile snapshot interaction tests ----
# Copied from test-snapshot-expression-profile.R
# ... existing code ...
