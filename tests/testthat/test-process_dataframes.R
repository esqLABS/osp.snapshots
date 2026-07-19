# Compound process df builders: empty-Parameters handling -----------------

test_that("legacy df builder omits a process with an empty Parameters list", {
  # PK-Sim can export a process with `"Parameters": []` (e.g. the
  # `GlomerularFiltration` renal-clearance process). It must not crash the
  # legacy `Compound$to_df()` path, and the parameterless process yields no
  # rows.
  raw_processes <- list(
    list(
      InternalName = "GlomerularFiltration",
      DataSource = "Publication",
      Parameters = list()
    )
  )

  df <- compound_processes_to_legacy_df("Fluvoxamine", raw_processes)

  expect_s3_class(df, "tbl_df")
  expect_equal(nrow(df), 0)
})

test_that("legacy df builder returns the typed empty schema when every process is parameterless", {
  # When a compound's only processes are parameterless, the builder must
  # return the full 8-column typed empty tibble, not a bare 0x0 tibble
  # that has lost the column schema.
  raw_processes <- list(
    list(
      InternalName = "GlomerularFiltration",
      DataSource = "Publication",
      Parameters = list()
    )
  )

  df <- compound_processes_to_legacy_df("Fluvoxamine", raw_processes)

  expect_identical(df, empty_compound_processes_legacy_tibble())
  expect_named(
    df,
    c(
      "compound",
      "category",
      "type",
      "parameter",
      "value",
      "unit",
      "data_source",
      "source"
    )
  )
  expect_equal(nrow(df), 0)
})

test_that("legacy_entry_to_df returns the typed empty schema for a parameterless entry", {
  # An entry that carries only metadata keys (a parameterless process) must
  # yield the typed 8-column empty tibble rather than a zero-column one.
  entry <- list(
    Process = "GlomerularFiltration",
    DataSource = "Publication"
  )

  df <- legacy_entry_to_df(
    "Fluvoxamine",
    "renal_clearance",
    "Publication",
    entry
  )

  expect_identical(df, empty_compound_processes_legacy_tibble())
  expect_named(
    df,
    c(
      "compound",
      "category",
      "type",
      "parameter",
      "value",
      "unit",
      "data_source",
      "source"
    )
  )
  expect_equal(nrow(df), 0)
})

test_that("long-form df builder omits a process with an empty Parameters list", {
  raw_processes <- list(
    list(
      InternalName = "GlomerularFiltration",
      DataSource = "Publication",
      Parameters = list()
    )
  )

  df <- compound_processes_to_long_df("Fluvoxamine", raw_processes)

  expect_s3_class(df, "tbl_df")
  expect_equal(nrow(df), 0)
})

test_that("a parameterless process does not drop rows from its neighbours", {
  # A parameterless process mixed alongside a real one keeps the real
  # process's rows intact.
  raw_processes <- list(
    list(
      InternalName = "GlomerularFiltration",
      DataSource = "Publication",
      Parameters = list()
    ),
    list(
      InternalName = "MetabolizationSpecific_MM",
      DataSource = "Optimized",
      Molecule = "CYP3A4",
      Metabolite = "OH-Drug",
      Parameters = list(list(Name = "Km", Value = 1.2, Unit = "µmol/l"))
    )
  )

  legacy <- compound_processes_to_legacy_df("Fluvoxamine", raw_processes)
  long <- compound_processes_to_long_df("Fluvoxamine", raw_processes)

  expect_equal(nrow(legacy), 1)
  expect_equal(unname(legacy$category), "metabolizing_enzymes")
  expect_equal(nrow(long), 1)
  expect_equal(unname(long$process_name), "MetabolizationSpecific_MM")
})
