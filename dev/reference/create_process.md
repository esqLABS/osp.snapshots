# Create a new compound process

Create a \[Process\] (a PK-Sim \`CompoundProcess\`) from named
arguments. This is a thin factory around \`Process\$new()\` that builds
the raw list shape for you.

For richer process structures (such as parameters with full value
origins), build the raw list directly or load a snapshot and copy the
relevant entry.

## Usage

``` r
create_process(
  internal_name,
  data_source,
  molecule = NULL,
  metabolite = NULL,
  species = NULL,
  parameters = NULL
)
```

## Arguments

- internal_name:

  Character. The PK-Sim \`InternalName\` for the process template (e.g.
  \`"SpecificBinding"\`, \`"MetabolizationSpecific_MM"\`,
  \`"GlomerularFiltration"\`). Required.

- data_source:

  Character. The \`DataSource\` string identifying the process.
  Required.

- molecule:

  Character. Optional molecule name for partial processes (e.g. the
  enzyme catalysing the reaction).

- metabolite:

  Character. Optional metabolite name for enzymatic processes.

- species:

  Character. Optional species name for species-dependent processes.

- parameters:

  List of \[Parameter\] objects (created with \[create_parameter()\]) or
  raw parameter lists to attach to the process.

## Value

A \[Process\] object.

## Examples

``` r
# Minimal protein-binding process
p <- create_process(
  internal_name = "SpecificBinding",
  data_source = "Publication X",
  molecule = "Albumin"
)

# Metabolizing enzyme with a parameter
p <- create_process(
  internal_name = "MetabolizationSpecific_MM",
  data_source = "Optimized",
  molecule = "CYP3A4",
  metabolite = "Hydroxy-Drug",
  parameters = list(
    create_parameter(name = "Km", value = 1.2, unit = "µmol/l")
  )
)
```
