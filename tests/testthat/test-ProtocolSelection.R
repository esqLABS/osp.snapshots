test_that("ProtocolSelection wraps name and Formulations", {
  raw <- list(
    Name = "Protocol-A",
    Formulations = list(
      list(Name = "Oral solution", Key = "Formulation")
    )
  )
  sel <- ProtocolSelection$new(raw)

  expect_s3_class(sel, "ProtocolSelection")
  expect_equal(sel$name, "Protocol-A")
  expect_length(sel$formulations, 1)
  expect_s3_class(sel$formulations[[1]], "FormulationSelection")
})

test_that("ProtocolSelection$data round-trips raw input", {
  raw <- list(
    Name = "Protocol-A",
    Formulations = list(
      list(Name = "Oral solution", Key = "Formulation")
    )
  )
  sel <- ProtocolSelection$new(raw)
  expect_identical(sel$data, raw)
})

test_that("ProtocolSelection reflects formulation mutations in $data", {
  sel <- ProtocolSelection$new(list(
    Name = "Protocol-A",
    Formulations = list(
      list(Name = "Oral solution", Key = "Formulation")
    )
  ))
  sel$formulations[[1]]$name <- "Tablet"
  expect_equal(sel$data$Formulations[[1]]$Name, "Tablet")
})

test_that("ProtocolSelection without Formulations works", {
  sel <- ProtocolSelection$new(list(Name = "Protocol-A"))
  expect_length(sel$formulations, 0)
  expect_identical(sel$data, list(Name = "Protocol-A"))
})
