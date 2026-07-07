# create_formulation preserves ValueOrigin from raw parameters

    Code
      form$parameters[["Dissolution shape"]]$value_origin
    Output
      $Source
      [1] "Lit"
      
      $Description
      [1] "ref"
      

# create_formulation preserves a custom TableFormula on any type

    Code
      from_points$parameters[[1]]$table_formula
    Output
      $Name
      [1] "Fraction (dose)"
      
      $XName
      [1] "Custom X"
      
      $YName
      [1] "Custom Y"
      
      $XDimension
      [1] "Time"
      
      $YDimension
      [1] "Fraction"
      
      $UseDerivedValues
      [1] TRUE
      
      $Points
      $Points[[1]]
      $Points[[1]]$X
      [1] 0
      
      $Points[[1]]$Y
      [1] 0
      
      $Points[[1]]$RestartSolver
      [1] FALSE
      
      
      $Points[[2]]
      $Points[[2]]$X
      [1] 60
      
      $Points[[2]]$Y
      [1] 1
      
      $Points[[2]]$RestartSolver
      [1] FALSE
      
      
      
      $XUnit
      [1] "min"
      

---

    Code
      from_formula$parameters[[1]]$table_formula
    Output
      $Name
      [1] "Fraction (dose)"
      
      $XName
      [1] "Time"
      
      $YName
      [1] "Fraction"
      
      $XDimension
      [1] "Time"
      
      $YDimension
      [1] "Fraction"
      
      $XUnit
      [1] "min"
      
      $UseDerivedValues
      [1] FALSE
      
      $Points
      $Points[[1]]
      $Points[[1]]$X
      [1] 0
      
      $Points[[1]]$Y
      [1] 0
      
      $Points[[1]]$RestartSolver
      [1] FALSE
      
      
      

# create_formulation curated form still errors on out-of-vocabulary alias

    Code
      create_formulation(name = "X", type = "Weibull", parameters = list(not_a_param = 1))
    Condition
      Error in `create_formulation()`:
      ! Invalid parameters for Weibull formulation: not_a_param
      i Valid parameters are: dissolution_time, dissolution_time_unit, lag_time, lag_time_unit, dissolution_shape, and suspension

# create_formulation rejects curated-looking parameters for an unknown type

    Code
      create_formulation(name = "X", type = "Formulation_BrandNew", parameters = list(
        some_alias = 1))
    Condition
      Error in `create_formulation()`:
      ! There is no curated parameter vocabulary for the "Formulation_BrandNew" formulation type.
      i Supply parameters for a custom type as a list of `create_parameter()` objects (or `list(Name=, Value=, ...)` dicts).

# create_formulation validates name and type

    Code
      create_formulation()
    Condition
      Error in `create_formulation()`:
      ! `name` must be a non-empty string

---

    Code
      create_formulation(name = "X")
    Condition
      Error in `create_formulation()`:
      ! `type` must be a non-empty string

---

    Code
      create_formulation(name = "", type = "Dissolved")
    Condition
      Error in `create_formulation()`:
      ! `name` must be a non-empty string

---

    Code
      create_formulation(name = "X", type = "Dissolved", parameters = "nope")
    Condition
      Error in `create_formulation()`:
      ! Parameters must be provided as a named list

# create_formulation curated Table shape is unchanged

    Code
      form <- create_formulation(name = "X", type = "Table", parameters = list(
        tableX = c(0, 1), tableY = c(0, 1)))
    Message
      No suspension parameter provided, using default value of TRUE
    Code
      form$data$Parameters
    Output
      [[1]]
      [[1]]$Name
      [1] "Use as suspension"
      
      [[1]]$Value
      [1] 1
      
      
      [[2]]
      [[2]]$Name
      [1] "Fraction (dose)"
      
      [[2]]$Value
      [1] 0
      
      [[2]]$TableFormula
      [[2]]$TableFormula$Name
      [1] "Fraction (dose)"
      
      [[2]]$TableFormula$XName
      [1] "Time"
      
      [[2]]$TableFormula$XDimension
      [1] "Time"
      
      [[2]]$TableFormula$XUnit
      [1] "h"
      
      [[2]]$TableFormula$YName
      [1] "Fraction (dose)"
      
      [[2]]$TableFormula$YDimension
      [1] "Dimensionless"
      
      [[2]]$TableFormula$UseDerivedValues
      [1] TRUE
      
      [[2]]$TableFormula$Points
      [[2]]$TableFormula$Points[[1]]
      [[2]]$TableFormula$Points[[1]]$X
      [1] 0
      
      [[2]]$TableFormula$Points[[1]]$Y
      [1] 0
      
      [[2]]$TableFormula$Points[[1]]$RestartSolver
      [1] FALSE
      
      
      [[2]]$TableFormula$Points[[2]]
      [[2]]$TableFormula$Points[[2]]$X
      [1] 1
      
      [[2]]$TableFormula$Points[[2]]$Y
      [1] 1
      
      [[2]]$TableFormula$Points[[2]]$RestartSolver
      [1] FALSE
      
      
      
      
      

# raw-form formulation round-trips through export

    Code
      reloaded_form$data$Parameters
    Output
      [[1]]
      [[1]]$Name
      [1] "Use as suspension"
      
      [[1]]$Value
      [1] 1
      
      [[1]]$ValueOrigin
      [[1]]$ValueOrigin$Source
      [1] "Lit"
      
      [[1]]$ValueOrigin$Description
      [1] "ref"
      
      
      
      [[2]]
      [[2]]$Name
      [1] "Fraction (dose)"
      
      [[2]]$Value
      [1] 0
      
      [[2]]$TableFormula
      [[2]]$TableFormula$Name
      [1] "Fraction (dose)"
      
      [[2]]$TableFormula$XName
      [1] "Time"
      
      [[2]]$TableFormula$YName
      [1] "Fraction"
      
      [[2]]$TableFormula$XDimension
      [1] "Time"
      
      [[2]]$TableFormula$YDimension
      [1] "Fraction"
      
      [[2]]$TableFormula$XUnit
      [1] "min"
      
      [[2]]$TableFormula$UseDerivedValues
      [1] FALSE
      
      [[2]]$TableFormula$Points
      [[2]]$TableFormula$Points[[1]]
      [[2]]$TableFormula$Points[[1]]$X
      [1] 0
      
      [[2]]$TableFormula$Points[[1]]$Y
      [1] 0
      
      [[2]]$TableFormula$Points[[1]]$RestartSolver
      [1] FALSE
      
      
      
      
      

