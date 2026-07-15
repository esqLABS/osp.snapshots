test_that("create_compound creates a minimal Compound", {
  compound <- create_compound(name = "Drug X")

  expect_s3_class(compound, "Compound")
  expect_equal(compound$name, "Drug X")
  expect_equal(compound$data$Name, "Drug X")
})

test_that("create_compound stores common fields on the Compound", {
  compound <- create_compound(
    name = "Drug X",
    is_small_molecule = TRUE,
    plasma_protein_binding_partner = "Albumin",
    molecular_weight = 250.3,
    calculation_methods = c("Partition coefficient - Schmitt"),
    description = "Test compound"
  )

  expect_equal(compound$is_small_molecule, TRUE)
  expect_equal(compound$plasma_protein_binding_partner, "Albumin")
  expect_equal(compound$molecular_weight, 250.3)
  expect_equal(compound$molecular_weight_unit, "g/mol")
  expect_equal(compound$data$Description, "Test compound")
  expect_equal(
    compound$data$CalculationMethods,
    list("Partition coefficient - Schmitt")
  )
})

test_that("create_compound accepts Parameter objects in parameters", {
  param <- create_parameter(name = "Cl_spec", value = 5, unit = "ml/min/kg")
  compound <- create_compound(name = "Drug X", parameters = list(param))

  expect_length(compound$parameters, 1)
  expect_equal(compound$parameters[[1]]$Name, "Cl_spec")
  expect_equal(compound$parameters[[1]]$Value, 5)
})

test_that("create_compound validates required arguments", {
  expect_snapshot(error = TRUE, create_compound())
  expect_snapshot(error = TRUE, create_compound(name = ""))
  expect_snapshot(
    error = TRUE,
    create_compound(name = "Drug", is_small_molecule = "yes")
  )
  expect_snapshot(
    error = TRUE,
    create_compound(name = "Drug", molecular_weight = "heavy")
  )
  expect_snapshot(
    error = TRUE,
    create_compound(name = "Drug", parameters = "not a list")
  )
  expect_snapshot(
    error = TRUE,
    create_compound(
      name = "Drug",
      molecular_weight = 250,
      molecular_weight_unit = "not-a-unit"
    )
  )
})


# Physicochemical property arguments -------------------------------------

test_that("create_compound sets a lipophilicity alternative", {
  compound <- create_compound(name = "X", lipophilicity = lipophilicity(2.5))

  alt <- compound$data$Lipophilicity
  expect_length(alt, 1)
  expect_equal(alt[[1]]$Name, "User defined")
  expect_equal(alt[[1]]$IsDefault, TRUE)
  expect_equal(alt[[1]]$Parameters[[1]]$Name, "Lipophilicity")
  expect_equal(alt[[1]]$Parameters[[1]]$Value, 2.5)
  expect_equal(alt[[1]]$Parameters[[1]]$Unit, "Log Units")
  expect_s3_class(compound$lipophilicity, "physicochemical_property")
})

test_that("create_compound sets a fraction unbound alternative without a unit", {
  compound <- create_compound(
    name = "X",
    fraction_unbound = fraction_unbound(1)
  )

  alt <- compound$data$FractionUnbound[[1]]
  param <- alt$Parameters[[1]]
  expect_equal(param$Name, "Fraction unbound (plasma, reference value)")
  expect_equal(param$Value, 1)
  expect_null(param$Unit)
  expect_equal(alt$Species, "Human")
})

test_that("fraction_unbound species defaults to Human and can be overridden", {
  compound <- create_compound(
    name = "X",
    fraction_unbound = fraction_unbound(1, species = "Rat")
  )
  expect_equal(compound$data$FractionUnbound[[1]]$Species, "Rat")
})

test_that("create_compound bundles reference pH and gain per charge into solubility", {
  compound <- create_compound(
    name = "X",
    solubility = solubility(9999, reference_pH = 7, gain_per_charge = 1000)
  )

  params <- compound$data$Solubility[[1]]$Parameters
  expect_length(params, 3)
  expect_equal(params[[1]]$Name, "Solubility at reference pH")
  expect_equal(params[[1]]$Value, 9999)
  expect_equal(params[[1]]$Unit, "mg/l")
  expect_equal(params[[2]]$Name, "Reference pH")
  expect_equal(params[[2]]$Value, 7)
  expect_equal(params[[3]]$Name, "Solubility gain per charge")
  expect_equal(params[[3]]$Value, 1000)
})

