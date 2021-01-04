
# Construction of Variables Used in "Private Consultants Promote Agricultural Investments in Mozambique"

The lists and tables below describe how the variables used for the data anaysis in the paper were constructed, starting from the data we collected from multiple sources.

&nbsp;

## ID Variables

- `prov` is an indicator variable for the province strata
- `associd` is the association identifier variable
- `hhid` is the unique household identifier variable
- `treatment` is a dummy variable equal to 1 if the association received follow-up visits from EY (the treatment)
- `bl_attended` is a dummy variable equal to 1 if the household attended the financial literacy training
- `data_endline` is a dummy variable equal to 1 if the household was interviewed in the endline survey
- `pweight` is a numerical variable equal for the sampling weights, i.e., the inverse of the probability that the household was sampled for the endline survey, in each association

&nbsp;

## Project Administrative Data

- `ad_items` is a string containing the list of items the association applied for (in Portuguese)
- `ad_d_equipment` is a dummy variable equal to 1 if the association received financing from the PROIRRI matching grant
- `ad_success` is a dummy variable equal to 1 if the association received financing from the PROIRRI matching grant, conditional on having applied
- `ad_proirri_cost` is the value of the PROIRRI matching grant equipment (in MZN)

&nbsp;

## Association and Household Census

| Variable name in Stata     | Definition
| -------------------------- | -----------
| `nbr_members`    	   	     | Total number of members in the producer organization
| `bl_communal_ha`  		 | Total area of communal land (in hectares)
| `bl_irrigation_ha`         | Total area of cultivated land covered by irrigation (in hectares)
| `bl_finlit_training`  	 | Any members received a financial literacy training before PROIRRI
| `bl_finlit_years_ago`	     | Conditional on receiving a financial literacy training (`bl_finlit_training` > 0), how many years ago any members received the training
| `bl_animal_traction_assoc` | Any members have animal traction kit
| `bl_multicultivator` 	 	 | Any members have a multi-cultivator
| `bl_processing` 			 | Any members have a processing machine
| `bl_silo` 				 | Any members have a silo
| `bl_mg_success`	    	 | Any members have received funding through the PROIRRI matching grant program
| `bl_bank_account`			 | Community has a bank account
| `bl_hhsize` 	   			 | Pre-intervention household size
| `bl_rainfed_ha`  			 | Pre-intervention rainfed land (in hectares)

&nbsp;

## Box Pick-Up Data

### Quarterly

| Variable name in Stata | Definition
| ---------------------- | -----------
| `bp_vX_boxvalue` 	     | Value of household saving contributions in quarter X
| `bp_vX_d_saved`	  	 | Household saved in quarter X, has some positive contribution in quarter X (`bp_vX_boxvalue` > 0)
| `bp_vX_boxvalue_cumul` | Value of household saving contributions accumulated by quarter X
| `bp_vX_d_saved_cumul`  | Household saved by quarter X (`bp_vX_boxvalue_cumul` > 0)
| `bp_vX_boxvalue_ihs`   | Inverse hyperbolic sine transformation of household saving contributions in quarter X
| `bp_vX_boxvalue_w95`   | Household saving contributions in quarter X winsorized at the 95th percentile
| `bp_vX_boxvalue_t95`   | Household saving contributions in quarter X trimmed at the 95th percentile

### Total

| Variable name in Stata | Definition
| ---------------------- | ----------
| `bp_v0_target`         | Planned household saving goal at the financial literacy training
| `bp_final_cont` 	     | Total value of household contributions, i.e., sum of quarter contributions (`bp_v1_boxvalue` + `bp_v2_boxvalue` + `bp_v3_boxvalue` + `bp_v4_boxvalue`)
| `bp_d_saved`	  	     | Household saved, i.e, has some positive contribution in one of the quarter (`bp_final_cont` > 0)
| `bp_final_gap`         | Household saving gap from planned saving target (`bp_final_cont` - `bp_v0_target`)
| `bp_d_saving_goal`     | Household reached saving goal (`bp_final_gap` < 0)

&nbsp;

## Household Endline Survey

