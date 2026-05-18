test_that("OriginData constructs from a raw snapshot list", {
  raw <- list(
    Species = "Human",
    Population = "European_ICRP_2002",
    Gender = "MALE",
    Age = list(Value = 30, Unit = "year(s)"),
    Weight = list(Value = 70, Unit = "kg"),
    Height = list(Value = 175, Unit = "cm"),
    CalculationMethods = c("Mosteller", "DuBois")
  )
  od <- OriginData$new(raw)
  expect_r6_class(od, "OriginData")
  expect_equal(od$species, "Human")
  expect_equal(od$population, "European_ICRP_2002")
  expect_equal(od$gender, "MALE")
  expect_equal(od$age, 30)
  expect_equal(od$age_unit, "year(s)")
  expect_equal(od$weight, 70)
  expect_equal(od$height, 175)
  expect_r6_class(od$calculation_methods, "CalculationMethodCache")
  expect_equal(od$calculation_methods$methods, c("Mosteller", "DuBois"))
})

test_that("OriginData handles NULL and empty input", {
  expect_no_error(OriginData$new())
  expect_no_error(OriginData$new(NULL))
  expect_no_error(OriginData$new(list()))
  od <- OriginData$new()
  expect_null(od$species)
  expect_null(od$age)
  expect_equal(od$calculation_methods$length, 0L)
})

test_that("OriginData active bindings mutate the underlying data", {
  od <- OriginData$new(list(
    Species = "Human",
    Age = list(Value = 30, Unit = "year(s)")
  ))
  od$species <- "Dog"
  od$age <- 5
  expect_equal(od$species, "Dog")
  expect_equal(od$age, 5)
  expect_equal(od$data$Species, "Dog")
  expect_equal(od$data$Age$Value, 5)
})

test_that("OriginData$data refreshes CalculationMethods from the cache", {
  od <- OriginData$new(list(
    CalculationMethods = c("A", "B"),
    Species = "Human"
  ))
  od$calculation_methods$add("C")
  expect_equal(
    unlist(od$data$CalculationMethods),
    c("A", "B", "C")
  )
})

test_that("OriginData$data drops CalculationMethods when the cache is empty", {
  od <- OriginData$new(list(
    CalculationMethods = c("A"),
    Species = "Human"
  ))
  od$calculation_methods$remove("A")
  expect_null(od$data$CalculationMethods)
})

test_that("OriginData accepts a CalculationMethodCache or a vector", {
  od <- OriginData$new()
  od$calculation_methods <- c("X", "Y")
  expect_equal(od$calculation_methods$methods, c("X", "Y"))
  od$calculation_methods <- CalculationMethodCache$new("Z")
  expect_equal(od$calculation_methods$methods, "Z")
})

test_that("OriginData prints a summary", {
  od <- OriginData$new(list(
    Species = "Human",
    Population = "European_ICRP_2002",
    Gender = "FEMALE",
    Age = list(Value = 28, Unit = "year(s)"),
    Weight = list(Value = 60, Unit = "kg"),
    CalculationMethods = c("Mosteller")
  ))
  expect_snapshot(od)
})
