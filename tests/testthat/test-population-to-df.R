test_that("Population to_df returns correct structure", {
    dfs <- test_snapshot$populations[[5]]$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("characteristics", "parameters"))
    expect_s3_class(dfs$characteristics, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Ensure eGFR columns are present in characteristics
    expect_true(all(
        c("egfr_min", "egfr_max", "egfr_unit") %in% names(dfs$characteristics)
    ))

    # Snapshot the outputs
    expect_snapshot(knitr::kable(dfs))
})

test_that("get_populations_dfs returns correct structure", {
    # Create a test snapshot with a population

    dfs <- get_populations_dfs(test_snapshot)

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("characteristics", "parameters"))
    expect_s3_class(dfs$characteristics, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Ensure eGFR columns are present in characteristics
    expect_true(all(
        c("egfr_min", "egfr_max", "egfr_unit") %in% names(dfs$characteristics)
    ))

    # Snapshot the outputs
    expect_snapshot(knitr::kable(dfs))
})

test_that("get_populations_dfs handles empty snapshot", {
    # Create empty snapshot
    snapshot_data <- list(Version = "80", Populations = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Get data frames
    dfs <- get_populations_dfs(snapshot)

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("characteristics", "parameters"))
    expect_s3_class(dfs$characteristics, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Ensure eGFR columns are present in characteristics
    expect_true(all(
        c("egfr_min", "egfr_max", "egfr_unit") %in% names(dfs$characteristics)
    ))

    # Snapshot the outputs
    expect_snapshot(knitr::kable(dfs))
})