| Variable name in Stata | Information contained                                                                               | Survey question(s) used |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------------------- |
| `el_durroof`		     | House has durable roof			                                                                   | 2.11                    |
| `el_durwalls`          | House has durable walls                                                                             | 2.12                    |
| `el_headgender`	 	 | Head of household's gender                                                                          | 3.04	                 |
| `el_headage`			 | Head of household's age                                                                             | 3.05                    |
| `el_headeduc`			 | Head of household's education level                                                                 | 3.08, 3.10              |
| `el_savingstart`       | How much money household saved pre-intervention (in MZN)                                            | 5.06                    |
| `el_proposal`          | Household participated in proposal                                                                  | 5.07                    |
| `el_groupproposal`	 | Household participated in group proposal                                                            | 5.08                    |
| `el_proposalspoke` 	 | Household talked with other members about contribution                                              | 5.12                    |
| `el_proposalpernow`	 | Percentage of members that reached their savings goals                                              | 5.13                    |
| `el_proposalperstart`  | Percentage of members expected to reach their savings goals in the beginning of the project         | 5.14                    |
| `el_proposalknow_more` | Household more inclined to contribute had they they know other members would reach savings goals    | 5.15                    |
| `el_visits`            | Knew of visit from the trainers                                                                     | 5.19                    |
| `el_one_meeting`       | Attended one meeting                                                                                | 5.20a-c                 |
| `el_two_meeting`       | Attended two meetings                                                                               | 5.20a-c                 |
| `el_three_meeting`     | Attended three meetings						                                                       | 5.20a-c                 |
| `el_visitgoals`        | Savings goals discussed during visits                                                               | 5.21                    |
| `el_visitreview`       | Savings plan reviewed during visits                                                                 | 5.22                    |
| `el_visitupdate`       | Savings plan updated during visits                                                                  | 5.23                    |
| `el_visitconseq_1`	 | Names of those who did not meet their goal was mentioned at meetings                                | 5.24                    |
| `el_visitconseq_2`	 | Names of those who did not meet their goal was displayed to the association                         | 5.24                    |
| `el_visitconseq_3`	 | Missing value of contributions were displaced                                                       | 5.24                    |
| `el_visituseful`       | Found the visits were useful in mobilizing savings                                                  | 5.25                    |
| `el_helpfultreat_12`   | Found the trainers were very or somewhat helpful                                                    | 5.27                    |
| `el_trustinfo`         | Trusted the information that the trainer provided to the association                                | 5.28                    |
| `el_trustmg`           | Trusted the project would give the matching grant if the saving guidelines on the proposal were met | 5.29                    |
| `el_credyn`			 | Household received credit                                                                           | 5.33                    |
| `el_credobj_inputs`    | Household received credit for agricultural inputs                                                   | 5.38                    |
| `el_credobj_goods `    | Household received credit for other commerical goods                                                | 5.38                    |
| `el_credobj_equipment` | Household received credit for agricultural machinery                                                | 5.38                    |
| `el_plot_rent_costs`   | Cost of plot rent (in MZN)                                                                          | 6.47                    |
| `el_seed_costs`        | Cost of seeds (in MZN)                                                                              | 8.13                    |
| `el_fertorguse`        | Household used organic fertilizer                                                                   | 8.18                    |
| `el_fertchemuse`       | Household used chemical fertilizer                                                                  | 8.23                    |
| `el_pestuse`           | Household used pesticides                                                                           | 8.28                    |
| `el_fertorg_costs`     | Costs of organic fertilizer (in MZN)                                                                | 8.22                    |
| `el_chemorg_costs`     | Costs of chemical fertilizer (in MZN)                                                               | 8.27                    |
| `el_pest_costs`        | Costs of pesticides (in MZN)                                                                        | 8.32                    |
| `el_worker_costs`      | Costs of workers (in MZN)                                                                           | 8.47, 8.50              |
| `el_livestock_costs`   | Cost of livestock (in MZN)                                                                          | 10.08                   |
| `el_d_usecattle`       | Household uses cattle                                                                               | 11.01                   |
| `el_d_usetraction`     | Household uses animal traction                                                                      | 11.01                   |
| `el_d_usecart`         | Household uses a cart                                                                               | 11.01                   |
| `el_d_usetractor`      | Household uses a tractor                                                                            | 11.01                   |
| `el_d_useplough`       | Household uses a plough                                                                             | 11.01                   |
| `el_d_usemotocult`     | Household uses a motocultivator                                                                     | 11.01                   |
| `el_d_useseeder`       | Household uses a seeder                                                                             | 11.01                   |
| `el_d_usetrailer`      | Household uses a trailer                                                                            | 11.01                   |
| `el_d_usemotorpump`    | Household uses a motorpump                                                                          | 11.01                   |
| `el_d_useelecpump`     | Household uses an electrict pump                                                                    | 11.01                   |
| `el_d_owncattle`       | Household owns cattle                                                                               | 11.02                   |
| `el_d_owntraction`     | Household owns animal traction                                                                      | 11.02                   |
| `el_d_owncart`         | Household owns a cart                                                                               | 11.02                   |
| `el_d_owntractor`      | Household owns a tractor                                                                            | 11.02                   |
| `el_d_ownplough`       | Household owns a plough                                                                             | 11.02                   |
| `el_d_ownmotocult`     | Household owns a motocultivator                                                                     | 11.02                   |
| `el_d_ownseeder`       | Household owns a seeder                                                                             | 11.02                   |
| `el_d_owntrailer`      | Household owns a trailer                                                                            | 11.02                   |
| `el_d_ownmotorpump`    | Household owns a motorpump                                                                          | 11.02                   |
| `el_d_ownelecpump`     | Household owns an electrict pump                                                                    | 11.02                   |
| `el_equip_rent_costs`  | Cost of equipment rent (in MZN)                                                                     | 11.03                   |

- `el_wealth_index` is a composite index equal to the arithmetic sum of dummy variables (0/1) measuring ownership of non-productive durable assets. Namely, the household assets considered were oil lamp (question 2.01), radio (2.02), bicycle (2.03), latrine (2.04), table (2.05), cellphone (2.06), solar panel (2.07), motorbike (2.08), television (2.09), and fridge (2.10)
- `el_shock_mean` is the share of households who were exposed to (at least) a shock in the association. Shocks considered are drought, flood, and cyclone (retrieved from questions 8.15b, 8.17, 8.56, 8.65, 9.10, and 10.05)
- `el_penalty_mean` is the share of households who reported penalty outcomes in the association. Penalty outcomes considered are `el_visitconseq_1`, `el_visitconseq_2` and `el_visitconseq_3` (see table above)

&nbsp;

-----------------------------------------------------------------------------------------------------