test_that("create_compound omits reference pH and gain per charge when not supplied", {
  compound <- create_compound(name = "X", solubility = solubility(9999))

  params <- compound$data$Solubility[[1]]$Parameters
  expect_length(params, 1)
  expect_equal(params[[1]]$Name, "Solubility at reference pH")
})

test_that("create_compound builds a table solubility alternative", {
  compound <- create_compound(
    name = "X",
    solubility = solubility(
      table = data.frame(
        pH = c(3, 6, 6.8),
        value = c(5000, 3000, 90)
      )
    )
  )

  param <- compound$data$Solubility[[1]]$Parameters[[1]]
  expect_equal(param$Name, "Solubility table")
  expect_equal(param$Value, 5000)
  expect_equal(param$Unit, "mg/l")

  formula <- param$TableFormula
  expect_equal(formula$XDimension, "Dimensionless")
  expect_equal(formula$YDimension, "Concentration (mass)")
  expect_equal(formula$YUnit, "mg/l")
  expect_equal(formula$UseDerivedValues, FALSE)
  expect_length(formula$Points, 3)
  expect_equal(
    formula$Points[[1]],
    list(X = 3, Y = 5000, RestartSolver = FALSE)
  )
  expect_equal(
    formula$Points[[2]],
    list(X = 6, Y = 3000, RestartSolver = FALSE)
  )
  expect_equal(
    formula$Points[[3]],
    list(X = 6.8, Y = 90, RestartSolver = FALSE)
  )
})

test_that("solubility() rejects both scalar and table forms", {
  expect_snapshot(
    error = TRUE,
    solubility(1, table = data.frame(pH = 3, value = 5000))
  )
})

test_that("create_compound sets an intestinal permeability alternative", {
  compound <- create_compound(
    name = "X",
    intestinal_permeability = intestinal_permeability(1.14e-05)
  )

  param <- compound$data$IntestinalPermeability[[1]]$Parameters[[1]]
  expect_equal(param$Name, "Specific intestinal permeability (transcellular)")
  expect_equal(param$Value, 1.14e-05)
  expect_equal(param$Unit, "cm/min")
})

test_that("create_compound sets a permeability alternative", {
  compound <- create_compound(name = "X", permeability = permeability(0.0069))

  param <- compound$data$Permeability[[1]]$Parameters[[1]]
  expect_equal(param$Name, "Permeability")
  expect_equal(param$Value, 0.0069)
  expect_equal(param$Unit, "cm/min")
})


# Multi-alternative (list) physicochemical property arguments ------------

test_that("create_compound accepts a list of solubility alternatives", {
  compound <- create_compound(
    name = "X",
    solubility = list(
      solubility(9999, name = "Aqueous"),
      solubility(200, name = "FaSSIF")
    )
  )

  alt <- compound$data$Solubility
  expect_length(alt, 2)
  expect_equal(vapply(alt, `[[`, character(1), "Name"), c("Aqueous", "FaSSIF"))
  expect_equal(alt[[1]]$IsDefault, TRUE)
  expect_equal(alt[[2]]$IsDefault, FALSE)

  # `compound$solubility` exposes both alternatives, each keyed by its
  # label via its `Name` field.
  labels <- vapply(compound$solubility, `[[`, character(1), "Name")
  expect_equal(labels, c("Aqueous", "FaSSIF"))
})

test_that("create_compound honours an explicit default that is not the first element", {
  compound <- create_compound(
    name = "X",
    solubility = list(
      solubility(9999, name = "Aqueous"),
      solubility(200, name = "FaSSIF", default = TRUE)
    )
  )

  alt <- compound$data$Solubility
  expect_length(alt, 2)
  expect_equal(vapply(alt, `[[`, character(1), "Name"), c("Aqueous", "FaSSIF"))
  expect_equal(alt[[1]]$IsDefault, FALSE)
  expect_equal(alt[[2]]$IsDefault, TRUE)
})

test_that("create_compound honours an explicit lipophilicity default that is not the first element", {
  compound <- create_compound(
    name = "X",
    lipophilicity = list(
      lipophilicity(2.5, name = "Measured"),
      lipophilicity(3.1, name = "Predicted", default = TRUE)
    )
  )

  alt <- compound$data$Lipophilicity
  expect_length(alt, 2)
  expect_equal(
    vapply(alt, `[[`, character(1), "Name"),
    c("Measured", "Predicted")
  )
  expect_equal(alt[[1]]$IsDefault, FALSE)
  expect_equal(alt[[2]]$IsDefault, TRUE)
})

