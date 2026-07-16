# create_schema validates required arguments

    Code
      create_schema()
    Condition
      Error in `create_schema()`:
      ! `name` must be a non-empty string

---

    Code
      create_schema(name = "")
    Condition
      Error in `create_schema()`:
      ! `name` must be a non-empty string

---

    Code
      create_schema(name = "Schema 1", parameters = "not a list")
    Condition
      Error in `create_schema()`:
      ! `parameters` must be a list

---

    Code
      create_schema(name = "Schema 1", items = "not a list")
    Condition
      Error in `create_schema()`:
      ! `items` must be a list

---

    Code
      create_schema(name = "Schema 1", items = list("not a SchemaItem or list"))
    Condition
      Error in `create_schema()`:
      ! Every entry of `items` must be a <SchemaItem> or a raw list

# create_schema promotes number_of_repetitions without a Unit key

    Code
      schema$data$Parameters
    Output
      [[1]]
      [[1]]$Name
      [1] "NumberOfRepetitions"
      
      [[1]]$Value
      [1] 3
      
      

# create_schema promotes time_between_repetitions with a default unit

    Code
      schema$data$Parameters
    Output
      [[1]]
      [[1]]$Name
      [1] "TimeBetweenRepetitions"
      
      [[1]]$Value
      [1] 24
      
      [[1]]$Unit
      [1] "h"
      
      

# create_schema honours a custom time_between_repetitions_unit

    Code
      schema$data$Parameters
    Output
      [[1]]
      [[1]]$Name
      [1] "TimeBetweenRepetitions"
      
      [[1]]$Value
      [1] 1
      
      [[1]]$Unit
      [1] "day(s)"
      
      

# create_schema promotes start_time with a default unit

    Code
      schema$data$Parameters
    Output
      [[1]]
      [[1]]$Name
      [1] "Start time"
      
      [[1]]$Value
      [1] 0
      
      [[1]]$Unit
      [1] "h"
      
      

# create_schema rejects an invalid time_between_repetitions_unit

    Code
      create_schema(name = "S", time_between_repetitions = 1,
        time_between_repetitions_unit = "furlong")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: furlong
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

# create_schema rejects a non-whole number_of_repetitions

    Code
      create_schema(name = "S", number_of_repetitions = 3.5)
    Condition
      Error in `create_schema()`:
      ! `number_of_repetitions` must be a single finite whole number

# create_schema rejects a non-scalar or non-finite number_of_repetitions

    Code
      create_schema(name = "S", number_of_repetitions = c(1, 2))
    Condition
      Error in `create_schema()`:
      ! `number_of_repetitions` must be a single finite numeric value

---

    Code
      create_schema(name = "S", number_of_repetitions = NA)
    Condition
      Error in `create_schema()`:
      ! `number_of_repetitions` must be a single finite numeric value

# create_schema errors on a NumberOfRepetitions conflict

    Code
      create_schema(name = "S", number_of_repetitions = 1, parameters = list(
        create_parameter(name = "NumberOfRepetitions", value = 2)))
    Condition
      Error in `create_schema()`:
      ! Promoted argument conflict with `parameters` entry.
      x `number_of_repetitions` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_schema errors on a TimeBetweenRepetitions conflict

    Code
      create_schema(name = "S", time_between_repetitions = 24, parameters = list(
        create_parameter(name = "TimeBetweenRepetitions", value = 12)))
    Condition
      Error in `create_schema()`:
      ! Promoted argument conflict with `parameters` entry.
      x `time_between_repetitions` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_schema errors on a Start time conflict

    Code
      create_schema(name = "S", start_time = 0, parameters = list(create_parameter(
        name = "Start time", value = 1)))
    Condition
      Error in `create_schema()`:
      ! Promoted argument conflict with `parameters` entry.
      x `start_time` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_schema resolves a conflict from a path-bearing parameter

    Code
      create_schema(name = "S", start_time = 0, parameters = list(create_parameter(
        path = "Start time", value = 0)))
    Condition
      Error in `create_schema()`:
      ! Promoted argument conflict with `parameters` entry.
      x `start_time` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_schema reports every conflict in a single error

    Code
      create_schema(name = "S", number_of_repetitions = 1, time_between_repetitions = 24,
        start_time = 0, parameters = list(create_parameter(name = "NumberOfRepetitions",
          value = 2), create_parameter(name = "TimeBetweenRepetitions", value = 12),
        create_parameter(name = "Start time", value = 1)))
    Condition
      Error in `create_schema()`:
      ! Promoted arguments conflict with `parameters` entries.
      x `number_of_repetitions`, `time_between_repetitions`, and `start_time` are also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_schema validates parameters entries before the conflict check

    Code
      create_schema(name = "S", number_of_repetitions = 2, parameters = list(
        "not a parameter"))
    Condition
      Error in `create_schema()`:
      ! Every entry of `parameters` must be a <Parameter> or a raw list

