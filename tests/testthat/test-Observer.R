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
  expect_equal(observer$formula, list(Formula = "Conc_Br"))
  expect_equal(observer$formula_expression, "Conc_Br")
  expect_equal(observer$container_tags, "Brain")
  expect_equal(observer$data, data)
})

test_that("Observer handles empty and NULL data", {
  empty <- Observer$new(list())
  expect_null(empty$name)
  expect_null(empty$type)
  expect_null(empty$dimension)
  expect_null(empty$formula)
  expect_null(empty$formula_expression)
  expect_null(empty$formula_dimension)
  expect_null(empty$formula_references)
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

test_that("Observer type setter validates against Amount/Container", {
  observer <- Observer$new(list(Name = "x"))
  expect_snapshot(observer$type <- "Bogus", error = TRUE)
})

test_that("Observer type is NULL for an empty observer", {
  expect_null(Observer$new(list())$type)
})

test_that("Observer dimension setter round-trips through data", {
  observer <- Observer$new(list(Name = "x"))

  observer$dimension <- "Time"

  expect_equal(observer$dimension, "Time")
  expect_equal(observer$data$Dimension, "Time")
})

test_that("Observer formula returns the full ExplicitFormula list", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(
      Name = "f",
      Formula = "Conc",
      Dimension = "D",
      References = list(list(Alias = "Conc", Path = "p", Dimension = "D"))
    )
  ))

  expect_equal(
    observer$formula,
    list(
      Name = "f",
      Formula = "Conc",
      Dimension = "D",
      References = list(list(Alias = "Conc", Path = "p", Dimension = "D"))
    )
  )
})

test_that("Observer formula setter replaces the whole structure", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(Name = "old", Formula = "Conc", Dimension = "D")
  ))

  observer$formula <- list(Name = "new", Formula = "2*Conc")

  expect_equal(observer$data$Formula, list(Name = "new", Formula = "2*Conc"))
})

test_that("Observer formula setter accepts NULL to drop the formula", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(Formula = "Conc")
  ))

  observer$formula <- NULL

  expect_null(observer$formula)
  expect_null(observer$data$Formula)
})

test_that("Observer formula_expression setter writes into nested Formula", {
  observer <- Observer$new(list(Name = "x"))

  observer$formula_expression <- "2*Conc"

  expect_equal(observer$formula_expression, "2*Conc")
  expect_equal(observer$data$Formula$Formula, "2*Conc")
})

test_that("Observer formula_expression setter preserves sibling fields", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(Name = "f", Formula = "Conc", Dimension = "D")
  ))

  observer$formula_expression <- "2*Conc"

  expect_equal(observer$data$Formula$Formula, "2*Conc")
  expect_equal(observer$data$Formula$Name, "f")
  expect_equal(observer$data$Formula$Dimension, "D")
})

test_that("Observer formula_dimension round-trips through nested Formula", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(Formula = "Conc", Dimension = "Concentration (molar)")
  ))

  expect_equal(observer$formula_dimension, "Concentration (molar)")

  observer$formula_dimension <- "Time"

  expect_equal(observer$formula_dimension, "Time")
  expect_equal(observer$data$Formula$Dimension, "Time")
  expect_equal(observer$data$Formula$Formula, "Conc")
})

test_that("Observer formula_references reads References from Formula", {
  refs <- list(
    list(Alias = "Conc_Br", Path = "Brain|Conc", Dimension = "C"),
    list(Alias = "Vol_Br", Path = "Brain|Vol", Dimension = "V")
  )
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(Formula = "Conc_Br/Vol_Br", References = refs)
  ))

  expect_equal(observer$formula_references, refs)
})

test_that("Observer formula_references is NULL when no formula present", {
  observer <- Observer$new(list(Name = "x"))
  expect_null(observer$formula_references)
})

test_that("Observer formula_references setter preserves sibling fields", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(Name = "f", Formula = "Conc", Dimension = "D")
  ))

  observer$formula_references <- list(create_formula_reference("a", "p"))

  expect_equal(
    observer$data$Formula$References,
    list(list(Alias = "a", Path = "p"))
  )
  expect_equal(observer$data$Formula$Name, "f")
  expect_equal(observer$data$Formula$Formula, "Conc")
  expect_equal(observer$data$Formula$Dimension, "D")
})

