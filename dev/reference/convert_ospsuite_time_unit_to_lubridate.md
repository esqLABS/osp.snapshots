# Convert ospsuite time units to lubridate-compatible units

Convert time units from ospsuite format to lubridate-compatible format.
This function handles the mapping of units like "day(s)" to "days", etc.

## Usage

``` r
convert_ospsuite_time_unit_to_lubridate(unit)
```

## Arguments

- unit:

  The ospsuite time unit to convert

## Value

A lubridate-compatible time unit
