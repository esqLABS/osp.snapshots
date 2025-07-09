# Compound collection is printed correctly

    Code
      print(snapshot$compounds)
    Message
      
      -- Compounds (6) ---------------------------------------------------------------
      * Rifampicin
      * BI 123456
      * Perpetrator_2
      * BI 100777- initial table parameters
      * BI 100777
      * test

# Compounds are printed correctly

    Code
      print(compound)
    Output
      
      -- Compound: Rifampicin --------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Small Molecule
      * Plasma Protein Binding Partner: Albumin
      * Molecular Weight: 822.94 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: PK-Sim Standard
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2.5 Log Units [Publication - Other - (R13-5357)]
      * Fraction Unbound:
        * 17 % [Publication - InVitro - (R13-5357)]
      * Solubility:
        * Aqueous: 2800 mg/l (pH 7.5) [Publication - (R20-1499)]
        * test: 345 mg/l (pH 7) [Unknown]
      * Intestinal Permeability:
        * 3.836e-07 cm/min [Publication - (PK-Sim default calculation)]
      * pKa Types:
        * Base: 7.9 [Database - (R24-3728)]
        * Acid: 1.7 [Database - (R24-3728)]
      
      -- Processes --
      
      Processes (21 total):
        * Metabolism:
          * MetabolizationSpecific_MM (AADAC): Enzyme concentration=1 µmol/l, Vmax=12
          µmol/l/min, Km=195.1 µmol/l, kcat=9.865 1/min [Nakajima 2011]
        * Transport:
          * ActiveTransportSpecific_MM (P-gp): Transporter concentration=1 nmol/l,
          Vmax=0 µmol/l/min, Km=55 µmol/l, kcat=0.6088 1/min [Collett 2004]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1.5 µmol/l, kcat=7.796 1/min [Tirona 2003]
        * Clearance:
          * BiliaryClearance [BCL]
          * LiverClearance: Specific clearance=666 1/h [test123]
          * TubularSecretion_FirstOrder: Tubular secretion=33 l/min, TSspec=55 1/min
          [RenCL_rif]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=18.5 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (P-gp): Ki=169 µmol/l [Reitman 2011]
          * CompetitiveInhibition (CYP2C8): Ki=30.2 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (OATP1B1): Ki=0.477 µmol/l [Hirano 2006]
          * CompetitiveInhibition (OATP1B3): Ki=0.9 µmol/l [Annaert 2010]
          * CompetitiveInhibition (CYP3A4): Ki=23 µmol/l [Comp]
          * MixedInhibition (CYP3A4): Ki_c=23 µmol/l, Ki_u=3 µmol/l [Mixed]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=22 µmol/l
          [Irreversible]
        * Induction:
          * Induction (CYP3A4): EC50=0.34 µmol/l, Emax=9 [Templeton 2011]
          * Induction (P-gp): EC50=0.34 µmol/l, Emax=2.5 [Greiner 1999]
          * Induction (OATP1B1): EC50=0.34 µmol/l, Emax=0.383 [Dixit 2007]
          * Induction (AADAC): EC50=0.34 µmol/l, Emax=0.985 [Assumed]
          * Induction (CYP2C8): EC50=0.34 µmol/l, Emax=3.2 [Buckley 2014]
          * Induction (CYP1A2): EC50=0.34 µmol/l, Emax=0.65 [Chen 2010]
          * Induction (CYP2E1): EC50=0.34 µmol/l, Emax=0.8 [Rae 2001]

