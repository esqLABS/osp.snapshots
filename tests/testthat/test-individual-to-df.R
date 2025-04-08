test_that("to_df returns all tables by default", {
    # Create individual with all fields populated, adding more data from test_snapshot.json
    ind <- create_individual(
        name = "Mouly2002",
        species = "Human",
        population = "WhiteAmerican_NHANES_1997",
        gender = "MALE",
        age = 29.9,
        age_unit = "year(s)",
        weight = 70,
        weight_unit = "kg",
        height = 175,
        height_unit = "cm",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        disease_state = "Healthy",
        seed = 1300547185
    )

    # Add parameters with more complete data including ValueOrigin
    ind$parameters <- list(
        Parameter$new(list(
            Path = "Organism|Gallbladder|Gallbladder ejection fraction",
            Value = 0.8,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        )),
        Parameter$new(list(
            Path = "Organism|Liver|EHC continuous fraction",
            Value = 1.0,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        ))
    )

    # Add expression profiles from test_snapshot.json
    data <- ind$data
    data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind <- Individual$new(data)

    # Get all tables
    dfs <- ind$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))
    expect_s3_class(dfs$origin, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")
    expect_s3_class(dfs$expressions, "tbl_df")

    # Snapshot all tables
    expect_snapshot({
        print(dfs$origin, width = Inf)
        print(dfs$parameters, width = Inf)
        print(dfs$expressions, width = Inf)
    })
})

test_that("to_df returns specific tables when requested", {
    # Create individual with all data based on test_snapshot.json
    ind <- create_individual(
        name = "European",
        species = "Human",
        population = "European_ICRP_2002",
        gender = "MALE",
        age = 30.0,
        age_unit = "year(s)",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        seed = 186687441
    )

    # Add expression profiles
    data <- ind$data
    data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind <- Individual$new(data)

    # Test origin data
    origin_df <- ind$to_df("origin")
    expect_s3_class(origin_df, "tbl_df")
    expect_snapshot(print(origin_df, width = Inf))

    # Test parameters data
    params_df <- ind$to_df("parameters")
    expect_s3_class(params_df, "tbl_df")
    expect_snapshot(print(params_df, width = Inf))

    # Test expression profiles data
    expr_df <- ind$to_df("expressions")
    expect_s3_class(expr_df, "tbl_df")
    expect_snapshot(print(expr_df, width = Inf))
})

test_that("to_df handles missing values", {
    # Create minimal individual
    ind <- create_individual(name = "Minimal")

    # Get all tables
    dfs <- ind$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))

    # Snapshot all tables
    expect_snapshot({
        print(dfs$origin, width = Inf)
        print(dfs$parameters, width = Inf)
        print(dfs$expressions, width = Inf)
    })
})

test_that("to_df validates type argument", {
    ind <- create_individual("Test")
    expect_error(
        ind$to_df("invalid"),
        "type must be one of: all, origin, parameters, expressions"
    )
})

