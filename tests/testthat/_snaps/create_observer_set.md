# create_observer_set validates required arguments

    Code
      create_observer_set()
    Condition
      Error in `create_observer_set()`:
      ! `name` must be a non-empty string

---

    Code
      create_observer_set(name = "")
    Condition
      Error in `create_observer_set()`:
      ! `name` must be a non-empty string

---

    Code
      create_observer_set(name = "S", observers = "nope")
    Condition
      Error in `create_observer_set()`:
      ! `observers` must be a list

---

    Code
      create_observer_set(name = "S", observers = list(42))
    Condition
      Error in `create_observer_set()`:
      ! Every entry of `observers` must be an <Observer> or a list

