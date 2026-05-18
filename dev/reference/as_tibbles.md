# Convert a snapshot collection to a tibble or list of tibbles

Unified bridge from a \`Snapshot\` to the tidyverse for any
building-block kind plus observed data. Replaces the eight per-kind
\`get\_\*\_dfs()\` functions as the canonical entry point; those remain
available as thin wrappers.

## Usage

``` r
as_tibbles(snapshot, kind)
```

## Arguments

- snapshot:

  A \`Snapshot\` object.

- kind:

  Character scalar naming the collection to convert. One of
  \`"compounds"\`, \`"individuals"\`, \`"formulations"\`,
  \`"populations"\`, \`"events"\`, \`"expression_profiles"\`,
  \`"protocols"\`, \`"observer_sets"\`, \`"observed_data"\`.

## Value

A tibble or a named list of tibbles, depending on \`kind\`:

- \`"compounds"\`, \`"protocols"\`, \`"observer_sets"\`,
  \`"observed_data"\`: a single tibble.

- \`"individuals"\`: a list with \`individuals\`,
  \`individuals_parameters\`, \`individuals_expressions\`.

- \`"formulations"\`: a list with \`formulations\`,
  \`formulations_parameters\`.

- \`"populations"\`: a list with \`populations\`,
  \`populations_parameters\`.

- \`"events"\`: a list with \`events\`, \`events_parameters\`.

- \`"expression_profiles"\`: a list with \`expression_profiles\`,
  \`expression_profiles_parameters\`.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam")

# Single tibble
compounds <- as_tibbles(snapshot, "compounds")

# List of tibbles
individuals <- as_tibbles(snapshot, "individuals")
individuals$individuals_parameters
} # }
```
