# ExpressionProfile print method works

    Code
      print(complete_expression_profile)
    Message
      
      -- Expression Profile: CYP3A4 (Enzyme) -----------------------------------------
      * Species: Human
      * Category: Healthy
      * Localization: Intracellular, BloodCellsIntracellular
      * Transport Type: Efflux
      * Ontogeny: CYP3A4
      * Parameters: 3

---

    Code
      print(minimal_expression_profile)
    Message
      
      -- Expression Profile: P-gp (Transporter) --------------------------------------
      * Species: Human
      * Category: Healthy

---

    Code
      print(without_category_expression_profile)
    Message
      
      -- Expression Profile: OATP1B1 (Transporter) -----------------------------------
      * Species: Rat
      * Category:
      * Parameters: 1

# print.expression_profile_collection works

    Code
      print(profiles)
    Message
      
      -- Expression Profiles (3) -----------------------------------------------------
      * CYP3A4 (Enzyme, Human, Healthy)
      * P-gp (Transporter, Human, Healthy)
      * OATP1B1 (Transporter, Rat, N/A)

---

    Code
      print(empty_profiles)
    Message
      
      -- Expression Profiles (0) -----------------------------------------------------
      i No expression profiles found

# expression_profile_collection from cloned test snapshot works

    Code
      print(profiles)
    Message
      
      -- Expression Profiles (14) ----------------------------------------------------
      * CYP3A4 (Enzyme, Human, Healthy)
      * AADAC (Enzyme, Human, Healthy)
      * P-gp (Transporter, Human, Healthy)
      * OATP1B1 (Transporter, Human, Healthy)
      * ATP1A2 (OtherProtein, Human, Healthy)
      * UGT1A4 (Enzyme, Human, Healthy)
      * GABRG2 (OtherProtein, Human, Healthy)
      * CYP3A4 (Enzyme, Human, Korean (Yu 2004 study))
      * AADAC (Enzyme, Human, Korean (Yu 2004 study))
      * P-gp (Transporter, Human, Korean (Yu 2004 study))
      * OATP1B1 (Transporter, Human, Korean (Yu 2004 study))
      * ATP1A2 (OtherProtein, Human, Korean (Yu 2004 study))
      * UGT1A4 (Enzyme, Human, Korean (Yu 2004 study))
      * GABRG2 (OtherProtein, Human, Korean (Yu 2004 study))

# Snapshot with empty expression profiles is handled correctly

    Code
      knitr::kable(dfs$expression_profiles)
    Output
      
      
      |expression_id |molecule |type |species |category |localization |ontogeny |
      |:-------------|:--------|:----|:-------|:--------|:------------|:--------|

---

    Code
      knitr::kable(dfs$expression_profiles_parameters)
    Output
      
      
      |expression_id |parameter | value|unit |source |description |
      |:-------------|:---------|-----:|:----|:------|:-----------|

