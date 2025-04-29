# Populations can be accessed from snapshot

    Code
      snapshot$populations
    Message
      
      -- Populations (6) -------------------------------------------------------------
      * pop_1 [Source: European_ICRP_2002] (100 individuals)
      * pop2 [Source: European_ICRP_2002] (10 individuals)
      * pop3 [Source: Asian_Tanaka_1996] (10 individuals)
      * pop4 [Source: European_ICRP_2002] (10 individuals)
      * pop6 [Source: European_ICRP_2002] (15 individuals)
      * pop7 [Source: Asian_Tanaka_1996] (12 individuals)

---

    Code
      print(pop)
    Message
      
      -- Population: pop_1 (Seed: 202395203) --
      
      Individual name: European (P-gp modified, CYP3A4 36 h)
      Source Population: European_ICRP_2002
      Number of individuals: 100
      Proportion of females: 50%
      Age range: 0 - 100 year(s)
      
      -- Advanced Parameters 
      4 advanced parameters defined

# Populations can be modified from the snapshot object and snapshot data is updated

    Code
      snapshot$data$Populations[[1]]
    Output
      $Name
      pop_1_modified
      
      $Seed
      [1] 12345678
      
      $Settings
      $Settings$NumberOfIndividuals
      [1] 110
      
      $Settings$ProportionOfFemales
      [1] 75
      
      $Settings$Age
      $Settings$Age$Min
      [1] 0
      
      $Settings$Age$Max
      [1] 100
      
      $Settings$Age$Unit
      [1] "year(s)"
      
      
      $Settings$Individual
      $Settings$Individual$Name
      [1] "European (P-gp modified, CYP3A4 36 h)"
      
      $Settings$Individual$Seed
      [1] 17189110
      
      $Settings$Individual$OriginData
      $Settings$Individual$OriginData$CalculationMethods
      [1] "SurfaceAreaPlsInt_VAR1"        "Body surface area - Mosteller"
      
      $Settings$Individual$OriginData$Species
      [1] "Human"
      
      $Settings$Individual$OriginData$Population
      [1] "European_ICRP_2002"
      
      $Settings$Individual$OriginData$Gender
      [1] "MALE"
      
      $Settings$Individual$OriginData$Age
      $Settings$Individual$OriginData$Age$Value
      [1] 30
      
      $Settings$Individual$OriginData$Age$Unit
      [1] "year(s)"
      
      
      
      $Settings$Individual$Parameters
      $Settings$Individual$Parameters[[1]]
      $Settings$Individual$Parameters[[1]]$Path
      [1] "Organism|Liver|EHC continuous fraction"
      
      $Settings$Individual$Parameters[[1]]$Value
      [1] 1
      
      $Settings$Individual$Parameters[[1]]$ValueOrigin
      $Settings$Individual$Parameters[[1]]$ValueOrigin$Source
      [1] "Unknown"
      
      
      
      
      $Settings$Individual$ExpressionProfiles
      [1] "CYP3A4|Human|Healthy"  "AADAC|Human|Healthy"   "P-gp|Human|Healthy"   
      [4] "OATP1B1|Human|Healthy" "ATP1A2|Human|Healthy"  "UGT1A4|Human|Healthy" 
      [7] "GABRG2|Human|Healthy" 
      
      
      
      $AdvancedParameters
      $AdvancedParameters[[1]]
      $AdvancedParameters[[1]]$Name
      [1] "CYP3A4|t1/2 (intestine)"
      
      $AdvancedParameters[[1]]$Seed
      [1] 202400546
      
      $AdvancedParameters[[1]]$DistributionType
      [1] "Normal"
      
      $AdvancedParameters[[1]]$Parameters
      $AdvancedParameters[[1]]$Parameters[[1]]
      $AdvancedParameters[[1]]$Parameters[[1]]$Name
      [1] "Mean"
      
      $AdvancedParameters[[1]]$Parameters[[1]]$Value
      [1] 23
      
      $AdvancedParameters[[1]]$Parameters[[1]]$Unit
      [1] "h"
      
      $AdvancedParameters[[1]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[1]]$Parameters[[1]]$ValueOrigin$Source
      [1] "ParameterIdentification"
      
      
      
      $AdvancedParameters[[1]]$Parameters[[2]]
      $AdvancedParameters[[1]]$Parameters[[2]]$Name
      [1] "Deviation"
      
      $AdvancedParameters[[1]]$Parameters[[2]]$Value
      [1] 12
      
      $AdvancedParameters[[1]]$Parameters[[2]]$Unit
      [1] "h"
      
      $AdvancedParameters[[1]]$Parameters[[2]]$ValueOrigin
      $AdvancedParameters[[1]]$Parameters[[2]]$ValueOrigin$Source
      [1] "Publication"
      
      $AdvancedParameters[[1]]$Parameters[[2]]$ValueOrigin$Description
      [1] "c01835608"
      
      
      
      
      
      $AdvancedParameters[[2]]
      $AdvancedParameters[[2]]$Name
      [1] "Organism|Bone|Lymph flow rate"
      
      $AdvancedParameters[[2]]$Seed
      [1] 203191984
      
      $AdvancedParameters[[2]]$DistributionType
      [1] "Discrete"
      
      $AdvancedParameters[[2]]$Parameters
      $AdvancedParameters[[2]]$Parameters[[1]]
      $AdvancedParameters[[2]]$Parameters[[1]]$Name
      [1] "Mean"
      
      $AdvancedParameters[[2]]$Parameters[[1]]$Value
      [1] 0.0001140143
      
      $AdvancedParameters[[2]]$Parameters[[1]]$Unit
      [1] "l/min"
      
      $AdvancedParameters[[2]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[2]]$Parameters[[1]]$ValueOrigin$Source
      [1] "ParameterIdentification"
      
      
      
      
      
      $AdvancedParameters[[3]]
      $AdvancedParameters[[3]]$Name
      [1] "Organism|Bone|Interstitial|pH"
      
      $AdvancedParameters[[3]]$Seed
      [1] 203212109
      
      $AdvancedParameters[[3]]$DistributionType
      [1] "Uniform"
      
      $AdvancedParameters[[3]]$Parameters
      $AdvancedParameters[[3]]$Parameters[[1]]
      $AdvancedParameters[[3]]$Parameters[[1]]$Name
      [1] "Minimum"
      
      $AdvancedParameters[[3]]$Parameters[[1]]$Value
      [1] 12
      
      $AdvancedParameters[[3]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[3]]$Parameters[[1]]$ValueOrigin$Source
      [1] "Other"
      
      $AdvancedParameters[[3]]$Parameters[[1]]$ValueOrigin$Description
      [1] "Assumed"
      
      
      
      $AdvancedParameters[[3]]$Parameters[[2]]
      $AdvancedParameters[[3]]$Parameters[[2]]$Name
      [1] "Maximum"
      
      $AdvancedParameters[[3]]$Parameters[[2]]$Value
      [1] 14
      
      $AdvancedParameters[[3]]$Parameters[[2]]$ValueOrigin
      $AdvancedParameters[[3]]$Parameters[[2]]$ValueOrigin$Source
      [1] "Publication"
      
      $AdvancedParameters[[3]]$Parameters[[2]]$ValueOrigin$Description
      [1] "R24-4085"
      
      
      
      
      
      $AdvancedParameters[[4]]
      $AdvancedParameters[[4]]$Name
      [1] "Organism|Gallbladder|Gallbladder ejection half-time"
      
      $AdvancedParameters[[4]]$Seed
      [1] 203229343
      
      $AdvancedParameters[[4]]$DistributionType
      [1] "Discrete"
      
      $AdvancedParameters[[4]]$Parameters
      $AdvancedParameters[[4]]$Parameters[[1]]
      $AdvancedParameters[[4]]$Parameters[[1]]$Name
      [1] "Mean"
      
      $AdvancedParameters[[4]]$Parameters[[1]]$Value
      [1] 19.7
      
      $AdvancedParameters[[4]]$Parameters[[1]]$Unit
      [1] "min"
      
      $AdvancedParameters[[4]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[4]]$Parameters[[1]]$ValueOrigin$Source
      [1] "Publication"
      
      $AdvancedParameters[[4]]$Parameters[[1]]$ValueOrigin$Description
      [1] "R24-4085"
      
      
      
      
      
      

