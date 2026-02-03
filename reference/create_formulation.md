# Create a new formulation

Create a new formulation with the specified properties. All arguments
are optional except for name and type.

## Usage

``` r
create_formulation(name, type, parameters = NULL)
```

## Arguments

- name:

  Character. Name of the formulation

- type:

  Character. Type of formulation, one of: \* "Dissolved" - Immediate
  release solution \* "Weibull" - Weibull tablet formulation \*
  "Lint80" - Lint80 tablet formulation \* "Particle" - Particle
  formulation \* "Table" - Custom release profile table \* "ZeroOrder" -
  Zero-order release formulation \* "FirstOrder" - First-order release
  formulation

- parameters:

  List. A named list of parameters for the formulation. The valid
  parameters depend on the formulation type. Invalid parameters will
  result in an error.

## Value

A Formulation object

## Weibull formulation parameters

\* dissolution_time - Time to achieve 50 \* dissolution_time_unit - Unit
for dissolution time (character, default: "min") \* lag_time - Lag time
before dissolution starts (numeric, default: 0) \* lag_time_unit - Unit
for lag time (character, default: "min") \* dissolution_shape -
Dissolution shape parameter (numeric, default: 0.92) \* suspension -
Whether to use as suspension (logical, default: TRUE)

## Lint80 formulation parameters

\* dissolution_time - Time to achieve 80 \* dissolution_time_unit - Unit
for dissolution time (character, default: "min") \* lag_time - Lag time
before dissolution starts (numeric, default: 0) \* lag_time_unit - Unit
for lag time (character, default: "min") \* suspension - Whether to use
as suspension (logical, default: TRUE)

## Particle formulation parameters

\* thickness - Thickness of unstirred water layer (numeric, default: 30)
\* thickness_unit - Unit for thickness (character, default: "\u00b5m")
\* distribution_type - Type of distribution, "mono" or "poly"
(character, default: "mono") \* radius - Particle radius (mean or
geometric mean) (numeric, default: 10) \* radius_unit - Unit for radius
(character, default: "\u00b5m")

Parameters for polydisperse distribution (when distribution_type =
"poly"): \* particle_size_distribution - "normal" or "lognormal"
(character, default: "normal") \* radius_sd - Radius standard deviation,
for normal distribution (numeric, default: 3) \* radius_sd_unit - Unit
for radius SD (character, default: "\u00b5m") \* radius_cv - Coefficient
of variation, for lognormal distribution (numeric, default: 1.5) \*
radius_min - Minimum particle radius (numeric, default: 1) \*
radius_min_unit - Unit for minimum radius (character, default:
"\u00b5m") \* radius_max - Maximum particle radius (numeric, default:
19) \* radius_max_unit - Unit for maximum radius (character, default:
"\u00b5m") \* n_bins - Number of bins (integer, default: 3)

## Table formulation parameters

\* tableX - Vector of time points for release profile in hours (numeric
vector, required) \* tableY - Vector of fraction of dose at each time
point (numeric vector, required) \* suspension - Whether to use as
suspension (logical, default: TRUE)

## ZeroOrder formulation parameters

\* end_time - Time of administration end (numeric, default: 60) \*
end_time_unit - Unit for end time (character, default: "min")

## FirstOrder formulation parameters

\* thalf - Half-life of the drug release (numeric, default: 0.01) \*
thalf_unit - Unit for half-life (character, default: "min")

## Examples

``` r
# Create a dissolved formulation (simplest type)
dissolved <- create_formulation(name = "Oral Solution", type = "Dissolved")

# Create a Weibull tablet formulation
tablet <- create_formulation(
  name = "Standard Tablet",
  type = "Weibull",
  parameters = list(
    dissolution_time = 60,
    dissolution_time_unit = "min",
    lag_time = 10,
    lag_time_unit = "min",
    dissolution_shape = 0.92,
    suspension = TRUE
  )
)

# Create a particle formulation with monodisperse distribution
particle <- create_formulation(
  name = "Suspension",
  type = "Particle",
  parameters = list(
    thickness = 25,
    thickness_unit = "\\u00b5m",
    radius = 5,
    radius_unit = "\\u00b5m"
  )
)
#> No distribution_type provided, using default of mono

# Create a table formulation with custom release profile
custom <- create_formulation(
  name = "Custom Release",
  type = "Table",
  parameters = list(
    tableX = c(0, 0.5, 1, 2, 4, 8),
    tableY = c(0, 0.1, 0.3, 0.6, 0.9, 1.0),
    suspension = TRUE
  )
)
```
