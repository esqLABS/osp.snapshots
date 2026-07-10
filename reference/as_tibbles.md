# Convert a snapshot collection to a tibble or list of tibbles

Unified bridge from a `Snapshot` to the tidyverse for any building-block
kind plus observed data. Replaces the nine per-kind `get_*_dfs()`
functions as the canonical entry point; those remain available as thin
wrappers. Omit `kind` to convert every kind of a snapshot in a single
call.

## Usage

``` r
as_tibbles(snapshot, kind = NULL)
```

## Arguments

- snapshot:

  A `Snapshot` object.

- kind:

  Character vector naming the collection(s) to convert, or `NULL` (the
  default) to convert every kind. Each element must be one of
  `"compounds"`, `"individuals"`, `"formulations"`, `"populations"`,
  `"events"`, `"expression_profiles"`, `"protocols"`, `"observer_sets"`,
  `"observed_data"`. A length-1 `kind` returns that kind's native shape
  directly (a tibble or a named list of tibbles); a length-2-or-more
  `kind` returns a named list keyed by the requested kinds, in request
  order; `NULL` returns a named list of all nine kinds in the order
  above.

## Value

When `kind` names a single collection, a tibble or a named list of
tibbles for that collection (see below). When `kind` names several
collections, or is `NULL` (all nine kinds), a named list keyed by the
requested kinds, each entry the native shape of that kind:

- `"compounds"`: a list with `properties` and `processes` tibbles.
  `properties` carries one row per (compound, physicochemical property)
  pair (plus folded process rows for backwards compatibility);
  `processes` is the long-form, one row per (compound, process,
  parameter) triple.

- `"protocols"`, `"observed_data"`: a single tibble.

- `"observer_sets"`: a list with `observer_sets` (one row per
  `ObserverSet`) and `observers` (one row per `Observer`, joinable to
  its parent via `observer_set_id` / `observer_set_name`).

- `"individuals"`: a list with `individuals`, `individuals_parameters`,
  `individuals_expressions`.

- `"formulations"`: a list with `formulations`,
  `formulations_parameters`.

- `"populations"`: a list with `populations`, `populations_parameters`.

- `"events"`: a list with `events`, `events_parameters`.

- `"expression_profiles"`: a list with `expression_profiles`,
  `expression_profiles_parameters`.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam")

# List of tibbles (compounds returns properties + processes)
compounds <- as_tibbles(snapshot, "compounds")
compounds$properties
compounds$processes

# List of tibbles
individuals <- as_tibbles(snapshot, "individuals")
individuals$individuals_parameters

# Omit `kind` to convert every kind at once, keyed by kind name
all_kinds <- as_tibbles(snapshot)
names(all_kinds)
} # }
```
