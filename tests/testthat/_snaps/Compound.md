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
      
      * Processes (22 total):
        * Metabolism
          * MetabolizationSpecific_MM (AADAC): Enzyme concentration=1 µmol/l, Vmax=12
          µmol/l/min, Km=195.1 µmol/l, kcat=9.865 1/min [Nakajima 2011]
        * Transport
          * ActiveTransportSpecific_MM (P-gp): Transporter concentration=1 nmol/l,
          Vmax=0 µmol/l/min, Km=55 µmol/l, kcat=0.6088 1/min [Collett 2004]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1.5 µmol/l, kcat=7.796 1/min [Tirona 2003]
        * Clearance
          * GlomerularFiltration: GFR fraction=1 [GFR]
          * BiliaryClearance [BCL]
          * LiverClearance: Specific clearance=47.3 1/min [test567]
          * LiverClearance: Specific clearance=666 1/h [test123]
        * Inhibition
          * CompetitiveInhibition (CYP3A4): Ki=18.5 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (P-gp): Ki=169 µmol/l [Reitman 2011]
          * CompetitiveInhibition (CYP2C8): Ki=30.2 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (OATP1B1): Ki=0.477 µmol/l [Hirano 2006]
          * CompetitiveInhibition (OATP1B3): Ki=0.9 µmol/l [Annaert 2010]
          * CompetitiveInhibition (CYP3A4): Ki=23 µmol/l [Comp]
          * MixedInhibition (CYP3A4): Ki_c=23 µmol/l, Ki_u=3 µmol/l [Mixed]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=22 µmol/l
          [Irreversible]
        * Induction
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
      
      * Processes (30 total):
        * Metabolism
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=0 pmol/min/mg mic. protein, Km=37.8 µmol/l,
          kcat=3.5911771641 1/min [Optimized]
          * MetabolizationSpecific_Hill (UGT1A4): Enzyme concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=2 1/min, Hill coefficient=1 [Kim et
          al, 2020]
          * MetabolizationIntrinsic_MM (CYP3A4): Vmax (liver tissue)=12 µmol/min/kg
          tissue, Km=1 µmol/l, Vmax=14.93 µmol/l/min [Int-MM]
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
          * MetabolizationLiverMicrosomes_FirstOrder (CYP3A4): In vitro CL for liver
          microsomes=0 µl/min/mg mic. protein, CLspec/[Enzyme]=23 l/µmol/min [test3]
        * Transport
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=1.8 nmol/l [Buhr 1997]
          * ActiveTransportIntrinsic_MM (OATP1B1): Vmax (liver tissue)=23 µmol/min/kg
          tissue, Km=1 µmol/l, Vmax=26 µmol/l/min [Int _ MM]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=3 µmol/l,
          Vmax=100 µmol/l/min, Km=2 µmol/l [Spec_MM]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=1
          µmol/l, Vmax=12 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
          * ActiveTransport_InVitro_VesicularAssay_MM (OATP1B1): In vitro
          Vmax/transporter=56 nmol/min/pmol transporter, Km=1 µmol/l, kcat=45 1/min
          [In vitro_MM]
          * SpecificBinding (NTCP): koff=3 1/min, Kd=4 µmol/l [wer]
        * Clearance
          * BiliaryClearance: Specific clearance=34 1/min [n45678]
          * KidneyClearance: Specific clearance=66 1/min [Kidney_plasma_CL]
        * Inhibition
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
          * UncompetitiveInhibition (CYP3A4): Ki=1.667 µmol/l [uncomp_inh]
          * NoncompetitiveInhibition (CYP3A4): Ki=3 µmol/l [non-comp_inh]
          * MixedInhibition (CYP3A4): Ki_c=1 µmol/l, Ki_u=1 µmol/l [mixed_inh]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=1 µmol/l,
          Ki=2 µmol/l [irr_ing_2]
          * CompetitiveInhibition (ABCB1): Ki=23 µmol/l [test]
          * IrreversibleInhibition (CYP3A4): kinact=1.67 1/min, K_kinact_half=6
          µmol/l [irr_3]
        * Induction
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=67 [induction]
          * Induction (GABRG2): EC50=1 µmol/l, Emax=200 [GABRG2-ind]
        * Other
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
      
      * Processes (2 total):
        * Clearance
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
      * Plasma Protein Binding Partner: Albumin
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
        * 0.00015549970673 cm/min [Publication - InVitro - (n00265826)]
      * pKa Types:
        * Base: 6.2 [Publication - (c26475781)]
        * Acid: 10.95 [Publication - (c26475781)]
      
      -- Processes --
      
      * Processes (9 total):
        * Metabolism
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=0 pmol/min/mg mic. protein, Km=37.8 µmol/l,
          kcat=3.5911771641 1/min [Optimized]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=342
          l/min, Specific clearance=234 1/min [Int_FO]
        * Transport
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=1.8 nmol/l [in-vitro]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=1
          µmol/l, Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
        * Clearance
          * BiliaryClearance: Specific clearance=34 1/min [n45678]
          * TubularSecretion_MM: TSmax=0 µmol/min, Km=33 µmol/l, TSmax_spec=23
          µmol/l/min [TuSec_MM]
        * Inhibition
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
        * Induction
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=67 [induction]
        * Other
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
      
      * Processes (9 total):
        * Metabolism
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=12 pmol/min/mg mic. protein, Km=40.23
          µmol/l [Optimized]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=888
          l/min, Specific clearance=234 1/min [Int_FO]
        * Transport
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=2.81 nmol/l [in-vitro]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=12
          µmol/l, Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
        * Clearance
          * BiliaryClearance: Specific clearance=32.88 1/min [n45678]
          * TubularSecretion_MM: TSmax=0 µmol/min, Km=33 µmol/l, TSmax_spec=22.65
          µmol/l/min [TuSec_MM]
        * Inhibition
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
        * Induction
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=65.134 [induction]
        * Other
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
      * Processes (22 total):
        * Metabolism
          * MetabolizationSpecific_MM (AADAC): Enzyme concentration=1 µmol/l, Vmax=12
          µmol/l/min, Km=195.1 µmol/l, kcat=9.865 1/min [Nakajima 2011]
        * Transport
          * ActiveTransportSpecific_MM (P-gp): Transporter concentration=1 nmol/l,
          Vmax=0 µmol/l/min, Km=55 µmol/l, kcat=0.6088 1/min [Collett 2004]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1.5 µmol/l, kcat=7.796 1/min [Tirona 2003]
        * Clearance
          * GlomerularFiltration: GFR fraction=1 [GFR]
          * BiliaryClearance [BCL]
          * LiverClearance: Specific clearance=47.3 1/min [test567]
          * LiverClearance: Specific clearance=666 1/h [test123]
        * Inhibition
          * CompetitiveInhibition (CYP3A4): Ki=18.5 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (P-gp): Ki=169 µmol/l [Reitman 2011]
          * CompetitiveInhibition (CYP2C8): Ki=30.2 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (OATP1B1): Ki=0.477 µmol/l [Hirano 2006]
          * CompetitiveInhibition (OATP1B3): Ki=0.9 µmol/l [Annaert 2010]
          * CompetitiveInhibition (CYP3A4): Ki=23 µmol/l [Comp]
          * MixedInhibition (CYP3A4): Ki_c=23 µmol/l, Ki_u=3 µmol/l [Mixed]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=22 µmol/l
          [Irreversible]
        * Induction
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

