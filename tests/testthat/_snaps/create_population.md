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

---

    Code
      create_population(name = "P", number_of_individuals = 10,
        gestational_age_range = list(min = 25, max = 42, unit = "week(s)"))
    Condition
      Error in `range_to_list()`:
      ! `gestational_age_range` must be a <Range> object
      i Use `range()` to create one.

# create_population validates disease state parameters

    Code
      create_population(name = "P", number_of_individuals = 10,
        disease_state_parameters = "not a list")
    Condition
      Error in `create_population()`:
      ! `disease_state_parameters` must be a named list of <Range> objects.

---

    Code
      create_population(name = "P", number_of_individuals = 10,
        disease_state_parameters = list(eGFR = list(min = 60, max = 120)))
    Condition
      Error in `range_to_list()`:
      ! `disease_state_parameters` must be a <Range> object
      i Use `range()` to create one.

---

    Code
      create_population(name = "P", number_of_individuals = 10,
        disease_state_parameters = list(range(60, 120, "ml/min/1.73m²")))
    Condition
      Error in `create_population()`:
      ! `disease_state_parameters` must be a named list of <Range> objects.
      i Each entry must be `name = range(...)`.

# create_population rejects individual combined with legacy args

    Code
      create_population(name = "P", number_of_individuals = 10, individual = ind,
        species = "Human")
    Condition
      Error in `create_population()`:
      ! `individual` cannot be combined with `individual_name`, `species`, or `source_population`.
      i Fold those fields into the `create_individual()` call instead.

---

    Code
      create_population(name = "P", number_of_individuals = 10, individual = ind,
        individual_name = "Base", source_population = "European_ICRP_2002")
    Condition
      Error in `create_population()`:
      ! `individual` cannot be combined with `individual_name`, `species`, or `source_population`.
      i Fold those fields into the `create_individual()` call instead.

# create_population rejects a non-Individual individual

    Code
      create_population(name = "P", number_of_individuals = 10, individual = list(
        Name = "Base"))
    Condition
      Error in `create_population()`:
      ! `individual` must be an <Individual> object (see `create_individual()`).

# create_population rejects NA name

    Code
      create_population(name = NA_character_, number_of_individuals = 10)
    Condition
      Error in `create_population()`:
      ! `name` must be a non-empty string

