# LocalizedParameter errors when no path is supplied

    Code
      LocalizedParameter$new(list(Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a non-empty path.

# LocalizedParameter errors when path is empty

    Code
      LocalizedParameter$new(list(Path = "", Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a non-empty path.

