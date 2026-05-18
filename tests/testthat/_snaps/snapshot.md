# load_snapshot handles OSP Models

    Code
      load_snapshot("Rifampicin")
    Message
      i Looking for template: Rifampicin
      i Found template: https://raw.githubusercontent.com/Open-Systems-Pharmacology/Rifampicin-Model/v2.0/Rifampicin-Model.json
      i Creating snapshot from list data
      v Snapshot loaded successfully
    Output
      
      -- PKSIM Snapshot --------------------------------------------------------------
      i Version: 80 (PKSIM 12.0)
      * Compounds: 1
      * ExpressionProfiles: 7
      * Formulations: 1
      * Individuals: 2
      * ObservedData: 89
      * ObservedDataClassifications: 20
      * ObserverSets: 1
      * ParameterIdentifications: 3
      * Protocols: 13
      * SimulationClassifications: 2
      * Simulations: 13

# Snapshot print method works

    Code
      snapshot
    Output
      
      -- PKSIM Snapshot --------------------------------------------------------------
      i Version: 79 (PKSIM 11.2)
      i Path: 'data/test_snapshot.json'
      * Compounds: 6
      * Events: 10
      * ExpressionProfiles: 14
      * Formulations: 9
      * Individuals: 5
      * ObservedData: 64
      * ObservedDataClassifications: 20
      * ObserverSets: 1
      * ParameterIdentifications: 1
      * Populations: 7
      * Protocols: 9
      * Simulations: 2

# add_compound errors on wrong class

    Code
      add_compound(snapshot, "not a compound")
    Condition
      Error in `snapshot$add_compound()`:
      ! Expected a Compound object, but got <character>

# remove_compound warns when name is missing

    Code
      remove_compound(snapshot, "Other")
    Condition
      Warning:
      Compound 'Other' not found in snapshot
    Message
      v Removed 1 compound(s)

# remove_compound warns on empty collection

    Code
      remove_compound(snapshot, "Drug X")
    Condition
      Warning:
      No compounds to remove

# add_population errors on wrong class

    Code
      add_population(snapshot, "not a population")
    Condition
      Error in `snapshot$add_population()`:
      ! Expected a Population object, but got <character>

# add_protocol errors on wrong class

    Code
      add_protocol(snapshot, "not a protocol")
    Condition
      Error in `snapshot$add_protocol()`:
      ! Expected a Protocol object, but got <character>

# remove_protocol warns when name is missing

    Code
      remove_protocol(snapshot, "Other")
    Condition
      Warning:
      Protocol 'Other' not found in snapshot
    Message
      v Removed 1 protocol(s)

# remove_protocol warns on empty collection

    Code
      remove_protocol(snapshot, "Single oral")
    Condition
      Warning:
      No protocols to remove

# add_event errors on wrong class

    Code
      add_event(snapshot, "not an event")
    Condition
      Error in `snapshot$add_event()`:
      ! Expected an Event object, but got <character>

# remove_event warns when name is missing

    Code
      remove_event(snapshot, "Other")
    Condition
      Warning:
      Event 'Other' not found in snapshot
    Message
      v Removed 1 event(s)

# remove_event warns on empty collection

    Code
      remove_event(snapshot, "Breakfast")
    Condition
      Warning:
      No events to remove

# add_observed_data exported wrapper errors on wrong class

    Code
      add_observed_data(snapshot, "not a dataset")
    Condition
      Error in `snapshot$add_observed_data()`:
      ! Expected a DataSet object, but got <character>

# mutators reject non-Snapshot inputs

    Code
      add_compound("nope", compound)
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <character>

---

    Code
      remove_compound("nope", "X")
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <character>

---

    Code
      add_population("nope", population)
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <character>

---

    Code
      add_protocol("nope", protocol)
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <character>

---

    Code
      remove_protocol("nope", "S")
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <character>

---

    Code
      add_event("nope", event)
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <character>

---

    Code
      remove_event("nope", "E")
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <character>

