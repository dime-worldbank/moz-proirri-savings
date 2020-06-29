
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*					Impact on household savings (IHS)						   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
		
		CREATES:	   	Table A14: Impact on Savings per Household – Inverse Hyperbolic Sine Transformation
						"${out_tab}/tabA14-hh_saving_ihs.tex"
												
* ---------------------------------------------------------------------------- */
												
	* Load data
	use 	  "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
		
	* Estimate regression on saving dummy with and without province fixed effects for each quarter
	est   clear

	forv  quarter = 1/4 {
			
		eststo 	   v`quarter' 	   	 : reg	   bp_v`quarter'_boxvalue_ihs  treatment, cl(associd)
		sum    						  		   bp_v`quarter'_boxvalue_ihs  if e(sample) == 1 & treatment == 0
		estadd scalar control_mean 	 = r(mean)
		estadd scalar control_sd   	 = r(sd)
		estadd local 		  provFE   ""
		
		eststo	   v`quarter'_prov   : reghdfe bp_v`quarter'_boxvalue_ihs  treatment, cl(associd) abs(prov)
		estadd     local 	  provFE   "\checkmark"
	}
	
	* Export formatted table
	#d	;
		esttab 	v1 v1_prov  		 		
				v2 v2_prov
				v3 v3_prov
				v4 v4_prov
				
				using "${out_tab}/todelete.tex",
				
				${esttabOptions}
				
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  N r2_a control_mean control_sd provFE,
				  lab(	  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(0 %9.3f %9.3f %9.3f)
					 )
				b(%9.3f) se(%9.3f)
				
				 prehead("&\multicolumn{2}{c}{1st quarter} &\multicolumn{2}{c}{2nd quarter} &\multicolumn{2}{c}{3rd quarter} &\multicolumn{2}{c}{4th quarter} \\	   			  "
						 " \cmidrule(lr){2-3} 				\cmidrule(lr){4-5} 				 \cmidrule(lr){6-7} 			  \cmidrule(lr){8-9}					   			  "
					     "&(1) &(2) 					   &(3) &(4) 						&(5) &(6)						 &(7) &(8) 						  \\ \hline \\[-1.8ex]"
					     )
				postfoot("[0.25em] \hline \hline \\[-1.8ex]")
		;
	#d	cr
	
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 					///
				"${out_tab}/tabA14-hh_saving_ihs.tex" ,	///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA14-hh_saving_ihs_log.tex":${out_tab}/tabA14-hh_saving_ihs.tex}"'
	

******************************** End of do-file ********************************
