# create_observed_data validates required arguments

    Code
      create_observed_data()
    Condition
      Error in `create_observed_data()`:
      ! `name` must be a non-empty string

---

    Code
      create_observed_data(name = "X", time = time(1:4), values = values(1:5,
      dimension = "Concentration (mass)"))
    Condition
      Error in `create_observed_data()`:
      ! `time` and `values` must have the same length, got 4 and 5

---

    Code
      create_observed_data(name = "X", time = time(1:3), values = values(1:3,
      dimension = "Concentration (mass)"), error = error(1:2))
    Condition
      Error in `create_observed_data()`:
      ! `error` must be a numeric vector of the same length as `values`

---

    Code
      create_observed_data(name = "X", time = time(1:3), values = values(1:3,
      dimension = "Concentration (mass)"), metadata = list("missing-key"))
    Condition
      Error in `create_observed_data()`:
      ! `metadata` must be a named list

# create_observed_data rejects a plain vector or the wrong helper

    Code
      create_observed_data(name = "X", time = 1:3, values = values(1:3, dimension = "Concentration (mass)"))
    Condition
      Error in `create_observed_data()`:
      ! `time` must be built with `time()`.
      i For example `time = time(c(0, 1, 2))`.

---

    Code
      create_observed_data(name = "X", time = time(1:3), values = time(1:3))
    Condition
      Error in `create_observed_data()`:
      ! `values` was built with the wrong helper.
      i Use `values()` for `values`, e.g. `values = values(c(0, 12), dimension = "Concentration (mass)")`.

# values() requires a dimension

    Code
      values(1:3)
    Condition
      Error in `values()`:
      ! `dimension` is required.
      i Pass one of: AUC (mass), AUC (molar), AUCM (molar), Abundance per mass protein, Abundance per tissue, Age in weeks, Age in years, Amount, Amount per area, Amount per area per time, Amount per time, Ampere, Area, Area per amount per time, BMI, Becquerel, CL per mass protein, CL per recombinant enzyme, CV Viscosity, CV Viscosity per Volume, CV mmHg*s²/ml, Candela, Compliance, Compliance (Area), Concentration (mass), Concentration (molar), Concentration (molar) per time, Coulomb, Count, Count per mass, Count per volume, Density, Diffusion coefficient, Dimensionless, Dose per body surface area, Dose per body weight, Elastance, Energy, Farad, Flow, Flow per body surface area, Flow per weight, Flow per weight organ, Flow², Fraction, Gray, Henry, Hertz, Hydraulic conductivity, Inversed area, Inversed concentration (molar), Inversed length, Inversed mol, Inversed time, Inversed volume, Joule, Katal, Kelvin, Length, Log Units, Lumen, Lux, Mass, Mass per area, Mass per area per time, Mass per time, Mass per tissue, Molecular weight, Newton, Ohm, Pressure, RT, Radian, Resistance, Resolution, Second order rate constant, Siemens, Sievert, Slope, Steradian, Temperature, Tesla, Time, Time², Velocity, Viscosity, Vmax per mass protein, Vmax per recombinant enzyme, Vmax per transporter, Vmax per weight organ tissue, Volt, Volume, Volume per body weight, Watt, Weber.

# create_observed_data validates time and value units

    Code
      time(1:3, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

---

    Code
      values(1:3, unit = "not-a-unit", dimension = "Concentration (mass)")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Concentration (mass) are: g/l, mg/l, µg/l, ng/l, pg/l, mg/dl, mg/ml, µg/ml, ng/ml, pg/ml, kg/l

