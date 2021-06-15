
/*******************************************************************************
*																 			   *
* 	  				"Do Private Consultants Promote Savings					   *
*					 and Investments in Rural Mozambique?"	  				   *
*																			   *
*						Impact on final saving gap							   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
		
		CREATES:	   	Table A4: Impact on Saving Gap
						"${out_tab}/tabA04-hh_saving_gap.tex"
												
* ---------------------------------------------------------------------------- */
	
	use 	  "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
	
	local	  varList		  bp_d_saving_goal bp_final_gap
	local	  estList		  ""
	
	foreach   outcomeVar of local varList {
	
		eststo 	 `outcomeVar' 	   	    : reg	  `outcomeVar' treatment, cl(associd)
		sum    						  			  `outcomeVar' if e(sample) == 1 & treatment == 0
		estadd scalar control_mean 		= r(mean)
		estadd scalar control_sd   		= r(sd)
		estadd local 		  provFE 	  ""
		
		local estList " `estList' `outcomeVar' "
		
		eststo	 `outcomeVar'_prov      : reghdfe  `outcomeVar' treatment, cl(associd) abs(prov)
		estadd local 	      provFE 	  "\checkmark"
		
		local estList " `estList' `outcomeVar'_prov "
	}
	
	#d	;
		esttab `estList'		 					
				using "${out_tab}/todelete.tex",
				
				replace tex
				se nocons fragment
				nodepvars nonumbers nomtitles nolines
				noobs nonotes alignment(c)
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  N r2_a control_mean control_sd provFE,
				  lab(	  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(0 %9.3f %9.3f %9.3f)
					 )
				star(* 0.10 ** 0.05 *** 0.01)
				b(%9.3f) se(%9.3f)
				
				 prehead("&\multicolumn{2}{c}{Reached saving goal (0/1)} &\multicolumn{2}{c}{Saving gap (value)}  \\
						   \cmidrule(lr){2-3}                             \cmidrule(lr){4-5}
						  &(1) &(2) &(3) &(4) \\ \hline					 ")
				postfoot("[0.25em]     		     \hline \hline \\[-1.8ex]")	
		;
	#d	cr
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 		    	///
				"${out_tab}/tabA03-hh_saving_gap.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA04-hh_saving_gap.tex":${out_tab}/tabA04-hh_saving_gap.tex}"'

	
******************************** End of do-file ********************************
