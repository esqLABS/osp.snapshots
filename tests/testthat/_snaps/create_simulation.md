# create_simulation enforces XOR on individual/population

    Code
      create_simulation(name = "S")
    Condition
      Error in `create_simulation()`:
      ! Simulation must reference exactly one of `individual` or `population`.
      i Supply one and leave the other `NULL`.

---

    Code
      create_simulation(name = "S", individual = "A", population = "P")
    Condition
      Error in `create_simulation()`:
      ! Simulation must reference exactly one of `individual` or `population`.
      i Supply one and leave the other `NULL`.

# create_simulation validates required arguments

    Code
      create_simulation()
    Condition
      Error in `create_simulation()`:
      ! `name` must be a non-empty string

---

    Code
      create_simulation(name = "", individual = "A")
    Condition
      Error in `create_simulation()`:
      ! `name` must be a non-empty string

---

    Code
      create_simulation(name = "S", individual = "A", allow_aging = "no")
    Condition
      Error in `create_simulation()`:
      ! `allow_aging` must be a single logical value

