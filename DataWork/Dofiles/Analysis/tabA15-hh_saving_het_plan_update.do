
/*******************************************************************************
*																 			   *
* 	  				"Do Private Consultants Promote Savings					   *
*					 and Investments in Rural Mozambique?"	  				   *
*																			   *
*				Heterogeneous effects by update in the saving plan			   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A15: Cumulative Impact on Household Savings – Heterogeneity by Update in the Saving Plan
						"${out_tab}/tabA15-hh_saving_het_plan_update.tex"
														
* ---------------------------------------------------------------------------- */	
	
	* Load data
	use		"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
	
	* Generate interaction variables
	gen 	  treat_plan_update 	 = treatment * bp_plan_update
	replace   treat_plan_update 	 = 0 if treatment == 0
	
	gen 	  treat_plan_updateValue = treatment * bp_plan_update_diff
	replace   treat_plan_updateValue = 0 if treatment == 0
	
	* Rescale plan update variable to thousand of MZN
	replace treat_plan_updateValue = treat_plan_updateValue / 1000
	
	* Drop all stored estimation results
	est 	clear
		
	local   estCount = 0 
	
	* Store regressions results with saving dummy
	local 	allCovariates update updateValue
	
	foreach covariate of local allCovariates {
		
		cap drop 		       covariate
		rename     treat_plan_`covariate' covariate
		
		eststo `covariate'		 	 : reg bp_d_saved treatment covariate	  ///
									 , cl(associd)
		estadd local 		  provFE 	  ""	
		local  estCount = `estCount' + 1
		
		* Include scheme fixed effects
		eststo `covariate'_assoc 	 : reghdfe bp_d_saved treatment covariate ///
									 , abs(prov) cl(associd)
		estadd  local  provFE 		 "\checkmark"
		
		rename  covariate treat_plan_`covariate'
		
		local  estCount = `estCount' + 1
	}
	
	#d	;
		esttab  * using "${out_tab}/dummy.tex",
				replace
			    se fragment
				nodepvars nonumbers nomtitles nolines
				nocons noobs nonotes alignment(c)
				coeflabel(treatment "\addlinespace[0.75em] Treatment"
						  covariate "Treatment $\times$ Update in the saving plan")
				stats(N N_clust r2_a provFE,
					  lab("\addlinespace[0.5em] Number of observations"
						  "Number of clusters"
						  "Adjusted R-squared"
						  "\addlinespace[0.5em] Province fixed effects"
						  )
				      fmt(0 0 %9.3f)
					)
				star(* 0.10 ** 0.05 *** 0.01)
				b(%9.3f) se(%9.3f)
		;
	#d	cr
	
	* Store regressions results with saving values
	est 	clear		
	local   estCount = 0 
	
	foreach covariate of local allCovariates {
		
		cap drop 		       covariate
		rename     treat_plan_`covariate' covariate
		
		eststo `covariate'		 	 : reg bp_final_cont treatment covariate					///
									 , cl(associd)
		estadd local 		  provFE 	  ""	
		local  estCount = `estCount' + 1
		
		eststo `covariate'_assoc 	 : reghdfe bp_final_cont treatment covariate ///
									 , abs(prov) cl(associd)
		estadd  local  provFE 		 "\checkmark"
		
		rename  covariate treat_plan_`covariate'
		
		local  estCount = `estCount' + 1
	}
	
	#d	;
		esttab  * using "${out_tab}/MZN.tex",
				replace
			    se fragment
				nodepvars nonumbers nomtitles nolines
				nocons noobs nonotes alignment(c)
				coeflabel(treatment   "\addlinespace[0.75em] Treatment"
						  covariate "Treatment $\times$ Update in the saving plan")
				stats(N N_clust r2_a provFE,
					  lab("\addlinespace[0.5em] Number of observations"
						  "Number of clusters"
						  "Adjusted R-squared"
						  "\addlinespace[0.5em] Province fixed effects"
						  )
				      fmt(0 0 %9.3f)
					)
				star(* 0.10 ** 0.05 *** 0.01)
				b(%9.2f) se(%9.2f)
		;
	#d	cr
	
	* Initiate final LaTeX file
	file open test  		   using "${out_tab}/todelete.tex", ///
		 text write replace
		
	* Append estimations in unique LaTeX file 								
	foreach  			panel    in 				dummy MZN 	{			
		
		file open 	   `panel' using "${out_tab}/`panel'.tex" , ///
			 text read
																				
		* Loop over lines of the LaTeX file and save everything in a local		
		local 		   `panel' ""														
			file  read `panel' line										
		while r(eof) == 0 { 														
			local 	   `panel' ///
				   `" ``panel'' `line' "'								
			file read  `panel' line										
		}																		
			file close `panel'											
		
		erase 	     				 "${out_tab}/`panel'.tex" 								
	}																			
	
	* Append all locals as strings, add footnote and end of LaTeX environments
	#d	;
		file write test
			 
			 " \hspace{40pt} \`Update in the saving plan' measure: &\multicolumn{2}{c}{\textit{Household updated}} &\multicolumn{2}{c}{\textit{Value of the update}} \\ " _n
			 "								 &\multicolumn{2}{c}{\textit{their saving plan}} 	 				   &\multicolumn{2}{c}{\textit{in the saving plan}}  \\ " _n
			 "								 & &											 	 				   &\multicolumn{2}{c}{\textit{(1000 MZN)}}  		 \\ " _n
			 "			   					  \cmidrule(lr){2-3} 								  \cmidrule(lr){4-5}					        		  			" _n
			 "			   					 & (1) & (2)				        	       		 & (3) & (4)					 	   		       \\ \hline \\[-1.8ex]" _n
						
			 "&\multicolumn{4}{c}{\textbf{Panel A -- Probability to Save}}   \\ [0.5ex] \hline    		  " _n
			 " `dummy'    													 \\ \hline 		   \\[-1.8ex] " _n
			 "&\multicolumn{4}{c}{\textbf{Panel B -- Savings per Household}} \\ [0.5ex] \hline    		  " _n
			 " `MZN' 						    							 \\ \hline  \hline \\[-1.8ex] " _n
		;
	#d	cr
	
	file close test
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 							///
				"${out_tab}/tabA15-hh_saving_het_plan_update.tex", 	///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	

***************************** End of do-file ***********************************
