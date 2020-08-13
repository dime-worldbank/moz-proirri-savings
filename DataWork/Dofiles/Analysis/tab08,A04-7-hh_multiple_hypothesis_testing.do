
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*					Multiple hypothesis testing								   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table 8: Impact on Mechanization Use
						"${out_tab}/tab08-hh_use_mechanization.tex"
						
						Table A4: Impact on Mechanization Ownership
						"${out_tab}/tabA04-hh_own_mechanization.tex"
						
						Table A5: Impact on Credit
						"${out_tab}/tabA05-hh_credit.tex"
						
						Table A6: Impact on Agricultural Inputs
						"${out_tab}/tabA06-hh_agri_inputs.tex"
						
						Table A7: Impact on Costs
						"${out_tab}/tabA07-hh_costs.tex"
						
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
			local    wyoungVarlist  `wyoungVarlist'  `outcomeVar'
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
		
			cmd(reg OUTCOMEVAR treatment [pw=pweight], cl(associd) )
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
		
			cmd(reghdfe OUTCOMEVAR treatment [pw=pweight], abs(prov) cl(associd) )
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
						
			eststo	   `state'`var'_prov : reghdfe el_d_`state'`var' treatment [pw=pweight], cl(associd) abs(prov)
			
			if 		  "`state'`var'" != "ownelecpump" { //removing this variable from the p-value as it could not be computed in absence of variation across treatment arm
			
				scalar 		  wyoung_pValue 	     = pValues_FE[1,`matrixColCount_FE']
				local  		  wyoung_pValue_str      = string(wyoung_pValue, "%9.3f")
				estadd local  wyoung_pValue_brackets = "[`wyoung_pValue_str']"
				
				local matrixColCount 	= `matrixColCount'    + 1
				local matrixColCount_FE = `matrixColCount_FE' + 1
			}
			
			estadd local 		 provFE  "\checkmark"
			
			sum    	   el_d_`state'`var' 	if e(sample) == 1 & treatment == 0
			estadd scalar control_mean   = r(mean)
			estadd scalar control_sd     = r(sd)
		}
		
		#d	;
			esttab `state'* using "${out_tab}/todelete.tex",
					
					${esttabOptions}
					
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
					
					prehead("&(1) 	 &(2) 	   &(3)  &(4)	  &(5)    &(6)            &(7)    &(8)		&(9)	  &(10) 	 \\       "
							"&Cattle &Animal   &Cart &Tractor &Plough &Motocultivator &Seeder &Trailer &Motorpump &Electrict \\       "
							"&		 &traction & 	 & 	   	  &  	  &			   	  & 	  &        & 		  &pump	  	 \\ \hline")
				   postfoot("[0.25em] \hline \hline \\[-1.8ex]")	
			;
		#d	cr
		
		if "`state'" == "use" local tabNumber "08"
		if "`state'" == "own" local tabNumber "A04"
		
		filefilter  "${out_tab}/todelete.tex" 							   	   ///
					"${out_tab}/tab`tabNumber'-hh_`state'_mechanization.tex" , ///
					from("[1em]") to("") replace	
		erase 		"${out_tab}/todelete.tex" 
	}	

