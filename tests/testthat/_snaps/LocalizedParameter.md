# LocalizedParameter errors when no path is supplied

    Code
      LocalizedParameter$new(list(Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is empty

    Code
      LocalizedParameter$new(list(Path = "", Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is NA

    Code
      LocalizedParameter$new(list(Path = NA_character_, Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is zero-length

    Code
      LocalizedParameter$new(list(Path = character(0), Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is a multi-element vector

    Code
      LocalizedParameter$new(list(Path = c("Organism|A", "Organism|B"), Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

