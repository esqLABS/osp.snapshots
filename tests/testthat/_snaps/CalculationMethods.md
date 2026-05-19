# CalculationMethods rejects NA method names

    Code
      CalculationMethods$new(c("a", NA))
    Condition
      Error in `private$.coerce()`:
      ! Method names must not be `NA`

# CalculationMethods$add validates the input

    Code
      cm$add(c("a", "b"))
    Condition
      Error in `cm$add()`:
      ! `name` must be a single non-missing character string

---

    Code
      cm$add(NA_character_)
    Condition
      Error in `cm$add()`:
      ! `name` must be a single non-missing character string

# CalculationMethods prints its contents

    Code
      CalculationMethods$new()
    Output
      CalculationMethods: (empty)

---

    Code
      CalculationMethods$new(c("Mosteller", "Rodgers"))
    Output
      CalculationMethods (2 methods)
      * Mosteller
      * Rodgers