# The tests below (unmodified) cover the "none marked" fallback (AC-2):
# omitting `default` on every element still produces `alt[[1]]$IsDefault ==
# TRUE`, exactly as before this change.
test_that("create_compound accepts a list of alternatives for lipophilicity, fraction_unbound, intestinal_permeability, and permeability", {
  compound <- create_compound(
    name = "X",
    lipophilicity = list(
      lipophilicity(2.5, name = "Measured"),
      lipophilicity(3.1, name = "Predicted")
    ),
    fraction_unbound = list(
      fraction_unbound(0.1, name = "Plasma"),
      fraction_unbound(0.2, name = "Microsomal")
    ),
    intestinal_permeability = list(
      intestinal_permeability(1.14e-05, name = "Caco-2"),
      intestinal_permeability(2e-05, name = "PAMPA")
    ),
    permeability = list(
      permeability(0.0069, name = "Measured"),
      permeability(0.008, name = "Predicted")
    )
  )

  for (field in c(
    "Lipophilicity",
    "FractionUnbound",
    "IntestinalPermeability",
    "Permeability"
  )) {
    alt <- compound$data[[field]]
    expect_length(alt, 2)
    expect_equal(alt[[1]]$IsDefault, TRUE)
    expect_equal(alt[[2]]$IsDefault, FALSE)
  }
  expect_equal(
    vapply(compound$data$Lipophilicity, `[[`, character(1), "Name"),
    c("Measured", "Predicted")
  )
  expect_equal(
    vapply(compound$data$FractionUnbound, `[[`, character(1), "Name"),
    c("Plasma", "Microsomal")
  )
  expect_equal(
    vapply(compound$data$FractionUnbound, `[[`, character(1), "Species"),
    c("Human", "Human")
  )
  expect_equal(
    vapply(compound$data$IntestinalPermeability, `[[`, character(1), "Name"),
    c("Caco-2", "PAMPA")
  )
  expect_equal(
    vapply(compound$data$Permeability, `[[`, character(1), "Name"),
    c("Measured", "Predicted")
  )
})

test_that("create_compound aborts when two or more alternatives are marked default", {
  expect_snapshot(
    error = TRUE,
    create_compound(
      name = "X",
      solubility = list(
        solubility(9999, name = "Aqueous", default = TRUE),
        solubility(200, name = "FaSSIF", default = TRUE)
      )
    )
  )
  expect_snapshot(
    error = TRUE,
    create_compound(
      name = "X",
      lipophilicity = list(
        lipophilicity(2.5, name = "Measured", default = TRUE),
        lipophilicity(3.1, name = "Predicted", default = TRUE)
      )
    )
  )
})

test_that("a single value object and a length-one list both ignore a redundant default flag", {
  from_scalar <- create_compound(
    name = "X",
    solubility = solubility(9999, default = TRUE)
  )
  from_list <- create_compound(
    name = "X",
    solubility = list(solubility(9999, default = TRUE))
  )
  expect_equal(from_scalar$data$Solubility[[1]]$IsDefault, TRUE)
  expect_equal(from_list$data$Solubility[[1]]$IsDefault, TRUE)
  expect_no_error(from_scalar)
  expect_no_error(from_list)
})

test_that("a length-one alternative list is byte-identical to a single value object", {
  from_list <- create_compound(name = "X", solubility = list(solubility(9999)))
  from_scalar <- create_compound(name = "X", solubility = solubility(9999))
  expect_identical(from_list$data$Solubility, from_scalar$data$Solubility)

  # The redundant `default = TRUE` flag on a lone alternative must not
  # change the byte-identical shape either (FR-5).
  from_list_default <- create_compound(
    name = "X",
    solubility = list(solubility(9999, default = TRUE))
  )
  from_scalar_default <- create_compound(
    name = "X",
    solubility = solubility(9999, default = TRUE)
  )
  expect_identical(
    from_list_default$data$Solubility,
    from_scalar_default$data$Solubility
  )
})

test_that("create_compound rejects a list containing a non-matching helper or a bare scalar", {
  expect_snapshot(
    error = TRUE,
    create_compound(
      name = "X",
      solubility = list(solubility(9999), lipophilicity(2.5))
    )
  )
  expect_snapshot(
    error = TRUE,
    create_compound(name = "X", solubility = list(solubility(9999), 200))
  )
})

