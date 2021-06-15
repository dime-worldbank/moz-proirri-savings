
/*******************************************************************************
*																 			   *
* 	  				"Do Private Consultants Promote Savings					   *
*					 and Investments in Rural Mozambique?"	  				   *
*																			   *
*					Multiple hypothesis testing with controls				   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A11: Impact on Costs, Including Covariate Imbalances
						"${out_tab}/tabA11-hh_costs_controls.tex"
						
						Table A12: Impact on Mechanization Use, Including Covariate Imbalances
						"${out_tab}/tabA12-hh_use_mechanization_controls.tex"
						
* ---------------------------------------------------------------------------- *
*									Prepare data 			   		   		   *
* ---------------------------------------------------------------------------- */
		
	* Set Stata version
	* (Stata version is local so the code would not reproduce correctly
	*  if we ran this file separately from the master file)
	version ${stataVersion}
		
	* Load data
	use 	 "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
	
	* Make sure to keep only households who were interviewed at endline
	keep if  data_endline == 1
	
	* Remove variable with no variation across treatment from global
	local 	 wyoungVarlist ""
	
	foreach  outcomeVar of varlist $multipleHypVars {
			
		if     "`outcomeVar'" == "el_d_ownelecpump" continue
		else {
			local    wyoungVarlist  `wyoungVarlist' `outcomeVar'
		}
	}
		
* ---------------------------------------------------------------------------- *
*							Multiple hypothesis testing		   		   		   *
* ---------------------------------------------------------------------------- *
		
	* Ensure the sort order
	* (this is essential to be done immediately before the random process,
	*  regardless of whether we have saved a fixed dataset already,
	*  as other commands may have unintentionally (and, in some cases, randomly)
	*  altered the sort order of our data)
	isid hhid , sort
	
	* Estimate regressions controlling the family-wise error rate for multiple hypothesis test
	* (this adjusts p-values using the free step-down resampling methodology of Westfall and Young)
	#d	;
		wyoung `wyoungVarlist' ,
		
			cmd(reg OUTCOMEVAR treatment ${controlVars} [pw=pweight], cl(associd) )
			familyp(treatment)
			cluster(associd)
			bootstraps(${repsNum})
			seed(926648) //retrieved from random.org on 8/11/2020, 3.37AM EST
		;
	#d	cr
	
	* Keep results
	mat list      	   	  r(table)
	mat 	 table	 	= r(table)
	matselrc table 	      pValues , c(3)
	
	* Transpose matrix
	mat 	 pValues    = pValues'
	mat list pValues
	
	* Same procedure with fixed effects
	isid hhid , sort
	
	#d	;
		wyoung `wyoungVarlist' ,
		
			cmd(reghdfe OUTCOMEVAR treatment ${controlVars} [pw=pweight], abs(prov) cl(associd) )
			familyp(treatment)
			strata(prov)
			cluster(associd)
			bootstraps(${repsNum})
			seed(568717) //retrieved from random.org on 8/11/2020, 3.38AM EST
		;
	#d	cr
	
	mat list      	   	  r(table)
	mat 	 table	 	= r(table)
	matselrc table 	      pValues_FE , c(3)
	
	mat 	 pValues_FE = pValues_FE'
	mat list pValues_FE
	
	* Start counters for matrix columns
	local 	 matrixColCount	   = 1
	local 	 matrixColCount_FE = 1
	