# expression_profile transportType is correctly extracted from snapshot

    Code
      knitr::kable(dfs$expression_profiles)
    Output
      
      
      |expression_id                        |molecule |type         |species |category               |localization                                             |transport_type |ontogeny |
      |:------------------------------------|:--------|:------------|:-------|:----------------------|:--------------------------------------------------------|:--------------|:--------|
      |CYP3A4_Human_Healthy                 |CYP3A4   |Enzyme       |Human   |Healthy                |Intracellular, BloodCellsIntracellular, VascEndosome     |NA             |CYP3A4   |
      |AADAC_Human_Healthy                  |AADAC    |Enzyme       |Human   |Healthy                |VascMembranePlasmaSide, VascMembraneTissueSide           |NA             |NA       |
      |P-gp_Human_Healthy                   |P-gp     |Transporter  |Human   |Healthy                |NA                                                       |Efflux         |P-gp     |
      |OATP1B1_Human_Healthy                |OATP1B1  |Transporter  |Human   |Healthy                |NA                                                       |Influx         |NA       |
      |ATP1A2_Human_Healthy                 |ATP1A2   |OtherProtein |Human   |Healthy                |Interstitial, BloodCellsMembrane, VascMembranePlasmaSide |NA             |NA       |
      |UGT1A4_Human_Healthy                 |UGT1A4   |Enzyme       |Human   |Healthy                |Intracellular, BloodCellsIntracellular, VascEndosome     |NA             |UGT1A4   |
      |GABRG2_Human_Healthy                 |GABRG2   |OtherProtein |Human   |Healthy                |Interstitial, BloodCellsMembrane, VascMembranePlasmaSide |NA             |NA       |
      |CYP3A4_Human_Korean (Yu 2004 study)  |CYP3A4   |Enzyme       |Human   |Korean (Yu 2004 study) |Intracellular, BloodCellsIntracellular, VascEndosome     |NA             |CYP3A4   |
      |AADAC_Human_Korean (Yu 2004 study)   |AADAC    |Enzyme       |Human   |Korean (Yu 2004 study) |Intracellular, BloodCellsIntracellular, VascEndosome     |NA             |CYP2C18  |
      |P-gp_Human_Korean (Yu 2004 study)    |P-gp     |Transporter  |Human   |Korean (Yu 2004 study) |NA                                                       |Efflux         |P-gp     |
      |OATP1B1_Human_Korean (Yu 2004 study) |OATP1B1  |Transporter  |Human   |Korean (Yu 2004 study) |NA                                                       |Influx         |NA       |
      |ATP1A2_Human_Korean (Yu 2004 study)  |ATP1A2   |OtherProtein |Human   |Korean (Yu 2004 study) |Interstitial, BloodCellsMembrane, VascMembranePlasmaSide |NA             |NA       |
      |UGT1A4_Human_Korean (Yu 2004 study)  |UGT1A4   |Enzyme       |Human   |Korean (Yu 2004 study) |Intracellular, BloodCellsIntracellular, VascEndosome     |NA             |CYP1A2   |
      |GABRG2_Human_Korean (Yu 2004 study)  |GABRG2   |OtherProtein |Human   |Korean (Yu 2004 study) |Interstitial, BloodCellsMembrane, VascMembranePlasmaSide |NA             |NA       |

