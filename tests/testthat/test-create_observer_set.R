test_that("create_observer_set creates an empty ObserverSet", {
  observer_set <- create_observer_set(name = "BrainPlasmaConcentration")

  expect_s3_class(observer_set, "ObserverSet")
  expect_equal(observer_set$name, "BrainPlasmaConcentration")
  expect_length(observer_set$observers, 0)
})

test_that("create_observer_set accepts raw observer lists", {
  observer_set <- create_observer_set(
    name = "BrainPlasmaConcentration",
    observers = list(
      list(
        Name = "brain_plasma_conc",
        Type = "Container",
        Dimension = "Concentration (molar)",
        Formula = list(Formula = "Conc_Br")
      )
    )
  )

  expect_length(observer_set$observers, 1)
  expect_s3_class(observer_set$observers[[1]], "Observer")
  expect_equal(observer_set$observers[[1]]$name, "brain_plasma_conc")
  expect_equal(observer_set$observers[[1]]$type, "Container")
  expect_equal(observer_set$data$Observers[[1]]$Name, "brain_plasma_conc")
})

test_that("create_observer_set accepts Observer R6 objects", {
  observer <- Observer$new(list(
    Name = "brain_plasma_conc",
    Type = "Container",
    Dimension = "Concentration (molar)",
    Formula = list(Formula = "Conc_Br")
  ))

  observer_set <- create_observer_set(
    name = "BrainPlasmaConcentration",
    observers = list(observer)
  )

  expect_length(observer_set$observers, 1)
  expect_s3_class(observer_set$observers[[1]], "Observer")
  expect_equal(observer_set$observers[[1]]$name, "brain_plasma_conc")
  expect_equal(observer_set$data$Observers[[1]]$Formula$Formula, "Conc_Br")
})

test_that("create_observer_set round-trips through ObserverSet$data", {
  raw <- list(
    Name = "Set",
    Observers = list(
      list(
        Name = "obs1",
        Type = "Container",
        Dimension = "Concentration (molar)",
        Formula = list(Formula = "Conc_Br")
      )
    )
  )

  observer_set <- create_observer_set(
    name = raw$Name,
    observers = raw$Observers
  )

  expect_equal(observer_set$data, raw)
})

test_that("create_observer_set validates required arguments", {
  expect_snapshot(error = TRUE, create_observer_set())
  expect_snapshot(error = TRUE, create_observer_set(name = ""))
  expect_snapshot(
    error = TRUE,
    create_observer_set(name = "S", observers = "nope")
  )
  expect_snapshot(
    error = TRUE,
    create_observer_set(name = "S", observers = list(42))
  )
})

test_that("create_observer_set rejects a bare Observer R6 as `observers`", {
  observer <- Observer$new(list(
    Name = "brain_plasma_conc",
    Type = "Container",
    Dimension = "Concentration (molar)",
    Formula = list(Formula = "Conc_Br")
  ))

  expect_snapshot(
    error = TRUE,
    create_observer_set(name = "S", observers = observer)
  )
})

test_that("create_observer_set rejects non-Observer R6 entries", {
  compound <- Compound$new(list(Name = "Aspirin"))

  expect_snapshot(
    error = TRUE,
    create_observer_set(name = "S", observers = list(compound))
  )
})
