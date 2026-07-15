# each helper returns the expected class and default slots

    Code
      unclass(lipophilicity(2.5))
    Output
      $value
      [1] 2.5
      
      $unit
      [1] "Log Units"
      
      $name
      [1] "User defined"
      
      $default
      [1] FALSE
      

---

    Code
      unclass(fraction_unbound(0.1))
    Output
      $value
      [1] 0.1
      
      $name
      [1] "User defined"
      
      $default
      [1] FALSE
      
      $species
      [1] "Human"
      

---

    Code
      unclass(solubility(9999))
    Output
      $value
      [1] 9999
      
      $unit
      [1] "mg/l"
      
      $reference_pH
      NULL
      
      $gain_per_charge
      NULL
      
      $table
      NULL
      
      $name
      [1] "User defined"
      
      $form
      [1] "scalar"
      
      $default
      [1] FALSE
      

---

    Code
      unclass(solubility(9999, reference_pH = 7, gain_per_charge = 1000))
    Output
      $value
      [1] 9999
      
      $unit
      [1] "mg/l"
      
      $reference_pH
      [1] 7
      
      $gain_per_charge
      [1] 1000
      
      $table
      NULL
      
      $name
      [1] "User defined"
      
      $form
      [1] "scalar"
      
      $default
      [1] FALSE
      

---

    Code
      unclass(intestinal_permeability(1.14e-05))
    Output
      $value
      [1] 1.14e-05
      
      $unit
      [1] "cm/min"
      
      $name
      [1] "User defined"
      
      $default
      [1] FALSE
      

---

    Code
      unclass(permeability(0.0069))
    Output
      $value
      [1] 0.0069
      
      $unit
      [1] "cm/min"
      
      $name
      [1] "User defined"
      
      $default
      [1] FALSE
      

---

    Code
      unclass(age(30))
    Output
      $value
      [1] 30
      
      $unit
      [1] "year(s)"
      

---

    Code
      unclass(weight(70))
    Output
      $value
      [1] 70
      
      $unit
      [1] "kg"
      

---

    Code
      unclass(height(175))
    Output
      $value
      [1] 175
      
      $unit
      [1] "cm"
      

---

    Code
      unclass(gestational_age(38))
    Output
      $value
      [1] 38
      
      $unit
      [1] "week(s)"
      

---

    Code
      unclass(time(c(0, 1, 2)))
    Output
      $value
      [1] 0 1 2
      
      $unit
      [1] "h"
      

---

    Code
      unclass(values(c(0, 12), unit = "mg/l", dimension = "Concentration (mass)"))
    Output
      $value
      [1]  0 12
      
      $unit
      [1] "mg/l"
      
      $dimension
      [1] "Concentration (mass)"
      

---

    Code
      unclass(error(c(0, 1)))
    Output
      $value
      [1] 0 1
      
      $unit
      NULL
      
      $type
      [1] "ArithmeticStdDev"
      

