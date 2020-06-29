
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*						Impact on scheme equipment							   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A9: Impact on Household Savings – Heterogeneity by Wealth and Shock Exposure
						"${out_tab}/tabA09-hh_saving_het_wealth_shock.tex"
														
* ---------------------------------------------------------------------------- *
*									Prepare data	  					   	   *
* ---------------------------------------------------------------------------- */

	* Load data
	use 	 "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear

	* Generate dummy for wealth index above the median
	sum							  el_wealth_index , d
	gen 	 wealth_aboveMedian = el_wealth_index > `r(p50)' if !mi(el_wealth_index)
	tab		 wealth_aboveMedian
			
	* Generate dummy variable for shock above the median
	preserve
	
		collapse el_shock_mean	   , by(${assocIdVars})
		tab		 el_shock_mean
		sum		 el_shock_mean	   , d
		gen 	 shock_aboveMedian = el_shock_mean > `r(p50)'
		tab		 shock_aboveMedian	 treatment
		tempfile shock_aboveMedian
		save    `shock_aboveMedian'
		
	restore
	
	merge 	 m:1 associd  using `shock_aboveMedian' , assert(match) nogen
	
* ---------------------------------------------------------------------------- *
*							Heterogeneity regressions		  	   			   *
* ---------------------------------------------------------------------------- *
	
	* List of covariates
	local 	allCovariates wealth_aboveMedian shock_aboveMedian
	
	* Drop all stored estimation results
	est 	clear
	
	* Start estimate count
	local   estCount = 0 
	
	* Store regressions results
	foreach covariate of local allCovariates {
		
		cap drop 		       covariate
		rename     `covariate' covariate
		
		cap drop 			   interaction
		gen		 			   interaction = treatment * covariate
		
		* Save estimates of regression with interaction
		if "`covariate'" == "wealth_aboveMedian" local weights "[pw=pweight]"
		if "`covariate'" == "shock_aboveMedian"  local weights ""
		
		eststo `covariate'		 	 : reg bp_d_saved treatment covariate interaction		///
									  `weights'												///
									 , cl(associd)
			
		estadd  scalar diff			 = _b[treatment] + _b[interaction]
			
		test    treatment	 	 	 + interaction = 0
		estadd  scalar p_diff 	 	 = r(p)
		
		estadd  local  provFE 		   ""
		
		local   estCount 		     = `estCount' + 1
		
		* Include association fixed effects
		eststo `covariate'_assoc 	 : reghdfe bp_d_saved treatment covariate interaction	///
									  `weights'												///
									 , abs(prov) cl(associd)
		
		estadd  scalar diff			 = _b[treatment] + _b[interaction]
			
		test    treatment	 	 	 + interaction = 0
		estadd  scalar p_diff 	 	 = r(p)
		
		estadd  local  provFE 		   "\checkmark"
		
		rename  covariate 			  `covariate'
		
		local   estCount		    = `estCount' + 1
	}
	
	* Export (temporary) formatted table in LaTeX
	#d	;
		esttab  * using "${out_tab}/dummy.tex",
				
				replace
			    se fragment
				nodepvars nonumbers nomtitles nolines
				noobs nonotes alignment(c)
				
				coeflabel(treatment   "\addlinespace[0.75em] Treatment"
						  covariate	  "Covariate"
						  interaction "Treatment $\times$ Covariate"
						  _cons		  "\addlinespace[0.5em] Constant")
						  
				stats(diff p_diff N N_clust r2_a provFE,
					  lab("\addlinespace[0.75em] \multicolumn{`estCount'}{l}{\textit{Total effect:} Treatment $+$ Treatment $\times$ Covariate} \\ \hspace{10pt} $\sum \hat{\beta}$"
						  "\hspace{10pt} P-value"
						  "\addlinespace[0.5em] Number of observations"
						  "Number of clusters"
						  "Adjusted R-squared"
						  "\addlinespace[0.5em] Province fixed effects"
						  )
				      fmt(%9.3f %9.3f 0 0 %9.3f)
					)
				star(* 0.10 ** 0.05 *** 0.01)
				b(%9.3f) se(%9.3f)
		;
	#d	cr
	
	* Drop all stored estimation results
	est 	clear
		
	local   estCount = 0 
	
	* Store regressions results with standardized test scores
	foreach covariate of local allCovariates {
		
		cap drop 		       covariate
		rename     `covariate' covariate
		
		cap drop 			   interaction
		gen		 			   interaction = treatment * covariate
		
		* Save estimates of regression with interaction
		if "`covariate'" == "wealth_aboveMedian" local weights "[pw=pweight]"
		if "`covariate'" == "shock_aboveMedian"  local weights ""
		
		eststo `covariate'		 	 : reg     bp_final_cont treatment covariate interaction	///
									  `weights'													///
									 , cl(associd)
			
		estadd  scalar diff			 = _b[treatment] + _b[interaction]
			
		test    treatment	 	 	 + interaction = 0
		estadd  scalar p_diff 	 	 = r(p)
		
		estadd  local  provFE 		 ""
		
		local  estCount = `estCount' + 1
		
		* Include scheme fixed effects
		eststo `covariate'_assoc 	 : reghdfe bp_final_cont treatment covariate interaction 	///
									  `weights'													///
									 , abs(prov) cl(associd)
		
		estadd  scalar diff			 = _b[treatment] + _b[interaction]
			
		test    treatment	 	 	 + interaction = 0
		estadd  scalar p_diff 	 	 = r(p)
		
		estadd  local  provFE 		 "\checkmark"
		
		rename  covariate `covariate'
		
		local  estCount = `estCount' + 1
	}
	
	#d	;
		esttab  *
				
				using "${out_tab}/MZN.tex",
				
				replace
			    se fragment
				nodepvars nonumbers nomtitles nolines
				noobs nonotes alignment(c)
				
				coeflabel(treatment   "\addlinespace[0.75em] Treatment"
						  covariate	  "Covariate"
						  interaction "Treatment $\times$ Covariate"
						  _cons		  "\addlinespace[0.5em] Constant")
						  
				stats(diff p_diff N N_clust r2_a provFE,
					  lab("\addlinespace[0.75em] \multicolumn{`estCount'}{l}{\textit{Total effect:} Treatment $+$ Treatment $\times$ Covariate} \\ \hspace{10pt} $\sum \hat{\beta}$"
						  "\hspace{10pt} P-value"
						  "\addlinespace[0.5em] Number of observations"
						  "Number of clusters"
						  "Adjusted R-squared"
						  "\addlinespace[0.5em] Province fixed effects"
						  )
				      fmt(%9.0f %9.3f 0 0 %9.3f)
					)
				star(* 0.10 ** 0.05 *** 0.01)
				b(%9.0f) se(%9.0f)	
		;
	#d	cr

