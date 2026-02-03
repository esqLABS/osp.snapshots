# Get all compounds in a snapshot as data frames

This function extracts all compounds from a snapshot and converts them
to data frames for easier analysis and visualization, following the same
format as the legacy compound dataframe functions.

## Usage

``` r
get_compounds_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A data frame with compound parameter data including:

- compound: Compound name

- category: Broad parameter category - "physicochemical_property" for
  basic properties, or descriptive categories like
  "protein_binding_partners", "metabolizing_enzymes",
  "hepatic_clearance", "transporter_proteins", "renal_clearance",
  "biliary_clearance", "inhibition", "induction" for process-related
  data

- type: Specific type within category - for physicochemical properties:
  property type (e.g., "lipophilicity", "fraction_unbound",
  "molecular_weight"); for processes: the InternalName from process data
  (e.g., "SpecificBinding", "Metabolization", "ActiveTransport")

- parameter: Specific parameter details (e.g., parameter names, molecule
  names)

- value: Parameter value (raw values from data)

- unit: Parameter unit

- data_source: Data source information from the snapshot

- source: Original source information

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all compound data as a data frame
compounds_df <- get_compounds_dfs(snapshot)

} # }
```