# helpers validate units against their dimension

    Code
      lipophilicity(2.5, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Log Units are: Log Units

---

    Code
      solubility(9999, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Concentration (mass) are: g/l, mg/l, µg/l, ng/l, pg/l, mg/dl, mg/ml, µg/ml, ng/ml, pg/ml, kg/l

---

    Code
      intestinal_permeability(1, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Velocity are: cm/min, cm/s, dm/min

---

    Code
      permeability(1, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Velocity are: cm/min, cm/s, dm/min

---

    Code
      age(30, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Age in years are: year(s), month(s), week(s), day(s)

---

    Code
      weight(70, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Mass are: kg, g, mg, µg, ng, pg

---

    Code
      height(175, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Length are: m, dm, cm, mm, µm, nm, pm

---

    Code
      gestational_age(38, unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

---

    Code
      time(c(0, 1), unit = "not-a-unit")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

---

    Code
      values(c(0, 1), unit = "not-a-unit", dimension = "Concentration (mass)")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: not-a-unit
      i Valid units for Concentration (mass) are: g/l, mg/l, µg/l, ng/l, pg/l, mg/dl, mg/ml, µg/ml, ng/ml, pg/ml, kg/l

# single-value helpers reject non-numeric or non-scalar values

    Code
      lipophilicity("x")
    Condition
      Error in `lipophilicity()`:
      ! `value` must be a numeric value

---

    Code
      lipophilicity(c(1, 2))
    Condition
      Error in `lipophilicity()`:
      ! `value` must be a numeric value

---

    Code
      age("x")
    Condition
      Error in `age()`:
      ! `value` must be a numeric value

# single-value helpers reject missing values

    Code
      lipophilicity(NA)
    Condition
      Error in `lipophilicity()`:
      ! `value` must be a numeric value

---

    Code
      lipophilicity(NA_real_)
    Condition
      Error in `lipophilicity()`:
      ! `value` must be a numeric value

---

    Code
      age(NA_real_)
    Condition
      Error in `age()`:
      ! `value` must be a numeric value

# series helpers reject non-numeric or empty vectors

    Code
      time("x")
    Condition
      Error in `time()`:
      ! `value` must be a non-empty numeric vector

---

    Code
      time(numeric(0))
    Condition
      Error in `time()`:
      ! `value` must be a non-empty numeric vector

---

    Code
      values(numeric(0), dimension = "Concentration (mass)")
    Condition
      Error in `values()`:
      ! `value` must be a non-empty numeric vector

---

    Code
      error(numeric(0))
    Condition
      Error in `error()`:
      ! `value` must be a non-empty numeric vector

# series helpers reject vectors containing missing values

    Code
      time(c(0, NA, 2))
    Condition
      Error in `time()`:
      ! `value` must be a non-empty numeric vector

---

    Code
      values(c(0, NA), dimension = "Concentration (mass)")
    Condition
      Error in `values()`:
      ! `value` must be a non-empty numeric vector

---

    Code
      error(c(0, NA))
    Condition
      Error in `error()`:
      ! `value` must be a non-empty numeric vector

# error() validates type against the schema AuxiliaryType values

    Code
      error(c(1, 2), type = "ArithmeticStdErr")
    Condition
      Error in `error()`:
      ! `type` must be one of the schema AuxiliaryType values.
      x Got "ArithmeticStdErr".
      i Valid values: "Undefined", "ArithmeticStdDev", "GeometricStdDev", "ArithmeticMeanPop", and "GeometricMeanPop".

---

    Code
      error(c(1, 2), type = "not-a-type")
    Condition
      Error in `error()`:
      ! `type` must be one of the schema AuxiliaryType values.
      x Got "not-a-type".
      i Valid values: "Undefined", "ArithmeticStdDev", "GeometricStdDev", "ArithmeticMeanPop", and "GeometricMeanPop".

# solubility() enforces scalar-vs-table exclusivity

    Code
      solubility(9999, table = df)
    Condition
      Error in `solubility()`:
      ! Solubility is set either by a single value or by a table, not both.
      i Supply the scalar form (`value`, `reference_pH`, `gain_per_charge`) or `table`, not both.

---

    Code
      solubility(table = df, reference_pH = 7)
    Condition
      Error in `solubility()`:
      ! Solubility is set either by a single value or by a table, not both.
      i Supply the scalar form (`value`, `reference_pH`, `gain_per_charge`) or `table`, not both.

---

    Code
      solubility(table = df, gain_per_charge = 1000)
    Condition
      Error in `solubility()`:
      ! Solubility is set either by a single value or by a table, not both.
      i Supply the scalar form (`value`, `reference_pH`, `gain_per_charge`) or `table`, not both.

# solubility() requires either a value or a table

    Code
      solubility()
    Condition
      Error in `solubility()`:
      ! `value` or `table` must be supplied to `solubility()`.
      i Use `value` for a single solubility, or `table` for a pH/value table.

# values() requires a dimension listing valid options

    Code
      values(1:3)
    Condition
      Error in `values()`:
      ! `dimension` is required.
      i Pass one of: AUC (mass), AUC (molar), AUCM (molar), Abundance per mass protein, Abundance per tissue, Age in weeks, Age in years, Amount, Amount per area, Amount per area per time, Amount per time, Ampere, Area, Area per amount per time, BMI, Becquerel, CL per mass protein, CL per recombinant enzyme, CV Viscosity, CV Viscosity per Volume, CV mmHg*s²/ml, Candela, Compliance, Compliance (Area), Concentration (mass), Concentration (molar), Concentration (molar) per time, Coulomb, Count, Count per mass, Count per volume, Density, Diffusion coefficient, Dimensionless, Dose per body surface area, Dose per body weight, Elastance, Energy, Farad, Flow, Flow per body surface area, Flow per weight, Flow per weight organ, Flow², Fraction, Gray, Henry, Hertz, Hydraulic conductivity, Inversed area, Inversed concentration (molar), Inversed length, Inversed mol, Inversed time, Inversed volume, Joule, Katal, Kelvin, Length, Log Units, Lumen, Lux, Mass, Mass per area, Mass per area per time, Mass per time, Mass per tissue, Molecular weight, Newton, Ohm, Pressure, RT, Radian, Resistance, Resolution, Second order rate constant, Siemens, Sievert, Slope, Steradian, Temperature, Tesla, Time, Time², Velocity, Viscosity, Vmax per mass protein, Vmax per recombinant enzyme, Vmax per transporter, Vmax per weight organ tissue, Volt, Volume, Volume per body weight, Watt, Weber.

# default flag is validated and carried on the slot

    Code
      lipophilicity(2.5, default = "yes")
    Condition
      Error in `lipophilicity()`:
      ! `default` must be a single logical value

---

    Code
      lipophilicity(2.5, default = c(TRUE, FALSE))
    Condition
      Error in `lipophilicity()`:
      ! `default` must be a single logical value

