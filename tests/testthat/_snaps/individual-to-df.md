# to_df returns all tables by default

    Code
      knitr::kable(dfs)
    Output
      
      
      |individual_id |name      |       seed|species |population                |gender |  age|age_unit | gestational_age|gestational_age_unit | weight|weight_unit | height|height_unit |disease_state |calculation_methods                                   |disease_state_parameters |
      |:-------------|:---------|----------:|:-------|:-------------------------|:------|----:|:--------|---------------:|:--------------------|------:|:-----------|------:|:-----------|:-------------|:-----------------------------------------------------|:------------------------|
      |Mouly2002     |Mouly2002 | 1300547185|Human   |WhiteAmerican_NHANES_1997 |MALE   | 29.9|year(s)  |              NA|NA                   |     70|kg          |    175|cm          |Healthy       |SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller |NA                       |
      
      |individual_id |path                                                         | value|unit |source      |description |
      |:-------------|:------------------------------------------------------------|-----:|:----|:-----------|:-----------|
      |Mouly2002     |Organism&#124;Gallbladder&#124;Gallbladder ejection fraction |   0.8|NA   |Publication |R24-4081    |
      |Mouly2002     |Organism&#124;Liver&#124;EHC continuous fraction             |   1.0|NA   |Publication |R24-4081    |
      
      |individual_id |profile                        |
      |:-------------|:------------------------------|
      |Mouly2002     |CYP1A2&#124;Human&#124;Healthy |
      |Mouly2002     |CYP2B6&#124;Human&#124;Healthy |

# to_df returns specific tables when requested

    Code
      knitr::kable(characteristics_df)
    Output
      
      
      |individual_id |name     |      seed|species |population         |gender | age|age_unit | gestational_age|gestational_age_unit | weight|weight_unit | height|height_unit |disease_state |calculation_methods                                   |disease_state_parameters |
      |:-------------|:--------|---------:|:-------|:------------------|:------|---:|:--------|---------------:|:--------------------|------:|:-----------|------:|:-----------|:-------------|:-----------------------------------------------------|:------------------------|
      |European      |European | 186687441|Human   |European_ICRP_2002 |MALE   |  30|year(s)  |              NA|NA                   |     NA|NA          |     NA|NA          |NA            |SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller |NA                       |

---

    Code
      knitr::kable(params_df)
    Output
      
      
      |individual_id |name | value|unit |source |description | source_id|
      |:-------------|:----|-----:|:----|:------|:-----------|---------:|

---

    Code
      knitr::kable(expr_df)
    Output
      
      
      |individual_id |profile                        |
      |:-------------|:------------------------------|
      |European      |CYP1A2&#124;Human&#124;Healthy |
      |European      |CYP2B6&#124;Human&#124;Healthy |

# to_df handles missing values

    Code
      knitr::kable(dfs)
    Output
      
      
      |individual_id |name    | seed|species |population |gender | age|age_unit | gestational_age|gestational_age_unit | weight|weight_unit | height|height_unit |disease_state |calculation_methods |disease_state_parameters |
      |:-------------|:-------|----:|:-------|:----------|:------|---:|:--------|---------------:|:--------------------|------:|:-----------|------:|:-----------|:-------------|:-------------------|:------------------------|
      |Minimal       |Minimal |   NA|NA      |NA         |NA     |  NA|NA       |              NA|NA                   |     NA|NA          |     NA|NA          |NA            |NA                  |NA                       |
      
      |individual_id |name | value|unit |source |description | source_id|
      |:-------------|:----|-----:|:----|:------|:-----------|---------:|
      
      |individual_id |profile |
      |:-------------|:-------|

# to_df includes gestational age

    Code
      knitr::kable(characteristics_df)
    Output
      
      
      |individual_id |name         | seed|species |population |gender | age|age_unit | gestational_age|gestational_age_unit | weight|weight_unit | height|height_unit |disease_state |calculation_methods |disease_state_parameters |
      |:-------------|:------------|----:|:-------|:----------|:------|---:|:--------|---------------:|:--------------------|------:|:-----------|------:|:-----------|:-------------|:-------------------|:------------------------|
      |Preterm Baby  |Preterm Baby |   NA|Human   |Preterm    |MALE   |  10|day(s)   |              30|week(s)              |    1.5|kg          |     40|cm          |NA            |NA                  |NA                       |

# get_individuals_dfs returns combined data frames from all individuals

    Code
      knitr::kable(dfs)
    Output
      
      
      |individual_id |name      |       seed|species |population                |gender |  age|age_unit | gestational_age|gestational_age_unit | weight|weight_unit | height|height_unit |disease_state |calculation_methods                                   |disease_state_parameters |
      |:-------------|:---------|----------:|:-------|:-------------------------|:------|----:|:--------|---------------:|:--------------------|------:|:-----------|------:|:-----------|:-------------|:-----------------------------------------------------|:------------------------|
      |Mouly2002     |Mouly2002 | 1300547185|Human   |WhiteAmerican_NHANES_1997 |MALE   | 29.9|year(s)  |              NA|NA                   |     NA|NA          |     NA|NA          |NA            |SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller |NA                       |
      |European      |European  |  186687441|Human   |European_ICRP_2002        |MALE   | 30.0|year(s)  |              NA|NA                   |     NA|NA          |     NA|NA          |NA            |SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller |NA                       |
      
      |individual_id |path                                                         | value|unit |source      |description |name | source_id|
      |:-------------|:------------------------------------------------------------|-----:|:----|:-----------|:-----------|:----|---------:|
      |Mouly2002     |Organism&#124;Gallbladder&#124;Gallbladder ejection fraction |   0.8|NA   |Publication |R24-4081    |NA   |        NA|
      |Mouly2002     |Organism&#124;Liver&#124;EHC continuous fraction             |   1.0|NA   |Publication |R24-4081    |NA   |        NA|
      
      |individual_id |profile                        |
      |:-------------|:------------------------------|
      |Mouly2002     |CYP1A2&#124;Human&#124;Healthy |
      |Mouly2002     |CYP2B6&#124;Human&#124;Healthy |
      |European      |CYP1A2&#124;Human&#124;Healthy |
      |European      |CYP2B6&#124;Human&#124;Healthy |

# get_individuals_dfs handles empty snapshot

    Code
      knitr::kable(dfs)
    Output
      
      
      |individual_id |name | seed|species |population |gender | age|age_unit | weight|weight_unit | height|height_unit |disease_state |calculation_methods |
      |:-------------|:----|----:|:-------|:----------|:------|---:|:--------|------:|:-----------|------:|:-----------|:-------------|:-------------------|
      
      |individual_id |name | value|unit |
      |:-------------|:----|-----:|:----|
      
      |individual_id |profile |
      |:-------------|:-------|

