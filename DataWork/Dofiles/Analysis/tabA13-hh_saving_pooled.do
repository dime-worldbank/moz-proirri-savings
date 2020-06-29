
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*					Impact on household savings (pooled)					   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A13: Impact on Household Savings per Household – Pooled Outcomes
						"${out_tab}/tabA13-hh_saving_pooled.tex"
												
* ---------------------------------------------------------------------------- */

	* Load data
	use		"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
	
	* Keep variables for reshape
	keep	     bp_v?_d_saved bp_v?_boxvalue     ${assocIdVars} hhid
	
	* Reshape variable to long format
	reshape long bp_v@_d_saved bp_v@_boxvalue , i(${assocIdVars} hhid) j(quart)
	
	* Rename reshape variables
	rename       bp_v_* *
	
	* Estimate regression on saving dummy with and without province and quarter fixed effects
	est clear 
	
	foreach var in d_saved boxvalue {
		
		eststo 	  `var'  	   : reg	 `var' treatment, cl(associd)
		sum     						 `var' if e(sample) == 1 & treatment == 0
		estadd  scalar  mean   = r(mean)
		estadd  scalar  sd	   = r(sd)
		estadd  local 	provFE   ""
		estadd  local   quartFE  ""
		
		eststo 	  `var'_prov   : reghdfe `var' treatment, cl(associd) abs(prov)
		sum     						 `var' if e(sample) == 1 & treatment == 0
		estadd  local 	provFE   "\checkmark"
		estadd  local   quartFE  ""
		
		eststo 	  `var'_quart  : reghdfe `var' treatment, cl(associd) abs(prov quart)
		sum     						 `var' if e(sample) == 1 & treatment == 0
		estadd  local 	provFE   "\checkmark"
		estadd  local   quartFE  "\checkmark"
	}
	
	* Export formatted table
	#d	;
		esttab   d_saved  d_saved_prov  d_saved_quart
				boxvalue boxvalue_prov boxvalue_quart
				   
				using "${out_tab}/todelete.tex",
				
				${esttabOptions}
				
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  N r2_a mean sd provFE quartFE,
				  lab(	  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects"
						  "Quarter fixed effects")
				  fmt(0 %9.3f %9.3f %9.3f)
					 )
				b(%9.3f) se(%9.3f)
				
				prehead("&\multicolumn{3}{c}{Probability to Save (0/1)} &\multicolumn{3}{c}{Savings per Household (MZN)} \\		   "
						" \cmidrule(lr){2-4} 						  		\cmidrule(lr){5-7}						     		   "
						"& (1) & (2) & (3)								& (4) & (5) & (6) 					 			 \\ \hline "
					    )
				 postfoot("[0.25em] \hline \hline \\[-1.8ex]")
		;
	#d	cr
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex"					///
				"${out_tab}/tabA13-hh_saving_pooled.tex",	///
				from("[1em]") to("") replace
	erase		"${out_tab}/todelete.tex"
	
	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA13-hh_saving_pooled.tex":${out_tab}/tabA13-hh_saving_pooled.tex}"'
	

***************************** End of do-file ***********************************
