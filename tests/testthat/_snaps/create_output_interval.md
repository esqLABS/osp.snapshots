# create_output_interval validates arguments

    Code
      create_output_interval()
    Condition
      Error in `create_output_interval()`:
      ! `start_time` must be a single finite numeric value

---

    Code
      create_output_interval(start_time = "x", end_time = 1, resolution = 1)
    Condition
      Error in `create_output_interval()`:
      ! `start_time` must be a single finite numeric value

