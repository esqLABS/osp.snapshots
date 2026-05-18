# create_population validates required arguments

    Code
      create_population()
    Condition
      Error in `create_population()`:
      ! `name` must be a non-empty string

---

    Code
      create_population(name = "P")
    Condition
      Error in `create_population()`:
      ! `number_of_individuals` must be a positive integer

---

    Code
      create_population(name = "P", number_of_individuals = 0)
    Condition
      Error in `create_population()`:
      ! `number_of_individuals` must be a positive integer

---

    Code
      create_population(name = "P", number_of_individuals = NA_integer_)
    Condition
      Error in `create_population()`:
      ! `number_of_individuals` must be a positive integer

---

    Code
      create_population(name = "P", number_of_individuals = 1.5)
    Condition
      Error in `create_population()`:
      ! `number_of_individuals` must be a positive integer

---

    Code
      create_population(name = "P", number_of_individuals = 10,
        proportion_of_females = 150)
    Condition
      Error in `create_population()`:
      ! `proportion_of_females` must be a number between 0 and 100

---

    Code
      create_population(name = "P", number_of_individuals = 10,
        proportion_of_females = c(30, 70))
    Condition
      Error in `create_population()`:
      ! `proportion_of_females` must be a number between 0 and 100

---

    Code
      create_population(name = "P", number_of_individuals = 10, age_range = list(min = 20,
        max = 60, unit = "year(s)"))
    Condition
      Error in `range_to_list()`:
      ! `age_range` must be a <Range> object
      i Use `range()` to create one.

# create_population rejects NA name

    Code
      create_population(name = NA_character_, number_of_individuals = 10)
    Condition
      Error in `create_population()`:
      ! `name` must be a non-empty string