test_that("Observer formula_references creates Formula when absent", {
  observer <- Observer$new(list(Name = "x"))

  observer$formula_references <- list(create_formula_reference("a", "p"))

  expect_equal(
    observer$data$Formula$References,
    list(list(Alias = "a", Path = "p"))
  )
})

test_that("Observer formula_references NULL removes only References", {
  observer <- Observer$new(list(
    Name = "x",
    Formula = list(
      Formula = "Conc",
      References = list(list(Alias = "a", Path = "p"))
    )
  ))

  observer$formula_references <- NULL

  expect_null(observer$data$Formula$References)
  expect_equal(observer$data$Formula$Formula, "Conc")
})

test_that("Observer formula_references setter aborts on non-list input", {
  observer <- Observer$new(list(Name = "x"))
  expect_snapshot(observer$formula_references <- "x", error = TRUE)
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

test_that("Observer container_criteria getter preserves Type verbatim", {
  criteria <- list(list(Tag = "Brain", Type = "MatchTag"))
  observer <- Observer$new(list(Name = "x", ContainerCriteria = criteria))

  expect_equal(observer$container_criteria, criteria)
  expect_equal(observer$container_tags, "Brain")
})

test_that("Observer container_criteria setter writes and removes", {
  observer <- Observer$new(list(Name = "x"))

  observer$container_criteria <- list(
    create_descriptor_condition("Liver", "NotInContainer")
  )
  expect_equal(
    observer$data$ContainerCriteria,
    list(list(Tag = "Liver", Type = "NotInContainer"))
  )

  observer$container_criteria <- NULL
  expect_null(observer$data$ContainerCriteria)
})

test_that("Observer container_criteria setter aborts on non-list input", {
  observer <- Observer$new(list(Name = "x"))
  expect_snapshot(observer$container_criteria <- "x", error = TRUE)
})

test_that("Observer molecule_list getter, setter, and removal work", {
  observer <- Observer$new(list(Name = "x"))

  molecule_list <- create_molecule_list(for_all = FALSE, include = "Drug")
  observer$molecule_list <- molecule_list

  expect_equal(observer$data$MoleculeList, molecule_list)
  expect_equal(observer$molecule_list, molecule_list)

  observer$molecule_list <- NULL
  expect_null(observer$data$MoleculeList)
})

test_that("Observer molecule_list setter aborts on non-list input", {
  observer <- Observer$new(list(Name = "x"))
  expect_snapshot(observer$molecule_list <- "x", error = TRUE)
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
    Formula = list(
      Formula = "t",
      Dimension = "Time",
      References = list(list(Alias = "t", Path = "Time", Dimension = "Time"))
    ),
    ContainerCriteria = list(list(Tag = "Brain", Type = "MatchTag"))
  ))

  df <- observer$to_df()

  expect_s3_class(df, "tbl_df")
  expect_equal(nrow(df), 1)
  expect_named(
    df,
    c(
      "name",
      "type",
      "dimension",
      "formula_expression",
      "formula_dimension",
      "formula_references",
      "container_tags"
    )
  )
  expect_equal(df$name, "obs")
  expect_equal(df$type, "Amount")
  expect_equal(df$formula_expression, "t")
  expect_equal(df$formula_dimension, "Time")
  expect_equal(df$formula_references, "t=Time")
  expect_equal(df$container_tags, "Brain")
})

test_that("Observer to_df fills NA for missing fields", {
  observer <- Observer$new(list(Name = "obs"))

  df <- observer$to_df()

  expect_equal(df$name, "obs")
  expect_equal(df$type, NA_character_)
  expect_equal(df$dimension, NA_character_)
  expect_equal(df$formula_expression, NA_character_)
  expect_equal(df$formula_dimension, NA_character_)
  expect_equal(df$formula_references, NA_character_)
  expect_equal(df$container_tags, NA_character_)
})

test_that("Observer to_df joins multiple formula references", {
  observer <- Observer$new(list(
    Name = "obs",
    Formula = list(
      Formula = "a+b",
      References = list(
        list(Alias = "a", Path = "p1", Dimension = "D"),
        list(Alias = "b", Path = "p2", Dimension = "D")
      )
    )
  ))

  df <- observer$to_df()

  expect_equal(df$formula_references, "a=p1|b=p2")
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
