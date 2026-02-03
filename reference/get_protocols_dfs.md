# Get all protocols in a snapshot as a single consolidated data frame

This function extracts all protocols from a snapshot and converts them
to a single consolidated data frame containing all protocol information,
including simple protocol parameters and advanced protocol schema
details.

## Usage

``` r
get_protocols_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A tibble containing all protocol data with the following columns:

- protocol_id: Protocol identifier

- protocol_name: Protocol name

- is_advanced: Whether the protocol is advanced (schema-based)

- protocol_application_type: Application type (for simple protocols)

- protocol_dosing_interval: Dosing interval (for simple protocols)

- protocol_time_unit: Time unit

- schema_id: Schema identifier (NA for simple protocols)

- schema_name: Schema name (NA for simple protocols)

- schema_item_id: Schema item identifier (NA for simple protocols)

- schema_item_name: Schema item name (NA for simple protocols)

- schema_item_application_type: Schema item application type (NA for
  simple protocols)

- schema_item_formulation_key: Schema item formulation key (NA for
  simple protocols)

- parameter_name: Parameter name (NA if no parameters)

- parameter_value: Parameter value (NA if no parameters)

- parameter_unit: Parameter unit (NA if no parameters)

- parameter_source: Parameter source (NA if no parameters)

- parameter_description: Parameter description (NA if no parameters)

- parameter_source_id: Parameter source ID (NA if no parameters)

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all protocol data as a single data frame
protocols_df <- get_protocols_dfs(snapshot)

# Filter simple protocols
simple_protocols <- protocols_df[!protocols_df$is_advanced, ]

# Filter advanced protocols
advanced_protocols <- protocols_df[protocols_df$is_advanced, ]
} # }
```
