test_that("Population to_df returns correct structure", {
    # Create a test population with all fields
    pop_data <- list(
        Name = "test_pop",
        Seed = 12345,
        Settings = list(
            NumberOfIndividuals = 100,
            ProportionOfFemales = 50,
            Age = list(
                Min = 20,
                Max = 60,
                Unit = "year(s)"
            ),
            Individual = list(
                Name = "Test Individual",
                OriginData = list(
                    Population = "Test_Population"
                ),
                DiseaseStateParameters = list(
                    list(
                        Name = "eGFR",
                        Value = 45.0,
                        Unit = "ml/min/1.73m²"
                    )
                )
            )
        ),
        AdvancedParameters = list(
            list(
                Name = "Test Parameter",
                Seed = 67890,
                DistributionType = "Normal",
                Parameters = list(
                    list(
                        Name = "Mean",
                        Value = 10.0,
                        Unit = "mg",
                        ValueOrigin = list(
                            Source = "Publication",
                            Description = "Test reference"
                        )
                    )
                )
            )
        )
    )

    pop <- Population$new(pop_data)

    # Get data frames
    dfs <- pop$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("characteristics", "parameters"))
    expect_s3_class(dfs$characteristics, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Snapshot the outputs
    expect_snapshot(dfs)
})

test_that("get_populations_dfs returns correct structure", {
    # Create a test snapshot with a population
    snapshot_data <- list(
        Version = "80",
        Populations = list(
            list(
                Name = "test_pop",
                Seed = 12345,
                Settings = list(
                    NumberOfIndividuals = 100,
                    ProportionOfFemales = 50,
                    Age = list(
                        Min = 20,
                        Max = 60,
                        Unit = "year(s)"
                    ),
                    Individual = list(
                        Name = "Test Individual",
                        OriginData = list(
                            Population = "Test_Population"
                        ),
                        DiseaseStateParameters = list(
                            list(
                                Name = "eGFR",
                                Value = 45.0,
                                Unit = "ml/min/1.73m²"
                            )
                        )
                    )
                ),
                AdvancedParameters = list(
                    list(
                        Name = "Test Parameter",
                        Seed = 67890,
                        DistributionType = "Normal",
                        Parameters = list(
                            list(
                                Name = "Mean",
                                Value = 10.0,
                                Unit = "mg",
                                ValueOrigin = list(
                                    Source = "Publication",
                                    Description = "Test reference"
                                )
                            )
                        )
                    )
                )
            )
        )
    )

    snapshot <- Snapshot$new(snapshot_data)

    # Get data frames
    dfs <- get_populations_dfs(snapshot)

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("characteristics", "parameters"))
    expect_s3_class(dfs$characteristics, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Snapshot the outputs
    expect_snapshot(dfs)
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

    # Check that data frames are empty but have correct structure
    expect_equal(nrow(dfs$characteristics), 0)
    expect_equal(nrow(dfs$parameters), 0)

    # Check column names
    expect_true("individual_name" %in% names(dfs$characteristics))
    expect_true("parameter_type" %in% names(dfs$parameters))

    # Snapshot the outputs
    expect_snapshot(dfs)
})
