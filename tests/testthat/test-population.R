# ---- Population logic tests ----
# (Add any population class logic tests here if they exist)

# ---- Population dataframe tests ----
test_that("get_populations_dfs returns correct data frames", {
  # Test with a snapshot containing populations
  dfs <- get_populations_dfs(test_snapshot)
  expect_type(dfs, "list")
  expect_named(dfs, c("populations", "populations_parameters"))
  expect_s3_class(dfs$populations, "tbl_df")
  expect_s3_class(dfs$populations_parameters, "tbl_df")
  expect_snapshot(dfs$populations)
  expect_snapshot(dfs$populations_parameters)

  # Test with an empty snapshot
  dfs_empty <- get_populations_dfs(empty_snapshot)
  expect_type(dfs_empty, "list")
  expect_named(dfs_empty, c("populations", "populations_parameters"))
  expect_s3_class(dfs_empty$populations, "tbl_df")
  expect_s3_class(dfs_empty$populations_parameters, "tbl_df")
  expect_snapshot(dfs_empty$populations)
  expect_snapshot(dfs_empty$populations_parameters)
})

# ---- Population snapshot interaction tests ----
# (Merged from test-snapshot-populations.R)