* ---------------------------------------------------------------------------- *
*						Credit, inputs and cost regressions	  				   *
* ---------------------------------------------------------------------------- *

	foreach outcomeVar in $credVars $inputVars $costVars {
		
		eststo  `outcomeVar' 	      		 : reg     `outcomeVar' treatment 	///
											  [pw=pweight]						///
											 , cl(associd)
		scalar 		  wyoung_pValue 	     = pValues[1,`matrixColCount']
		local  		  wyoung_pValue_str      = string(wyoung_pValue, "%9.3f")
		estadd local  wyoung_pValue_brackets = "[`wyoung_pValue_str']"
		
		sum    						  		  `outcomeVar' if e(sample) == 1 & treatment == 0
		estadd scalar control_mean  		 = r(mean)
		estadd scalar control_sd    		 = r(sd)
		estadd local 		 provFE  	""
		
		local matrixColCount = `matrixColCount' + 1
		
		eststo  `outcomeVar'_prov   : reghdfe `outcomeVar' treatment 			///
								   [pw=pweight]									///
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
	
	#d	;
		esttab 	el_credyn      	  	 el_credyn_prov  		 		
				el_credobj_inputs 	 el_credobj_inputs_prov
				el_credobj_goods 	 el_credobj_goods_prov
				el_credobj_equipment el_credobj_equipment_prov
				
				using "${out_tab}/todelete.tex",
				
				${esttabOptions}
				
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
				
				 prehead("&\multicolumn{2}{c}{Received} &\multicolumn{2}{c}{For agricultural} &\multicolumn{2}{c}{For other} 		&\multicolumn{2}{c}{For agricultural} \\       "
						 "&\multicolumn{2}{c}{credit}   &\multicolumn{2}{c}{inputs} 		  &\multicolumn{2}{c}{commercial goods} &\multicolumn{2}{c}{machinery} 	      \\       "
						 " \cmidrule(lr){2-3}		     \cmidrule(lr){4-5}					   \cmidrule(lr){6-7}					 \cmidrule(lr){8-9} 				           "
						 "&(1) 	 	   &(2) 	   	    &(3)  		 &(4)				      &(5)   	   &(6)           		    &(7)         &(8)  					  \\ \hline"
						 )
				postfoot("[0.25em] \hline \hline \\ [-1.8ex]")
		;
	#d	cr
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 	   		///
				"${out_tab}/tabA05-hh_credit.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA05-hh_credit.tex":${out_tab}/tabA05-hh_credit.tex}"'
	
	#d	;
		esttab 	 el_fertorguse     el_fertorguse_prov
				el_fertchemuse    el_fertchemuse_prov
				    el_pestuse        el_pestuse_prov
			  el_fertorg_costs  el_fertorg_costs_prov
			  el_chemorg_costs  el_chemorg_costs_prov
			     el_pest_costs     el_pest_costs_prov
			  
				using "${out_tab}/todelete.tex",
				
				${esttabOptions}
				
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
				
				 prehead("&\multicolumn{6}{c}{\textbf{Used:}}      														  &\multicolumn{6}{c}{\textbf{Costs}} 																	  \\ 	   "
						 " \cmidrule(lr){2-7} \cmidrule(lr){8-13}"
						 "&\multicolumn{2}{c}{Organic}    &\multicolumn{2}{c}{Chemical}   &\multicolumn{2}{c}{Pesticides} &\multicolumn{2}{c}{Organic}    &\multicolumn{2}{c}{Chemical}   &\multicolumn{2}{c}{Pesticides} \\ 	   "
						 "&\multicolumn{2}{c}{fertilizer} &\multicolumn{2}{c}{fertilizer} &\multicolumn{2}{c}{}           &\multicolumn{2}{c}{fertilizer} &\multicolumn{2}{c}{fertilizer} &\multicolumn{2}{c}{} 	      \\ 	   "
						 " \cmidrule(lr){2-3}		       \cmidrule(lr){4-5}			   \cmidrule(lr){6-7}			   \cmidrule(lr){8-9}			   \cmidrule(lr){10-11}            \cmidrule(lr){12-13}           	 	   "
						 "&(1) 	 	   &(2) 	   	      &(3)  	   &(4)				  &(5)   	   &(6)               &(7)          &(8)  			  &(9)         &(10)              &(11)        &(12)  			  \\ \hline"
						 )
				postfoot("[0.25em] \hline \hline \\ [-1.8ex]")
		;
	#d	cr
	
	filefilter  "${out_tab}/todelete.tex" 			 	 ///
				"${out_tab}/tabA06-hh_agri_inputs.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA06-hh_agri_inputs.tex":${out_tab}/tabA06-hh_agri_inputs.tex}"'


	#d	;
		esttab  el_worker_costs     el_worker_costs_prov
				  el_seed_costs       el_seed_costs_prov
			el_equip_rent_costs el_equip_rent_costs_prov
			 el_plot_rent_costs  el_plot_rent_costs_prov
			 el_livestock_costs  el_livestock_costs_prov
			  
				using "${out_tab}/todelete.tex",
				
				${esttabOptions}
				
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
	
	filefilter  "${out_tab}/todelete.tex" 		   ///
				"${out_tab}/tabA07-hh_costs.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA07-hh_costs.tex":${out_tab}/tabA07-hh_costs.tex}"'

	
***************************** End of do-file ***********************************
