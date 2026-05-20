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

# add_simulation warns about unresolved references

    Code
      snap$add_simulation(sim)
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

