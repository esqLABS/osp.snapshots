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

# Create test individuals that will be used across tests
complete_individual <- Individual$new(complete_individual_data)
minimal_individual <- Individual$new(minimal_individual_data)