* ---------------------------------------------------------------------------- *
*							Machinery regressions	  		 		   		   *
* ---------------------------------------------------------------------------- *
		
	* Estimate regression with fixed effects (same technique used done for pre-specified outcomes)
	* adding probability weights as all data come from the endline survey
	foreach  state in use own  {
	
		foreach  var of global machineryItems {
						
			eststo	   `state'`var' 	 : reg	   el_d_`state'`var' treatment ${controlVars} [pw=pweight], cl(associd)
			
			sum    						  		   el_d_`state'`var' if e(sample) == 1 & treatment == 0
			estadd scalar control_mean  		 = r(mean)
			estadd scalar control_sd    		 = r(sd)
			estadd local 		 provFE  	""
		
			if 		  "`state'`var'" != "ownelecpump" { //removing this variable from the p-value as it could not be computed in absence of variation across treatment arm
			
				scalar 		  wyoung_pValue 	     = pValues[1, `matrixColCount']
				local  		  wyoung_pValue_str      = string(wyoung_pValue, "%9.3f")
				estadd local  wyoung_pValue_brackets = "[`wyoung_pValue_str']"
				
				local matrixColCount 	= `matrixColCount'    + 1
			}
			
			eststo	   `state'`var'_prov : reghdfe el_d_`state'`var' treatment ${controlVars} [pw=pweight], cl(associd) abs(prov)
			
			if 		  "`state'`var'" != "ownelecpump" { //removing this variable from the p-value as it could not be computed in absence of variation across treatment arm
			
				scalar 		  wyoung_pValue 	     = pValues_FE[1,`matrixColCount_FE']
				local  		  wyoung_pValue_str      = string(wyoung_pValue, "%9.3f")
				estadd local  wyoung_pValue_brackets = "[`wyoung_pValue_str']"
				
				local matrixColCount_FE = `matrixColCount_FE' + 1
			}
			
			estadd local 		 provFE  "\checkmark"
		}
		
		#d	;
			esttab `state'* using "${out_tab}/todelete.tex",
					
					${esttabOptions}
					
					keep(	  treatment)
					coeflabel(treatment "\addlinespace[0.75em] Treatment")
					stats(	  wyoung_pValue_brackets N r2_a control_mean control_sd provFE,
					  lab(	  " " //blank space
							  "\addlinespace[0.75em] Number of observations"
							  "Adjusted R-squared"
							  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
							  "SD dep.\ var.\ control group"
							  "\addlinespace[0.75em] Province fixed effects")
					  fmt(0 0 %9.3f %9.3f %9.3f)
						 )
					
					b(%9.3f) se(%9.3f)
			;
		#d	cr	 
	}	

* ---------------------------------------------------------------------------- *
*						Credit, inputs and cost regressions	  				   *
* ---------------------------------------------------------------------------- *

	foreach outcomeVar in $credVars $inputVars $costVars {
		
		eststo  `outcomeVar' 	      		 : reg     `outcomeVar' treatment ${controlVars}	///
											  [pw=pweight]										///
											 , cl(associd)
		scalar 		  wyoung_pValue 	     = pValues[1,`matrixColCount']
		local  		  wyoung_pValue_str      = string(wyoung_pValue, "%9.3f")
		estadd local  wyoung_pValue_brackets = "[`wyoung_pValue_str']"
		
		sum    						  		  `outcomeVar' if e(sample) == 1 & treatment == 0
		estadd scalar control_mean  		 = r(mean)
		estadd scalar control_sd    		 = r(sd)
		estadd local 		 provFE  	""
		
		local matrixColCount = `matrixColCount' + 1
		
		eststo  `outcomeVar'_prov   : reghdfe `outcomeVar' treatment ${controlVars}				///
								     [pw=pweight]												///
							        , cl(associd) abs(prov)
		scalar 		  wyoung_pValue 	     = pValues_FE[1,`matrixColCount_FE']
		local  		  wyoung_pValue_str      = string(wyoung_pValue, "%9.3f")
		estadd local  wyoung_pValue_brackets = "[`wyoung_pValue_str']"
		
		estadd local 		 provFE  "\checkmark"
		
		local matrixColCount_FE = `matrixColCount_FE' + 1
	}
	
	
* ---------------------------------------------------------------------------- *
*							Export formatted tables			  				   *
* ---------------------------------------------------------------------------- *
	
	foreach  state in use /*own*/ {
	
		#d	;
			esttab 	`state'cattle 		`state'cattle_prov 		
					`state'traction		`state'traction_prov
					`state'cart 		`state'cart_prov			  
					`state'tractor		`state'tractor_prov
					`state'plough		`state'plough_prov
					`state'motocult		`state'motocult_prov
					`state'seeder		`state'seeder_prov
					`state'trailer		`state'trailer_prov
					`state'motorpump  	`state'motorpump_prov
					`state'elecpump		`state'elecpump_prov
					
					using "${out_tab}/todelete.tex",
					
					${esttabOptions}
					
					keep(	  treatment)
					coeflabel(treatment "\addlinespace[0.75em] Treatment")
					stats(	  wyoung_pValue_brackets N r2_a control_mean control_sd provFE,
					  lab(	  " " //blank space
							  "\addlinespace[0.75em] Number of observations"
							  "Adjusted R-squared"
							  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
							  "SD dep.\ var.\ control group"
							  "\addlinespace[0.75em] Province fixed effects")
					  fmt(0 0 %9.3f %9.3f %9.3f)
						 )
					
					b(%9.3f) se(%9.3f)
					
					 prehead("&(1) &(2) 	   			  &(3) &(4)	  				    &(5) &(6)                 &(7) &(8)		               &(9)	&(10) 	               &(11) &(12)                         &(13) &(14)                 &(15) &(16)                  &(17) &(18)                    &(19) &(20)                    \\       "
							 "&\multicolumn{2}{c}{Cattle} &\multicolumn{2}{c}{Animal}   &\multicolumn{2}{c}{Cart} &\multicolumn{2}{c}{Tractor} &\multicolumn{2}{c}{Plough} &\multicolumn{2}{c}{Motocultivator} &\multicolumn{2}{c}{Seeder} &\multicolumn{2}{c}{Trailer} &\multicolumn{2}{c}{Motorpump} &\multicolumn{2}{c}{Electrict} \\       "
							 "&	   &	 				  &\multicolumn{2}{c}{traction} &    &                    &    &			   	       & 	&                      & 	 &                             & &                         &     &                      &     &                        &\multicolumn{2}{c}{pump}	  \\ \hline")
					postfoot("[0.25em] \hline \hline \\ [-1.8ex]")
			;
		#d	cr
		
		if "`state'" == "use" local tabNumber "A12"
		
		filefilter  "${out_tab}/todelete.tex" 							   	   			///
					"${out_tab}/tab`tabNumber'-hh_`state'_mechanization_controls.tex" , ///
					from("[1em]") to("") replace	
		erase 		"${out_tab}/todelete.tex"
	}

	#d	;
		esttab  el_worker_costs     el_worker_costs_prov
				  el_seed_costs       el_seed_costs_prov
			el_equip_rent_costs el_equip_rent_costs_prov
			 el_plot_rent_costs  el_plot_rent_costs_prov
			 el_livestock_costs  el_livestock_costs_prov
			  
				using "${out_tab}/todelete.tex",
				
				${esttabOptions}
				
				keep(	  treatment)
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  wyoung_pValue_brackets N r2_a control_mean control_sd provFE,
				  lab(	  " " //blank space
						  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(0 0 %9.3f %9.3f %9.3f)
					 )
				
				b(%9.3f) se(%9.3f)
				
				 prehead("&\multicolumn{2}{c}{Workers} &\multicolumn{2}{c}{Seeds} &\multicolumn{2}{c}{Equipment rent} &\multicolumn{2}{c}{Plot rent} &\multicolumn{2}{c}{Livestock} \\		 "
						 " \cmidrule(lr){2-3}		    \cmidrule(lr){4-5}		   \cmidrule(lr){6-7}				   \cmidrule(lr){8-9}			  \cmidrule(lr){10-11}             		 "
						 "&(1) 	 	   &(2) 	   	   &(3)  	    &(4)		  &(5)   	   &(6)               	  &(7)         &(8)  			 &(9)         &(10)        		\\ \hline"
						 )
				postfoot("[0.25em] \hline \hline \\ [-1.8ex]")
		;
	#d	cr
	
	filefilter  "${out_tab}/todelete.tex" 		  ///
				"${out_tab}/tabA11-hh_costs.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA11-hh_costs_controls.tex":${out_tab}/tabA11-hh_costs_controls.tex}"'

	
***************************** End of do-file ***********************************
