# Population to_df returns correct structure

    Code
      knitr::kable(dfs)
    Output
      
      
      |population_id |name |      seed| number_of_individuals| proportion_of_females|source_population  |individual_name | age_min| age_max|age_unit | weight_min| weight_max|weight_unit | height_min| height_max|height_unit | bmi_min| bmi_max|bmi_unit | egfr_min| egfr_max|egfr_unit     |
      |:-------------|:----|---------:|---------------------:|---------------------:|:------------------|:---------------|-------:|-------:|:--------|----------:|----------:|:-----------|----------:|----------:|:-----------|-------:|-------:|:--------|--------:|--------:|:-------------|
      |pop6          |pop6 | 324184656|                    15|                    50|European_ICRP_2002 |CKD             |       0|     100|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      NA|NA       |        0| 60.00159|ml/min/1.73m² |
      
      |population_id |parameter | seed|distribution_type |statistic | value|unit |source |description |
      |:-------------|:---------|----:|:-----------------|:---------|-----:|:----|:------|:-----------|

# get_populations_dfs returns correct structure

    Code
      knitr::kable(dfs)
    Output
      
      
      |population_id |name  |        seed| number_of_individuals| proportion_of_females|source_population  |individual_name                       | age_min| age_max|age_unit | weight_min| weight_max|weight_unit | height_min| height_max|height_unit | bmi_min| bmi_max|bmi_unit | egfr_min| egfr_max|egfr_unit     |
      |:-------------|:-----|-----------:|---------------------:|---------------------:|:------------------|:-------------------------------------|-------:|-------:|:--------|----------:|----------:|:-----------|----------:|----------:|:-----------|-------:|-------:|:--------|--------:|--------:|:-------------|
      |pop_1         |pop_1 |   202395203|                   100|                    50|European_ICRP_2002 |European (P-gp modified, CYP3A4 36 h) |       0|     100|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      NA|NA       |       NA|       NA|NA            |
      |pop2          |pop2  | -1746093953|                    10|                    50|European_ICRP_2002 |European (P-gp modified, CYP3A4 36 h) |      46|      87|year(s)  |         56|        120|kg          |        160|        189|cm          |      NA|      NA|NA       |       NA|       NA|NA            |
      |pop3          |pop3  |  2040342218|                    10|                     2|Asian_Tanaka_1996  |Korean (Yu 2004 study)                |      40|      77|year(s)  |         55|        120|kg          |        160|        190|cm          |      23|      67|kg/m²    |       NA|       NA|NA            |
      |pop4          |pop4  |   235227359|                    10|                    50|European_ICRP_2002 |European (P-gp modified, CYP3A4 36 h) |      45|      90|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      25|kg/m²    |       NA|       NA|NA            |
      |pop6          |pop6  |   324184656|                    15|                    50|European_ICRP_2002 |CKD                                   |       0|     100|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      NA|NA       |        0| 60.00159|ml/min/1.73m² |
      |pop7          |pop7  |   486878578|                    12|                    50|Asian_Tanaka_1996  |Korean (Yu 2004 study)                |      34|      81|year(s)  |         NA|         NA|NA          |         NA|         NA|NA          |      NA|      NA|NA       |       NA|       NA|NA            |
      
      |population_id |parameter                                                                   |        seed|distribution_type |statistic          |     value|unit     |source                  |description |
      |:-------------|:---------------------------------------------------------------------------|-----------:|:-----------------|:------------------|---------:|:--------|:-----------------------|:-----------|
      |pop_1         |CYP3A4&#124;t1/2 (intestine)                                                |   202400546|Normal            |Mean               | 23.000000|h        |ParameterIdentification |NA          |
      |pop_1         |CYP3A4&#124;t1/2 (intestine)                                                |   202400546|Normal            |Deviation          | 12.000000|h        |Publication             |c01835608   |
      |pop_1         |Organism&#124;Bone&#124;Lymph flow rate                                     |   203191984|Discrete          |Mean               |  0.000114|l/min    |ParameterIdentification |NA          |
      |pop_1         |Organism&#124;Bone&#124;Interstitial&#124;pH                                |   203212109|Uniform           |Minimum            | 12.000000|NA       |Other                   |Assumed     |
      |pop_1         |Organism&#124;Bone&#124;Interstitial&#124;pH                                |   203212109|Uniform           |Maximum            | 14.000000|NA       |Publication             |R24-4085    |
      |pop_1         |Organism&#124;Gallbladder&#124;Gallbladder ejection half-time               |   203229343|Discrete          |Mean               | 19.700000|min      |Publication             |R24-4085    |
      |pop2          |Organism&#124;pH (intracellular)                                            | -1746013984|LogNormal         |Mean               |  7.000000|NA       |ParameterIdentification |NA          |
      |pop2          |Organism&#124;pH (intracellular)                                            | -1746013984|LogNormal         |GeometricDeviation |  1.000000|NA       |Publication             |n00265826   |
      |pop2          |Organism&#124;Vf (lipid, blood cells)                                       | -1745931843|Uniform           |Minimum            |  0.000000|NA       |Other                   |Assumed     |
      |pop2          |Organism&#124;Vf (lipid, blood cells)                                       | -1745931843|Uniform           |Maximum            |  1.000000|NA       |Other                   |Assumed     |
      |pop3          |CYP3A4&#124;Reference concentration                                         |  2040343562|Normal            |Mean               |  3.627133|µmol/l   |Other                   |Assumed     |
      |pop3          |CYP3A4&#124;Reference concentration                                         |  2040343562|Normal            |Deviation          |  0.200000|µmol/l   |Other                   |Assumed     |
      |pop3          |CYP3A4&#124;t1/2 (intestine)                                                |  2040343578|Normal            |Mean               | 12.000000|h        |NA                      |NA          |
      |pop3          |CYP3A4&#124;t1/2 (intestine)                                                |  2040343578|Normal            |Deviation          |  0.000000|h        |NA                      |NA          |
      |pop3          |Organism&#124;Lumen&#124;Stomach&#124;pH in fasted state                    | -1998157671|Normal            |Mean               |  5.000000|NA       |ParameterIdentification |NA          |
      |pop3          |Organism&#124;Lumen&#124;Stomach&#124;pH in fasted state                    | -1998157671|Normal            |Deviation          |  0.300000|NA       |ParameterIdentification |NA          |
      |pop3          |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Fraction mucosa | -1998136828|LogNormal         |Mean               |  0.260000|NA       |Other                   |Assumed     |
      |pop3          |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Fraction mucosa | -1998136828|LogNormal         |GeometricDeviation | 56.000000|NA       |NA                      |NA          |
      |pop3          |Organism&#124;Bone&#124;Hydraulic conductivity                              | -1998090937|Normal            |Mean               |  0.000324|ml/min/N |Other                   |Assumed     |
      |pop3          |Organism&#124;Bone&#124;Hydraulic conductivity                              | -1998090937|Normal            |Deviation          | 56.000000|ml/min/N |ParameterIdentification |NA          |
      |pop3          |Organism&#124;LargeIntestine&#124;Mucosa&#124;Caecum&#124;Fraction mucosa   | -1998056218|Uniform           |Minimum            |  0.200000|NA       |ParameterIdentification |NA          |
      |pop3          |Organism&#124;LargeIntestine&#124;Mucosa&#124;Caecum&#124;Fraction mucosa   | -1998056218|Uniform           |Maximum            |  1.000000|NA       |ParameterIdentification |NA          |
      |pop3          |Organism&#124;Heart&#124;Hydraulic conductivity                             | -1991794781|Normal            |Mean               |  0.000516|ml/min/N |ParameterIdentification |NA          |
      |pop3          |Organism&#124;Heart&#124;Hydraulic conductivity                             | -1991794781|Normal            |Deviation          | 56.000000|ml/min/N |ParameterIdentification |NA          |
      |pop3          |Organism&#124;Fraction endosomal (global)                                   | -1991777546|Normal            |Mean               |  0.200000|NA       |ParameterIdentification |NA          |
      |pop3          |Organism&#124;Fraction endosomal (global)                                   | -1991777546|Normal            |Deviation          |  3.000000|NA       |Other                   |Assumed     |
      |pop3          |Organism&#124;pH (blood cells)                                              | -1991750437|Normal            |Mean               |  7.220000|NA       |ParameterIdentification |NA          |
      |pop3          |Organism&#124;pH (blood cells)                                              | -1991750437|Normal            |Deviation          |  6.000000|NA       |ParameterIdentification |NA          |

# get_populations_dfs handles empty snapshot

    Code
      knitr::kable(dfs)
    Output
      
      
      |population_id |name | seed| number_of_individuals| proportion_of_females|source_population |individual_name | age_min| age_max|age_unit | weight_min| weight_max|weight_unit | height_min| height_max|height_unit | bmi_min| bmi_max|bmi_unit | egfr_min| egfr_max|egfr_unit |
      |:-------------|:----|----:|---------------------:|---------------------:|:-----------------|:---------------|-------:|-------:|:--------|----------:|----------:|:-----------|----------:|----------:|:-----------|-------:|-------:|:--------|--------:|--------:|:---------|
      
      |population_id |parameter | seed|distribution_type |statistic | value|unit |source |description |
      |:-------------|:---------|----:|:-----------------|:---------|-----:|:----|:------|:-----------|

