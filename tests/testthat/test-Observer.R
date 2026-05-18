test_that("Observer class initialization works", {
  data <- list(
    Name = "brain_plasma",
    Type = "Container",
    Dimension = "Concentration (molar)",
    Formula = list(Formula = "Conc_Br"),
    ContainerCriteria = list(list(Tag = "Brain", Type = "MatchTag"))
  )

  observer <- Observer$new(data)

  expect_s3_class(observer, "R6")
  expect_s3_class(observer, "Observer")
  expect_equal(observer$name, "brain_plasma")
  expect_equal(observer$type, "Container")
  expect_equal(observer$dimension, "Concentration (molar)")
  expect_equal(observer$formula, "Conc_Br")
  expect_equal(observer$container_tags, "Brain")
  expect_equal(observer$data, data)
})

test_that("Observer handles empty and NULL data", {
  empty <- Observer$new(list())
  expect_null(empty$name)
  expect_null(empty$type)
  expect_null(empty$dimension)
  expect_null(empty$formula)
  expect_null(empty$container_tags)

  null_data <- Observer$new(NULL)
  expect_null(null_data$name)
})

test_that("Observer name setter round-trips through data", {
  observer <- Observer$new(list(Name = "old"))

  observer$name <- "new"

  expect_equal(observer$name, "new")
  expect_equal(observer$data$Name, "new")
})

test_that("Observer type setter round-trips through data", {
  observer <- Observer$new(list(Name = "x"))

  observer$type <- "Amount"

  expect_equal(observer$type, "Amount")
  expect_equal(observer$data$Type, "Amount")
})

test_that("Observer dimension setter round-trips through data", {
  observer <- Observer$new(list(Name = "x"))

  observer$dimension <- "Time"

  expect_equal(observer$dimension, "Time")
  expect_equal(observer$data$Dimension, "Time")
})

test_that("Observer formula setter writes into nested Formula", {
  observer <- Observer$new(list(Name = "x"))

  observer$formula <- "2*Conc"

  expect_equal(observer$formula, "2*Conc")
  expect_equal(observer$data$Formula$Formula, "2*Conc")
})

test_that("Observer formula setter preserves existing Formula fields", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(Name = "f", Formula = "Conc", Dimension = "D")
  ))

  observer$formula <- "2*Conc"

  expect_equal(observer$data$Formula$Formula, "2*Conc")
  expect_equal(observer$data$Formula$Name, "f")
  expect_equal(observer$data$Formula$Dimension, "D")
})

test_that("Observer container_tags joins multiple tags", {
  observer <- Observer$new(list(
    Name = "x",
    ContainerCriteria = list(
      list(Tag = "Organism", Type = "MatchTag"),
      list(Tag = "Liver", Type = "MatchTag")
    )
  ))

  expect_equal(observer$container_tags, "Organism|Liver")
})

test_that("Observer container_tags is read-only", {
  observer <- Observer$new(list(Name = "x"))
  expect_snapshot(observer$container_tags <- "x", error = TRUE)
})

test_that("Observer data is read-only", {
  observer <- Observer$new(list(Name = "x"))
  expect_snapshot(observer$data <- list(), error = TRUE)
})

test_that("Observer to_df returns a single-row tibble", {
  observer <- Observer$new(list(
    Name = "obs",
    Type = "Amount",
    Dimension = "Time",
    Formula = list(Formula = "t"),
    ContainerCriteria = list(list(Tag = "Brain", Type = "MatchTag"))
  ))

  df <- observer$to_df()

  expect_s3_class(df, "tbl_df")
  expect_equal(nrow(df), 1)
  expect_named(
    df,
    c("name", "type", "dimension", "formula", "container_tags")
  )
  expect_equal(df$name, "obs")
  expect_equal(df$type, "Amount")
  expect_equal(df$container_tags, "Brain")
})

test_that("Observer to_df fills NA for missing fields", {
  observer <- Observer$new(list(Name = "obs"))

  df <- observer$to_df()

  expect_equal(df$name, "obs")
  expect_equal(df$type, NA_character_)
  expect_equal(df$dimension, NA_character_)
  expect_equal(df$formula, NA_character_)
  expect_equal(df$container_tags, NA_character_)
})

test_that("Observer round-trips raw data verbatim", {
  data <- list(
    Name = "obs",
    Type = "Container",
    Dimension = "Dimensionless",
    ContainerCriteria = list(list(Tag = "Brain", Type = "MatchTag")),
    Formula = list(
      Name = "test",
      Formula = "2*Conc_Br",
      References = list(list(
        Alias = "Conc_Br",
        Dimension = "Concentration (molar)",
        Path = "Organism|Brain|Plasma|Drug|Concentration"
      )),
      Dimension = "Dimensionless"
    ),
    MoleculeList = list(
      ForAll = FALSE,
      MoleculeNamesToInclude = list("Drug")
    )
  )

  observer <- Observer$new(data)

  expect_equal(observer$data, data)
})

test_that("print.Observer prints a summary", {
  observer <- Observer$new(list(
    Name = "brain_plasma",
    Type = "Container",
    Dimension = "Concentration (molar)",
    Formula = list(Formula = "Conc_Br"),
    ContainerCriteria = list(list(Tag = "Brain", Type = "MatchTag"))
  ))

  expect_snapshot(print(observer))
})