test_that("create_compound rejects duplicate alternative names within one property", {
  expect_snapshot(
    error = TRUE,
    create_compound(
      name = "X",
      solubility = list(solubility(9999), solubility(200))
    )
  )
  expect_snapshot(
    error = TRUE,
    create_compound(
      name = "X",
      solubility = list(
        solubility(9999, name = "Aqueous"),
        solubility(200, name = "Aqueous")
      )
    )
  )
})

test_that("create_compound treats an empty list like NULL for a physicochemical property", {
  compound <- create_compound(name = "X", solubility = list())
  expect_null(compound$data$Solubility)
})

test_that("create_compound builds a multi-alternative solubility list mixing scalar and table forms", {
  compound <- create_compound(
    name = "X",
    solubility = list(
      solubility(9999, reference_pH = 7, name = "Scalar"),
      solubility(
        table = data.frame(pH = c(3, 6), value = c(5000, 3000)),
        name = "Table"
      )
    )
  )

  alt <- compound$data$Solubility
  expect_length(alt, 2)
  expect_equal(alt[[1]]$Parameters[[1]]$Name, "Solubility at reference pH")
  expect_equal(alt[[2]]$Parameters[[1]]$Name, "Solubility table")
  expect_equal(alt[[1]]$IsDefault, TRUE)
  expect_equal(alt[[2]]$IsDefault, FALSE)
})

test_that("create_compound honours a non-first default in a mixed scalar/table solubility list", {
  compound <- create_compound(
    name = "X",
    solubility = list(
      solubility(9999, reference_pH = 7, name = "Scalar"),
      solubility(
        table = data.frame(pH = c(3, 6), value = c(5000, 3000)),
        name = "Table",
        default = TRUE
      )
    )
  )

  alt <- compound$data$Solubility
  expect_length(alt, 2)
  expect_equal(alt[[1]]$IsDefault, FALSE)
  expect_equal(alt[[2]]$IsDefault, TRUE)
})

test_that("get_default_alternative() honours an explicit non-first default", {
  compound <- create_compound(
    name = "X",
    solubility = list(
      solubility(9999, name = "Aqueous"),
      solubility(200, name = "FaSSIF", default = TRUE)
    )
  )
  expect_equal(get_default_alternative(compound$data$Solubility), "FaSSIF")
  # The user-facing field accessor returns the same classed group.
  expect_equal(get_default_alternative(compound$solubility), "FaSSIF")
})

test_that("helper-set physicochemical properties never land in Parameters", {
  compound <- create_compound(
    name = "X",
    molecular_weight = 250,
    lipophilicity = lipophilicity(2.5),
    fraction_unbound = fraction_unbound(0.1),
    solubility = solubility(9999),
    intestinal_permeability = intestinal_permeability(1.14e-05),
    permeability = permeability(0.0069)
  )

  # Only molecular weight belongs in the generic Parameters array.
  param_names <- vapply(compound$data$Parameters, function(p) p$Name, "")
  expect_equal(param_names, "Molecular weight")
})

test_that("create_compound sets pKa types preserving order", {
  compound <- create_compound(
    name = "X",
    pKa = list(
      list(type = "Base", value = 10.02),
      list(type = "Acid", value = 1.7)
    )
  )

  expect_equal(
    compound$data$PkaTypes,
    list(
      list(Type = "Base", Pka = 10.02),
      list(Type = "Acid", Pka = 1.7)
    )
  )
})

test_that("create_compound rejects invalid pKa entries", {
  expect_snapshot(
    error = TRUE,
    create_compound(name = "X", pKa = list(list(type = "Weak", value = 1)))
  )
  expect_snapshot(
    error = TRUE,
    create_compound(name = "X", pKa = list(list(type = "Base", value = "big")))
  )
})

test_that("helper name argument overrides the alternative name", {
  compound <- create_compound(
    name = "X",
    lipophilicity = lipophilicity(2.5, name = "Custom lipo"),
    fraction_unbound = fraction_unbound(1, name = "Custom fu"),
    solubility = solubility(9999, name = "Custom sol"),
    intestinal_permeability = intestinal_permeability(
      1.14e-05,
      name = "Custom ip"
    ),
    permeability = permeability(0.0069, name = "Custom perm")
  )

  expect_equal(compound$data$Lipophilicity[[1]]$Name, "Custom lipo")
  expect_equal(compound$data$FractionUnbound[[1]]$Name, "Custom fu")
  expect_equal(compound$data$Solubility[[1]]$Name, "Custom sol")
  expect_equal(compound$data$IntestinalPermeability[[1]]$Name, "Custom ip")
  expect_equal(compound$data$Permeability[[1]]$Name, "Custom perm")
})

