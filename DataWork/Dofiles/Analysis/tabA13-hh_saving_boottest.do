
/*******************************************************************************
*																 			   *
* 	  				"Do Private Consultants Promote Savings					   *
*					 and Investments in Rural Mozambique?"	  				   *
*																			   *
*					Wild bootstrap confidence intervals						   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
						
		CREATES:	   	Table A13: Impact on Household Savings with Wild Bootstrap Confidence Intervals
						"${out_tab}/tabA13-hh_saving_boottest.tex"
												
* ---------------------------------------------------------------------------- */
	
	* Load data
	use 	  	   "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
		
	* Estimate regression on saving dummy with and without province fixed effects for each quarter
	est clear
	
	forv  quarter = 1/4 {
		
		eststo 	   v`quarter' 	   	 : reg	   bp_v`quarter'_d_saved_cumul treatment, cl(associd)
		sum    						  		   bp_v`quarter'_d_saved_cumul if e(sample) == 1 & treatment == 0
				
		estadd scalar control_mean 		= r(mean)
		estadd scalar control_sd   		= r(sd)
		estadd local 		  provFE 	  ""
		
		boottest   													 treatment, ///
			boottype(wild) seed(${wildSeedsNum}) rep(`=${repsNum}-1') 			///
			level(90) nograph
		estadd scalar boot_p            = r(p)
		
		matrix CI_temp = r(CI)
		scalar 		  boot_ci_lb 	     = CI_temp[1,1]
		local  		  boot_ci_lb_str     = string(boot_ci_lb , "%9.3f")
		scalar 		  boot_ci_ub 	     = CI_temp[1,2]
		local  		  boot_ci_ub_str     = string(boot_ci_ub , "%9.3f")

		estadd local  boot_ci_brackets = "[`boot_ci_lb_str', `boot_ci_ub_str']"
				
		eststo	   v`quarter'_prov   : reghdfe bp_v`quarter'_d_saved_cumul treatment, cl(associd) abs(prov)
		estadd     local 	  provFE "\checkmark"
		
		boottest   													 treatment, ///
			boottype(wild) seed(${wildSeedsNum}) rep(`=${repsNum}-1') 			///
			level(90) nograph
		estadd scalar boot_p            = r(p)
		
		matrix CI_temp = r(CI)
		scalar 		  boot_ci_lb 	     = CI_temp[1,1]
		local  		  boot_ci_lb_str     = string(boot_ci_lb , "%9.3f")
		scalar 		  boot_ci_ub 	     = CI_temp[1,2]
		local  		  boot_ci_ub_str     = string(boot_ci_ub , "%9.3f")

		estadd local  boot_ci_brackets = "[`boot_ci_lb_str', `boot_ci_ub_str']"
	}
	
	* Export (temporary) formatted table in LaTeX
	#d	;
		esttab 	v1 v1_prov  		 		
				v2 v2_prov
				v3 v3_prov
				v4 v4_prov
				
				using "${out_tab}/dummy.tex" ,
				
				${esttabOptions}
				
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  boot_ci_brackets boot_p N r2_a control_mean control_sd provFE,
				  lab(	  "\addlinespace[0.75em] Wild bootstrap 90\% confidence intervals"
						  "Wild bootstrap p-value"
						  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(%9.3f %9.3f 0 %9.3f %9.3f %9.3f %9.3f)
					 )
				b(%9.3f) se(%9.3f)
		;
	#d	cr
	
	* Clear estimates and do the same for saving values (in MZN)
	est clear
	
	forv  quarter = 1/4 {
		
		eststo 	    v`quarter' 	   	    : reg	  bp_v`quarter'_boxvalue_cumul treatment, cl(associd)
		sum    						  			  bp_v`quarter'_boxvalue_cumul if e(sample) == 1 & treatment == 0
		estadd scalar control_mean 		= r(mean)
		estadd scalar control_sd   		= r(sd)
		estadd local 		   provFE 	  ""
		
		boottest   													 treatment, ///
			boottype(wild) seed(${wildSeedsNum}) rep(`=${repsNum}-1') 			///
			level(90) nograph
		estadd scalar boot_p            = r(p)
		
		matrix CI_temp = r(CI)
		scalar 		  boot_ci_lb 	     = CI_temp[1,1]
		local  		  boot_ci_lb_str     = string(boot_ci_lb , "%9.0f")
		scalar 		  boot_ci_ub 	     = CI_temp[1,2]
		local  		  boot_ci_ub_str     = string(boot_ci_ub , "%9.0f")
		estadd local  boot_ci_brackets = "[`boot_ci_lb_str', `boot_ci_ub_str']"
		
		eststo	    v`quarter'_prov     : reghdfe bp_v`quarter'_boxvalue_cumul treatment, cl(associd) abs(prov)
		estadd      local 	   provFE 	  "\checkmark"
		
		boottest   													 treatment, ///
			boottype(wild) seed(${wildSeedsNum}) rep(`=${repsNum}-1') 			///
			level(90) nograph
		estadd scalar boot_p            = r(p)
		
		matrix CI_temp = r(CI)
		scalar 		  boot_ci_lb 	     = CI_temp[1,1]
		local  		  boot_ci_lb_str     = string(boot_ci_lb , "%9.0f")
		scalar 		  boot_ci_ub 	     = CI_temp[1,2]
		local  		  boot_ci_ub_str     = string(boot_ci_ub , "%9.0f")
		estadd local  boot_ci_brackets = "[`boot_ci_lb_str', `boot_ci_ub_str']"
	}
	
	#d	;
		esttab 	v1 v1_prov  		 		
				v2 v2_prov
				v3 v3_prov
				v4 v4_prov
				
				using "${out_tab}/MZN.tex" ,
				
				${esttabOptions}
				
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  boot_ci_brackets boot_p N r2_a control_mean control_sd provFE,
				  lab(	  "\addlinespace[0.75em] Wild bootstrap 90\% confidence intervals"
						  "Wild bootstrap p-value"
						  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(%9.3f %9.3f 0 %9.3f %9.0f %9.0f %9.0f)
					 )
				b(%9.0f) se(%9.0f)
		;
	#d	cr
	
	* Initiate final LaTeX file
	file open test  		   using "${out_tab}/todelete.tex", ///
		 text write replace
		
	* Append estimations in unique LaTeX file 								
	foreach  			panel    in 			  dummy MZN 	{			
		
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
			 
			 "&\multicolumn{2}{c}{1st quarter} &\multicolumn{2}{c}{2nd quarter} &\multicolumn{2}{c}{3rd quarter} &\multicolumn{2}{c}{4th quarter} \\	   			  " _n
			 " \cmidrule(lr){2-3} 				\cmidrule(lr){4-5} 				 \cmidrule(lr){6-7} 			  \cmidrule(lr){8-9}					   			  " _n
			 "&(1) &(2) 					   &(3) &(4) 						&(5) &(6)						 &(7) &(8) 						  \\ \hline \\[-1.8ex]" _n
			 
			 "&\multicolumn{8}{c}{\textbf{Panel A -- Probability to Save}}   \\ [0.5ex] \hline    		  " _n
			 " `dummy'    													 \\ 		\hline \\[-1.8ex] " _n
			 "&\multicolumn{8}{c}{\textbf{Panel B -- Savings per Household}} \\ [0.5ex] \hline    		  " _n
			 " `MZN' 						    							 \\ \hline  \hline \\[-1.8ex] " _n
		;
	#d	cr
	
	file close test
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 		   			 ///
				"${out_tab}/tabA13-hh_saving_boottest.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA13-hh_saving_boottest.tex":${out_tab}/tabA13-hh_saving_boottest.tex}"'
		

******************************** End of do-file ********************************
