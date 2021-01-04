
/*******************************************************************************
*																 			   *
* 	  "Private Consultants Promote Agricultural Investments in Mozambique"	   *
*																			   *
*						Impact on scheme target (total)						   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A1: Impact on Total Scheme Target Value of Savings
						"${out_tab}/tabA01-assoc_targetValue.tex"
												
* ---------------------------------------------------------------------------- */

	* Load data
	use		"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
		
	* Sum saving target by association and collapse
	collapse (sum) bp_v0_target , by(${assocIdVars})
	
	count
	assert `r(N)' == ${assocNum} 
	
	* Estimate regression model with and without fixed effects and store results
	eststo 	  v0			    : reg 	 bp_v0_target    treatment      , cl(associd)
	
	* Add mean and standard deviation of the control group
	sum    						 		 bp_v0_target if treatment == 0 &  e(sample) == 1
	estadd scalar  control_mean = r(mean)
	estadd scalar  control_sd   = r(sd)
		
	estadd local   provFE 	      ""
	
	eststo 	    v0_prov   	    : reghdfe bp_v0_target    treatment		, cl(associd) abs(prov)
	estadd local   provFE		  "\checkmark"
	
	* Export formatted table in LaTeX
	#d	;
		esttab  v0
				v0_prov		 		

				using "${out_tab}/todelete.tex",
				
				${esttabOptions}
				
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  N r2_a control_mean control_sd provFE,
				  lab(	  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(0 %9.3f %9.0f %9.0f)
					 )
				b(%9.0f) se(%9.0f)
				 
				 //including header with column numbers and spacing after footnote
				 prehead( "&(1) &(2) \\ \hline			 ")
				 postfoot("[0.25em] 	\hline
										\hline \\[-1.8ex]")	
		;
	#d	cr
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex"  	 			    ///
				"${out_tab}/tabA01-assoc_targetValue.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out}/tabA01-assoc_targetValue.tex":${out}/tabA01-assoc_targetValue.tex}"'

	
***************************** End of do-file ***********************************
