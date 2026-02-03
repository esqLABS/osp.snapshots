# Compound class for OSP snapshot compounds

An R6 class that represents a compound in an OSP snapshot. This class
provides methods to access different properties of a compound and
display a summary of its information.

## Active bindings

- `data`:

  The raw data of the compound (read-only)

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

  The processes of the compound

- `calculation_methods`:

  The calculation methods of the compound

- `parameters`:

  The additional parameters of the compound (excluding molecular weight)

- `protein_binding_partners`:

  The protein binding partners data of the compound

- `metabolizing_enzymes`:

  The metabolizing enzymes data of the compound

- `hepatic_clearance`:

  The hepatic clearance data of the compound

- `transporter_proteins`:

  The transporter proteins data of the compound

- `renal_clearance`:

  The renal clearance data of the compound

- `biliary_clearance`:

  The biliary clearance data of the compound

- `inhibition`:

  The inhibition data of the compound

- `induction`:

  The induction data of the compound

## Methods

### Public methods

- [`Compound$new()`](#method-Compound-new)

- [`Compound$print()`](#method-Compound-print)

- [`Compound$to_df()`](#method-Compound-to_df)

- [`Compound$clone()`](#method-Compound-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Compound object

#### Usage

    Compound$new(data)

#### Arguments

- `data`:

  Raw compound data from a snapshot

#### Returns

A new Compound object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the compound including its properties and parameters.

#### Usage

    Compound$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Compound object for method chaining

------------------------------------------------------------------------

### Method `to_df()`

Convert compound data to tibbles for analysis

#### Usage

    Compound$to_df()

#### Returns

A tibble containing compound parameter data in the same format as legacy
code

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Compound$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
