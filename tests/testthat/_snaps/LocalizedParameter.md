# LocalizedParameter$data is read-only

    Code
      param$data <- list()
    Condition
      Error:
      ! data is read-only

# LocalizedParameter accepts Name as a legacy path fallback

    Code
      param <- LocalizedParameter$new(list(Name = "Dose", Value = 100))
    Condition
      Warning:
      Using Name as a path is deprecated for <LocalizedParameter>.
      i Supply Path instead. Name will be dropped from the data.
      This warning is displayed once every 8 hours.

# LocalizedParameter errors when no path is supplied

    Code
      LocalizedParameter$new(list(Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is empty

    Code
      LocalizedParameter$new(list(Path = "", Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is NA

    Code
      LocalizedParameter$new(list(Path = NA_character_, Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is zero-length

    Code
      LocalizedParameter$new(list(Path = character(0), Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# LocalizedParameter errors when path is a multi-element vector

    Code
      LocalizedParameter$new(list(Path = c("Organism|A", "Organism|B"), Value = 1.5))
    Condition
      Error in `initialize()`:
      ! <LocalizedParameter> requires a single non-empty path.

# Renal rename leaves the segment unchanged when the compound is ambiguous

    Code
      snapshot <- Snapshot$new(data)
    Message
      i Creating snapshot from list data
      i Could not determine the owning compound for the renal-clearance container "GlomerularFiltration" in path "Sim|Organism|Kidney|GlomerularFiltration|Plasma clearance"; leaving the segment unchanged.
      v Snapshot loaded successfully

