
# Dofiles' Inputs and Outputs in "Private Consultants Promote Agricultural Investments in Mozambique"

## Figures
- `fig01-assoc_item_mix.do` uses project administrative data at the association level &#8594; plots Figure 1.

- `figA01-treat_map.R` uses GPS coordinates at the association level (these are identified information and, therefore, are not part of the final dataset) &#8594; plots Figure A1. *[NOTE:  The R script requires you to have a Google API key (to be included in line 57) in order to retrieve the base map.]*
- `figA02-hh_penalty_outcomes.do` uses household endline survey data &#8594; plots Figure A2.

## Tables
- `tab02-baltab.do`	uses administrative and household survey data &#8594; produces Table 2. *[NOTE: This code may take a long time as it employs randomization inference techniques with 10,000 replications.]*
- `tab03-assoc_savingsValue.do` uses project administrative data at the association level &#8594; produces Table 3.
- `tab04-hh_saving.do` uses box pick-up data at the household level &#8594; produces Table 4.
- `tab05-assoc_equipment.do` uses project administrative data at the association level &#8594; produces Table 5.
- `tab06-7,A04-6-hh_multiple_hypothesis_testing.do` uses household endline survey data &#8594; produces Tables 6, 7, A4, A5, and A6. *[NOTE: This code may take a long time as the multiple hypothesis testing procedure performs (10,000) bootstrap replications for resampling.]*


- `tabA01-assoc_targetValue.do` uses project administrative data at the association level &#8594; produces Table A1.
- `tabA02-descriptives.do` uses data at the association and household level &#8594; produces Table A2.
- `tabA03-hh_saving_gap.do` uses box pick-up data at the household level &#8594; produces Table A3.
- `tabA07-hh_saving_pooled.do` uses box pick-up data at the household level &#8594; produces Table A7.
- `tabA08-hh_saving_winsor.do` uses box pick-up data at the household level &#8594; produces Table A8.
- `tabA09-hh_saving_training.do` uses box pick-up data at the household level &#8594; produces Table A9.
- `tabA10-hh_saving_controls.do` uses box pick-up and survey data at the household level &#8594; produces Table A10.
- `tabA11-hh_saving_el.do` uses box pick-up data at the household level &#8594; produces Table A11.
- `tabA12-hh_saving_boottest.do` uses box pick-up data at the household level &#8594; produces Table A12.
- `tabA13-hh_followup_visits.do` uses household endline survey data &#8594; produces Table A13.
- `tabA14-hh_saving_het_penalty.do` uses box pick-up and endline survey data at the household level &#8594; produces Table A14.
- `tabA15-hh_collective_action.do` uses household endline survey data &#8594; produces Table A15.

&nbsp;

-----------------------------------------------------------------------------------------------------
