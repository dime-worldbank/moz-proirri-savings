
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique"		   		       *
*																			   *
*							MAIN/PRINCIPAL DO-FILE							   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:			Matteo Ruzzante [mruzzante@worldbank.org]
		REVIEWED BY:			
		
		Last update on:		July 2020
						
			PART 0: Settings
			PART 1:	Folder paths
			PART 2:	Data processing
					
					
/-------------------------------------------------------------------------------
 							 Select sections to run							   
-------------------------------------------------------------------------------*/
	
	local packages		1		//install or update packages
	local analysis		1		//produce tables and figures in the main text of the paper
	local appendix		1		//produce tables and figures in the appendix of the paper
	
********************************************************************************
*          PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS				   *
********************************************************************************
{		
	if `packages' {
	
		* List all packages that this project requires
		#d	;
		
			local packageList
							  dataout
							  distinct
							  estout
							  ftools   	//needed for 'reghdfe'
							  keeporder
							  iefieldkit
							  ietoolkit
							  reghdfe
							  ritest
							  winsor2
							  wyoung
			;
		#d	cr
	
		foreach  package of local packageList {
		
			ssc  install `package', replace
		}
		
		* Force an update
		ftools  , compile
		reghdfe , compile
		//solve issues with estimations based on previous versions
		//namely, error "class FixedEffects undefined" may arise
	}
	
	* Set key globals for computation
	global repsNum   	10000		//number of replications for randomization inference estimations
	global seedsNum		868379		//retrieved from random.org on 5/13/2019, 3.10PM EST
  	global sleepTime	1000		//delay code for running so it doesn't crash
	global stataVersion 15.0		//Stata version: change to older version if you don't have the one specified
									//however, beware that this may cause some packages to not work properly
									//and some results to vary
	
	//In order to reproduce some of the figures, you will need to have
	//Stata version 15 or 16: in particular, you won't be able to use the 
	//feature that adjusts the transparency of elements in graphs
	
	* Standardize settings across users
	ieboilstart, version(${stataVersion})
			  `r(version)'                    
}	
	
********************************************************************************
*						PART 1:  SET FOLDER PATH GLOBALS					   *
********************************************************************************
{
	* Directory (root folder) 
	* ---------
	
		* Original coder
		if  c(username) == "ruzza" {
			
			global dataFolder "C:/Users/ruzza/Dropbox/PROIRRI Financial Literacy - DIME Analytics Code Review"
			global githubRepo "C:/Users/ruzza/OneDrive/Documenti/GitHub/moz-proirri-savings"
		}
		
		* Reviewer or other user
		if 	c(username) ==    "" { //you can find your username by running "di c(username)" in the command window, and then subsitute it here
			
			global dataFolder ""   //add the path where you saved the datasets here
			global githubRepo ""   //add the path where you cloned the GitHub repository here
								   //(see examples above)
		}
	
	* Subfolders
	* ----------
	
		global dt_fin	   "${dataFolder}"
		
		global dataWork    "${githubRepo}/DataWork"
			
		global out		   "${dataWork}/Output"
		global out_tab	   "${out}/Tables"
		global out_fig	   "${out}/Figures"
		
		global do		   "${dataWork}/Dofiles"
		global do_anl	   "${do}/Analysis"
				
		macro  list
		
		* Create folders if missing
		cap mkdir		   "${dt_int}"
		cap mkdir		   "${dt_fin}"
		
		cap mkdir		   "${out}"
		cap mkdir		   "${out_tab}"
		cap mkdir		   "${out_fig}"
}
	
********************************************************************************
*							PART 2:  RUN DO FILES							   *
******************************************************************************** 
{	
	* Set default graphical options
	set scheme 			 	s2color
	global 		  fontType "Palatino Linotype"
	gr set window fontface "${fontType}"
	gr set eps 	  fontface "${fontType}"
	
	global    controlColor	eltblue
	global  treatmentColor	navy
	global    generalColor  midblue
	
	global 	  graphOptions  title("") 											///
							ylab(, nogrid angle(horizontal))					///
							graphregion(color(white)) plotregion(color(white))	///
							bgcolor(white)
	
	* Set table general formatting options for [esttab]
	global	 esttabOptions  replace tex											///
							se nocons fragment									///
							nodepvars nonumbers nomtitles nolines				///
							noobs nonotes alignment(c)							///
							star(* 0.10 ** 0.05 *** 0.01)
	
	
	* Record important numbers about the sample
	global           hhNum  3081
	global 		  assocNum  42
	
	* Define important variables lists that are used across multiple do-files
	#d	;
	
		global assocIdVars
							prov associd treatment
		;
		
		global newBlVars
							bl_communal_ha 		bl_irrigation_ha
							bl_finlit_training  bl_finlit_years_ago
							bl_animal_traction_assoc
							bl_multicultivator  bl_processing bl_silo
							bl_mg_success 		bl_bank_account
							bl_hhsize  			bl_rainfed_ha
		;
		global balVars	
							nbr_members
							${newBlVars}
							el_headage 		    el_headeduc 		el_headgender
							el_durroof 		    el_durwalls 		el_savingstart
		;
		
		global machineryItems
							cattle traction cart tractor plough motocult seeder trailer
							motorpump elecpump
		;
		
		global credVars		
							el_credyn
							el_credobj_inputs   el_credobj_goods 	el_credobj_equipment
		;
		
		global inputVars	
							el_fertorguse       el_fertchemuse  	el_pestuse
							el_fertorg_costs    el_chemorg_costs 	el_pest_costs
		;
		
		global costVars  	
							el_worker_costs     el_seed_costs
							el_equip_rent_costs el_plot_rent_costs
							el_livestock_costs
		;
		
		global multipleHypVars 
							el_d_usecattle 		el_d_usetraction 	el_d_usecart 			  
							el_d_usetractor		el_d_useplough		el_d_usemotocult
							el_d_useseeder 	  	el_d_usetrailer	  	el_d_usemotorpump  
							el_d_useelecpump
				
							el_d_owncattle 		el_d_owntraction 	el_d_owncart 			  
							el_d_owntractor		el_d_ownplough		el_d_ownmotocult
							el_d_ownseeder 	  	el_d_owntrailer	  	el_d_ownmotorpump  
				
							${credVars}
							${inputVars}
							${costVars}
		;
						
		global controlVars
							nbr_members
							bl_irrigation_ha 	el_headage			el_headeduc
		;
		
	#d	cr
}				
	
	* Run do files	
	if `analysis' {
		
		* Main tables
		* -----------
		
		//Table 1 presents the timeline of the project implementation and
		//was directly typed in LaTeX
		
		do "${do_anl}/tab02-sample.do"											//Study sample
		
		do "${do_anl}/tab03-assoc_targetValue.do"								//Impact on target value at the association level (administrative data)
		
		do "${do_anl}/tab04-baltab.do"											//Balance table
		
		do "${do_anl}/tab05-assoc_savingsValue.do"								//Impact on saving value at the association level (administrative data)
		
		do "${do_anl}/tab06-hh_saving.do"										//Impact on saving decision and value at the household level (box pick-up data)
		
		do "${do_anl}/tab07-assoc_equipment.do"									//Impact on equipment reception and value at the association level (administrative data)
		
		do "${do_anl}/tab08,A04-7-hh_multiple_hypothesis_testing.do"			//Impact on outcomes from household survey data,
																				//such as mechanization use and ownership, credit, input use and costs
																				//that were not part of our pre-analysis plan for 
																				//the experiment filed in the AEA RCT Registry
																				//under "Group Interventions for Agricultural Transformation in Mozambique"
																				//(RCT ID: AEARCTR-0000937)
																				
		* Main figures
		* ------------
		
		do "${do_anl}/fig01-assoc_item_mix.do"									//Mix of items in the grant application (administrative data)
	}
	
	if `appendix' {
		
		* Supplementary figures
		* ---------------------
		
		// Figure 1 is produced by the R script "${do_anl}/figA01-treat_map.R"
		// using PII community-level data, i.e., GPS coordinates, 
		// that we are not making publicly available for privacy concerns
		
		do "${do_anl}/figA02-hh_penalty_outcomes.do"							//Percentage of households reporting penalty outcomes (household survey data)
		
		
		* Supplementary tables
		* --------------------
		
		do "${do_anl}/tabA01-descriptives.do"									//Descriptives and data source for variables used in `analysis'
		
		do "${do_anl}/tabA02-descriptives_app.do"								//Descriptives and data source for variables used in `appendix'

		do "${do_anl}/tabA03-hh_saving_gap.do"									//Impact on saving gap at the household level (box pick-up data)
		
		do "${do_anl}/tabA08-baltab_wealth.do"									//Balance table by wealth
		
		do "${do_anl}/tabA09-hh_saving_het_wealth_shock.do"						//Saving heterogeneous effect by wealth and shock exposure
		
		do "${do_anl}/tabA10-hh_use_mechanization_het_wealth.do"				//Mechanization heterogeneous effect by wealth
		
		do "${do_anl}/tabA11-baltab_shock.do"									//Balance table by shock exposure
		
		do "${do_anl}/tabA12-hh_saving_cumul.do"								//Impact on saving decision and value at the household level (box pick-up data) -- cumulative outcomes (summing over quarters)
		
		do "${do_anl}/tabA13-hh_saving_pooled.do"								//Impact on saving decision and value at the household level (box pick-up data) -- pooled outcomes
		
		do "${do_anl}/tabA14-hh_saving_ihs.do"									//Impact on saving decision and value at the household level (box pick-up data) -- inverse hyperbolic sine and logarithm transformation
		
		do "${do_anl}/tabA15-hh_saving_winsor.do"								//Impact on saving decision and value at the household level (box pick-up data) -- winsorized and trimmed values
		
		do "${do_anl}/tabA16-hh_saving_training.do"								//Impact on saving decision and value at the household level (box pick-up data) -- sample that attended the financial literacy training
		
		do "${do_anl}/tabA17-hh_saving_controls.do"								//Impact on savings, controlling for unbalanced covariates
		
		do "${do_anl}/tabA18-hh_saving_el.do"									//Impact on saving decision and value at the household level (box pick-up data) -- sample that was interviewed at endline		
		
		do "${do_anl}/tabA19-hh_followup_visits.do"								//Summary statistics on follow-up visits (household survey data)
		
	    do "${do_anl}/tabA20-hh_saving_het_penalty.do"							//Heterogeneous effect by penalty outcomes
		
		do "${do_anl}/tabA21-hh_collective_action.do"							//Impact on collective action failure (household survey data)	
	}
	

	* Close all graph windows, end the code and exit Stata
	gr 	   close _all
	exit , clear
	
	
	// Estamos juntos! :D 