test_that("create_compound attaches processes", {
  compound <- create_compound(
    name = "X",
    processes = list(
      create_process(
        internal_name = "GlomerularFiltration",
        data_source = "Publication X"
      )
    )
  )

  expect_length(compound$processes, 1)
  expect_equal(compound$processes[[1]]$category, "renal_clearance")
  expect_null(names(compound$data$Processes))
  expect_equal(
    compound$data$Processes[[1]]$InternalName,
    "GlomerularFiltration"
  )
})

test_that("only fraction unbound gains a Species key", {
  compound <- create_compound(
    name = "X",
    lipophilicity = lipophilicity(2.5),
    intestinal_permeability = intestinal_permeability(1.14e-05),
    permeability = permeability(0.0069)
  )
  expect_false("Species" %in% names(compound$data$Lipophilicity[[1]]))
  expect_false("Species" %in% names(compound$data$IntestinalPermeability[[1]]))
  expect_false("Species" %in% names(compound$data$Permeability[[1]]))
})

test_that("solubility alternatives gain no Species key (scalar and table)", {
  scalar <- create_compound(
    name = "X",
    solubility = solubility(9999, reference_pH = 7)
  )
  expect_false("Species" %in% names(scalar$data$Solubility[[1]]))

  tbl <- create_compound(
    name = "X",
    solubility = solubility(
      table = data.frame(pH = c(3, 6), value = c(5000, 90))
    )
  )
  expect_false("Species" %in% names(tbl$data$Solubility[[1]]))
})

test_that("physicochemical helpers reject non-numeric values", {
  expect_snapshot(error = TRUE, lipophilicity("a"))
  expect_snapshot(error = TRUE, fraction_unbound("a"))
  expect_snapshot(error = TRUE, fraction_unbound(1, species = "Klingon"))
  expect_snapshot(
    error = TRUE,
    fraction_unbound(1, species = c("Human", "Dog"))
  )
  expect_snapshot(error = TRUE, solubility("a"))
  expect_snapshot(error = TRUE, solubility(9999, reference_pH = "a"))
  expect_snapshot(error = TRUE, solubility(9999, gain_per_charge = "a"))
  expect_snapshot(error = TRUE, intestinal_permeability("a"))
  expect_snapshot(error = TRUE, permeability("a"))
})

test_that("create_compound rejects a plain scalar or the wrong helper", {
  expect_snapshot(
    error = TRUE,
    create_compound(name = "X", lipophilicity = 2.5)
  )
  expect_snapshot(
    error = TRUE,
    create_compound(name = "X", lipophilicity = weight(70))
  )
})

test_that("create_compound rejects a non-list processes argument", {
  expect_snapshot(
    error = TRUE,
    create_compound(name = "X", processes = "not a list")
  )
})

test_that("solubility() rejects a malformed table", {
  expect_snapshot(error = TRUE, solubility(table = c(3, 6)))
})

test_that("solubility() rejects an empty or non-numeric table", {
  expect_snapshot(
    error = TRUE,
    solubility(table = data.frame(pH = numeric(0), value = numeric(0)))
  )
  expect_snapshot(
    error = TRUE,
    solubility(table = data.frame(pH = c(3, 6), value = c("a", "b")))
  )
})

test_that("physicochemical helpers validate units", {
  expect_snapshot(error = TRUE, lipophilicity(2.5, unit = "nope"))
  expect_snapshot(error = TRUE, solubility(1, unit = "nope"))
  expect_snapshot(error = TRUE, intestinal_permeability(1, unit = "nope"))
  expect_snapshot(error = TRUE, permeability(1, unit = "nope"))
})

test_that("create_compound accepts the default property units", {
  expect_no_error(create_compound(
    name = "X",
    lipophilicity = lipophilicity(2.5),
    solubility = solubility(1),
    intestinal_permeability = intestinal_permeability(1),
    permeability = permeability(1)
  ))
})

test_that("create_compound validates plasma_protein_binding_partner against the enum", {
  expect_snapshot(
    error = TRUE,
    create_compound(name = "X", plasma_protein_binding_partner = "Casein")
  )
  compound <- create_compound(
    name = "X",
    plasma_protein_binding_partner = "Albumin"
  )
  expect_equal(compound$plasma_protein_binding_partner, "Albumin")
})
