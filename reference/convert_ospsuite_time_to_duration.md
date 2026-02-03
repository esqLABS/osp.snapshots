# Convert time value and unit to lubridate duration

Convert a time value and ospsuite unit to a lubridate duration object.
This function handles unit conversion and special cases like
kiloseconds.

## Usage

``` r
convert_ospsuite_time_to_duration(value, unit)
```

## Arguments

- value:

  The time value

- unit:

  The ospsuite time unit

## Value

A lubridate duration object
