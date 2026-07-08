# Create a new formulation

Create a new formulation with the specified properties. All arguments
are optional except for name and type.

## Usage

``` r
create_formulation(name, type, parameters = NULL)
```

## Arguments

- name:

  Character. Name of the formulation.

- type:

  Character. Type of formulation. A curated human-readable alias or a
  known raw `Formulation_*` key resolves to that key:

  - "Dissolved" - Immediate release solution

  - "Weibull" - Weibull tablet formulation

  - "Lint80" - Lint80 tablet formulation

  - "Particle" - Particle formulation

  - "Table" - Custom release profile table

  - "Zero Order" - Zero-order release formulation

  - "First Order" - First-order release formulation

  Any other non-empty string is accepted verbatim and written straight
  to `FormulationType`, so a new or otherwise unknown PK-Sim template
  type can be authored (mirroring how
  [`create_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event.md)
  treats `template`). The curated parameter vocabulary below only exists
  for the known types.

- parameters:

  List. Accepts either of two mutually exclusive forms (they are never
  mixed in one call):

  - Curated form: a named list drawn from the per-type alias vocabulary
    of a known `type` (documented in the sections below), with
    scalar/vector values. Defaults, informational messages,
    alias-to-`Name` synthesis, and the built-in `Table` shape apply.
    Invalid aliases error.

  - Raw form: a list of
    [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
    objects (built with
    [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md))
    and/or raw `list(Name=, Value=, ...)` dicts. Each entry is written
    to `data$Parameters` with its `Name`, `Value`, `Unit`,
    `ValueOrigin`, and `TableFormula` preserved verbatim, for any
    `type`. This is the form that unlocks arbitrary real parameter names
    (including on `Dissolved`), per-parameter `ValueOrigin`, and a
    custom `TableFormula` on any type.

  Only the raw form is valid for an unknown `type` (there is no alias
  vocabulary to interpret a curated-looking list against).

## Value

A Formulation object

## Weibull formulation parameters

- dissolution_time - Time to achieve 50% dissolution (numeric, default:
  240)

- dissolution_time_unit - Unit for dissolution time (character, default:
  "min")

- lag_time - Lag time before dissolution starts (numeric, default: 0)

- lag_time_unit - Unit for lag time (character, default: "min")

- dissolution_shape - Dissolution shape parameter (numeric, default:
  0.92)

- suspension - Whether to use as suspension (logical, default: TRUE)

## Lint80 formulation parameters

- dissolution_time - Time to achieve 80% dissolution (numeric, default:
  240)

- dissolution_time_unit - Unit for dissolution time (character, default:
  "min")

- lag_time - Lag time before dissolution starts (numeric, default: 0)

- lag_time_unit - Unit for lag time (character, default: "min")

- suspension - Whether to use as suspension (logical, default: TRUE)

## Particle formulation parameters

- thickness - Thickness of unstirred water layer (numeric, default: 30)

- thickness_unit - Unit for thickness (character, default: "\u00b5m")

- distribution_type - Type of distribution, "mono" or "poly" (character,
  default: "mono")

- radius - Particle radius (mean or geometric mean) (numeric, default:
  10)

- radius_unit - Unit for radius (character, default: "\u00b5m")

Parameters for polydisperse distribution (when distribution_type =
"poly"):

- particle_size_distribution - "normal" or "lognormal" (character,
  default: "normal")

- radius_sd - Radius standard deviation, for normal distribution
  (numeric, default: 3)

- radius_sd_unit - Unit for radius SD (character, default: "\u00b5m")

- radius_cv - Coefficient of variation, for lognormal distribution
  (numeric, default: 1.5)

- radius_min - Minimum particle radius (numeric, default: 1)

- radius_min_unit - Unit for minimum radius (character, default:
  "\u00b5m")

- radius_max - Maximum particle radius (numeric, default: 19)

- radius_max_unit - Unit for maximum radius (character, default:
  "\u00b5m")

- n_bins - Number of bins (integer, default: 3)

## Table formulation parameters

- tableX - Vector of time points for release profile in hours (numeric
  vector, required)

- tableY - Vector of fraction of dose at each time point (numeric
  vector, required)

- suspension - Whether to use as suspension (logical, default: TRUE)

## ZeroOrder formulation parameters

- end_time - Time of administration end (numeric, default: 60)

- end_time_unit - Unit for end time (character, default: "min")

## FirstOrder formulation parameters

- thalf - Half-life of the drug release (numeric, default: 0.01)

- thalf_unit - Unit for half-life (character, default: "min")

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
    thickness_unit = "µm",
    radius = 5,
    radius_unit = "µm"
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

# Raw form: set an arbitrary parameter (with a ValueOrigin) on Dissolved
raw_dissolved <- create_formulation(
  name = "Suspension",
  type = "Dissolved",
  parameters = list(
    create_parameter(
      name = "Use as suspension",
      value = 1,
      source = "Lit",
      description = "Reference XYZ"
    )
  )
)

# Raw form on an unknown type carrying a custom TableFormula
custom_type <- create_formulation(
  name = "Novel",
  type = "Formulation_BrandNew",
  parameters = list(
    create_parameter(
      name = "Fraction (dose)",
      value = 0,
      table_points = list(list(x = 0, y = 0), list(x = 60, y = 1)),
      x_name = "Time",
      y_name = "Fraction",
      x_unit = "min",
      x_dimension = "Time",
      y_dimension = "Fraction"
    )
  )
)
```