---

    Code
      print(compound)
    Output
      
      -- Compound: BI 123456 ---------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Large Molecule
      * Plasma Protein Binding Partner: Glycoprotein
      * Molecular Weight: 150000 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: Charge dependent Schmitt
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * Optimized: 2.8972038771 Log Units [ParameterIdentification - (Value updated
        from '3.3.2 - Base oral model (SD, solution, + DDI, + MD), with CatC, both
        pKa fitted' on 2024-03-11 17:39)]
        * LogP (Simcyp): 3.53 Log Units [Publication - (R13-5357)]
      * Fraction Unbound:
        * Gertz et al. 2010: 0.031 [ParameterIdentification - (Value updated from 'PI
        Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on 2019-04-09
        16:10)]
        * test: 12 % [Publication - (R13-5357)]
      * Solubility:
        * FaSSiF: 0.049 mg/ml (pH 6.5) [ParameterIdentification - (Value updated from
        'PI Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on
        2019-04-09 16:10)]
        * Table: 5000 mg/l (Table: pH 3→5000 mg/l, pH 6→3000 mg/l, pH 6.8→90 mg/l)
        [Publication - (R20-1499)]
      * Intestinal Permeability:
        * 0.00015549970673 cm/min [ParameterIdentification - (Value updated from 'PI
        Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on 2019-04-09
        16:10)]
      * pKa Types:
        * Base: 6.2 [Publication - (c26475781)]
        * Acid: 10.95 [Publication - (c26475781)]
      
      -- Processes --
      
      Processes (30 total):
        * Metabolism:
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=0 pmol/min/mg mic. protein, Km=37.8 µmol/l,
          kcat=3.5911771641 1/min [Optimized]
          * MetabolizationSpecific_Hill (UGT1A4): Enzyme concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=2 1/min, Hill coefficient=1 [Kim et
          al, 2020]
          * MetabolizationIntrinsic_MM (CYP3A4): Fraction intracellular (liver)=0.45,
          Vmax (liver tissue)=12 µmol/min/kg tissue, Km=1 µmol/l, Vmax=14.93
          µmol/l/min [Int-MM]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Fraction intracellular
          (liver)=0.8, Intrinsic clearance=800 l/min, Specific clearance=234 1/min
          [Int_FO]
          * MetabolizationSpecific_FirstOrder (CYP3A4): Enzyme concentration=1
          µmol/l, Specific clearance=330 1/min, CLspec/[Enzyme]=12 l/µmol/min [In
          vitro_FO]
          * MetabolizationSpecific_MM (CYP3A4): Enzyme concentration=1 µmol/l, Vmax=0
          µmol/l/min, Km=1 µmol/l, kcat=56 1/min [In vitro_MM]
          * MetabolizationSpecific_Hill (CYP3A4): Enzyme concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=12 µmol/l, kcat=211 1/min, Hill coefficient=8 [In
          vitro_H]
          * rCYP450_FirstOrder (CYP3A4): In vitro CL/recombinant enzyme=0 µl/min/pmol
          rec. enzyme, CLspec/[Enzyme]=45 l/µmol/min [In vitro_recombinant_FO]
          * rCYP450_MM (CYP3A4): In vitro Vmax/recombinant enzyme=59 nmol/min/pmol
          rec. enzyme, Km=3 µmol/l, kcat=13 1/min [In vitro_recombinant_MM]
          * MetabolizationLiverMicrosomes_FirstOrder (CYP3A4): In vitro CL for liver
          microsomes=56 µl/min/mg mic. protein, Content of CYP proteins in liver
          microsomes=120 pmol/mg mic. protein, CLspec/[Enzyme]=0.467 l/µmol/min
          [liv_micros_FO]
          * MetabolizationLiverMicrosomes_MM (CYP3A4): In vitro Vmax for liver
          microsomes=0 pmol/min/mg mic. protein, Km=3 µmol/l, kcat=44 1/min
          [liv_micros_MM]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=78.6
          l/min [test]
        * Transport:
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=1.8 nmol/l [Buhr 1997]
          * ActiveTransportIntrinsic_MM (OATP1B1): Vmax (liver tissue)=23 µmol/min/kg
          tissue, Km=1 µmol/l, Vmax=26 µmol/l/min [Int _ MM]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=3 µmol/l,
          Vmax=100 µmol/l/min, Km=2 µmol/l, kcat=33.3333333333 1/min [Spec_MM]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=1
          µmol/l, Vmax=12 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
          * ActiveTransport_InVitro_VesicularAssay_MM (OATP1B1): In vitro
          Vmax/transporter=56 nmol/min/pmol transporter, Km=1 µmol/l, kcat=45 1/min
          [In vitro_MM]
          * SpecificBinding (NTCP): koff=3 1/min, Kd=4 µmol/l [wer]
        * Clearance:
          * BiliaryClearance: Specific clearance=34 1/min [n45678]
          * KidneyClearance: Specific clearance=66 1/min [Kidney_plasma_CL]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
          * UncompetitiveInhibition (CYP3A4): Ki=1.667 µmol/l [uncomp_inh]
          * NoncompetitiveInhibition (CYP3A4): Ki=3 µmol/l [non-comp_inh]
          * MixedInhibition (CYP3A4): Ki_c=1 µmol/l, Ki_u=1 µmol/l [mixed_inh]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=1 µmol/l,
          Ki=2 µmol/l [irr_ing_2]
          * CompetitiveInhibition (ABCB1): Ki=23 µmol/l [test]
          * IrreversibleInhibition (CYP3A4): kinact=1.67 1/min, K_kinact_half=6
          µmol/l [irr_3]
        * Induction:
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=67 [induction]
          * Induction (GABRG2): EC50=1 µmol/l, Emax=200 [GABRG2-ind]
        * Other:
          * LiverMicrosomeHalfTime: t1/2 (microsomal assay)=23 min, Specific
          clearance=19.49 1/min [In vitro_mic_t1/2]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c01835608)]
        * F: 1 [Publication - (c01835608)]

---

    Code
      print(compound)
    Output
      
      -- Compound: Perpetrator_2 -----------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Small Molecule
      * Plasma Protein Binding Partner: Albumin
      * Molecular Weight: 822.94 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: PK-Sim Standard
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2.5 Log Units [Publication - Other - (R13-5357)]
      * Fraction Unbound:
        * 17 % [Publication - InVitro - (R13-5357)]
      * Solubility:
        * Aqueous: 2800 mg/l (pH 7.5) [Publication - (R20-1499)]
        * test: 345 mg/l (pH 7) [Unknown]
      * pKa Types:
        * Base: 7.9 [Database - (R24-3728)]
        * Acid: 1.7 [Database - (R24-3728)]
      
      -- Processes --
      
      Processes (2 total):
        * Clearance:
          * GlomerularFiltration: GFR fraction=1 [GFR]
          * HepatocytesRes: Measuring time=12 min, Residual fraction=23 % [In vitro
          hep_res]

