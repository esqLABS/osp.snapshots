test_that("to_raw_r6_or_list returns $data for R6 entries", {
  item <- SchemaItem$new(list(Name = "Item 1", ApplicationType = "Oral"))
  result <- to_raw_r6_or_list(list(item), "SchemaItem", "items")
  expect_equal(result, list(item$data))
})

test_that("to_raw_r6_or_list returns raw lists as-is", {
  raw <- list(Name = "Item 1", ApplicationType = "Oral")
  result <- to_raw_r6_or_list(list(raw), "SchemaItem", "items")
  expect_equal(result, list(raw))
})

test_that("to_raw_r6_or_list mixes R6 and raw entries", {
  item <- SchemaItem$new(list(Name = "Item 1", ApplicationType = "Oral"))
  raw <- list(Name = "Item 2", ApplicationType = "Oral")
  result <- to_raw_r6_or_list(list(item, raw), "SchemaItem", "items")
  expect_equal(result, list(item$data, raw))
})

test_that("to_raw_r6_or_list drops outer names", {
  raw <- list(Name = "Item 1", ApplicationType = "Oral")
  result <- to_raw_r6_or_list(list(a = raw), "SchemaItem", "items")
  expect_null(names(result))
})

test_that("to_raw_r6_or_list rejects non-R6 non-list entries", {
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list(list("not valid"), "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list rejects a bare R6 as the outer collection", {
  item <- SchemaItem$new(list(Name = "Item 1", ApplicationType = "Oral"))
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list(item, "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list rejects a non-list outer collection", {
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list("not a list", "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list rejects a wrong-class R6 entry", {
  compound <- Compound$new(list(Name = "Aspirin"))
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list(list(compound), "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list returns an empty list for empty input", {
  result <- to_raw_r6_or_list(list(), "SchemaItem", "items")
  expect_equal(result, list())
})

test_that("build_expression_containers maps name and value rows", {
  result <- build_expression_containers(
    data.frame(name = c("Liver", "Kidney"), value = c(1, 0.5))
  )
  expect_null(names(result))
  expect_equal(
    result,
    list(
      list(Name = "Liver", Value = 1),
      list(Name = "Kidney", Value = 0.5)
    )
  )
})

test_that("build_expression_containers maps transporter rows without value", {
  result <- build_expression_containers(
    data.frame(
      name = "Liver",
      compartment = "Intracellular",
      transport_direction = "EffluxIntracellularToInterstitial"
    )
  )
  expect_equal(
    result,
    list(list(
      Name = "Liver",
      CompartmentName = "Intracellular",
      TransportDirection = "EffluxIntracellularToInterstitial"
    ))
  )
})

test_that("build_expression_containers preserves order and duplicate names", {
  result <- build_expression_containers(
    data.frame(
      name = c("Kidney", "Kidney"),
      transport_direction = c("Efflux", "Influx")
    )
  )
  expect_length(result, 2)
  expect_equal(result[[1]]$TransportDirection, "Efflux")
  expect_equal(result[[2]]$TransportDirection, "Influx")
})

test_that("build_expression_containers omits Value for NA rows", {
  result <- build_expression_containers(
    data.frame(name = c("Liver", "Kidney"), value = c(1, NA))
  )
  expect_equal(result[[1]], list(Name = "Liver", Value = 1))
  expect_equal(result[[2]], list(Name = "Kidney"))
})

test_that("build_expression_containers passes a raw list through unnamed", {
  raw <- list(a = list(Name = "Liver", Value = 1))
  result <- build_expression_containers(raw)
  expect_null(names(result))
  expect_equal(result, list(list(Name = "Liver", Value = 1)))
})

test_that("build_expression_containers treats empty input as unset", {
  expect_null(build_expression_containers(NULL))
  expect_null(build_expression_containers(data.frame(name = character(0))))
  expect_null(build_expression_containers(list()))
})

test_that("build_expression_containers validates its input", {
  expect_snapshot(error = TRUE, build_expression_containers("Liver"))
  expect_snapshot(
    error = TRUE,
    build_expression_containers(data.frame(value = 1))
  )
  expect_snapshot(
    error = TRUE,
    build_expression_containers(
      data.frame(name = c("Liver", NA), value = c(1, 2))
    )
  )
})

test_that("build_disease_state maps name and Name-keyed parameters", {
  result <- build_disease_state(
    list(
      name = "CKD",
      parameters = list(create_parameter(name = "p", value = 1))
    )
  )
  expect_equal(
    result,
    list(Name = "CKD", Parameters = list(list(Name = "p", Value = 1)))
  )
})

test_that("build_disease_state omits Parameters when none supplied", {
  result <- build_disease_state(list(name = "CKD"))
  expect_equal(result, list(Name = "CKD"))
  expect_false("Parameters" %in% names(result))
})

test_that("build_disease_state treats NULL as unset", {
  expect_null(build_disease_state(NULL))
})

test_that("build_disease_state validates a non-empty name", {
  expect_snapshot(error = TRUE, build_disease_state(list(parameters = list())))
})

test_that("build_disease_state rejects a non-list value", {
  expect_snapshot(error = TRUE, build_disease_state("CKD"))
})
