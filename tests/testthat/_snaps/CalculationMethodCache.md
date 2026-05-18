# CalculationMethodCache rejects NA method names

    Code
      CalculationMethodCache$new(c("a", NA))
    Condition
      Error in `private$.coerce()`:
      ! Method names must not be `NA`

# CalculationMethodCache$add validates the input

    Code
      cache$add(c("a", "b"))
    Condition
      Error in `cache$add()`:
      ! `method` must be a single non-missing character string

---

    Code
      cache$add(NA_character_)
    Condition
      Error in `cache$add()`:
      ! `method` must be a single non-missing character string

# CalculationMethodCache prints its contents

    Code
      CalculationMethodCache$new()
    Output
      CalculationMethodCache: (empty)

---

    Code
      CalculationMethodCache$new(c("Mosteller", "Rodgers"))
    Output
      CalculationMethodCache (2 methods)
      * Mosteller
      * Rodgers

