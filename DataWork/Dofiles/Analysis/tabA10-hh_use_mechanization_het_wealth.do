
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*					Heterogeneous effect on machinery use					   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table 10: Impact on Mechanization Use – Heterogeneity by Wealth
						"${out_tab}/tabA10-hh_use_mechanization_het_wealth.tex"
														
* ---------------------------------------------------------------------------- *
*				Prepare data and definte interaction variables		  	   	   *
* ---------------------------------------------------------------------------- */

	* Load data
	use 	 "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear

	* Generate dummy for wealth index above the median
	sum							  el_wealth_index , d
	gen 	 wealth_aboveMedian = el_wealth_index > `r(p50)' if !mi(el_wealth_index)
	tab		 wealth_aboveMedian
		
	* Generate interaction term
	gen		interactionTerm = treatment * wealth_aboveMedian
			
	* Drop all stored estimation results
	est 	clear	
		
	* Store regressions results with standardized test scores
	foreach outcomeVar of global machineryItems {
				
		* Include scheme fixed effects
		eststo `outcomeVar'	: reghdfe el_d_use`outcomeVar' treatment wealth_aboveMedian interactionTerm ///
									   [pw=pweight]														///
									 , abs(prov) cl(associd)
		
		estadd  scalar diff			 = _b[treatment] + _b[interactionTerm]
			
		test    treatment	 	 	 + interactionTerm = 0
		estadd  scalar p_diff 	 	 = r(p)
					
		local  estCount = `estCount' + 1
	}
	
	* Export formatted table
	#d	;
		esttab  * using "${out_tab}/todelete.tex",
				replace
			    se fragment
				nodepvars nonumbers nomtitles nolines
				noobs nonotes alignment(c)
				coeflabel(treatment  		 "\addlinespace[0.75em] Treatment"
						  wealth_aboveMedian "Above median wealth"
						  interactionTerm	 "Treatment $\times$ Above median wealth"
						  _cons		  "\addlinespace[0.5em] Constant")
				stats(diff p_diff N N_clust r2_a,
					  lab("\addlinespace[0.75em] \multicolumn{11}{l}{\textit{Total effect:} Treatment $+$ Treatment $\times$ Above median wealth} \\ \hspace{10pt} $\sum \hat{\beta}$"
						  "\hspace{10pt} P-value"
						  "\addlinespace[0.5em] Number of observations"
						  "Number of clusters"
						  "Adjusted R-squared"
						  )
				      fmt(%9.3f %9.3f 0 0 %9.3f)
					)
				star(* 0.10 ** 0.05 *** 0.01)
				b(%9.3f) se(%9.3f)
				
				prehead("&(1) 	 &(2) 	   &(3)  &(4)	  &(5)    &(6)            &(7)    &(8)		&(9)	  &(10) 	 \\       "
						"&Cattle &Animal   &Cart &Tractor &Plough &Motocultivator &Seeder &Trailer &Motorpump &Electrict \\       "
						"&		 &traction & 	 & 	   	  &  	  &			   	  & 	  &        & 		  &pump	  	 \\ \hline")
				postfoot("[0.25em] \hline \hline \\[-1.8ex]")	
		;
	#d	cr
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 			 				 	  ///
				"${out_tab}/tabA10-hh_use_mechanization_het_wealth.tex" , ///
				from("[1em]") to("") replace
	erase		"${out_tab}/todelete.tex"
	
	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA10-hh_use_mechanization_het_wealth.tex":${out_tab}/tabA10-hh_use_mechanization_het_wealth.tex}"'
		
		
******************************** End of do-file ********************************

	