---

    Code
      print(compound)
    Output
      
      -- Compound: BI 100777- initial table parameters -------------------------------
      
      -- Basic Properties --
      
      * Type: Large Molecule
      * Molecular Weight: 150000 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: Charge dependent Schmitt
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2.8972038771 Log Units [Publication - InVitro - (R24-4081)]
      * Fraction Unbound:
        * 0.031 % [Publication - InVitro - (R24-4081)]
      * Solubility:
        * 0.049 mg/ml (pH 6.5) [Publication - InVivo - (n00261417)]
      * Intestinal Permeability:
        * 0.00015549970673 cm/min [Publication - InVitro - (123456_456444_4.0)]
      * pKa Types:
        * Base: 6.2 [Publication - (c26475781)]
        * Acid: 10.95 [Publication - (c26475781)]
      
      -- Processes --
      
      Processes (9 total):
        * Metabolism:
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=0 pmol/min/mg mic. protein, Km=37.8 µmol/l,
          kcat=3.5911771641 1/min [Optimized]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=342
          l/min, Specific clearance=234 1/min [Int_FO]
        * Transport:
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=1.8 nmol/l [in-vitro]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=1
          µmol/l, Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
        * Clearance:
          * BiliaryClearance: Specific clearance=34 1/min [n45678]
          * TubularSecretion_MM: TSmax=0 µmol/min, Km=33 µmol/l, TSmax_spec=23
          µmol/l/min [TuSec_MM]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
        * Induction:
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=67 [induction]
        * Other:
          * LiverMicrosomeRes: Measuring time=345 min, Residual fraction=34 % [In
          vitro_mic_res]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c26475781)]
        * F: 1 [Publication - (c26475781)]

---

    Code
      print(compound)
    Output
      
      -- Compound: BI 100777 ---------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Large Molecule
      * Molecular Weight: 150000 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Poulin and Theil
      * Permeability: Charge dependent Schmitt
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 3.233 Log Units [ParameterIdentification]
      * Fraction Unbound:
        * 0.031 % [Publication - InVitro - (n00261417)]
      * Solubility:
        * 0.5 mg/ml (pH 6.5) [ParameterIdentification]
      * Intestinal Permeability:
        * 2.04 cm/min [ParameterIdentification]
      * pKa Types:
        * Base: 6.2 [Publication - (c26475781)]
        * Acid: 10.95 [Publication - (c26475781)]
      
      -- Processes --
      
      Processes (9 total):
        * Metabolism:
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=12 pmol/min/mg mic. protein, Content of CYP
          proteins in liver microsomes=109 pmol/mg mic. protein, Km=40.23 µmol/l,
          kcat=0.1111111111 1/min [Optimized]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=888
          l/min, Specific clearance=234 1/min [Int_FO]
        * Transport:
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=2.81 nmol/l [in-vitro]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=12
          µmol/l, Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
        * Clearance:
          * BiliaryClearance: Specific clearance=32.88 1/min [n45678]
          * TubularSecretion_MM: TSmax=12 µmol/min, Km=33 µmol/l, TSmax_spec=22.65
          µmol/l/min [TuSec_MM]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
        * Induction:
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=65.134 [induction]
        * Other:
          * LiverMicrosomeRes: Measuring time=345 min, Residual fraction=34 % [In
          vitro_mic_res]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c26475781)]
        * F: 1 [Publication - (c26475781)]

---

    Code
      print(compound)
    Output
      
      -- Compound: test --------------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Small Molecule
      * Plasma Protein Binding Partner: Albumin
      * Molecular Weight: 123 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: PK-Sim Standard
      * Permeability: PK-Sim Standard
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2 Log Units [ParameterIdentification]
      * Fraction Unbound:
        * 0.45 [ParameterIdentification]
      * Solubility:
        * Measurement: 3 mg/l (pH 7) [ParameterIdentification]
        * test: 5 mg/l (pH 7) [Unknown]
      * pKa Types:
        * Base: 2 [Unknown]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Br: 1 [Unknown]
        * Cl: 1 [Unknown]

# Compounds sections can be accessed and are correctly printed

    Code
      snapshot$compounds[[1]]$lipophilicity
    Message
      * Lipophilicity:
        * 2.5 Log Units [Publication - Other - (R13-5357)]

---

    Code
      snapshot$compounds[[1]]$processes
    Message
      Processes (21 total):
        * Metabolism:
          * MetabolizationSpecific_MM (AADAC): Enzyme concentration=1 µmol/l, Vmax=12
          µmol/l/min, Km=195.1 µmol/l, kcat=9.865 1/min [Nakajima 2011]
        * Transport:
          * ActiveTransportSpecific_MM (P-gp): Transporter concentration=1 nmol/l,
          Vmax=0 µmol/l/min, Km=55 µmol/l, kcat=0.6088 1/min [Collett 2004]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1.5 µmol/l, kcat=7.796 1/min [Tirona 2003]
        * Clearance:
          * BiliaryClearance [BCL]
          * LiverClearance: Specific clearance=666 1/h [test123]
          * TubularSecretion_FirstOrder: Tubular secretion=33 l/min, TSspec=55 1/min
          [RenCL_rif]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=18.5 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (P-gp): Ki=169 µmol/l [Reitman 2011]
          * CompetitiveInhibition (CYP2C8): Ki=30.2 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (OATP1B1): Ki=0.477 µmol/l [Hirano 2006]
          * CompetitiveInhibition (OATP1B3): Ki=0.9 µmol/l [Annaert 2010]
          * CompetitiveInhibition (CYP3A4): Ki=23 µmol/l [Comp]
          * MixedInhibition (CYP3A4): Ki_c=23 µmol/l, Ki_u=3 µmol/l [Mixed]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=22 µmol/l
          [Irreversible]
        * Induction:
          * Induction (CYP3A4): EC50=0.34 µmol/l, Emax=9 [Templeton 2011]
          * Induction (P-gp): EC50=0.34 µmol/l, Emax=2.5 [Greiner 1999]
          * Induction (OATP1B1): EC50=0.34 µmol/l, Emax=0.383 [Dixit 2007]
          * Induction (AADAC): EC50=0.34 µmol/l, Emax=0.985 [Assumed]
          * Induction (CYP2C8): EC50=0.34 µmol/l, Emax=3.2 [Buckley 2014]
          * Induction (CYP1A2): EC50=0.34 µmol/l, Emax=0.65 [Chen 2010]
          * Induction (CYP2E1): EC50=0.34 µmol/l, Emax=0.8 [Rae 2001]

