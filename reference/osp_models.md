# Browse available OSPSuite building block templates

Browse and display all available building block templates from the
OSPSuite.BuildingBlockTemplates repository. This function helps users
discover what templates are available for loading with
\`load_snapshot()\`.

## Usage

``` r
osp_models(pattern = NULL)
```

## Arguments

- pattern:

  Character string. Optional pattern to filter template names (case
  insensitive). Uses regular expression matching.

## Value

A data.frame with template information (invisibly), while also printing
a formatted list to the console.

## Examples

``` r
if (FALSE) { # \dontrun{
# Browse all available templates
osp_models()

# Filter templates containing "midazolam"
osp_models(pattern = "midazolam")

# Get the data frame of templates for programmatic use
templates_df <- osp_models()
} # }
```
