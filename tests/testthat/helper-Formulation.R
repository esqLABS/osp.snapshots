# Create some test fixtures for Formulation tests

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