---

    Code
      snapshot$compounds[[2]]$parameters
    Message
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c01835608)]
        * F: 1 [Publication - (c01835608)]

# Compounds can be converted to dataframes

    Code
      print(get_compounds_dfs(snapshot), n = Inf)
    Output
      # A tibble: 237 x 7
          name                           parameter type  value unit  source dataSource
          <chr>                          <chr>     <chr> <chr> <chr> <chr>  <chr>     
        1 BI 100777                      lipophil~ "Opt~ "3.2~ Log ~ "Para~ <NA>      
        2 BI 100777                      fraction~ "Ger~ "0.0~ %     "n002~ <NA>      
        3 BI 100777                      molecula~  <NA> "150~ g/mol "c264~ <NA>      
        4 BI 100777                      halogens  "Cl"  "1"   <NA>  "c264~ <NA>      
        5 BI 100777                      halogens  "F"   "1"   <NA>  "c264~ <NA>      
        6 BI 100777                      pKa       "bas~ "6.2" <NA>  "c264~ <NA>      
        7 BI 100777                      pKa       "aci~ "10.~ <NA>  "c264~ <NA>      
        8 BI 100777                      solubili~ "pH ~ "0.5" mg/ml "Para~ <NA>      
        9 BI 100777                      intestin~ "Opt~ "2.0~ cm/m~ "Para~ <NA>      
       10 BI 100777                      protein_~ "kof~ "1"   1/min "Para~ in-vitro  
       11 BI 100777                      protein_~ "Kd,~ "2.8~ nmol~ "Para~ in-vitro  
       12 BI 100777                      metaboli~ "In ~ "12"  pmol~ "n002~ Optimized 
       13 BI 100777                      metaboli~ "Con~ "109" pmol~ "n002~ Optimized 
       14 BI 100777                      metaboli~ "Km,~ "40.~ µmol~ "Para~ Optimized 
       15 BI 100777                      metaboli~ "kca~ "0.1~ 1/min "PK-S~ Optimized 
       16 BI 100777                      metaboli~ "Int~ "888" l/min  <NA>  Int_FO    
       17 BI 100777                      metaboli~ "Spe~ "234" 1/min "n002~ Int_FO    
       18 BI 100777                      hepatic_~ "Lip~ "3.2~ Log ~  <NA>  In vitro_~
       19 BI 100777                      hepatic_~ "Mea~ "345" min   "R24-~ In vitro_~
       20 BI 100777                      hepatic_~ "Res~ "34"  %     "R24-~ In vitro_~
       21 BI 100777                      transpor~ "Tra~ "12"  µmol~  <NA>  Spec_H    
       22 BI 100777                      transpor~ "Vma~ "0"   µmol~  <NA>  Spec_H    
       23 BI 100777                      transpor~ "Km,~ "1"   µmol~ "n002~ Spec_H    
       24 BI 100777                      transpor~ "kca~ "222" 1/min "n002~ Spec_H    
       25 BI 100777                      transpor~ "Hil~ "2"   <NA>   <NA>  Spec_H    
       26 BI 100777                      renal_cl~ "TSm~ "12"  µmol~  <NA>  TuSec_MM  
       27 BI 100777                      renal_cl~ "Km"  "33"  µmol~ "n002~ TuSec_MM  
       28 BI 100777                      renal_cl~ "TSm~ "22.~ µmol~ "Para~ TuSec_MM  
       29 BI 100777                      biliary_~ "Fra~ "0.0~ <NA>   <NA>  n45678    
       30 BI 100777                      biliary_~ "Lip~ "2.8~ Log ~  <NA>  n45678    
       31 BI 100777                      biliary_~ "Pla~ "34"  ml/m~ "Assu~ n45678    
       32 BI 100777                      biliary_~ "Spe~ "32.~ 1/min "Para~ n45678    
       33 BI 100777                      inhibiti~ "Ki,~ "2"   µmol~ "n002~ comp_inh  
       34 BI 100777                      induction "EC5~ "1"   µmol~ "n002~ induction 
       35 BI 100777                      induction "Ema~ "65.~ <NA>  "Para~ induction 
       36 BI 100777- initial table para~ lipophil~ "Opt~ "2.8~ Log ~ "R24-~ <NA>      
       37 BI 100777- initial table para~ fraction~ "Ger~ "0.0~ %     "R24-~ <NA>      
       38 BI 100777- initial table para~ molecula~  <NA> "150~ g/mol "c264~ <NA>      
       39 BI 100777- initial table para~ halogens  "Cl"  "1"   <NA>  "c264~ <NA>      
       40 BI 100777- initial table para~ halogens  "F"   "1"   <NA>  "c264~ <NA>      
       41 BI 100777- initial table para~ pKa       "bas~ "6.2" <NA>  "c264~ <NA>      
       42 BI 100777- initial table para~ pKa       "aci~ "10.~ <NA>  "c264~ <NA>      
       43 BI 100777- initial table para~ solubili~ "pH ~ "0.0~ mg/ml "n002~ <NA>      
       44 BI 100777- initial table para~ intestin~ "Opt~ "0.0~ cm/m~ "1234~ <NA>      
       45 BI 100777- initial table para~ protein_~ "kof~ "1"   1/min "Assu~ in-vitro  
       46 BI 100777- initial table para~ protein_~ "Kd,~ "1.8" nmol~  <NA>  in-vitro  
       47 BI 100777- initial table para~ metaboli~ "In ~ "0"   pmol~  <NA>  Optimized 
       48 BI 100777- initial table para~ metaboli~ "Km,~ "37.~ µmol~ "Assu~ Optimized 
       49 BI 100777- initial table para~ metaboli~ "kca~ "3.5~ 1/min "n002~ Optimized 
       50 BI 100777- initial table para~ metaboli~ "Int~ "342" l/min "n002~ Int_FO    
       51 BI 100777- initial table para~ metaboli~ "Spe~ "234" 1/min "Calc~ Int_FO    
       52 BI 100777- initial table para~ hepatic_~ "Lip~ "2.8~ Log ~  <NA>  In vitro_~
       53 BI 100777- initial table para~ hepatic_~ "Mea~ "345" min   "R24-~ In vitro_~
       54 BI 100777- initial table para~ hepatic_~ "Res~ "34"  %     "R24-~ In vitro_~
       55 BI 100777- initial table para~ transpor~ "Tra~ "1"   µmol~  <NA>  Spec_H    
       56 BI 100777- initial table para~ transpor~ "Vma~ "0"   µmol~  <NA>  Spec_H    
       57 BI 100777- initial table para~ transpor~ "Km,~ "1"   µmol~ "n002~ Spec_H    
       58 BI 100777- initial table para~ transpor~ "kca~ "222" 1/min "n002~ Spec_H    
       59 BI 100777- initial table para~ transpor~ "Hil~ "2"   <NA>   <NA>  Spec_H    
       60 BI 100777- initial table para~ renal_cl~ "TSm~ "0"   µmol~  <NA>  TuSec_MM  
       61 BI 100777- initial table para~ renal_cl~ "Km"  "33"  µmol~ "n002~ TuSec_MM  
       62 BI 100777- initial table para~ renal_cl~ "TSm~ "23"  µmol~ "Assu~ TuSec_MM  
       63 BI 100777- initial table para~ biliary_~ "Fra~ "0.0~ <NA>   <NA>  n45678    
       64 BI 100777- initial table para~ biliary_~ "Lip~ "2.8~ Log ~  <NA>  n45678    
       65 BI 100777- initial table para~ biliary_~ "Pla~ "0"   ml/m~  <NA>  n45678    
       66 BI 100777- initial table para~ biliary_~ "Spe~ "34"  1/min "Assu~ n45678    
       67 BI 100777- initial table para~ inhibiti~ "Ki,~ "2"   µmol~ "n002~ comp_inh  
       68 BI 100777- initial table para~ induction "EC5~ "1"   µmol~ "n002~ induction 
       69 BI 100777- initial table para~ induction "Ema~ "67"  <NA>  "n002~ induction 
       70 BI 123456                      lipophil~ "Opt~ "2.8~ Log ~ "Para~ <NA>      
       71 BI 123456                      lipophil~ "Log~ "3.5~ Log ~ "R13-~ <NA>      
       72 BI 123456                      fraction~ "Ger~ "0.0~ <NA>  "Para~ <NA>      
       73 BI 123456                      fraction~ "tes~ "12"  %     "R13-~ <NA>      
       74 BI 123456                      molecula~  <NA> "150~ g/mol "c018~ <NA>      
       75 BI 123456                      halogens  "Cl"  "1"   <NA>  "c018~ <NA>      
       76 BI 123456                      halogens  "F"   "1"   <NA>  "c018~ <NA>      
       77 BI 123456                      pKa       "bas~ "6.2" <NA>  "c264~ <NA>      
       78 BI 123456                      pKa       "aci~ "10.~ <NA>  "c264~ <NA>      
       79 BI 123456                      solubili~ "FaS~ "0.0~ mg/ml "Para~ <NA>      
       80 BI 123456                      solubili~ "Tab~ "pH ~ mg/l  "R20-~ <NA>      
       81 BI 123456                      intestin~ "Opt~ "0.0~ cm/m~ "Para~ <NA>      
       82 BI 123456                      protein_~ "kof~ "1"   1/min "Para~ Buhr 1997 
       83 BI 123456                      protein_~ "Kd,~ "1.8" nmol~ "Para~ Buhr 1997 
       84 BI 123456                      protein_~ "kof~ "3"   1/min "c443~ wer       
       85 BI 123456                      protein_~ "Kd,~ "4"   µmol~ "c443~ wer       
       86 BI 123456                      metaboli~ "In ~ "0"   pmol~  <NA>  Optimized 
       87 BI 123456                      metaboli~ "Km,~ "37.~ µmol~ "Para~ Optimized 
       88 BI 123456                      metaboli~ "kca~ "3.5~ 1/min "Para~ Optimized 
       89 BI 123456                      metaboli~ "Enz~ "1"   µmol~  <NA>  Kim et al~
       90 BI 123456                      metaboli~ "Vma~ "0"   µmol~  <NA>  Kim et al~
       91 BI 123456                      metaboli~ "Km,~ "1"   µmol~ "R07-~ Kim et al~
       92 BI 123456                      metaboli~ "kca~ "2"   1/min "R07-~ Kim et al~
       93 BI 123456                      metaboli~ "Hil~ "1"   <NA>  "Assu~ Kim et al~
       94 BI 123456                      metaboli~ "Fra~ "0.4~ <NA>  "Assu~ Int-MM    
       95 BI 123456                      metaboli~ "Vma~ "12"  µmol~ "c443~ Int-MM    
       96 BI 123456                      metaboli~ "Km,~ "1"   µmol~ "Assu~ Int-MM    
       97 BI 123456                      metaboli~ "Vma~ "14.~ µmol~ "PK-S~ Int-MM    
       98 BI 123456                      metaboli~ "Fra~ "0.8" <NA>  "Assu~ Int_FO    
       99 BI 123456                      metaboli~ "Int~ "800" l/min "c123~ Int_FO    
      100 BI 123456                      metaboli~ "Spe~ "234" 1/min "PK-S~ Int_FO    
      101 BI 123456                      metaboli~ "Enz~ "1"   µmol~  <NA>  In vitro_~
      102 BI 123456                      metaboli~ "Spe~ "330" 1/min  <NA>  In vitro_~
      103 BI 123456                      metaboli~ "CLs~ "12"  l/µm~ "Para~ In vitro_~
      104 BI 123456                      metaboli~ "Enz~ "1"   µmol~  <NA>  In vitro_~
      105 BI 123456                      metaboli~ "Vma~ "0"   µmol~  <NA>  In vitro_~
      106 BI 123456                      metaboli~ "Km,~ "1"   µmol~ "Para~ In vitro_~
      107 BI 123456                      metaboli~ "kca~ "56"  1/min "c264~ In vitro_~
      108 BI 123456                      metaboli~ "Enz~ "1"   µmol~  <NA>  In vitro_H
      109 BI 123456                      metaboli~ "Vma~ "0"   µmol~  <NA>  In vitro_H
      110 BI 123456                      metaboli~ "Km,~ "12"  µmol~ "c443~ In vitro_H
      111 BI 123456                      metaboli~ "kca~ "211" 1/min "c443~ In vitro_H
      112 BI 123456                      metaboli~ "Hil~ "8"   <NA>  "Assu~ In vitro_H
      113 BI 123456                      metaboli~ "In ~ "0"   µl/m~  <NA>  In vitro_~
      114 BI 123456                      metaboli~ "CLs~ "45"  l/µm~ "c264~ In vitro_~
      115 BI 123456                      metaboli~ "In ~ "59"  nmol~ "c443~ In vitro_~
      116 BI 123456                      metaboli~ "Km,~ "3"   µmol~ "c443~ In vitro_~
      117 BI 123456                      metaboli~ "kca~ "13"  1/min "Para~ In vitro_~
      118 BI 123456                      metaboli~ "In ~ "56"  µl/m~ "c443~ liv_micro~
      119 BI 123456                      metaboli~ "Con~ "120" pmol~ "c443~ liv_micro~
      120 BI 123456                      metaboli~ "CLs~ "0.4~ l/µm~ "PK-S~ liv_micro~
      121 BI 123456                      metaboli~ "In ~ "0"   pmol~  <NA>  liv_micro~
      122 BI 123456                      metaboli~ "Km,~ "3"   µmol~ "c319~ liv_micro~
      123 BI 123456                      metaboli~ "kca~ "44"  1/min "Para~ liv_micro~
      124 BI 123456                      metaboli~ "Int~ "78.~ l/min "c443~ test      
      125 BI 123456                      hepatic_~ "Lip~ "2.8~ Log ~ "PK-S~ In vitro_~
      126 BI 123456                      hepatic_~ "t1/~ "23"  min   "R24-~ In vitro_~
      127 BI 123456                      hepatic_~ "Spe~ "19.~ 1/min "PK-S~ In vitro_~
      128 BI 123456                      transpor~ "Vma~ "23"  µmol~  <NA>  Int _ MM  
      129 BI 123456                      transpor~ "Km,~ "1"   µmol~ "c264~ Int _ MM  
      130 BI 123456                      transpor~ "Vma~ "26"  µmol~ "c264~ Int _ MM  
      131 BI 123456                      transpor~ "Tra~ "3"   µmol~ "c264~ Spec_MM   
      132 BI 123456                      transpor~ "Vma~ "100" µmol~ "c264~ Spec_MM   
      133 BI 123456                      transpor~ "Km,~ "2"   µmol~ "c443~ Spec_MM   
      134 BI 123456                      transpor~ "kca~ "33.~ 1/min "PK-S~ Spec_MM   
      135 BI 123456                      transpor~ "Tra~ "1"   µmol~  <NA>  Spec_H    
      136 BI 123456                      transpor~ "Vma~ "12"  µmol~  <NA>  Spec_H    
      137 BI 123456                      transpor~ "Km,~ "1"   µmol~ "c443~ Spec_H    
      138 BI 123456                      transpor~ "kca~ "222" 1/min "c443~ Spec_H    
      139 BI 123456                      transpor~ "Hil~ "2"   <NA>  "Assu~ Spec_H    
      140 BI 123456                      transpor~ "In ~ "56"  nmol~  <NA>  In vitro_~
      141 BI 123456                      transpor~ "Km,~ "1"   µmol~ "Para~ In vitro_~
      142 BI 123456                      transpor~ "kca~ "45"  1/min "Para~ In vitro_~
      143 BI 123456                      renal_cl~ "Fra~ "0.0~ <NA>   <NA>  Kidney_pl~
      144 BI 123456                      renal_cl~ "Pla~ "24"  ml/m~  <NA>  Kidney_pl~
      145 BI 123456                      renal_cl~ "Spe~ "66"  1/min "Para~ Kidney_pl~
      146 BI 123456                      biliary_~ "Fra~ "0.0~ <NA>   <NA>  n45678    
      147 BI 123456                      biliary_~ "Lip~ "2.8~ Log ~  <NA>  n45678    
      148 BI 123456                      biliary_~ "Pla~ "12"  ml/m~  <NA>  n45678    
      149 BI 123456                      biliary_~ "Spe~ "34"  1/min "Para~ n45678    
      150 BI 123456                      inhibiti~ "Ki,~ "2"   µmol~ "c264~ comp_inh  
      151 BI 123456                      inhibiti~ "Ki,~ "1.6~ µmol~ "Para~ uncomp_inh
      152 BI 123456                      inhibiti~ "Ki,~ "3"   µmol~ "c443~ non-comp_~
      153 BI 123456                      inhibiti~ "Ki_~ "1"   µmol~ "c443~ mixed_inh 
      154 BI 123456                      inhibiti~ "Ki_~ "1"   µmol~ "Para~ mixed_inh 
      155 BI 123456                      inhibiti~ "kin~ "2"   1/min "Para~ irr_ing_2 
      156 BI 123456                      inhibiti~ "K_k~ "1"   µmol~ "R24-~ irr_ing_2 
      157 BI 123456                      inhibiti~ "Ki,~ "2"   µmol~ "c264~ irr_ing_2 
      158 BI 123456                      inhibiti~ "Ki,~ "23"  µmol~ "Para~ test      
      159 BI 123456                      inhibiti~ "kin~ "1.6~ 1/min "c319~ irr_3     
      160 BI 123456                      inhibiti~ "K_k~ "6"   µmol~ "c319~ irr_3     
      161 BI 123456                      inhibiti~ "Ki,~ "6"   µmol~ "Assu~ irr_3     
      162 BI 123456                      induction "EC5~ "1"   µmol~ "Para~ induction 
      163 BI 123456                      induction "Ema~ "67"  <NA>  "c443~ induction 
      164 BI 123456                      induction "EC5~ "1"   µmol~ "Para~ GABRG2-ind
      165 BI 123456                      induction "Ema~ "200" <NA>  "Para~ GABRG2-ind
      166 Perpetrator_2                  lipophil~ "Opt~ "2.5" Log ~ "R13-~ <NA>      
      167 Perpetrator_2                  fraction~ "Tem~ "17"  %     "R13-~ <NA>      
      168 Perpetrator_2                  molecula~  <NA> "822~ g/mol  <NA>  <NA>      
      169 Perpetrator_2                  pKa       "bas~ "7.9" <NA>  "R24-~ <NA>      
      170 Perpetrator_2                  pKa       "aci~ "1.7" <NA>  "R24-~ <NA>      
      171 Perpetrator_2                  solubili~ "Aqu~ "280~ mg/l  "R20-~ <NA>      
      172 Perpetrator_2                  solubili~ "tes~ "345" mg/l   <NA>  <NA>      
      173 Perpetrator_2                  hepatic_~ "Mea~ "12"  min   "c319~ In vitro ~
      174 Perpetrator_2                  hepatic_~ "Res~ "23"  %     "c319~ In vitro ~
      175 Perpetrator_2                  renal_cl~ "GFR~ "1"   <NA>  "R20-~ GFR       
      176 Rifampicin                     lipophil~ "Opt~ "2.5" Log ~ "R13-~ <NA>      
      177 Rifampicin                     fraction~ "Tem~ "17"  %     "R13-~ <NA>      
      178 Rifampicin                     molecula~  <NA> "822~ g/mol "R13-~ <NA>      
      179 Rifampicin                     pKa       "bas~ "7.9" <NA>  "R24-~ <NA>      
      180 Rifampicin                     pKa       "aci~ "1.7" <NA>  "R24-~ <NA>      
      181 Rifampicin                     solubili~ "Aqu~ "280~ mg/l  "R20-~ <NA>      
      182 Rifampicin                     solubili~ "tes~ "345" mg/l   <NA>  <NA>      
      183 Rifampicin                     intestin~ "PK-~ "3.8~ cm/m~ "PK-S~ <NA>      
      184 Rifampicin                     metaboli~ "Enz~ "1"   µmol~  <NA>  Nakajima ~
      185 Rifampicin                     metaboli~ "Vma~ "12"  µmol~  <NA>  Nakajima ~
      186 Rifampicin                     metaboli~ "Km,~ "195~ µmol~ "Para~ Nakajima ~
      187 Rifampicin                     metaboli~ "kca~ "9.8~ 1/min "R24-~ Nakajima ~
      188 Rifampicin                     hepatic_~ "Fra~ "0.1~ <NA>   <NA>  test123   
      189 Rifampicin                     hepatic_~ "Lip~ "2.5" Log ~  <NA>  test123   
      190 Rifampicin                     hepatic_~ "Pla~ "12"  ml/m~  <NA>  test123   
      191 Rifampicin                     hepatic_~ "Spe~ "666" 1/h   "c443~ test123   
      192 Rifampicin                     transpor~ "Tra~ "1"   nmol~  <NA>  Collett 2~
      193 Rifampicin                     transpor~ "Vma~ "0"   µmol~  <NA>  Collett 2~
      194 Rifampicin                     transpor~ "Km,~ "55"  µmol~ "Para~ Collett 2~
      195 Rifampicin                     transpor~ "kca~ "0.6~ 1/min "R20-~ Collett 2~
      196 Rifampicin                     transpor~ "Tra~ "1"   µmol~  <NA>  Tirona 20~
      197 Rifampicin                     transpor~ "Vma~ "0"   µmol~  <NA>  Tirona 20~
      198 Rifampicin                     transpor~ "Km,~ "1.5" µmol~ "Para~ Tirona 20~
      199 Rifampicin                     transpor~ "kca~ "7.7~ 1/min "R20-~ Tirona 20~
      200 Rifampicin                     renal_cl~ "Tub~ "33"  l/min  <NA>  RenCL_rif 
      201 Rifampicin                     renal_cl~ "TSs~ "55"  1/min "Assu~ RenCL_rif 
      202 Rifampicin                     biliary_~ "Fra~ "0.1~ <NA>  "PK-S~ BCL       
      203 Rifampicin                     biliary_~ "Lip~ "2.5" Log ~ "PK-S~ BCL       
      204 Rifampicin                     biliary_~ "Pla~ "12"  ml/m~ "Assu~ BCL       
      205 Rifampicin                     inhibiti~ "Ki,~ "18.~ µmol~ "R18-~ Kajosaari~
      206 Rifampicin                     inhibiti~ "Ki,~ "30.~ µmol~ "R18-~ Kajosaari~
      207 Rifampicin                     inhibiti~ "Ki,~ "169" µmol~ "R24-~ Reitman 2~
      208 Rifampicin                     inhibiti~ "Ki,~ "0.4~ µmol~ "R24-~ Hirano 20~
      209 Rifampicin                     inhibiti~ "Ki,~ "0.9" µmol~ "R24-~ Annaert 2~
      210 Rifampicin                     inhibiti~ "Ki,~ "23"  µmol~ "Para~ Comp      
      211 Rifampicin                     inhibiti~ "Ki_~ "23"  µmol~ "R18-~ Mixed     
      212 Rifampicin                     inhibiti~ "Ki_~ "3"   µmol~ "Para~ Mixed     
      213 Rifampicin                     inhibiti~ "kin~ "2"   1/min "R24-~ Irreversi~
      214 Rifampicin                     inhibiti~ "K_k~ "22"  µmol~ "R24-~ Irreversi~
      215 Rifampicin                     inhibiti~ "Ki,~ "22"  µmol~ "Assu~ Irreversi~
      216 Rifampicin                     induction "EC5~ "0.3~ µmol~ "R24-~ Templeton~
      217 Rifampicin                     induction "Ema~ "9"   <NA>  "R24-~ Templeton~
      218 Rifampicin                     induction "EC5~ "0.3~ µmol~ "R20-~ Greiner 1~
      219 Rifampicin                     induction "Ema~ "2.5" <NA>  "R20-~ Greiner 1~
      220 Rifampicin                     induction "EC5~ "0.3~ µmol~ "Para~ Dixit 2007
      221 Rifampicin                     induction "Ema~ "0.3~ <NA>  "Para~ Dixit 2007
      222 Rifampicin                     induction "EC5~ "0.3~ µmol~ "R20-~ Assumed   
      223 Rifampicin                     induction "Ema~ "0.9~ <NA>  "Para~ Assumed   
      224 Rifampicin                     induction "EC5~ "0.3~ µmol~ "Para~ Buckley 2~
      225 Rifampicin                     induction "Ema~ "3.2" <NA>  "R20-~ Buckley 2~
      226 Rifampicin                     induction "EC5~ "0.3~ µmol~ "P07-~ Chen 2010 
      227 Rifampicin                     induction "Ema~ "0.6~ <NA>  "Para~ Chen 2010 
      228 Rifampicin                     induction "EC5~ "0.3~ µmol~ "P07-~ Rae 2001  
      229 Rifampicin                     induction "Ema~ "0.8" <NA>  "R24-~ Rae 2001  
      230 test                           lipophil~ "Mea~ "2"   Log ~ "Para~ <NA>      
      231 test                           fraction~ "Mea~ "0.4~ <NA>  "Para~ <NA>      
      232 test                           molecula~  <NA> "123" g/mol  <NA>  <NA>      
      233 test                           halogens  "Br"  "1"   <NA>   <NA>  <NA>      
      234 test                           halogens  "Cl"  "1"   <NA>   <NA>  <NA>      
      235 test                           pKa       "bas~ "2"   <NA>   <NA>  <NA>      
      236 test                           solubili~ "Mea~ "3"   mg/l  "Para~ <NA>      
      237 test                           solubili~ "tes~ "5"   mg/l   <NA>  <NA>      

