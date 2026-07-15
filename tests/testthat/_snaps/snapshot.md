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

# Snapshot migration-band snapshots report how to upgrade and abort

    Code
      Snapshot$new(list(Version = 78))
    Message
      i Creating snapshot from list data
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot Version 78 is below the supported floor.
      i Set `upgrade = TRUE` to migrate it up to whatever the installed ospsuite core emits (currently Version 80).
      i Migration round-trips the snapshot through PK-Sim and can take several minutes.

---

    Code
      Snapshot$new(testthat::test_path("data", "snapshot_v78.json"))
    Message
      i Reading snapshot from 'data/snapshot_v78.json'
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot Version 78 is below the supported floor.
      i Set `upgrade = TRUE` to migrate it up to whatever the installed ospsuite core emits (currently Version 80).
      i Migration round-trips the snapshot through PK-Sim and can take several minutes.

# Snapshot rejects snapshots too old to migrate

    Code
      Snapshot$new(list(Version = 73))
    Message
      i Creating snapshot from list data
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot Version 73 is too old to migrate.
      i osp.snapshots supports snapshots from Version 79 to 81, and can migrate Version 74 to 78.
      i Re-export the project from a newer PK-Sim before loading it.

---

    Code
      Snapshot$new(testthat::test_path("data", "snapshot_v73.json"))
    Message
      i Reading snapshot from 'data/snapshot_v73.json'
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot Version 73 is too old to migrate.
      i osp.snapshots supports snapshots from Version 79 to 81, and can migrate Version 74 to 78.
      i Re-export the project from a newer PK-Sim before loading it.

# Snapshot rejects snapshots newer than the supported ceiling

    Code
      Snapshot$new(list(Version = 82))
    Message
      i Creating snapshot from list data
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot Version 82 is not supported yet.
      i osp.snapshots supports snapshots up to Version 81; upgrade osp.snapshots to load newer snapshots.

---

    Code
      Snapshot$new(testthat::test_path("data", "snapshot_v82.json"))
    Message
      i Reading snapshot from 'data/snapshot_v82.json'
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot Version 82 is not supported yet.
      i osp.snapshots supports snapshots up to Version 81; upgrade osp.snapshots to load newer snapshots.

---

    Code
      Snapshot$new(list(Version = 82), upgrade = TRUE)
    Message
      i Creating snapshot from list data
    Condition
      Error in `private$.validate_version()`:
      ! Snapshot Version 82 is not supported yet.
      i osp.snapshots supports snapshots up to Version 81; upgrade osp.snapshots to load newer snapshots.

# Snapshot warns when a snapshot is newer than the installed core

    Code
      s <- Snapshot$new(list(Version = 81))
    Message
      i Creating snapshot from list data
    Condition
      Warning:
      Snapshot Version 81 is newer than the installed ospsuite core (Version 80).
      i It may not load or run in the installed ospsuite; editing and exporting still work here.
    Message
      v Snapshot loaded successfully

# Snapshot migration aborts before converting on an incompatible core

    Code
      Snapshot$new(list(Version = 78), upgrade = TRUE)
    Message
      i Creating snapshot from list data
    Condition
      Error in `initialize()`:
      ! Cannot migrate this snapshot with the installed ospsuite core.
      i The installed core would emit Version 82, which is above the highest version osp.snapshots supports (Version 81).
      i Upgrade osp.snapshots (or install a matching ospsuite) before migrating.

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

# add_compound errors on wrong class

    Code
      add_compound(snapshot, "not a compound")
    Condition
      Error in `snapshot$add_compound()`:
      ! Expected a Compound object or a list of them, but got <character>

# remove_compound warns when name is missing

    Code
      remove_compound(snapshot, "Other")
    Condition
      Warning:
      Compound 'Other' not found in snapshot
    Message
      v Removed 0 compound(s)

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
      ! Expected a Population object or a list of them, but got <character>

# add_protocol errors on wrong class

    Code
      add_protocol(snapshot, "not a protocol")
    Condition
      Error in `snapshot$add_protocol()`:
      ! Expected a Protocol object or a list of them, but got <character>

# remove_protocol warns when name is missing

    Code
      remove_protocol(snapshot, "Other")
    Condition
      Warning:
      Protocol 'Other' not found in snapshot
    Message
      v Removed 0 protocol(s)

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
      ! Expected an Event object or a list of them, but got <character>

