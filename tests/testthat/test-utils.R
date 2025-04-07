test_that("validate_unit accepts valid units", {
    # Test valid units for different dimensions
    expect_true(validate_unit("year(s)", "Age in years"))
    expect_true(validate_unit("kg", "Mass"))
    expect_true(validate_unit("cm", "Length"))
})

test_that("validate_unit rejects invalid units", {
    # Test invalid units for different dimensions
    expect_error(
        validate_unit("invalid_unit", "Age in years"),
        "Invalid unit: invalid_unit"
    )
    expect_error(
        validate_unit("invalid_unit", "Mass"),
        "Invalid unit: invalid_unit"
    )
    expect_error(
        validate_unit("invalid_unit", "Length"),
        "Invalid unit: invalid_unit"
    )
})

test_that("validate_unit handles invalid dimensions", {
    expect_error(
        validate_unit("kg", "InvalidDimension"),
        "NULL"
    )
})
