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

# Snapshot rejects pre-v11 snapshots

    Code
      Snapshot$new(list(Version = 78))
    Message
      i Creating snapshot from list data
    Condition
      Error in `private$.validate_version()`:
      ! Unsupported snapshot Version 78.
      i osp.snapshots requires PK-Sim v11+ snapshots (Version >= 79).

# Snapshot rejects snapshots missing a Version field

    Code
      Snapshot$new(list(Compounds = list()))
    Message
      i Creating snapshot from list data
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot is missing an integer Version field.
      i osp.snapshots requires PK-Sim v11+ snapshots (Version >= 79).

# Snapshot rejects snapshots with a non-integer Version

    Code
      Snapshot$new(list(Version = "v11"))
    Message
      i Creating snapshot from list data
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot is missing an integer Version field.
      i osp.snapshots requires PK-Sim v11+ snapshots (Version >= 79).

