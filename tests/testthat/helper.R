# Load test snapshot ----------------------------------------------------------
test_snapshot <- Snapshot$new(testthat::test_path("data", "test_snapshot.json"))

empty_snapshot <- Snapshot$new(testthat::test_path(
  "data",
  "empty_snapshot.json"
))

# Temporary file and snapshot helpers -----------------------------------------

#' Create a temporary snapshot file from data
#'
#' Creates a temporary file with snapshot data that will be automatically cleaned up
#' when the test or function finishes.
#'
#' @param data A list representing the snapshot data
#' @param env The environment in which to register the cleanup, defaults to parent.frame()
#' @return Path to the temporary file
local_snapshot_file <- function(data, env = parent.frame()) {
  # Create temp file with automatic cleanup using withr
  temp_file <- withr::local_tempfile(fileext = ".json", .local_envir = env)

  # Convert data to JSON and write to file
  json_data <- jsonlite::toJSON(data, auto_unbox = TRUE, pretty = TRUE)
  writeLines(json_data, temp_file)

  # Return the path to the temp file
  return(temp_file)
}

#' Create a temporary snapshot with specific data
#'
#' Creates a Snapshot object from provided data that will be automatically
#' cleaned up when the test or function finishes.
#'
#' @param data A list representing the snapshot data
#' @param env The environment in which to register the cleanup, defaults to parent.frame()
#' @return A Snapshot object
local_snapshot <- function(data = list(Version = 80), env = parent.frame()) {
  # Create a snapshot from the provided data
  snapshot <- Snapshot$new(data)

  # Return the snapshot (no cleanup needed for in-memory objects)
  return(snapshot)
}

# Test fixtures: Formulation --------------------------------------------------

# Create a complete Weibull formulation data
complete_formulation_data <- list(
  Name = "Test Tablet",
  FormulationType = "Formulation_Tablet_Weibull",
  Parameters = list(
    list(
      Name = "Dissolution time (50% dissolved)",
      Value = 60.0,
      Unit = "min",
      ValueOrigin = list(
        Source = "Publication",
        Description = "Test reference"
      )
    ),
    list(
      Name = "Lag time",
      Value = 10.0,
      Unit = "min",
      ValueOrigin = list(
        Source = "Publication",
        Description = "Test reference"
      )
    ),
    list(
      Name = "Dissolution shape",
      Value = 0.92,
      ValueOrigin = list(
        Source = "Publication",
        Description = "Test reference"
      )
    ),
    list(
      Name = "Use as suspension",
      Value = 1.0,
      ValueOrigin = list(
        Source = "Other",
        Description = "Assumed"
      )
    )
  )
)

# Create a complete formulation object
complete_formulation <- Formulation$new(complete_formulation_data)

# Create a minimal formulation data
minimal_formulation_data <- list(
  Name = "Oral Solution",
  FormulationType = "Formulation_Dissolved"
)

# Create a minimal formulation object
minimal_formulation <- Formulation$new(minimal_formulation_data)

# Create a table-based formulation data
table_formulation_data <- list(
  Name = "Custom Release",
  FormulationType = "Formulation_Table",
  Parameters = list(
    list(
      Name = "Use as suspension",
      Value = 1.0
    ),
    list(
      Name = "Fraction (dose)",
      Value = 0.0,
      TableFormula = list(
        Name = "Fraction (dose)",
        XName = "Time",
        XDimension = "Time",
        XUnit = "h",
        YName = "Fraction (dose)",
        YDimension = "Dimensionless",
        UseDerivedValues = TRUE,
        Points = list(
          list(X = 0.0, Y = 0.0, RestartSolver = FALSE),
          list(X = 0.5, Y = 0.2, RestartSolver = FALSE),
          list(X = 1.0, Y = 0.4, RestartSolver = FALSE),
          list(X = 2.0, Y = 0.6, RestartSolver = FALSE),
          list(X = 4.0, Y = 0.8, RestartSolver = FALSE),
          list(X = 8.0, Y = 1.0, RestartSolver = FALSE)
        )
      )
    )
  )
)

# Create a table-based formulation object
table_formulation <- Formulation$new(table_formulation_data)

# Create a particle formulation data
particle_formulation_data <- list(
  Name = "Particle Formulation",
  FormulationType = "Formulation_Particles",
  Parameters = list(
    list(
      Name = "Thickness (unstirred water layer)",
      Value = 30.0,
      Unit = "µm"
    ),
    list(
      Name = "Type of particle size distribution",
      Value = 0.0
    ),
    list(
      Name = "Particle radius (mean)",
      Value = 10.0,
      Unit = "µm"
    )
  )
)

# Create a particle formulation object
particle_formulation <- Formulation$new(particle_formulation_data)

# Create a zero-order formulation data
zero_order_formulation_data <- list(
  Name = "Zero Order Release",
  FormulationType = "Formulation_ZeroOrder",
  Parameters = list(
    list(
      Name = "End time",
      Value = 60.0,
      Unit = "min"
    )
  )
)

# Create a zero-order formulation object
zero_order_formulation <- Formulation$new(zero_order_formulation_data)

# Create a first-order formulation data
first_order_formulation_data <- list(
  Name = "First Order Release",
  FormulationType = "Formulation_FirstOrder",
  Parameters = list(
    list(
      Name = "t1/2",
      Value = 0.01,
      Unit = "min"
    )
  )
)

