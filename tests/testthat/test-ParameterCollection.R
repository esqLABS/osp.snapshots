test_that("ParameterCollection can be initialized", {
    # Test empty initialization
    collection <- ParameterCollection$new()
    expect_null(collection$parameters)

    # Test initialization with parameters
    test_params <- list(
        list(
            Path = "param_1",
            Value = 10,
            Unit = "mg"
        ),
        list(
            Path = "param_2",
            Value = 20,
            Unit = "ml"
        )
    )

    collection <- ParameterCollection$new(parameters = test_params)
    expect_length(collection$parameters, 2)
    expect_equal(collection$parameters$param_1$value, 10)
    expect_equal(collection$parameters$param_2$value, 20)
})

test_that("ParameterCollection methods work correctly", {
    collection <- ParameterCollection$new()

    # Test add_parameter
    param <- Parameter$new(list(Path = "test_param", Value = 10, Unit = "mg"))
    collection$add_parameter(param)
    expect_equal(collection$parameters$test_param$value, 10)

    # Test get_parameter
    retrieved_param <- collection$get_parameter("test_param")
    expect_equal(retrieved_param$value, 10)
    expect_equal(retrieved_param$unit, "mg")

    # Test set_parameter
    new_param <- Parameter$new(list(
        Path = "test_param",
        Value = 20,
        Unit = "g"
    ))
    collection$set_parameter("test_param", new_param)
    expect_equal(collection$parameters$test_param$value, 20)
    expect_equal(collection$parameters$test_param$unit, "g")

    # Test non-existent parameter
    expect_null(collection$get_parameter("non_existent"))
})