---

    Code
      knitr::kable(dfs$expression_profiles_parameters)
    Output
      
      
      |expression_id                        |parameter                                                                                                              |      value|unit   |source                  |description                                                        |
      |:------------------------------------|:----------------------------------------------------------------------------------------------------------------------|----------:|:------|:-----------------------|:------------------------------------------------------------------|
      |CYP3A4_Human_Healthy                 |CYP3A4&#124;Reference concentration                                                                                    |  4.3200000|µmol/l |Other                   |PK-Sim default value                                               |
      |CYP3A4_Human_Healthy                 |CYP3A4&#124;t1/2 (intestine)                                                                                           | 23.0000000|h      |Publication             |R24-3733                                                           |
      |CYP3A4_Human_Healthy                 |CYP3A4&#124;t1/2 (liver)                                                                                               | 35.1000000|h      |Publication             |R24-3733                                                           |
      |CYP3A4_Human_Healthy                 |Organism&#124;Brain&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                            |  0.0041683|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;Gonads&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                           |  0.0007869|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;Kidney&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                           |  0.0053603|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;CYP3A4&#124;Relative expression                           |  1.0000000|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;CYP3A4&#124;Relative expression                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;Lung&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                             |  0.0004270|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                   |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Intracellular&#124;CYP3A4&#124;Relative expression         |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerIleum&#124;Intracellular&#124;CYP3A4&#124;Relative expression       |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerJejunum&#124;Intracellular&#124;CYP3A4&#124;Relative expression     |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperIleum&#124;Intracellular&#124;CYP3A4&#124;Relative expression       |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperJejunum&#124;Intracellular&#124;CYP3A4&#124;Relative expression     |  0.0727698|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Healthy                  |AADAC&#124;Reference concentration                                                                                     |  1.0000000|µmol/l |Other                   |PK-Sim default value                                               |
      |AADAC_Human_Healthy                  |AADAC&#124;Relative expression in plasma                                                                               |  0.0000391|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Healthy                  |AADAC&#124;t1/2 (intestine)                                                                                            | 23.0000000|h      |Other                   |PK-Sim default value                                               |
      |AADAC_Human_Healthy                  |AADAC&#124;t1/2 (liver)                                                                                                | 36.0000000|h      |Other                   |PK-Sim default value                                               |
      |P-gp_Human_Healthy                   |Organism&#124;Bone&#124;Intracellular&#124;P-gp&#124;Relative expression                                               |  0.0242518|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Brain&#124;Intracellular&#124;P-gp&#124;Relative expression                                              |  0.0760890|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Gonads&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.0174180|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Heart&#124;Intracellular&#124;P-gp&#124;Relative expression                                              |  0.0419198|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Kidney&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.7092199|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;LargeIntestine&#124;Intracellular&#124;P-gp&#124;Relative expression                                     |  0.1108416|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonAscendens&#124;Intracellular&#124;P-gp&#124;Relative expression     |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonDescendens&#124;Intracellular&#124;P-gp&#124;Relative expression    |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonSigmoid&#124;Intracellular&#124;P-gp&#124;Relative expression       |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonTransversum&#124;Intracellular&#124;P-gp&#124;Relative expression   |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;P-gp&#124;Relative expression                             |  0.1916810|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;P-gp&#124;Relative expression                              |  0.1916810|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Lung&#124;Intracellular&#124;P-gp&#124;Relative expression                                               |  0.0657549|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Muscle&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.0128343|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Pancreas&#124;Intracellular&#124;P-gp&#124;Relative expression                                           |  0.0142511|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;SmallIntestine&#124;Intracellular&#124;P-gp&#124;Relative expression                                     |  0.2808544|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Intracellular&#124;P-gp&#124;Relative expression           |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerIleum&#124;Intracellular&#124;P-gp&#124;Relative expression         |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerJejunum&#124;Intracellular&#124;P-gp&#124;Relative expression       |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperIleum&#124;Intracellular&#124;P-gp&#124;Relative expression         |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperJejunum&#124;Intracellular&#124;P-gp&#124;Relative expression       |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Spleen&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.0742556|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |Organism&#124;Stomach&#124;Intracellular&#124;P-gp&#124;Relative expression                                            |  0.0260853|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Healthy                   |P-gp&#124;Reference concentration                                                                                      |  1.4100000|µmol/l |Other                   |PK-Sim default value                                               |
      |P-gp_Human_Healthy                   |P-gp&#124;t1/2 (intestine)                                                                                             | 23.0000000|h      |Publication             |R24-3733                                                           |
      |P-gp_Human_Healthy                   |P-gp&#124;t1/2 (liver)                                                                                                 | 36.0000000|h      |Publication             |R24-3733                                                           |
      |OATP1B1_Human_Healthy                |OATP1B1&#124;Reference concentration                                                                                   |  2.5600000|µmol/l |Publication             |n00254091                                                          |
      |OATP1B1_Human_Healthy                |OATP1B1&#124;t1/2 (intestine)                                                                                          | 23.0000000|h      |Other                   |PK-Sim default value                                               |
      |OATP1B1_Human_Healthy                |OATP1B1&#124;t1/2 (liver)                                                                                              | 36.0000000|h      |Other                   |PK-Sim default value                                               |
      |OATP1B1_Human_Healthy                |Organism&#124;Brain&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                           |  0.0001417|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Healthy                |Organism&#124;Gonads&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                          |  0.0141667|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Healthy                |Organism&#124;Heart&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                           |  0.0008254|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Healthy                |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;OATP1B1&#124;Relative expression                          |  1.0000000|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Healthy                |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;OATP1B1&#124;Relative expression                           |  1.0000000|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Healthy                |Organism&#124;Lung&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                            |  0.0000401|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Healthy                |Organism&#124;Muscle&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                          |  0.0006468|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |ATP1A2&#124;Reference concentration                                                                                    |  0.4766171|µmol/l |Other                   |PK-Sim default value                                               |
      |ATP1A2_Human_Healthy                 |ATP1A2&#124;t1/2 (intestine)                                                                                           | 23.0000000|h      |Other                   |PK-Sim default                                                     |
      |ATP1A2_Human_Healthy                 |ATP1A2&#124;t1/2 (liver)                                                                                               | 36.0000000|h      |Other                   |PK-Sim default value                                               |
      |ATP1A2_Human_Healthy                 |Organism&#124;Bone&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                             |  0.0062154|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Brain&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Gonads&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.0508741|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Heart&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                            |  0.3179119|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Kidney&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.0158939|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;LargeIntestine&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                   |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonAscendens&#124;Intracellular&#124;ATP1A2&#124;Relative expression   |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonDescendens&#124;Intracellular&#124;ATP1A2&#124;Relative expression  |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonSigmoid&#124;Intracellular&#124;ATP1A2&#124;Relative expression     |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonTransversum&#124;Intracellular&#124;ATP1A2&#124;Relative expression |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;ATP1A2&#124;Relative expression                           |  0.0223785|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;ATP1A2&#124;Relative expression                            |  0.0223785|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Lung&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                             |  0.0272345|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Muscle&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.7034194|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Pancreas&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                         |  0.0073903|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Skin&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                             |  0.0389468|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                   |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Intracellular&#124;ATP1A2&#124;Relative expression         |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerIleum&#124;Intracellular&#124;ATP1A2&#124;Relative expression       |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerJejunum&#124;Intracellular&#124;ATP1A2&#124;Relative expression     |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperIleum&#124;Intracellular&#124;ATP1A2&#124;Relative expression       |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperJejunum&#124;Intracellular&#124;ATP1A2&#124;Relative expression     |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Spleen&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.0103243|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Healthy                 |Organism&#124;Stomach&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                          |  0.0309436|NA     |NA                      |NA                                                                 |
      |UGT1A4_Human_Healthy                 |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;UGT1A4&#124;Relative expression                           |  1.0000000|NA     |NA                      |NA                                                                 |
      |UGT1A4_Human_Healthy                 |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;UGT1A4&#124;Relative expression                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |UGT1A4_Human_Healthy                 |UGT1A4&#124;Reference concentration                                                                                    |  2.3200000|µmol/l |Unknown                 |PK-Sim default value                                               |
      |UGT1A4_Human_Healthy                 |UGT1A4&#124;t1/2 (intestine)                                                                                           | 23.0000000|h      |Unknown                 |PK-Sim default value                                               |
      |UGT1A4_Human_Healthy                 |UGT1A4&#124;t1/2 (liver)                                                                                               | 36.0000000|h      |Unknown                 |PK-Sim default value                                               |
      |GABRG2_Human_Healthy                 |GABRG2&#124;Reference concentration                                                                                    |  1.0877710|µmol/l |Publication             |n00265826                                                          |
      |GABRG2_Human_Healthy                 |GABRG2&#124;t1/2 (intestine)                                                                                           | 23.0000000|h      |Publication             |PK-Sim default value                                               |
      |GABRG2_Human_Healthy                 |GABRG2&#124;t1/2 (liver)                                                                                               | 36.0000000|h      |Publication             |PK-Sim default value                                               |
      |GABRG2_Human_Healthy                 |Organism&#124;Brain&#124;Intracellular&#124;GABRG2&#124;Relative expression                                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |CYP3A4&#124;Reference concentration                                                                                    |  3.6271334|µmol/l |ParameterIdentification |Value updated from 'PI Korean (Yu 2004 study)' on 2020-03-26 11:40 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |CYP3A4&#124;t1/2 (intestine)                                                                                           | 12.0000000|h      |Other                   |PK-Sim default value                                               |
      |CYP3A4_Human_Korean (Yu 2004 study)  |CYP3A4&#124;t1/2 (liver)                                                                                               | 10.0000000|h      |Publication             |R24-3730                                                           |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;Brain&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                            |  0.0041683|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;Gonads&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                           |  0.0007869|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;Kidney&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                           |  0.0053603|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;CYP3A4&#124;Relative expression                           |  1.0000000|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;CYP3A4&#124;Relative expression                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;Lung&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                             |  0.0004270|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Intracellular&#124;CYP3A4&#124;Relative expression                                   |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Intracellular&#124;CYP3A4&#124;Relative expression         |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerIleum&#124;Intracellular&#124;CYP3A4&#124;Relative expression       |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerJejunum&#124;Intracellular&#124;CYP3A4&#124;Relative expression     |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperIleum&#124;Intracellular&#124;CYP3A4&#124;Relative expression       |  0.0727698|NA     |NA                      |NA                                                                 |
      |CYP3A4_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperJejunum&#124;Intracellular&#124;CYP3A4&#124;Relative expression     |  0.0727698|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |AADAC&#124;Reference concentration                                                                                     |  1.0000000|µmol/l |Database                |PK-Sim default value                                               |
      |AADAC_Human_Korean (Yu 2004 study)   |AADAC&#124;Relative expression in blood cells                                                                          |  0.0000391|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |AADAC&#124;Relative expression in plasma                                                                               |  0.0000391|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |AADAC&#124;t1/2 (intestine)                                                                                            | 23.0000000|h      |Database                |PK-Sim database                                                    |
      |AADAC_Human_Korean (Yu 2004 study)   |AADAC&#124;t1/2 (liver)                                                                                                | 45.0000000|h      |Publication             |c26475781                                                          |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Bone&#124;Intracellular&#124;AADAC&#124;Relative expression                                              |  0.0000487|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Brain&#124;Intracellular&#124;AADAC&#124;Relative expression                                             |  0.0000397|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Gonads&#124;Intracellular&#124;AADAC&#124;Relative expression                                            |  0.0011923|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Heart&#124;Intracellular&#124;AADAC&#124;Relative expression                                             |  0.0026603|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Kidney&#124;Intracellular&#124;AADAC&#124;Relative expression                                            |  0.0000571|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;LargeIntestine&#124;Intracellular&#124;AADAC&#124;Relative expression                                    |  0.0001038|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonAscendens&#124;Intracellular&#124;AADAC&#124;Relative expression    |  0.0001038|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonDescendens&#124;Intracellular&#124;AADAC&#124;Relative expression   |  0.0001038|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonSigmoid&#124;Intracellular&#124;AADAC&#124;Relative expression      |  0.0001038|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonTransversum&#124;Intracellular&#124;AADAC&#124;Relative expression  |  0.0001038|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;AADAC&#124;Relative expression                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;AADAC&#124;Relative expression                             |  1.0000000|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Lung&#124;Intracellular&#124;AADAC&#124;Relative expression                                              |  0.0269231|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Muscle&#124;Intracellular&#124;AADAC&#124;Relative expression                                            |  0.0002083|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Pancreas&#124;Intracellular&#124;AADAC&#124;Relative expression                                          |  0.1474359|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;SmallIntestine&#124;Intracellular&#124;AADAC&#124;Relative expression                                    |  0.2544872|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Intracellular&#124;AADAC&#124;Relative expression          |  0.2544872|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerIleum&#124;Intracellular&#124;AADAC&#124;Relative expression        |  0.2544872|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerJejunum&#124;Intracellular&#124;AADAC&#124;Relative expression      |  0.2544872|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperIleum&#124;Intracellular&#124;AADAC&#124;Relative expression        |  0.2544872|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperJejunum&#124;Intracellular&#124;AADAC&#124;Relative expression      |  0.2544872|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Spleen&#124;Intracellular&#124;AADAC&#124;Relative expression                                            |  0.0003712|NA     |NA                      |NA                                                                 |
      |AADAC_Human_Korean (Yu 2004 study)   |Organism&#124;Stomach&#124;Intracellular&#124;AADAC&#124;Relative expression                                           |  0.0775641|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Bone&#124;Intracellular&#124;P-gp&#124;Relative expression                                               |  0.0242518|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Brain&#124;Intracellular&#124;P-gp&#124;Relative expression                                              |  0.0760890|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Gonads&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.0174180|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Heart&#124;Intracellular&#124;P-gp&#124;Relative expression                                              |  0.0419198|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Kidney&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.7092199|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;LargeIntestine&#124;Intracellular&#124;P-gp&#124;Relative expression                                     |  0.1108416|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonAscendens&#124;Intracellular&#124;P-gp&#124;Relative expression     |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonDescendens&#124;Intracellular&#124;P-gp&#124;Relative expression    |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonSigmoid&#124;Intracellular&#124;P-gp&#124;Relative expression       |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonTransversum&#124;Intracellular&#124;P-gp&#124;Relative expression   |  0.3971631|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;P-gp&#124;Relative expression                             |  0.1916810|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;P-gp&#124;Relative expression                              |  0.1916810|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Lung&#124;Intracellular&#124;P-gp&#124;Relative expression                                               |  0.0657549|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Muscle&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.0128343|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Pancreas&#124;Intracellular&#124;P-gp&#124;Relative expression                                           |  0.0142511|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;SmallIntestine&#124;Intracellular&#124;P-gp&#124;Relative expression                                     |  0.2808544|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Intracellular&#124;P-gp&#124;Relative expression           |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerIleum&#124;Intracellular&#124;P-gp&#124;Relative expression         |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerJejunum&#124;Intracellular&#124;P-gp&#124;Relative expression       |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperIleum&#124;Intracellular&#124;P-gp&#124;Relative expression         |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperJejunum&#124;Intracellular&#124;P-gp&#124;Relative expression       |  1.0000000|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Spleen&#124;Intracellular&#124;P-gp&#124;Relative expression                                             |  0.0742556|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |Organism&#124;Stomach&#124;Intracellular&#124;P-gp&#124;Relative expression                                            |  0.0260853|NA     |NA                      |NA                                                                 |
      |P-gp_Human_Korean (Yu 2004 study)    |P-gp&#124;Reference concentration                                                                                      |  1.4100000|µmol/l |Publication             |R24-3733                                                           |
      |P-gp_Human_Korean (Yu 2004 study)    |P-gp&#124;t1/2 (intestine)                                                                                             | 23.0000000|h      |Other                   |PK-Sim default value                                               |
      |P-gp_Human_Korean (Yu 2004 study)    |P-gp&#124;t1/2 (liver)                                                                                                 | 36.0000000|h      |Publication             |n00261417                                                          |
      |OATP1B1_Human_Korean (Yu 2004 study) |OATP1B1&#124;Reference concentration                                                                                   |  1.0000000|µmol/l |Unknown                 |PK-Sim default value                                               |
      |OATP1B1_Human_Korean (Yu 2004 study) |OATP1B1&#124;t1/2 (intestine)                                                                                          | 12.3400000|h      |Publication             |n00261417                                                          |
      |OATP1B1_Human_Korean (Yu 2004 study) |OATP1B1&#124;t1/2 (liver)                                                                                              | 36.0000000|h      |Unknown                 |PK-Sim default value                                               |
      |OATP1B1_Human_Korean (Yu 2004 study) |Organism&#124;Brain&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                           |  0.0001417|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Korean (Yu 2004 study) |Organism&#124;Gonads&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                          |  0.0141667|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Korean (Yu 2004 study) |Organism&#124;Heart&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                           |  0.0008254|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Korean (Yu 2004 study) |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;OATP1B1&#124;Relative expression                          |  1.0000000|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Korean (Yu 2004 study) |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;OATP1B1&#124;Relative expression                           |  1.0000000|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Korean (Yu 2004 study) |Organism&#124;Lung&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                            |  0.0000401|NA     |NA                      |NA                                                                 |
      |OATP1B1_Human_Korean (Yu 2004 study) |Organism&#124;Muscle&#124;Intracellular&#124;OATP1B1&#124;Relative expression                                          |  0.0006468|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |ATP1A2&#124;Reference concentration                                                                                    |  0.4766171|µmol/l |Publication             |R24-3733                                                           |
      |ATP1A2_Human_Korean (Yu 2004 study)  |ATP1A2&#124;t1/2 (intestine)                                                                                           | 23.0000000|h      |Database                |PK-Sim database                                                    |
      |ATP1A2_Human_Korean (Yu 2004 study)  |ATP1A2&#124;t1/2 (liver)                                                                                               | 36.0000000|h      |Database                |PK-Sim default value                                               |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Bone&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                             |  0.0062154|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Brain&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Gonads&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.0508741|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Heart&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                            |  0.3179119|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Kidney&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.0158939|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;LargeIntestine&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                   |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonAscendens&#124;Intracellular&#124;ATP1A2&#124;Relative expression   |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonDescendens&#124;Intracellular&#124;ATP1A2&#124;Relative expression  |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonSigmoid&#124;Intracellular&#124;ATP1A2&#124;Relative expression     |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;LargeIntestine&#124;Mucosa&#124;ColonTransversum&#124;Intracellular&#124;ATP1A2&#124;Relative expression |  0.0786999|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;ATP1A2&#124;Relative expression                           |  0.0223785|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;ATP1A2&#124;Relative expression                            |  0.0223785|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Lung&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                             |  0.0272345|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Muscle&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.7034194|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Pancreas&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                         |  0.0073903|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Skin&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                             |  0.0389468|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                   |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;Duodenum&#124;Intracellular&#124;ATP1A2&#124;Relative expression         |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerIleum&#124;Intracellular&#124;ATP1A2&#124;Relative expression       |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;LowerJejunum&#124;Intracellular&#124;ATP1A2&#124;Relative expression     |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperIleum&#124;Intracellular&#124;ATP1A2&#124;Relative expression       |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;SmallIntestine&#124;Mucosa&#124;UpperJejunum&#124;Intracellular&#124;ATP1A2&#124;Relative expression     |  0.0501580|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Spleen&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                           |  0.0103243|NA     |NA                      |NA                                                                 |
      |ATP1A2_Human_Korean (Yu 2004 study)  |Organism&#124;Stomach&#124;Intracellular&#124;ATP1A2&#124;Relative expression                                          |  0.0309436|NA     |NA                      |NA                                                                 |
      |UGT1A4_Human_Korean (Yu 2004 study)  |Organism&#124;Liver&#124;Pericentral&#124;Intracellular&#124;UGT1A4&#124;Relative expression                           |  1.0000000|NA     |NA                      |NA                                                                 |
      |UGT1A4_Human_Korean (Yu 2004 study)  |Organism&#124;Liver&#124;Periportal&#124;Intracellular&#124;UGT1A4&#124;Relative expression                            |  1.0000000|NA     |NA                      |NA                                                                 |
      |UGT1A4_Human_Korean (Yu 2004 study)  |UGT1A4&#124;Reference concentration                                                                                    |  2.3200000|µmol/l |Publication             |R24-3734                                                           |
      |UGT1A4_Human_Korean (Yu 2004 study)  |UGT1A4&#124;t1/2 (intestine)                                                                                           | 23.0000000|h      |Unknown                 |PK-Sim default value                                               |
      |UGT1A4_Human_Korean (Yu 2004 study)  |UGT1A4&#124;t1/2 (liver)                                                                                               | 36.0000000|h      |Other                   |PK-Sim default value                                               |
      |GABRG2_Human_Korean (Yu 2004 study)  |GABRG2&#124;Reference concentration                                                                                    |  1.0877710|µmol/l |Other                   |PK-Sim default value                                               |
      |GABRG2_Human_Korean (Yu 2004 study)  |GABRG2&#124;t1/2 (intestine)                                                                                           | 23.0000000|h      |Other                   |PK-Sim default value                                               |
      |GABRG2_Human_Korean (Yu 2004 study)  |GABRG2&#124;t1/2 (liver)                                                                                               | 36.0000000|h      |Other                   |PK-Sim default value                                               |
      |GABRG2_Human_Korean (Yu 2004 study)  |Organism&#124;Brain&#124;Intracellular&#124;GABRG2&#124;Relative expression                                            |  1.0000000|NA     |NA                      |NA                                                                 |

