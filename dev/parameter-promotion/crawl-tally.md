# Raw parameter tally

Per-factory, per-parameter occurrence counts from the crawl of 113 pinned PK-Sim project snapshots (see `source-manifest.csv`). This is the human-readable view of the authoritative `crawl-tally.csv`; regenerate both with `crawl.R` (replay). Columns: `occurrences` (total block-level occurrences), `n_models` (distinct source models), `distinct_units` (`;`-joined, `(none)` = unitless), and `n_source_models` (the count of contributing models; the CSV's `source_models` column lists them by name).

## create_compound() (9 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| Molecular weight | Name | 265 | 113 | g/mol | 113 |
| Cl | Name | 79 | 37 | (none) | 37 |
| F | Name | 38 | 27 | (none) | 27 |
| Kd (FcRn) in endosomal space | Name | 9 | 8 | µmol/l | 8 |
| Enable supersaturation | Name | 8 | 5 | (none) | 5 |
| Radius (solute) | Name | 8 | 7 | nm;µm | 7 |
| Density (drug) | Name | 7 | 4 | g/cm³ | 4 |
| Treat precipitated drug as | Name | 7 | 4 | (none) | 4 |
| Aqueous diffusion coefficient | Name | 2 | 2 | dm²/min | 2 |

## create_event() (4 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| Meal energy content | Name | 14 | 11 | kcal | 11 |
| Meal fraction solid | Name | 3 | 3 | (none) | 3 |
| Gallbladder emptying lag time | Name | 2 | 1 | min | 1 |
| Meal volume | Name | 1 | 1 | l | 1 |

## create_expression_profile() (1285 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| OATP1B1\|Reference concentration | Path | 185 | 38 | µmol/l | 38 |
| OATP1B1\|t1/2 (intestine) | Path | 185 | 38 | h;min | 38 |
| OATP1B1\|t1/2 (liver) | Path | 185 | 38 | h;min | 38 |
| Organism\|Brain\|Intracellular\|OATP1B1\|Relative expression | Path | 185 | 38 | (none) | 38 |
| Organism\|Gonads\|Intracellular\|OATP1B1\|Relative expression | Path | 185 | 38 | (none) | 38 |
| Organism\|Heart\|Intracellular\|OATP1B1\|Relative expression | Path | 185 | 38 | (none) | 38 |
| Organism\|Liver\|Pericentral\|Intracellular\|OATP1B1\|Relative expression | Path | 185 | 38 | (none) | 38 |
| Organism\|Liver\|Periportal\|Intracellular\|OATP1B1\|Relative expression | Path | 185 | 38 | (none) | 38 |
| Organism\|Muscle\|Intracellular\|OATP1B1\|Relative expression | Path | 185 | 38 | (none) | 38 |
| Organism\|Lung\|Intracellular\|OATP1B1\|Relative expression | Path | 180 | 33 | (none) | 33 |
| CYP3A4\|Reference concentration | Path | 139 | 56 | µmol/l | 56 |
| CYP3A4\|t1/2 (intestine) | Path | 139 | 56 | h;min | 56 |
| CYP3A4\|t1/2 (liver) | Path | 139 | 56 | h;min | 56 |
| Organism\|Liver\|Pericentral\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|Liver\|Periportal\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|SmallIntestine\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|SmallIntestine\|Mucosa\|Duodenum\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|SmallIntestine\|Mucosa\|LowerIleum\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|SmallIntestine\|Mucosa\|LowerJejunum\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|SmallIntestine\|Mucosa\|UpperIleum\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|SmallIntestine\|Mucosa\|UpperJejunum\|Intracellular\|CYP3A4\|Relative expression | Path | 139 | 56 | (none) | 56 |
| Organism\|Brain\|Intracellular\|CYP3A4\|Relative expression | Path | 138 | 55 | (none) | 55 |
| Organism\|Gonads\|Intracellular\|CYP3A4\|Relative expression | Path | 138 | 55 | (none) | 55 |
| Organism\|Kidney\|Intracellular\|CYP3A4\|Relative expression | Path | 138 | 55 | (none) | 55 |
| Organism\|Lung\|Intracellular\|CYP3A4\|Relative expression | Path | 138 | 55 | (none) | 55 |
| AADAC\|Reference concentration | Path | 110 | 35 | µmol/l | 35 |
| AADAC\|t1/2 (intestine) | Path | 110 | 35 | h;min | 35 |
| AADAC\|t1/2 (liver) | Path | 110 | 35 | h;min | 35 |
| Organism\|Gonads\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|Heart\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|Kidney\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|LargeIntestine\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|LargeIntestine\|Mucosa\|ColonAscendens\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|LargeIntestine\|Mucosa\|ColonDescendens\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|LargeIntestine\|Mucosa\|ColonSigmoid\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|LargeIntestine\|Mucosa\|ColonTransversum\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|Liver\|Pericentral\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|Liver\|Periportal\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|Lung\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |
| Organism\|Muscle\|Intracellular\|AADAC\|Relative expression | Path | 110 | 35 | (none) | 35 |

_(1245 further localized-path rows omitted from this view; all are in `crawl-tally.csv`.)_

## create_population() (30 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| Age | Name | 73 | 16 | day(s);month(s);year(s) | 16 |
| CYP3A4\|Reference concentration | Name | 57 | 13 | (none) | 13 |
| CYP3A4\|t1/2 (intestine) | Name | 47 | 12 | (none) | 12 |
| CYP3A4\|t1/2 (liver) | Name | 47 | 12 | (none) | 12 |
| Weight | Name | 38 | 11 | kg | 11 |
| BMI | Name | 29 | 7 | kg/m² | 7 |
| CYP2D6\|Reference concentration | Name | 25 | 5 | (none) | 5 |
| CYP1A2\|Reference concentration | Name | 16 | 7 | (none) | 7 |
| CYP1A2\|t1/2 (liver) | Name | 16 | 7 | (none) | 7 |
| Height | Name | 16 | 7 | cm | 7 |
| CYP2D6\|t1/2 (liver) | Name | 15 | 4 | (none) | 4 |
| ABCB1\|Reference concentration | Name | 14 | 2 | (none) | 2 |
| UGT1A4\|Reference concentration | Name | 13 | 1 | (none) | 1 |
| CYP2C8\|Reference concentration | Name | 11 | 2 | (none) | 2 |
| CYP2C8\|t1/2 (liver) | Name | 11 | 2 | (none) | 2 |
| UGT2B7\|Reference concentration | Name | 10 | 1 | (none) | 1 |
| CYP2C9\|Reference concentration | Name | 9 | 6 | (none) | 6 |
| CYP2C9\|t1/2 (liver) | Name | 9 | 6 | (none) | 6 |
| MRP2\|Reference concentration | Name | 9 | 1 | (none) | 1 |
| CYP2C19\|Reference concentration | Name | 8 | 5 | (none) | 5 |
| CYP2C19\|t1/2 (liver) | Name | 8 | 5 | (none) | 5 |
| CYP3A5\|Reference concentration | Name | 8 | 6 | (none) | 6 |
| CYP3A5\|t1/2 (liver) | Name | 8 | 6 | (none) | 6 |
| ABCC2\|Reference concentration | Name | 4 | 1 | (none) | 1 |
| CYP2C9\|t1/2 (intestine) | Name | 4 | 1 | (none) | 1 |
| CYP2C18\|Reference concentration | Name | 3 | 1 | (none) | 1 |
| CYP2E1\|Reference concentration | Name | 3 | 1 | (none) | 1 |
| CYP2E1\|t1/2 (liver) | Name | 3 | 1 | (none) | 1 |
| CYP2C19\|t1/2 (intestine) | Name | 1 | 1 | (none) | 1 |
| UGT1A1\|Reference concentration | Name | 1 | 1 | (none) | 1 |

## create_process() (40 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| Km | Name | 662 | 82 | mM;nmol/l;µM;µmol/l | 82 |
| kcat | Name | 546 | 70 | 1/min | 70 |
| In vitro Vmax for liver microsomes | Name | 333 | 49 | nmol/min/mg mic. protein;pmol/min/mg mic. protein | 49 |
| Ki | Name | 258 | 49 | nmol/l;µmol/l | 49 |
| Content of CYP proteins in liver microsomes | Name | 207 | 31 | pmol/mg mic. protein | 31 |
| GFR fraction | Name | 203 | 91 | (none) | 91 |
| In vitro Vmax/recombinant enzyme | Name | 173 | 40 | nmol/min/pmol rec. enzyme;pmol/min/pmol rec. enzyme | 40 |
| Specific clearance | Name | 114 | 50 | 1/h;1/min | 50 |
| Vmax | Name | 113 | 41 | pmol/ml/min;µmol/l/min | 41 |
| Fraction unbound (experiment) | Name | 97 | 49 | (none) | 49 |
| Plasma clearance | Name | 96 | 48 | l/h/kg;ml/h/kg;ml/min/kg | 48 |
| EC50 | Name | 81 | 15 | µmol/l | 15 |
| Emax | Name | 81 | 15 | (none) | 15 |
| Transporter concentration | Name | 79 | 33 | nmol/l;µmol/l | 33 |
| Lipophilicity (experiment) | Name | 70 | 42 | Log Units | 42 |
| K_kinact_half | Name | 62 | 26 | µmol/l | 26 |
| kinact | Name | 62 | 26 | 1/h;1/min | 26 |
| Intrinsic clearance | Name | 47 | 25 | l/min;ml/min | 25 |
| Enzyme concentration | Name | 41 | 26 | pmol/l;µmol/l | 26 |
| In vitro Vmax/transporter | Name | 26 | 8 | nmol/min/pmol transporter;pmol/min/pmol transporter | 8 |
| Kd | Name | 26 | 18 | nmol/l;µmol/l | 18 |
| koff | Name | 26 | 18 | 1/min | 18 |
| In vitro CL/recombinant enzyme | Name | 22 | 11 | µl/min/pmol rec. enzyme | 11 |
| CLspec/[Enzyme] | Name | 12 | 8 | l/µmol/min | 8 |
| Vmax (liver tissue) | Name | 10 | 3 | pmol/min/g tissue;µmol/min/kg tissue | 3 |
| Tubular secretion | Name | 8 | 4 | l/min;ml/min | 4 |
| Ki_c | Name | 7 | 7 | nmol/l;µmol/l | 7 |
| Ki_u | Name | 7 | 7 | nmol/l;µmol/l | 7 |
| Body weight | Name | 4 | 4 | kg | 4 |
| Blood/Plasma concentration ratio | Name | 3 | 2 | (none) | 2 |
| Hill coefficient | Name | 3 | 3 | (none) | 3 |
| In vitro CL for liver microsomes | Name | 3 | 3 | µl/min/mg mic. protein | 3 |
| Blood flow rate (kidney) | Name | 2 | 2 | l/min | 2 |
| Blood flow rate (liver) | Name | 2 | 2 | l/min | 2 |
| Blood flow rate (portal vein) | Name | 2 | 2 | l/min | 2 |
| Volume (liver) | Name | 2 | 2 | l | 2 |
| Fraction intracellular (liver) | Name | 1 | 1 | (none) | 1 |
| Hematocrit | Name | 1 | 1 | (none) | 1 |
| TSmax | Name | 1 | 1 | µmol/min | 1 |
| TSspec | Name | 1 | 1 | 1/min | 1 |

## create_protocol() (5 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| InputDose | Name | 901 | 98 | mg;mg/kg;mg/m² | 98 |
| Start time | Name | 900 | 98 | h | 98 |
| Volume of water/body weight | Name | 596 | 84 | ml/kg | 84 |
| Infusion time | Name | 235 | 54 | h;min;s | 54 |
| End time | Name | 127 | 37 | day(s);h;month(s) | 37 |

## create_schema() (3 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| NumberOfRepetitions | Name | 809 | 85 | (none) | 85 |
| TimeBetweenRepetitions | Name | 809 | 85 | day(s);h;min | 85 |
| Start time | Name | 805 | 85 | day(s);h;min | 85 |

## create_schema_item() (4 distinct parameters)

| parameter_id | id_field | occurrences | n_models | distinct_units | n_source_models |
|---|---|---|---|---|---|
| InputDose | Name | 928 | 85 | mg;mg/kg | 85 |
| Start time | Name | 925 | 84 | day(s);h;min;s | 84 |
| Volume of water/body weight | Name | 835 | 81 | ml/kg | 81 |
| Infusion time | Name | 78 | 24 | h;min;s | 24 |