# Create a first-order formulation object
first_order_formulation <- Formulation$new(first_order_formulation_data)

# Test fixtures: ExpressionProfile --------------------------------------------

# Create test data for a complete expression profile
complete_expression_profile_data <- list(
  Type = "Enzyme",
  Species = "Human",
  Molecule = "CYP3A4",
  Category = "Healthy",
  Localization = "Intracellular, BloodCellsIntracellular",
  TransportType = "Efflux",
  Ontogeny = list(
    Name = "CYP3A4"
  ),
  Parameters = list(
    list(
      Path = "CYP3A4|Reference concentration",
      Value = 4.32,
      Unit = "µmol/l",
      ValueOrigin = list(
        Source = "Other",
        Description = "PK-Sim default value"
      )
    ),
    list(
      Path = "CYP3A4|t1/2 (intestine)",
      Value = 23.0,
      Unit = "h",
      ValueOrigin = list(
        Source = "Publication",
        Description = "R24-3733"
      )
    ),
    list(
      Path = "Organism|Liver|Pericentral|Intracellular|CYP3A4|Relative expression",
      Value = 1.0
    )
  )
)

# Create test data for a minimal expression profile
minimal_expression_profile_data <- list(
  Type = "Transporter",
  Species = "Human",
  Molecule = "P-gp",
  Category = "Healthy"
)

# Create test data for a expression profile without category
without_category_expression_profile_data <- list(
  Type = "Transporter",
  Species = "Rat",
  Molecule = "OATP1B1",
  Parameters = list(
    list(
      Path = "OATP1B1|Reference concentration",
      Value = 2.15,
      Unit = "µmol/l"
    )
  )
)

# Create test expression profiles that will be used across tests
complete_expression_profile <- ExpressionProfile$new(
  complete_expression_profile_data
)
minimal_expression_profile <- ExpressionProfile$new(
  minimal_expression_profile_data
)
without_category_expression_profile <- ExpressionProfile$new(
  without_category_expression_profile_data
)

# Test fixtures: Individual ---------------------------------------------------

# Create test data for a complete individual
complete_individual_data <- list(
  Name = "Test Individual",
  Seed = 12345,
  OriginData = list(
    Species = "Human",
    Population = "European_ICRP_2002",
    Gender = "MALE",
    Age = list(Value = 30, Unit = "year(s)"),
    Weight = list(Value = 70, Unit = "kg"),
    Height = list(Value = 175, Unit = "cm")
  ),
  Parameters = list(
    list(
      Path = "Organism|Liver|EHC continuous fraction",
      Value = 1.0,
      ValueOrigin = list(Source = "Unknown")
    ),
    list(
      Path = "Organism|Kidney|GFR",
      Value = 120.5,
      Unit = "ml/min",
      ValueOrigin = list(
        Source = "Publication",
        Description = "Standard reference value from ICRP 2002",
        Id = 42
      )
    )
  ),
  ExpressionProfiles = c(
    "CYP3A4|Human|Healthy",
    "P-gp|Human|Healthy"
  )
)

# Create test data for a minimal individual
minimal_individual_data <- list(
  Name = "Minimal Individual"
)

# Create test data for a preterm individual with gestational age
preterm_individual_data <- list(
  Name = "Preterm Baby",
  Seed = 54321,
  OriginData = list(
    Species = "Human",
    Population = "Preterm",
    Gender = "MALE",
    Age = list(Value = 10.0, Unit = "day(s)"),
    GestationalAge = list(Value = 30.0, Unit = "week(s)"),
    Weight = list(Value = 1.5, Unit = "kg"),
    Height = list(Value = 40, Unit = "cm")
  )
)

# Create test data for an individual with characteristics and expression profiles but no parameters
characteristics_expr_individual_data <- list(
  Name = "CharExpr Individual",
  OriginData = list(
    Species = "Human",
    Population = "European_ICRP_2002",
    Gender = "FEMALE",
    Age = list(Value = 28, Unit = "year(s)"),
    Weight = list(Value = 60, Unit = "kg"),
    Height = list(Value = 165, Unit = "cm")
  ),
  ExpressionProfiles = c(
    "CYP2D6|Human|Healthy",
    "OATP1B1|Human|Healthy"
  )
)

# Create test individuals that will be used across tests
complete_individual <- Individual$new(complete_individual_data)
minimal_individual <- Individual$new(minimal_individual_data)
preterm_individual <- Individual$new(preterm_individual_data)
characteristics_expr_individual <- Individual$new(
  characteristics_expr_individual_data
)

# Test fixtures: Event --------------------------------------------------------

# Test fixture for Event class
test_event_data <- list(
  Name = "Test Meal",
  Template = "Meal: Standard (Human)",
  Parameters = list(
    list(
      Name = "Meal energy content",
      Value = 500,
      Unit = "kcal",
      ValueOrigin = list(
        Source = "Publication",
        Description = "Test reference"
      )
    ),
    list(
      Name = "Meal volume",
      Value = 0.3,
      Unit = "l"
    ),
    list(
      Name = "Meal fraction solid",
      Value = 0.7
    )
  )
)

# Simple event without parameters
simple_event_data <- list(
  Name = "GB emptying",
  Template = "Gallbladder emptying"
)