* ---------------------------------------------------------------------------- *
*						Join panels in final table		 	 	   			   *
* ---------------------------------------------------------------------------- *
	
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
			 
			 "\hspace{16pt} Covariate dummy: &\multicolumn{2}{c}{\textit{Househod}}     &\multicolumn{2}{c}{\textit{Communal shock}} \\ 	  			                " _n
			 "								 &\multicolumn{2}{c}{\textit{wealth index}} &\multicolumn{2}{c}{\textit{exposure}} 		 \\ 	  			                " _n
			 "			   					  \cmidrule(lr){2-3} 						 \cmidrule(lr){4-5}					        		  			 			    " _n
			 "			   					 & (1) & (2)				        	    & (3) & (4)					 	   		     \\               \hline \\[-1.8ex] " _n
						
			 "&\multicolumn{4}{c}{\textbf{Panel A -- Probability to Save}}   														 \\[0.5ex] \hline    		        " _n
			 " `dummy'    													 														 \\        \hline 		 \\[-1.8ex] " _n
			 "&\multicolumn{4}{c}{\textbf{Panel B -- Savings per Household}} 													     \\[0.5ex] \hline    		        " _n
			 " `MZN' 						    							 														 \\        \hline \hline \\[-1.8ex] " _n
		;
	#d	cr
	
	file close test
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 			 			    ///
				"${out_tab}/tabA09-hh_saving_het_wealth_shock.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA09-hh_saving_het_wealth_shock.tex":${out_tab}/tabA09-hh_saving_het_wealth_shock.tex}"'

	
***************************** End of do-file ***********************************
