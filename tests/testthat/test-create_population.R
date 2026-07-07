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
    create_population(name = "P", number_of_individuals = NA_integer_)
  )
  expect_snapshot(
    error = TRUE,
    create_population(name = "P", number_of_individuals = 1.5)
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
      proportion_of_females = c(30, 70)
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
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      gestational_age_range = list(min = 25, max = 42, unit = "week(s)")
    )
  )
})

test_that("create_population stores description", {
  pop <- create_population(
    name = "P",
    number_of_individuals = 10,
    description = "A cohort"
  )
  expect_equal(pop$data$Description, "A cohort")

  pop_no_desc <- create_population(name = "P", number_of_individuals = 10)
  expect_null(pop_no_desc$data$Description)
})

test_that("create_population stores gestational age range", {
  pop <- create_population(
    name = "P",
    number_of_individuals = 10,
    gestational_age_range = range(25, 42, "week(s)")
  )
  expect_equal(
    pop$data$Settings$GestationalAge,
    list(Min = 25, Max = 42, Unit = "week(s)")
  )
  expect_s3_class(pop$gestational_age_range, "Range")
  expect_equal(pop$gestational_age_range$min, 25)
})

test_that("create_population stores disease state parameters", {
  pop <- create_population(
    name = "P",
    number_of_individuals = 10,
    disease_state_parameters = list(eGFR = range(60, 120, "ml/min/1.73m²"))
  )
  expect_length(pop$data$Settings$DiseaseStateParameters, 1)
  expect_equal(
    pop$data$Settings$DiseaseStateParameters[[1]],
    list(Name = "eGFR", Min = 60, Max = 120, Unit = "ml/min/1.73m²")
  )
})

test_that("create_population validates disease state parameters", {
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      disease_state_parameters = "not a list"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      disease_state_parameters = list(eGFR = list(min = 60, max = 120))
    )
  )
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      disease_state_parameters = list(range(60, 120, "ml/min/1.73m²"))
    )
  )
})

test_that("create_population carries a composed base individual verbatim", {
  ind <- create_individual(
    name = "Base",
    species = "Human",
    population = "European_ICRP_2002",
    gender = "MALE",
    age = 40,
    seed = 99
  )
  pop <- create_population(
    name = "P",
    number_of_individuals = 10,
    individual = ind
  )
  expect_equal(pop$data$Settings$Individual, ind$data)
})

test_that("create_population rejects individual combined with legacy args", {
  ind <- create_individual(species = "Human")
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      individual = ind,
      species = "Human"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      individual = ind,
      individual_name = "Base",
      source_population = "European_ICRP_2002"
    )
  )
})

test_that("create_population rejects a non-Individual individual", {
  expect_snapshot(
    error = TRUE,
    create_population(
      name = "P",
      number_of_individuals = 10,
      individual = list(Name = "Base")
    )
  )
})

test_that("create_population rejects NA name", {
  expect_snapshot(
    error = TRUE,
    create_population(name = NA_character_, number_of_individuals = 10)
  )
})