# Populations can be converted to data frames

    Code
      knitr::kable(dfs)
    Output
      
      
      |population_id  |name           |        seed| number_of_individuals| proportion_of_females|source_population  |individual_name                       | age_min| age_max|age_unit | weight_min| weight_max|weight_unit | height_min| height_max|height_unit | bmi_min| bmi_max|bmi_unit | egfr_min| egfr_max|egfr_unit     |
      |:--------------|:--------------|-----------:|---------------------:|---------------------:|:------------------|:-------------------------------------|-------:|-------:|:--------|----------:|----------:|:-----------|----------:|----------:|:-----------|-------:|-------:|:--------|--------:|--------:|:-------------|
      |pop_1_modified |pop_1_modified |    12345678|                   110|                    75|European_ICRP_2002 |European (P-gp modified, CYP3A4 36 h) |       0|     100|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      NA|NA       |       NA|       NA|NA            |
      |pop2           |pop2           | -1746093953|                    10|                    50|European_ICRP_2002 |European (P-gp modified, CYP3A4 36 h) |      46|      87|year(s)  |         56|        120|kg          |        160|        189|cm          |      NA|      NA|NA       |       NA|       NA|NA            |
      |pop3           |pop3           |  2040342218|                    10|                     2|Asian_Tanaka_1996  |Korean (Yu 2004 study)                |      40|      77|year(s)  |         55|        120|kg          |        160|        190|cm          |      23|      67|kg/m²    |       NA|       NA|NA            |
      |pop4           |pop4           |   235227359|                    10|                    50|European_ICRP_2002 |European (P-gp modified, CYP3A4 36 h) |      45|      90|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      25|kg/m²    |       NA|       NA|NA            |
      |pop6           |pop6           |   324184656|                    15|                    50|European_ICRP_2002 |CKD                                   |       0|     100|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      NA|NA       |        0| 60.00159|ml/min/1.73m² |
      |pop7           |pop7           |   486878578|                    12|                    50|Asian_Tanaka_1996  |Korean (Yu 2004 study)                |      34|      81|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      NA|NA       |       NA|       NA|NA            |
      
      |population_id  |parameter                                                                   |        seed|distribution_type |statistic          |     value|unit     |source                  |description |
      |:--------------|:---------------------------------------------------------------------------|-----------:|:-----------------|:------------------|---------:|:--------|:-----------------------|:-----------|
      |pop_1_modified |CYP3A4&#124;t1/2 (intestine)                                                |   202400546|Normal            |Mean               | 23.000000|h        |ParameterIdentification |NA          |
      |pop_1_modified |CYP3A4&#124;t1/2 (intestine)                                                |   202400546|Normal            |Deviation          | 12.000000|h        |Publication             |c01835608   |
      |pop_1_modified |Organism&#124;Bone&#124;Lymph flow rate                                     |   203191984|Discrete          |Mean               |  0.000114|l/min    |ParameterIdentification |NA          |
      |pop_1_modified |Organism&#124;Bone&#124;Interstitial&#124;pH                                |   203212109|Uniform           |Minimum            | 12.000000|NA       |Other                   |Assumed     |
      |pop_1_modified |Organism&#124;Bone&#124;Interstitial&#124;pH                                |   203212109|Uniform           |Maximum            | 14.000000|NA       |Publication             |R24-4085    |
      |pop_1_modified |Organism&#124;Gallbladder&#124;Gallbladder ejection half-time               |   203229343|Discrete          |Mean               | 19.700000|min      |Publication             |R24-4085    |
      |pop2           |Organism&#124;pH (intracellular)                                            | -1746013984|LogNormal         |Mean               |  7.000000|NA       |ParameterIdentification |NA          |
      |pop2           |Organism&#124;pH (intracellular)                                            | -1746013984|LogNormal         |GeometricDeviation |  1.000000|NA       |Publication             |n00265826   |
      |pop2           |Organism&#124;Vf (lipid, blood cells)                                       | -1745931843|Uniform           |Minimum            |  0.000000|NA       |Other                   |Assumed     |
      |pop2           |Organism&#124;Vf (lipid, blood cells)                                       | -1745931843|Uniform           |Maximum            |  1.000000|NA       |Other                   |Assumed     |
      |pop3           |CYP3A4&#124;Reference concentration                                         |  2040343562|Normal            |Mean               |  3.627133|µmol/l   |Other                   |Assumed     |
      |pop3           |CYP3A4&#124;Reference concentration                                         |  2040343562|Normal            |Deviation          |  0.200000|µmol/l   |Other                   |Assumed     |
      |pop3           |CYP3A4&#124;t1/2 (intestine)                                                |  2040343578|Normal            |Mean               | 12.000000|h        |NA                      |NA          |
      |pop3           |CYP3A4&#124;t1/2 (intestine)                                                |  2040343578|Normal            |Deviation          |  0.000000|h        |NA                      |NA          |
      |pop3           |Organism&#124;Lumen&#124;Stomach&#124;pH in fasted state                    | -1998157671|Normal            |Mean               |  5.000000|NA       |ParameterIdentification |NA          |
      |pop3           |Organism&#124;Lumen&#124;Stomach&#124;pH in fasted state                    | -1998157671|Normal            |Deviation          |  0.300000|NA       |ParameterIdentification |NA          |
      |pop3           |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Fraction mucosa | -1998136828|LogNormal         |Mean               |  0.260000|NA       |Other                   |Assumed     |
      |pop3           |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Fraction mucosa | -1998136828|LogNormal         |GeometricDeviation | 56.000000|NA       |NA                      |NA          |
      |pop3           |Organism&#124;Bone&#124;Hydraulic conductivity                              | -1998090937|Normal            |Mean               |  0.000324|ml/min/N |Other                   |Assumed     |
      |pop3           |Organism&#124;Bone&#124;Hydraulic conductivity                              | -1998090937|Normal            |Deviation          | 56.000000|ml/min/N |ParameterIdentification |NA          |
      |pop3           |Organism&#124;LargeIntestine&#124;Mucosa&#124;Caecum&#124;Fraction mucosa   | -1998056218|Uniform           |Minimum            |  0.200000|NA       |ParameterIdentification |NA          |
      |pop3           |Organism&#124;LargeIntestine&#124;Mucosa&#124;Caecum&#124;Fraction mucosa   | -1998056218|Uniform           |Maximum            |  1.000000|NA       |ParameterIdentification |NA          |
      |pop3           |Organism&#124;Heart&#124;Hydraulic conductivity                             | -1991794781|Normal            |Mean               |  0.000516|ml/min/N |ParameterIdentification |NA          |
      |pop3           |Organism&#124;Heart&#124;Hydraulic conductivity                             | -1991794781|Normal            |Deviation          | 56.000000|ml/min/N |ParameterIdentification |NA          |
      |pop3           |Organism&#124;Fraction endosomal (global)                                   | -1991777546|Normal            |Mean               |  0.200000|NA       |ParameterIdentification |NA          |
      |pop3           |Organism&#124;Fraction endosomal (global)                                   | -1991777546|Normal            |Deviation          |  3.000000|NA       |Other                   |Assumed     |
      |pop3           |Organism&#124;pH (blood cells)                                              | -1991750437|Normal            |Mean               |  7.220000|NA       |ParameterIdentification |NA          |
      |pop3           |Organism&#124;pH (blood cells)                                              | -1991750437|Normal            |Deviation          |  6.000000|NA       |ParameterIdentification |NA          |

