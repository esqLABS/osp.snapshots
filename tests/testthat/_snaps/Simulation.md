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

# add_simulation rejects a formulation map with an unnamed element

    Code
      suppressMessages(snap$add_simulation(name = "BadFormulationMap", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
          formulation = c(`form-Lint80` = "Lint 80mg tablet", "ZO tablet")))))
    Condition
      Error in `snap$add_simulation()`:
      ! Every element of a named `formulation` map must have a slot key name

# add_simulation rejects a formulation map with a duplicate slot key

    Code
      suppressMessages(snap$add_simulation(name = "DuplicateSlotKey", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
          formulation = c(Formulation = "A", Formulation = "B")))))
    Condition
      Error in `snap$add_simulation()`:
      ! `formulation` names slot key "Formulation" more than once; a slot can be bound at most once.

# add_simulation rejects a formulation map with an empty value

    Code
      suppressMessages(snap$add_simulation(name = "EmptyFormulationValue",
        individual = "Korean (Yu 2004 study)", compounds = list(list(name = "Rifampicin",
          protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
          formulation = c(Formulation = "A", Other = "")))))
    Condition
      Error in `snap$add_simulation()`:
      ! Every value of a named `formulation` map must be a non-empty string

# add_simulation warns, but does not error, on an unknown formulation slot key

    Code
      snap$add_simulation(name = "UnknownSlotKey", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
          formulation = c(`form-Lint80` = "form_Lint80", `Nonexistent-Slot` = "Oral solution"))))
    Message
      i Derived defaults for 1 compound from the snapshot:
      * Rifampicin: calculation methods, alternatives
      ! A `formulation` map names a slot key not found on the referenced protocol:
      * Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56): Nonexistent-Slot
      i PK-Sim rejects an unbound or mis-bound slot when the snapshot is loaded.
      v Added 1 simulation(s)

# add_simulation emits no unknown-slot-key warning against an unresolved protocol

    Code
      suppressMessages(snap$add_simulation(name = "UnresolvedProtocolSlot",
        individual = "Korean (Yu 2004 study)", compounds = list(list(name = "Rifampicin",
          protocol = "NoSuchProtocol", formulation = c(AnySlot = "Oral solution")))))
    Condition
      Warning:
      Simulation "UnresolvedProtocolSlot" references building blocks that are not in the snapshot:
      * Protocols: NoSuchProtocol
      i PK-Sim will fail to resolve these at load time.

# add_simulation notes a multi-slot protocol when the formulation key is inferred

    Code
      suppressWarnings(snap$add_simulation(name = "InferredMultiSlot", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
          formulation = "Oral solution"))))
    Message
      i Derived defaults for 1 compound from the snapshot:
      * Rifampicin: calculation methods, alternatives
      ! Protocol "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)" has multiple application slots; mapped the formulation to the first slot.
      i Pass a named `formulation` map (slot key = formulation name) to bind every slot explicitly.
      v Added 1 simulation(s)

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

# add_simulation selects an alternative by friendly name and label

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
              "value": ["User defined"]
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
              "value": ["FaSSIF"]
            }
          ]
        }
      ]
    }

# add_simulation errors selecting an unknown alternative label

    Code
      suppressMessages(snap$add_simulation(name = "BadLabel", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", alternatives = c(solubility = "Not a real label")))))
    Condition
      Error in `snap$add_simulation()`:
      ! Compound "Rifampicin" has no solubility alternative named "Not a real label".
      i Available: "Aqueous" and "test".

# add_simulation errors selecting an unknown friendly property name

    Code
      suppressMessages(snap$add_simulation(name = "BadProperty", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", alternatives = c(not_a_property = "Aqueous")))))
    Condition
      Error in `snap$add_simulation()`:
      ! `alternatives` names unknown property "not_a_property".
      i Valid properties are "lipophilicity", "fraction_unbound", "solubility", "intestinal_permeability", and "permeability".

# add_simulation rejects a raw CompoundGroupSelection-shaped alternatives entry

    Code
      suppressMessages(snap$add_simulation(name = "RawSelection", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", alternatives = list(list(
          GroupName = "COMPOUND_SOLUBILITY", AlternativeName = "Aqueous"))))))
    Condition
      Error in `snap$add_simulation()`:
      ! `alternatives` must be a named character vector or a named list of length-one strings.
      i For example `alternatives = c(solubility = "FaSSIF")`.

# add_simulation errors on a duplicate friendly property name in alternatives

    Code
      suppressMessages(snap$add_simulation(name = "DupProperty", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", alternatives = c(solubility = "Aqueous",
          solubility = "test")))))
    Condition
      Error in `snap$add_simulation()`:
      ! `alternatives` names "solubility" more than once; a group can be selected at most once.

# add_simulation alternatives selection against a property with no alternatives available errors

    Code
      suppressMessages(snap$add_simulation(name = "NoAlternatives", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", alternatives = c(permeability = "Anything")))))
    Condition
      Error in `snap$add_simulation()`:
      ! Compound "Rifampicin" has no permeability alternatives available.

# add_simulation alternatives selection against the wrong property is still an error

    Code
      suppressMessages(snap$add_simulation(name = "WrongProperty", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "Rifampicin", alternatives = c(solubility = "Optimized")))))
    Condition
      Error in `snap$add_simulation()`:
      ! Compound "Rifampicin" has no solubility alternative named "Optimized".
      i Available: "Aqueous" and "test".

# add_simulation with alternatives against an unresolved compound is emitted verbatim

    Code
      suppressMessages(snap$add_simulation(name = "UnresolvedCompound", individual = "Korean (Yu 2004 study)",
        compounds = list(list(name = "NoSuchCompound", alternatives = c(solubility = "FaSSIF")))))
    Condition
      Warning:
      Simulation "UnresolvedCompound" references building blocks that are not in the snapshot:
      * Compounds: NoSuchCompound
      i PK-Sim will fail to resolve these at load time.

# add_simulation errors when compounds contains a CompoundProperties object

    Code
      snap$add_simulation(name = "EscapeSim", individual = "Korean (Yu 2004 study)",
        compounds = list(cp))
    Condition
      Error in `snap$add_simulation()`:
      ! `compounds` no longer accepts a <CompoundProperties> object.
      i Pass an inline compound-config list instead, e.g. `list(name = ..., alternatives = c(solubility = "FaSSIF"))`.

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

