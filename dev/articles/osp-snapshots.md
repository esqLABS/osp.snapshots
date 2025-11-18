# Getting Started with osp.snapshots

``` r
library(osp.snapshots)
library(dplyr)
```

## Overview

osp.snapshots provides a convenient R interface for working with PKSIM
project snapshots. This package allows you to:

- Import PKSIM snapshots from JSON files, URLs, or predefined templates
- Navigate and explore complex nested snapshot structures
- Modify building blocks and parameters in place
- Export modified snapshots back to JSON for use in PKSIM
- Convert snapshot data to data frames for analysis in R

## Loading a Snapshot

### From a File

The most common way to start is by loading a snapshot from a JSON file:

``` r
# Load from a local file
snapshot <- load_snapshot("path/to/your_snapshot.json")

# Load from a URL
snapshot <- load_snapshot("https://example.com/snapshot.json")

# From an OSP model
snapshot <- load_snapshot("Midazolam")
```

### Using the Package Example

For this tutorial, we’ll use the test snapshot included with the
package:

``` r
# Load the test snapshot
snapshot <- load_snapshot("Midazolam")

# View snapshot overview
snapshot
#> 
#> ── PKSIM Snapshot ──────────────────────────────────────────────────────────────
#> ℹ Version: 80 (PKSIM 12.0)
#> • Compounds: 1
#> • Events: 1
#> • ExpressionProfiles: 8
#> • Formulations: 2
#> • Individuals: 2
#> • ObservedData: 115
#> • ObservedDataClassifications: 47
#> • ParameterIdentifications: 3
#> • Protocols: 33
#> • SimulationClassifications: 4
#> • Simulations: 37
```

## Exploring Building Blocks

The snapshot contains various building blocks used in PKSIM simulations.
Let’s explore each type:

### Individuals

Individuals represent patient profiles with demographics and
physiological parameters:

``` r
# List all individuals
snapshot$individuals
#> 
#> ── Individuals (2) ─────────────────────────────────────────────────────────────
#> • European (P-gp modified, CYP3A4 36 h)
#> • Korean (Yu 2004 study)

# Examine a specific individual
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
#> 
#> ── Individual: European (P-gp modified, CYP3A4 36 h) | Seed: 17189110 ──────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: MALE
#> • Age: 30 year(s)
#> • Calculation Methods:
#>   • SurfaceAreaPlsInt_VAR1
#>   • Body surface area - Mosteller
#> 
#> ── Parameters ──
#> 
#> • Organism|Liver|EHC continuous fraction: 1
#> 
#> ── Expression Profiles ──
#> 
#> • CYP3A4|Human|European (P-gp modified, CYP3A4 36 h)
#> • AADAC|Human|European (P-gp modified, CYP3A4 36 h)
#> • P-gp|Human|European (P-gp modified, CYP3A4 36 h)
#> • OATP1B1|Human|European (P-gp modified, CYP3A4 36 h)
#> • ATP1A2|Human|European (P-gp modified, CYP3A4 36 h)
#> • UGT1A4|Human|European (P-gp modified, CYP3A4 36 h)
#> • GABRG2|Human|European (P-gp modified, CYP3A4 36 h)

# Access individual properties
individual <- snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
individual$age
#> [1] 30
individual$gender
#> [1] "MALE"
individual$species
#> [1] "Human"
```

### Compounds

Compounds define drug properties and ADME parameters:

``` r
# View available compounds
snapshot$compounds
#> 
#> ── Compounds (1) ───────────────────────────────────────────────────────────────
#> • Midazolam

# Examine a compound
snapshot$compounds$Midazolam
#> 
#> ── Compound: Midazolam ─────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> • Type: Small Molecule
#> • Plasma Protein Binding Partner: Albumin
#> • Molecular Weight: 325.78 g/mol
#> 
#> ── Calculation Methods ──
#> 
#> • Partition Coefficient: Rodgers and Rowland
#> • Permeability: PK-Sim Standard
#> 
#> ── Physicochemical Properties ──
#> 
#> • Lipophilicity:
#>   • 2.8972038771 Log Units [ParameterIdentification - (Value updated from 'PI
#>   Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on 2019-04-09
#>   16:10)]
#> • Fraction Unbound:
#>   • 0.031 [ParameterIdentification - (Value updated from 'PI Hohmann iv+po,
#>   Hyland feUr MDZG, Thummel feUr unchanged - Pint' on 2019-04-09 16:10)]
#> • Solubility:
#>   • Aqueous solubility: 0.13 mg/ml (pH 5) [Publication - InVitro - (Heikkinen
#>   2012)]
#>   • FaSSIF: 0.049 mg/ml (pH 6.5) [Publication - InVitro - (Heikkinen 2012)]
#>   • FeSSIF: 0.09 mg/ml (pH 5) [Publication - InVitro - (Heikkinen 2012)]
#> • Intestinal Permeability:
#>   • 0.00015549970673 cm/min [ParameterIdentification - (Value updated from 'PI
#>   Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on 2019-04-09
#>   16:10)]
#> • pKa Types:
#>   • Base: 6.2 [Unknown]
#>   • Acid: 10.95 [Unknown]
#> 
#> ── Processes ──
#> 
#> Processes (4 total):
#>   • Metabolism:
#>     • MetabolizationLiverMicrosomes_MM (CYP3A4): In vitro Vmax for liver
#>     microsomes=850 pmol/min/mg mic. protein, Km=4 µmol/l, kcat=8.7607941215
#>     1/min [Optimized]
#>     • MetabolizationLiverMicrosomes_MM (UGT1A4): In vitro Vmax for liver
#>     microsomes=276 pmol/min/mg mic. protein, Content of CYP proteins in liver
#>     microsomes=58 pmol/mg mic. protein, Km=37.8 µmol/l, kcat=3.5911771641 1/min
#>     [Optimized]
#>   • Transport:
#>     • SpecificBinding (GABRG2): koff=1 1/min, Kd=1.8 nmol/l [Buhr 1997]
#>   • Clearance:
#>     • GlomerularFiltration: GFR fraction=0.6401025724 [Optimized]
#> 
#> ── Additional Parameters ──
#> 
#> • Additional Parameters (2 total):
#>   • Cl: 1 [Unknown]
#>   • F: 1 [Unknown]
```

### Formulations

Formulations describe how drugs are formulated and released:

``` r
# View formulations
snapshot$formulations
#> 
#> ── Formulations (2) ────────────────────────────────────────────────────────────
#> • Oral solution (Dissolved)
#> • Tablet (Dormicum) (Weibull)

# Examine a tablet formulation
snapshot$formulations$`Tablet (Dormicum)`
#> 
#> ── Formulation: Tablet (Dormicum) ──────────────────────────────────────────────
#> • Type: Weibull
#> 
#> ── Parameters ──
#> 
#> • Dissolution time (50% dissolved): 0.0107481462 min
#> • Lag time: 0 min
#> • Dissolution shape: 4.3802943225
#> • Use as suspension: 1
```

### Other Building Blocks

The snapshot includes several other building block types:

``` r
# Populations - groups of virtual individuals
snapshot$populations
#> 
#> ── Populations (0) ─────────────────────────────────────────────────────────────
#> ℹ No populations found

# Events - simulation events like meals
snapshot$events
#> 
#> ── Events (1) ──────────────────────────────────────────────────────────────────
#> • High-fat breakfast (Meal: High-fat breakfast (Human))

# Protocols - dosing regimens
snapshot$protocols
#> 
#> ── Protocols (33) ──────────────────────────────────────────────────────────────
#> • iv 0.075 mg/kg (1 min) (Simple - Intravenous - Once)
#> • iv 0.05 mg/kg (30 min) (Simple - Intravenous - Once)
#> • iv 1 mg (5 min) (Simple - Intravenous - Once)
#> • iv 0.001 mg (5 min) (Simple - Intravenous - Once)
#> • iv 1 mg (bolus) (Simple - Intravenous bolus - Once)
#> • iv 2 mg (2 min) (Simple - Intravenous - Once)
#> • iv 2 mg (bolus) (Simple - Intravenous bolus - Once)
#> • iv 0.05 mg/kg (2 min) (Simple - Intravenous - Once)
#> • iv 5 mg (30 sec) (Simple - Intravenous - Once)
#> • iv 5 mg (bolus) (Simple - Intravenous bolus - Once)
#> • iv 0.05 mg/kg (bolus) (Simple - Intravenous bolus - Once)
#> • iv 0.15 mg/kg (bolus) (Simple - Intravenous bolus - Once)
#> • po 1 mg (Simple - Oral - Once)
#> • po 5 mg (Simple - Oral - Once)
#> • po 7.5 mg (Simple - Oral - Once)
#> • po 0.075 mg (Simple - Oral - Once)
#> • po 3 mg (Simple - Oral - Once)
#> • po 4 mg (Simple - Oral - Once)
#> • po 6 mg (Simple - Oral - Once)
#> • po 8 mg (Simple - Oral - Once)
#> • po 15 mg (Simple - Oral - Once)
#> • po 2 mg (Simple - Oral - Once)
#> • po 0.075 mg/kg (Simple - Oral - Once)
#> • po 10 mg (Simple - Oral - Once)
#> • po 20 mg (Simple - Oral - Once)
#> • po 40 mg (Simple - Oral - Once)
#> • po 0.003 mg (Simple - Oral - Once)
#> • po 15 mg (1 h delayed) (Advanced - 1 schema)
#> • po 2.5 mg (Simple - Oral - Once)
#> • po 0.01 mg (Simple - Oral - Once)
#> • po 3.5 mg (Simple - Oral - Once)
#> • Mikus 2017 (Advanced - 2 schemas)
#> • iv 1 mg (2 min) (Simple - Intravenous - Once)

# Expression profiles - protein expression data
snapshot$expression_profiles
#> 
#> ── Expression Profiles (8) ─────────────────────────────────────────────────────
#> • CYP3A4 (Enzyme, Human, European (P-gp modified, CYP3A4 36 h))
#> • AADAC (Enzyme, Human, European (P-gp modified, CYP3A4 36 h))
#> • P-gp (Transporter, Human, European (P-gp modified, CYP3A4 36 h))
#> • OATP1B1 (Transporter, Human, European (P-gp modified, CYP3A4 36 h))
#> • ATP1A2 (OtherProtein, Human, European (P-gp modified, CYP3A4 36 h))
#> • UGT1A4 (Enzyme, Human, European (P-gp modified, CYP3A4 36 h))
#> • GABRG2 (OtherProtein, Human, European (P-gp modified, CYP3A4 36 h))
#> • CYP3A4 (Enzyme, Human, Korean (Yu 2004 study))
```

## Modifying Building Blocks

All building blocks are mutable and can be modified directly:

### Changing Individual Properties

``` r
# Modify age
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`$age <- 45

# Modify parameter values
individual$parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$value <- 0.7

# Verify changes
snapshot$individuals$`European (P-gp modified, CYP3A4 36 h)`
#> 
#> ── Individual: European (P-gp modified, CYP3A4 36 h) | Seed: 17189110 ──────────
#> 
#> ── Characteristics ──
#> 
#> • Species: Human
#> • Population: European_ICRP_2002
#> • Gender: MALE
#> • Age: 45 year(s)
#> • Calculation Methods:
#>   • SurfaceAreaPlsInt_VAR1
#>   • Body surface area - Mosteller
#> 
#> ── Parameters ──
#> 
#> • Organism|Liver|EHC continuous fraction: 1
#> • : 0.7
#> 
#> ── Expression Profiles ──
#> 
#> • CYP3A4|Human|European (P-gp modified, CYP3A4 36 h)
#> • AADAC|Human|European (P-gp modified, CYP3A4 36 h)
#> • P-gp|Human|European (P-gp modified, CYP3A4 36 h)
#> • OATP1B1|Human|European (P-gp modified, CYP3A4 36 h)
#> • ATP1A2|Human|European (P-gp modified, CYP3A4 36 h)
#> • UGT1A4|Human|European (P-gp modified, CYP3A4 36 h)
#> • GABRG2|Human|European (P-gp modified, CYP3A4 36 h)
```

### Working with Parameters

Parameters have special behavior and validation:

``` r

