# Compounds can be converted to dataframes

    Code
      print(get_compounds_dfs(snapshot), n = Inf)
    Output
      # A tibble: 167 x 6
          name                                parameter       type  value unit  source
          <chr>                               <chr>           <chr> <chr> <chr> <chr> 
        1 BI 100777                           lipophilicity   "Opt~ "3.2~ Log ~ Param~
        2 BI 100777                           fraction_unbou~ "Ger~ "0.0~ %     n0026~
        3 BI 100777                           molecular_weig~  <NA> "150~ g/mol c2647~
        4 BI 100777                           halogens        "Cl"  "1"   <NA>  c2647~
        5 BI 100777                           halogens        "F"   "1"   <NA>  c2647~
        6 BI 100777                           pKa             "bas~ "6.2" <NA>  c2647~
        7 BI 100777                           pKa             "aci~ "10.~ <NA>  c2647~
        8 BI 100777                           solubility      "pH ~ "0.5" mg/ml Param~
        9 BI 100777                           intestinal_per~ "Opt~ "2.0~ cm/m~ Param~
       10 BI 100777                           protein_bindin~ "kof~ "1"   1/min Param~
       11 BI 100777                           protein_bindin~ "Kd,~ "2.8~ nmol~ Param~
       12 BI 100777                           metabolizing_e~ "Spe~ "234" 1/min n0026~
       13 BI 100777                           metabolizing_e~ "Km,~ "40.~ µmol~ Param~
       14 BI 100777                           transporter_pr~ "Km,~ "1"   µmol~ n0026~
       15 BI 100777                           transporter_pr~ "kca~ "222" 1/min n0026~
       16 BI 100777                           transporter_pr~ "Hil~ "2"   <NA>  <NA>  
       17 BI 100777                           renal_clearance "Km,~ "33"  µmol~ n0026~
       18 BI 100777                           renal_clearance "TSm~ "22.~ µmol~ Param~
       19 BI 100777                           biliary_cleara~ "Spe~ "32.~ 1/min Param~
       20 BI 100777                           inhibition      "Ki,~ "2"   µmol~ n0026~
       21 BI 100777                           induction       "EC5~ "1"   µmol~ n0025~
       22 BI 100777                           induction       "Ema~ "65.~ <NA>  Param~
       23 BI 100777- initial table parameters lipophilicity   "Opt~ "2.8~ Log ~ R24-4~
       24 BI 100777- initial table parameters fraction_unbou~ "Ger~ "0.0~ %     R24-4~
       25 BI 100777- initial table parameters molecular_weig~  <NA> "150~ g/mol c2647~
       26 BI 100777- initial table parameters halogens        "Cl"  "1"   <NA>  c2647~
       27 BI 100777- initial table parameters halogens        "F"   "1"   <NA>  c2647~
       28 BI 100777- initial table parameters pKa             "bas~ "6.2" <NA>  c2647~
       29 BI 100777- initial table parameters pKa             "aci~ "10.~ <NA>  c2647~
       30 BI 100777- initial table parameters solubility      "pH ~ "0.0~ mg/ml n0026~
       31 BI 100777- initial table parameters intestinal_per~ "Opt~ "0.0~ cm/m~ n0026~
       32 BI 100777- initial table parameters protein_bindin~ "kof~ "1"   1/min Assum~
       33 BI 100777- initial table parameters protein_bindin~ "Kd,~ "1.8" nmol~ <NA>  
       34 BI 100777- initial table parameters metabolizing_e~ "Spe~ "234" 1/min Calcu~
       35 BI 100777- initial table parameters metabolizing_e~ "Km,~ "37.~ µmol~ Assum~
       36 BI 100777- initial table parameters metabolizing_e~ "kca~ "3.5~ 1/min n0026~
       37 BI 100777- initial table parameters transporter_pr~ "Km,~ "1"   µmol~ n0026~
       38 BI 100777- initial table parameters transporter_pr~ "kca~ "222" 1/min n0026~
       39 BI 100777- initial table parameters transporter_pr~ "Hil~ "2"   <NA>  <NA>  
       40 BI 100777- initial table parameters renal_clearance "Km,~ "33"  µmol~ n0026~
       41 BI 100777- initial table parameters renal_clearance "TSm~ "23"  µmol~ Assum~
       42 BI 100777- initial table parameters biliary_cleara~ "Spe~ "34"  1/min Assum~
       43 BI 100777- initial table parameters inhibition      "Ki,~ "2"   µmol~ n0026~
       44 BI 100777- initial table parameters induction       "EC5~ "1"   µmol~ n0025~
       45 BI 100777- initial table parameters induction       "Ema~ "67"  <NA>  n0025~
       46 BI 123456                           lipophilicity   "Opt~ "2.8~ Log ~ Param~
       47 BI 123456                           lipophilicity   "Log~ "3.5~ Log ~ R13-5~
       48 BI 123456                           fraction_unbou~ "Ger~ "0.0~ <NA>  Param~
       49 BI 123456                           fraction_unbou~ "tes~ "12"  %     R13-5~
       50 BI 123456                           molecular_weig~  <NA> "150~ g/mol c0183~
       51 BI 123456                           halogens        "Cl"  "1"   <NA>  c0183~
       52 BI 123456                           halogens        "F"   "1"   <NA>  c0183~
       53 BI 123456                           pKa             "bas~ "6.2" <NA>  c2647~
       54 BI 123456                           pKa             "aci~ "10.~ <NA>  c2647~
       55 BI 123456                           solubility      "FaS~ "0.0~ mg/ml Param~
       56 BI 123456                           solubility      "Tab~ "pH ~ mg/l  R20-1~
       57 BI 123456                           intestinal_per~ "Opt~ "0.0~ cm/m~ Param~
       58 BI 123456                           protein_bindin~ "kof~ "1"   1/min Param~
       59 BI 123456                           protein_bindin~ "Kd,~ "1.8" nmol~ Param~
       60 BI 123456                           protein_bindin~ "kof~ "3"   1/min c4436~
       61 BI 123456                           protein_bindin~ "Kd,~ "4"   µmol~ c4436~
       62 BI 123456                           metabolizing_e~ "Km,~ "1"   µmol~ Assum~
       63 BI 123456                           metabolizing_e~ "Vma~ "14.~ µmol~ PK-Si~
       64 BI 123456                           metabolizing_e~ "Spe~ "234" 1/min PK-Si~
       65 BI 123456                           metabolizing_e~ "CLs~ "12"  l/µm~ Param~
       66 BI 123456                           metabolizing_e~ "Km,~ "1"   µmol~ Param~
       67 BI 123456                           metabolizing_e~ "kca~ "56"  1/min c2647~
       68 BI 123456                           metabolizing_e~ "Km,~ "12"  µmol~ c4436~
       69 BI 123456                           metabolizing_e~ "kca~ "211" 1/min c4436~
       70 BI 123456                           metabolizing_e~ "Hil~ "8"   <NA>  Assum~
       71 BI 123456                           metabolizing_e~ "CLs~ "45"  l/µm~ c2647~
       72 BI 123456                           metabolizing_e~ "Km,~ "3"   µmol~ c4436~
       73 BI 123456                           metabolizing_e~ "kca~ "13"  1/min Param~
       74 BI 123456                           metabolizing_e~ "CLs~ "0.4~ l/µm~ PK-Si~
       75 BI 123456                           metabolizing_e~ "Km,~ "3"   µmol~ c3195~
       76 BI 123456                           metabolizing_e~ "kca~ "44"  1/min Param~
       77 BI 123456                           metabolizing_e~ "CLs~ "23"  l/µm~ Param~
       78 BI 123456                           metabolizing_e~ "Km,~ "37.~ µmol~ Param~
       79 BI 123456                           metabolizing_e~ "kca~ "3.5~ 1/min Param~
       80 BI 123456                           metabolizing_e~ "Km,~ "1"   µmol~ R07-0~
       81 BI 123456                           metabolizing_e~ "kca~ "2"   1/min R07-0~
       82 BI 123456                           metabolizing_e~ "Hil~ "1"   <NA>  Assum~
       83 BI 123456                           hepatic_cleara~ "Tot~ "19.~ 1/min PK-Si~
       84 BI 123456                           transporter_pr~ "Km,~ "1"   µmol~ c2647~
       85 BI 123456                           transporter_pr~ "Vma~ "26"  µmol~ c2647~
       86 BI 123456                           transporter_pr~ "Km,~ "2"   µmol~ c4436~
       87 BI 123456                           transporter_pr~ "Km,~ "1"   µmol~ c4436~
       88 BI 123456                           transporter_pr~ "kca~ "222" 1/min c4436~
       89 BI 123456                           transporter_pr~ "Hil~ "2"   <NA>  Assum~
       90 BI 123456                           transporter_pr~ "Km,~ "1"   µmol~ Param~
       91 BI 123456                           transporter_pr~ "kca~ "45"  1/min Param~
       92 BI 123456                           renal_clearance "Spe~ "66"  1/min Param~
       93 BI 123456                           biliary_cleara~ "Spe~ "34"  1/min Param~
       94 BI 123456                           inhibition      "Ki,~ "23"  µmol~ Param~
       95 BI 123456                           inhibition      "Ki,~ "2"   µmol~ c2647~
       96 BI 123456                           inhibition      "Ki,~ "1.6~ µmol~ Param~
       97 BI 123456                           inhibition      "Ki,~ "3"   µmol~ c4436~
       98 BI 123456                           inhibition      "Ki-~ "1"   µmol~ c4436~
       99 BI 123456                           inhibition      "Ki-~ "1"   µmol~ Param~
      100 BI 123456                           inhibition      "kin~ "2"   1/min Param~
      101 BI 123456                           inhibition      "K-k~ "1"   µmol~ R24-3~
      102 BI 123456                           inhibition      "Ki,~ "2"   µmol~ c2647~
      103 BI 123456                           inhibition      "kin~ "1.6~ 1/min c3195~
      104 BI 123456                           inhibition      "K-k~ "6"   µmol~ c3195~
      105 BI 123456                           inhibition      "Ki,~ "6"   µmol~ Assum~
      106 BI 123456                           induction       "EC5~ "1"   µmol~ Param~
      107 BI 123456                           induction       "Ema~ "67"  <NA>  c4436~
      108 BI 123456                           induction       "EC5~ "1"   µmol~ Param~
      109 BI 123456                           induction       "Ema~ "200" <NA>  Param~
      110 Perpetrator_2                       lipophilicity   "Opt~ "2.5" Log ~ R13-5~
      111 Perpetrator_2                       fraction_unbou~ "Tem~ "17"  %     R13-5~
      112 Perpetrator_2                       molecular_weig~  <NA> "822~ g/mol <NA>  
      113 Perpetrator_2                       pKa             "bas~ "7.9" <NA>  R24-3~
      114 Perpetrator_2                       pKa             "aci~ "1.7" <NA>  R24-3~
      115 Perpetrator_2                       solubility      "Aqu~ "280~ mg/l  R20-1~
      116 Perpetrator_2                       solubility      "tes~ "345" mg/l  <NA>  
      117 Perpetrator_2                       renal_clearance "GFR~ "1"   <NA>  R20-1~
      118 Rifampicin                          lipophilicity   "Opt~ "2.5" Log ~ R13-5~
      119 Rifampicin                          fraction_unbou~ "Tem~ "17"  %     R13-5~
      120 Rifampicin                          molecular_weig~  <NA> "822~ g/mol R13-5~
      121 Rifampicin                          pKa             "bas~ "7.9" <NA>  R24-3~
      122 Rifampicin                          pKa             "aci~ "1.7" <NA>  R24-3~
      123 Rifampicin                          solubility      "Aqu~ "280~ mg/l  R20-1~
      124 Rifampicin                          solubility      "tes~ "345" mg/l  <NA>  
      125 Rifampicin                          intestinal_per~ "PK-~ "3.8~ cm/m~ PK-Si~
      126 Rifampicin                          metabolizing_e~ "Km,~ "195~ µmol~ Param~
      127 Rifampicin                          metabolizing_e~ "kca~ "9.8~ 1/min R24-3~
      128 Rifampicin                          hepatic_cleara~ "Tot~ "47.~ 1/min Param~
      129 Rifampicin                          hepatic_cleara~ "Tot~ "666" 1/h   c4436~
      130 Rifampicin                          transporter_pr~ "Km,~ "1.5" µmol~ Param~
      131 Rifampicin                          transporter_pr~ "kca~ "7.7~ 1/min R20-1~
      132 Rifampicin                          transporter_pr~ "Km,~ "55"  µmol~ Param~
      133 Rifampicin                          transporter_pr~ "kca~ "0.6~ 1/min R20-1~
      134 Rifampicin                          renal_clearance "GFR~ "1"   <NA>  R20-1~
      135 Rifampicin                          inhibition      "Ki,~ "30.~ µmol~ R18-3~
      136 Rifampicin                          inhibition      "Ki,~ "18.~ µmol~ R18-3~
      137 Rifampicin                          inhibition      "Ki,~ "23"  µmol~ Param~
      138 Rifampicin                          inhibition      "Ki-~ "23"  µmol~ R18-3~
      139 Rifampicin                          inhibition      "Ki-~ "3"   µmol~ Param~
      140 Rifampicin                          inhibition      "kin~ "2"   1/min R24-3~
      141 Rifampicin                          inhibition      "K-k~ "22"  µmol~ R24-3~
      142 Rifampicin                          inhibition      "Ki,~ "22"  µmol~ Assum~
      143 Rifampicin                          inhibition      "Ki,~ "0.4~ µmol~ R24-3~
      144 Rifampicin                          inhibition      "Ki,~ "0.9" µmol~ R24-3~
      145 Rifampicin                          inhibition      "Ki,~ "169" µmol~ R24-3~
      146 Rifampicin                          induction       "EC5~ "0.3~ µmol~ R20-1~
      147 Rifampicin                          induction       "Ema~ "0.9~ <NA>  Param~
      148 Rifampicin                          induction       "EC5~ "0.3~ µmol~ P07-0~
      149 Rifampicin                          induction       "Ema~ "0.6~ <NA>  Param~
      150 Rifampicin                          induction       "EC5~ "0.3~ µmol~ Param~
      151 Rifampicin                          induction       "Ema~ "3.2" <NA>  R20-1~
      152 Rifampicin                          induction       "EC5~ "0.3~ µmol~ P07-0~
      153 Rifampicin                          induction       "Ema~ "0.8" <NA>  R24-3~
      154 Rifampicin                          induction       "EC5~ "0.3~ µmol~ R24-3~
      155 Rifampicin                          induction       "Ema~ "9"   <NA>  R24-3~
      156 Rifampicin                          induction       "EC5~ "0.3~ µmol~ Param~
      157 Rifampicin                          induction       "Ema~ "0.3~ <NA>  Param~
      158 Rifampicin                          induction       "EC5~ "0.3~ µmol~ R20-1~
      159 Rifampicin                          induction       "Ema~ "2.5" <NA>  R20-1~
      160 test                                lipophilicity   "Mea~ "2"   Log ~ Param~
      161 test                                fraction_unbou~ "Mea~ "0.4~ <NA>  Param~
      162 test                                molecular_weig~  <NA> "123" g/mol <NA>  
      163 test                                halogens        "Br"  "1"   <NA>  <NA>  
      164 test                                halogens        "Cl"  "1"   <NA>  <NA>  
      165 test                                pKa             "bas~ "2"   <NA>  <NA>  
      166 test                                solubility      "Mea~ "3"   mg/l  Param~
      167 test                                solubility      "tes~ "5"   mg/l  <NA>  