# remove_event warns when name is missing

    Code
      remove_event(snapshot, "Other")
    Condition
      Warning:
      Event 'Other' not found in snapshot
    Message
      v Removed 0 event(s)

# remove_event warns on empty collection

    Code
      remove_event(snapshot, "Breakfast")
    Condition
      Warning:
      No events to remove

# remove_individual warns when name is missing

    Code
      remove_individual(snapshot, "Other")
    Condition
      Warning:
      Individual 'Other' not found in snapshot
    Message
      v Removed 0 individual(s)

# remove_individual warns on empty collection

    Code
      remove_individual(snapshot, "Subject_001")
    Condition
      Warning:
      No individuals to remove

# remove_individual reports the actual count when some names are missing

    Code
      remove_individual(snapshot, c(existing, "Other"))
    Condition
      Warning:
      Individual 'Other' not found in snapshot
    Message
      v Removed 1 individual(s)

# remove_formulation warns when name is missing

    Code
      remove_formulation(snapshot, "Other")
    Condition
      Warning:
      Formulation 'Other' not found in snapshot
    Message
      v Removed 0 formulation(s)

# remove_formulation warns on empty collection

    Code
      remove_formulation(snapshot, "Tablet")
    Condition
      Warning:
      No formulations to remove

# remove_population warns when name is missing

    Code
      remove_population(snapshot, "Other")
    Condition
      Warning:
      Population 'Other' not found in snapshot
    Message
      v Removed 0 population(s)

# remove_population warns on empty collection

    Code
      remove_population(snapshot, "pop_1")
    Condition
      Warning:
      No populations to remove

# remove_observed_data warns when name is missing

    Code
      remove_observed_data(snapshot, "Other")
    Condition
      Warning:
      Observed data 'Other' not found in snapshot
    Message
      v Removed 0 observed data item(s)

# remove_observed_data warns on empty collection

    Code
      remove_observed_data(snapshot, "Study A")
    Condition
      Warning:
      No observed data to remove

# remove_observed_data reports the actual count when some names are missing

    Code
      remove_observed_data(snapshot, c(dataset$name, "Other"))
    Condition
      Warning:
      Observed data 'Other' not found in snapshot
    Message
      v Removed 1 observed data item(s)

# remove_expression_profile warns when id is missing

    Code
      remove_expression_profile(snapshot, "Other|Human|Healthy")
    Condition
      Warning:
      Expression profile 'Other|Human|Healthy' not found in snapshot
    Message
      v Removed 0 expression profile(s)

# remove_expression_profile warns on empty collection

    Code
      remove_expression_profile(snapshot, "CYP3A4|Human|Healthy")
    Condition
      Warning:
      No expression profiles to remove

# add_observed_data exported wrapper errors on wrong class

    Code
      add_observed_data(snapshot, "not a dataset")
    Condition
      Error in `snapshot$add_observed_data()`:
      ! Expected a DataSet object or a list of them, but got <character>

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

# add_compound errors on an empty list

    Code
      add_compound(snapshot, list())
    Condition
      Error in `snapshot$add_compound()`:
      ! Must supply at least one <Compound>.

# add_individual errors on an empty list

    Code
      add_individual(snapshot, list())
    Condition
      Error in `snapshot$add_individual()`:
      ! Must supply at least one <Individual>.

# add_compound rejects a list with a wrong-class element

    Code
      add_compound(snapshot, bad)
    Condition
      Error in `snapshot$add_compound()`:
      ! Every element must be a <Compound> object.
      x Element 2 is <character>.

# add_individual rejects a list with a wrong-class element

    Code
      add_individual(snapshot, bad)
    Condition
      Error in `snapshot$add_individual()`:
      ! Every element must be an <Individual> object.
      x Element 2 is <character>.

# add_expression_profile rejects a list with a wrong-class element

    Code
      add_expression_profile(snapshot, bad)
    Condition
      Error in `snapshot$add_expression_profile()`:
      ! Every element must be an <ExpressionProfile> object.
      x Element 2 is <character>.

# add_*() reports the count of added entries

    Code
      snapshot <- add_compound(snapshot, create_compound(name = "X"))
    Message
      v Added 1 compound(s)
    Code
      snapshot <- add_compound(snapshot, list(create_compound(name = "Y"),
      create_compound(name = "Z")))
    Message
      v Added 2 compound(s)

