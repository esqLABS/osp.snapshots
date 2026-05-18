# Compound class for OSP snapshot compounds

An R6 class that represents a compound in an OSP snapshot. This class
provides methods to access different properties of a compound and
display a summary of its information.

Compound processes are exposed via \`\$processes\`, a flat named list of
\[Process\] objects. The per-category tibble accessors
(\`\$protein_binding_partners\`, \`\$metabolizing_enzymes\`,
\`\$hepatic_clearance\`, \`\$transporter_proteins\`,
\`\$renal_clearance\`, \`\$biliary_clearance\`, \`\$inhibition\`,
\`\$induction\`) are \[\`lifecycle::deprecate_soft()\`\]-warned in
favour of \`\$processes\` and the long-form \`processes\` tibble
returned by \[get_compounds_dfs()\].

## Active bindings

- `data`:

  The raw data of the compound (read-only). Refreshed from the embedded
  \[CalculationMethodCache\] and the cached \[Process\] objects so that
  mutations flow back to the export payload.

- `name`:

  The name of the compound

- `is_small_molecule`:

  Whether the compound is a small molecule

- `plasma_protein_binding_partner`:

  The plasma protein binding partner of the compound

- `molecular_weight`:

  The molecular weight of the compound

- `molecular_weight_unit`:

  The unit of the molecular weight

- `lipophilicity`:

  The lipophilicity data of the compound

- `fraction_unbound`:

  The fraction unbound data of the compound

- `solubility`:

  The solubility data of the compound

- `intestinal_permeability`:

  The intestinal permeability data of the compound

- `pka_types`:

  The pKa types of the compound

- `processes`:

  A flat named list of \[Process\] objects, one per entry in the
  compound's \`Processes\` array. Duplicate names are disambiguated with
  a numeric suffix (\`\_1\`, \`\_2\`, ...). The list is built once at
  construction so that state changes made on a \[Process\] persist
  across accesses.

- `calculation_methods`:

  A \[CalculationMethodCache\] holding the compound's calculation
  methods.

- `parameters`:

  The additional parameters of the compound (excluding molecular weight)

- `protein_binding_partners`:

  Deprecated. Filter \[get_compounds_dfs()\]\`\$processes\` on
  \`category == "protein_binding_partners"\`, or iterate
  \`self\$processes\` and check \`process\$category\`.

- `metabolizing_enzymes`:

  Deprecated. See \`\$protein_binding_partners\`.

- `hepatic_clearance`:

  Deprecated. See \`\$protein_binding_partners\`.

- `transporter_proteins`:

  Deprecated. See \`\$protein_binding_partners\`.

- `renal_clearance`:

  Deprecated. See \`\$protein_binding_partners\`.

- `biliary_clearance`:

  Deprecated. See \`\$protein_binding_partners\`.

- `inhibition`:

  Deprecated. See \`\$protein_binding_partners\`.

- `induction`:

  Deprecated. See \`\$protein_binding_partners\`.

## Methods

### Public methods

- [`Compound$new()`](#method-Compound-initialize)

- [`Compound$print()`](#method-Compound-print)

- [`Compound$to_df()`](#method-Compound-to_df)

- [`Compound$clone()`](#method-Compound-clone)

------------------------------------------------------------------------

### `Compound$new()`

Create a new Compound object

#### Usage

    Compound$new(data)

#### Arguments

- `data`:

  Raw compound data from a snapshot

#### Returns

A new Compound object

------------------------------------------------------------------------

### `Compound$print()`

Print a summary of the compound including its properties and parameters.

#### Usage

    Compound$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Compound object for method chaining

------------------------------------------------------------------------

### `Compound$to_df()`

Convert this compound's physicochemical properties and process
parameters to a single long-form tibble (legacy shape).

Used by \[get_compounds_dfs()\] to assemble the compound-wide
\`properties\` tibble. The process-derived rows produced here are
\[\`lifecycle::deprecate_soft()\`\]-warned at the
\[get_compounds_dfs()\] entry point; prefer the long-form \`processes\`
tibble returned alongside.

#### Usage

    Compound$to_df()

#### Returns

A tibble with columns \`compound\`, \`category\`, \`type\`,
\`parameter\`, \`value\`, \`unit\`, \`data_source\`, \`source\`.

------------------------------------------------------------------------

### `Compound$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Compound$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
