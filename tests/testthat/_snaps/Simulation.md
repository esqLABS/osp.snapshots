# Simulation$allow_aging requires a single logical or NULL

    Code
      sim$allow_aging <- "yes"
    Condition
      Error:
      ! `allow_aging` must be a single logical value

---

    Code
      sim$allow_aging <- c(TRUE, FALSE)
    Condition
      Error:
      ! `allow_aging` must be a single logical value

# Simulation aborts when both Individual and Population are set

    Code
      Simulation$new(list(Name = "S", Model = "4Comp", Individual = "A", Population = "P"))
    Condition
      Error in `initialize()`:
      ! Simulation must reference exactly one of Individual or Population.
      i Set one and leave the other absent or empty.

# Simulation aborts when neither Individual nor Population is set

    Code
      Simulation$new(list(Name = "S", Model = "4Comp"))
    Condition
      Error in `initialize()`:
      ! Simulation must reference exactly one of Individual or Population.
      i Set one and leave the other absent or empty.

# add_simulation defaults alternatives to each group default

    {
      "type": "list",
      "attributes": {},
      "value": [
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["GroupName", "AlternativeName"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["COMPOUND_LIPOPHILICITY"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["Optimized"]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["GroupName", "AlternativeName"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["COMPOUND_FRACTION_UNBOUND"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["Templeton 2011"]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["GroupName", "AlternativeName"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["COMPOUND_SOLUBILITY"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["Aqueous"]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["GroupName", "AlternativeName"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["COMPOUND_INTESTINAL_PERMEABILITY"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["PK-Sim default calculation"]
            }
          ]
        }
      ]
    }

# add_simulation build mode enforces XOR on individual/population

    Code
      snap$add_simulation(name = "S")
    Condition
      Error in `snap$add_simulation()`:
      ! Simulation must reference exactly one of `individual` or `population`.
      i Supply one and leave the other `NULL`.

---

    Code
      snap$add_simulation(name = "S", individual = "A", population = "P")
    Condition
      Error in `snap$add_simulation()`:
      ! Simulation must reference exactly one of `individual` or `population`.
      i Supply one and leave the other `NULL`.

# add_simulation build mode validates required arguments

    Code
      snap$add_simulation()
    Condition
      Error in `snap$add_simulation()`:
      ! Nothing to add.
      i Supply a pre-built <Simulation> via `simulation`, or `name` plus `individual`/`population` to build one.

---

    Code
      snap$add_simulation(name = "", individual = "A")
    Condition
      Error in `snap$add_simulation()`:
      ! `name` must be a non-empty string

---

    Code
      snap$add_simulation(name = "S", individual = "A", allow_aging = "no")
    Condition
      Error in `snap$add_simulation()`:
      ! `allow_aging` must be a single logical value

# add_simulation warns about unresolved references

    Code
      snap$add_simulation(name = "MissingRefs", individual = "NoSuchIndividual",
        compounds = list(list(name = "NoSuchCompound", protocol = "NoSuchProtocol",
          formulation = "NoSuchFormulation")), events = list(create_event_selection(
          name = "NoSuchEvent", start_time = 1)), observer_sets = list(
          create_observer_set_selection(name = "NoSuchSet")), observed_data_names = c(
          "NoSuchData"))
    Condition
      Warning:
      Simulation "MissingRefs" references building blocks that are not in the snapshot:
      * Individuals: NoSuchIndividual
      * Compounds: NoSuchCompound
      * Protocols: NoSuchProtocol
      * Formulations: NoSuchFormulation
      * Events: NoSuchEvent
      * ObserverSets: NoSuchSet
      * ObservedData: NoSuchData
      i PK-Sim will fail to resolve these at load time.
    Message
      v Added 1 simulation(s)

# remove_simulation warns on unknown name

    Code
      snap$remove_simulation("NoSuchSim")
    Condition
      Warning:
      Simulation 'NoSuchSim' not found in snapshot
    Message
      v Removed 0 simulation(s)

