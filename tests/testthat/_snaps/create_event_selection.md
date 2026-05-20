# create_event_selection validates arguments

    Code
      create_event_selection()
    Condition
      Error in `create_event_selection()`:
      ! `name` must be a non-empty string

---

    Code
      create_event_selection(name = "E")
    Condition
      Error in `create_event_selection()`:
      ! `start_time` must be a single numeric value

---

    Code
      create_event_selection(name = "E", start_time = "x")
    Condition
      Error in `create_event_selection()`:
      ! `start_time` must be a single numeric value

