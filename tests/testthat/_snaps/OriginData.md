# OriginData demographic fields reject bare numeric scalars

    Code
      od$age <- 5
    Condition
      Error:
      ! `age` must be built with `age()`.
      i For example `age = age(...)`.

---

    Code
      od$weight <- 70
    Condition
      Error:
      ! `weight` must be built with `weight()`.
      i For example `weight = weight(...)`.

---

    Code
      od$height <- 175
    Condition
      Error:
      ! `height` must be built with `height()`.
      i For example `height = height(...)`.

---

    Code
      od$gestational_age <- 30
    Condition
      Error:
      ! `gestational_age` must be built with `gestational_age()`.
      i For example `gestational_age = gestational_age(...)`.

# OriginData prints a summary

    Code
      od
    Output
      
      -- OriginData --
      
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: FEMALE
      * Age: 28 year(s)
      * Weight: 60 kg
      * Calculation methods:
        * Mosteller

