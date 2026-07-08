# ObserverSet data is read-only

    Code
      os$data <- list()
    Condition
      Error:
      ! data is read-only

# ObserverSet$name requires a non-empty scalar string

    Code
      os$name <- ""
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      os$name <- 5
    Condition
      Error:
      ! `name` must be a non-empty string

# add_observer_set() rejects non-ObserverSet inputs

    Code
      add_observer_set(snapshot, list())
    Condition
      Error in `snapshot$add_observer_set()`:
      ! Must supply at least one <ObserverSet>.

# add_observer_set() rejects non-Snapshot inputs

    Code
      add_observer_set(list(), os)
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <list>

# remove_observer_set() warns on missing name

    Code
      remove_observer_set(snapshot, "missing")
    Condition
      Warning:
      Observer set 'missing' not found in snapshot
    Message
      v Removed 0 observer set(s)

# remove_observer_set() warns on empty collection

    Code
      remove_observer_set(snapshot, "missing")
    Condition
      Warning:
      No observer sets to remove

# remove_observer_set() deduplicates warnings and reports actual count

    Code
      remove_observer_set(snapshot, c("drop", "drop", "missing", "missing"))
    Condition
      Warning:
      Observer set 'missing' not found in snapshot
    Message
      v Removed 1 observer set(s)

# print.ObserverSet prints a summary

    Code
      print(os)
    Output
      
      -- ObserverSet: BrainPlasmaConcentration ---------------------------------------
      * 2 observers

# print.observer_set_collection prints a summary

    Code
      print(sets)
    Output
      
      -- Observer Sets (2) -----------------------------------------------------------
      * A (1 observer)
      * B (0 observers)

---

    Code
      print(empty)
    Output
      
      -- Observer Sets (0) -----------------------------------------------------------
      i No observer sets found