# Access parameters collection
params <- snapshot$individuals$`Korean (Yu 2004 study)`$parameters
params
#> Parameter Collection with 1 parameters:
#> Name                                     | Value           | Unit
#> -----------------------------------------|-----------------|----------------
#> Organism|Liver|EHC continuous fraction   | 1               |

# Get a specific parameter
params$`Organism|Liver|EHC continuous fraction`
#> 
#> ── Parameter: Organism|Liver|EHC continuous fraction 
#> • Value: 1
#> • Source: Unknown

# Modify parameter value
params$`Organism|Liver|EHC continuous fraction`$value <- 0.4

params
#> Parameter Collection with 1 parameters:
#> Name                                     | Value           | Unit
#> -----------------------------------------|-----------------|----------------
#> Organism|Liver|EHC continuous fraction   | 0.4             |
```

## Working with Observed Data

Snapshots often contain observed data from clinical studies:

``` r
# View observed data collection
snapshot$observed_data
#> 
#> ── Observed Data (115) ─────────────────────────────────────────────────────────
#> • Bornemann 1986 - 1 h after a meal - Midazolam - PO - 15 mg - Plasma - agg.
#> (n=18)
#> • Olkkola 1993 - po Control (Perpetrator Placebo) - Midazolam - PO - 15 mg -
#> Plasma - agg. (n=12)
#> • Allonen 1981 - oral - Midazolam - PO - 15 mg - Plasma - agg. (n=6)
#> • Allonen 1981 - iv - Midazolam - IV - 0.075 mg/kg - Plasma - agg. (n=6)
#> • Backman 1996 - Control (Perpetrator Placebo) - Midazolam - PO - 15 mg -
#> Plasma - agg. (n=10)
#> ... and 110 more

# Access a specific dataset
obs_data <- snapshot$observed_data[[1]]
obs_data
#> <DataSet>
#>   • Name: Bornemann 1986 - 1 h after a meal - Midazolam - PO - 15 mg - Plasma -
#>   agg. (n=18)
#>   • X dimension: Time
#>   • X unit: h
#>   • Y dimension: Concentration (mass)
#>   • Y unit: mg/l
#>   • Error type: NULL
#>   • Error unit: NULL
#>   • Molecular weight: 325.77
#>   • LLOQ: NULL
#> Meta data:
#>   • DB Version: OSP DATABASE
#>   • ID: 104
#>   • Study Id: Bornemann 1986
#>   • Reference: https://www.ncbi.nlm.nih.gov/pubmed/2936766
#>   • Source: Fig. 1
#>   • Grouping: 1 h after a meal
#>   • Data type: aggregated
#>   • N: 18
#>   • Molecule: Midazolam
#>   • Species: Human
#>   • Organ: Peripheral Venous Blood
#>   • Compartment: Plasma
#>   • Route: PO
#>   • Dose: 15 mg
#>   • Times of Administration [h]: 1
#>   • Formulation: .
#>   • Food state: Fed
#>   • Comment: .

# These are ospsuite DataSet objects
class(obs_data)
#> [1] "DataSet"       "DotNetWrapper" "NetObject"     "R6"
```

## Exporting Snapshots

After making modifications, you can export the snapshot back to a JSON
file:

``` r
# Export to a new file
export_snapshot(snapshot, "modified_snapshot.json")
```

The exported file can be imported back into PKSIM, preserving all your
modifications.

## Next Steps

Now that you understand the basics, explore these advanced topics:

- **Working with Data Frames**: Learn how to convert building blocks to
  data frames for analysis with
  [`vignette("working-with-dataframes")`](https://esqlabs.github.io/osp.snapshots/dev/articles/working-with-dataframes.md)
- **Creating Building Blocks**: Create new individuals, formulations,
  and other building blocks from scratch with
  [`vignette("creating-building-blocks")`](https://esqlabs.github.io/osp.snapshots/dev/articles/creating-building-blocks.md)
