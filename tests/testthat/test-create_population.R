test_that("create_population creates a minimal Population", {
  pop <- create_population(name = "Adults", number_of_individuals = 100)

  expect_s3_class(pop, "Population")
  expect_equal(pop$name, "Adults")
  expect_equal(pop$number_of_individuals, 100)
  expect_equal(pop$proportion_of_females, 50)
})

test_that("create_population stores ranges and base individual info", {
  pop <- create_population(
    name = "Healthy Adults",
    number_of_individuals = 50,
    proportion_of_females = 40,
    species = "Human",
    source_population = "European_ICRP_2002",
    individual_name = "Base Individual",
    age_range = range(20, 60, "year(s)"),
    weight_range = range(50, 90, "kg"),
    seed = 12345
  )

  expect_equal(pop$proportion_of_females, 40)
  expect_equal(pop$seed, 12345)
  expect_equal(pop$source_population, "European_ICRP_2002")
  expect_equal(pop$individual_name, "Base Individual")
  expect_equal(pop$age_range$min, 20)
  expect_equal(pop$age_range$max, 60)
  expect_equal(pop$age_range$unit, "year(s)")
  expect_equal(pop$weight_range$unit, "kg")
})

test_that("create_population validates required arguments", {
  expect_snapshot(error = TRUE, create_population())
  expect_snapshot(error = TRUE, create_population(name = "P"))
  expect_snapshot(
    error = TRUE,
    create_population(name = "P", number_of_individuals = 0)
  )
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      proportion_of_females = 150
    )
  )
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      age_range = list(min = 20, max = 60, unit = "year(s)")
    )
  )
})