test_that("get_individuals_df returns combined data frames from all individuals", {
    # Create a test snapshot with minimal data structure
    snapshot_data <- list(Version = "80", Individuals = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Add first individual with parameters from test_snapshot.json
    ind1 <- create_individual(
        name = "Mouly2002",
        species = "Human",
        population = "WhiteAmerican_NHANES_1997",
        gender = "MALE",
        age = 29.9,
        age_unit = "year(s)",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        seed = 1300547185
    )

    ind1$parameters <- list(
        Parameter$new(list(
            Path = "Organism|Gallbladder|Gallbladder ejection fraction",
            Value = 0.8,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        )),
        Parameter$new(list(
            Path = "Organism|Liver|EHC continuous fraction",
            Value = 1.0,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        ))
    )

    # Add expression profiles to first individual
    ind1_data <- ind1$data
    ind1_data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind1 <- Individual$new(ind1_data)
    snapshot$add_individual(ind1)

    # Add second individual from test_snapshot.json
    ind2 <- create_individual(
        name = "European",
        species = "Human",
        population = "European_ICRP_2002",
        gender = "MALE",
        age = 30.0,
        age_unit = "year(s)",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        seed = 186687441
    )

    # Add expression profiles to second individual
    ind2_data <- ind2$data
    ind2_data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind2 <- Individual$new(ind2_data)
    snapshot$add_individual(ind2)

    # Get combined data frames
    dfs <- get_individuals_df(snapshot)

    # Verify structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))
    expect_s3_class(dfs$origin, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")
    expect_s3_class(dfs$expressions, "tbl_df")

    # Check number of rows
    expect_equal(nrow(dfs$origin), 2)
    expect_equal(nrow(dfs$parameters), 2)
    expect_equal(nrow(dfs$expressions), 4)

    # Test snapshot for all data frames
    expect_snapshot({
        print(dfs$origin, width = Inf)
        print(dfs$parameters, width = Inf)
        print(dfs$expressions, width = Inf)
    })
})

test_that("get_individuals_df handles empty snapshot", {
    # Create empty snapshot
    snapshot_data <- list(Version = "80", Individuals = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Get data frames
    dfs <- get_individuals_df(snapshot)

    # Verify structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))

    # Check that all data frames are empty but have correct structure
    expect_equal(nrow(dfs$origin), 0)
    expect_equal(nrow(dfs$parameters), 0)
    expect_equal(nrow(dfs$expressions), 0)

    # Snapshot empty data frames
    expect_snapshot({
        print(dfs$origin, width = Inf)
        print(dfs$parameters, width = Inf)
        print(dfs$expressions, width = Inf)
    })
})

test_that("get_origin_df returns only origin data", {
    # Create a test snapshot with an individual
    snapshot_data <- list(Version = "80", Individuals = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Create a more complete individual based on test_snapshot.json
    ind <- create_individual(
        name = "Mouly2002",
        species = "Human",
        population = "WhiteAmerican_NHANES_1997",
        gender = "MALE",
        age = 29.9,
        age_unit = "year(s)",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        seed = 1300547185
    )

    snapshot$add_individual(ind)

    # Get origin data
    origin_df <- get_origin_df(snapshot)

    # Verify result
    expect_s3_class(origin_df, "tbl_df")
    expect_equal(nrow(origin_df), 1)

    # Use snapshot to verify content
    expect_snapshot({
        print(origin_df, width = Inf)
    })
})

test_that("get_parameters_df returns only parameter data", {
    # Create a test snapshot with an individual that has parameters
    snapshot_data <- list(Version = "80", Individuals = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Create individual with test_snapshot.json parameters
    ind <- create_individual(name = "Mouly2002")
    ind$parameters <- list(
        Parameter$new(list(
            Path = "Organism|Gallbladder|Gallbladder ejection fraction",
            Value = 0.8,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        ))
    )
    snapshot$add_individual(ind)

    # Get parameter data
    param_df <- get_parameters_df(snapshot)

    # Verify result
    expect_s3_class(param_df, "tbl_df")
    expect_equal(nrow(param_df), 1)

    # Use snapshot to verify content
    expect_snapshot({
        print(param_df, width = Inf)
    })
})

test_that("get_expressions_df returns only expression data", {
    # Create a test snapshot with an individual that has expression profiles
    snapshot_data <- list(Version = "80", Individuals = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Add expression profiles from test_snapshot.json
    ind_data <- list(
        Name = "Mouly2002",
        OriginData = list(),
        ExpressionProfiles = c(
            "CYP1A2|Human|Healthy",
            "CYP2B6|Human|Healthy"
        )
    )
    ind <- Individual$new(ind_data)
    snapshot$add_individual(ind)

    # Get expression data
    expr_df <- get_expressions_df(snapshot)

    # Verify result
    expect_s3_class(expr_df, "tbl_df")
    expect_equal(nrow(expr_df), 2)

    # Use snapshot to verify content
    expect_snapshot({
        print(expr_df, width = Inf)
    })
})
