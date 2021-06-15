
/*******************************************************************************
*																 			   *
* 	  				"Do Private Consultants Promote Savings					   *
*					 and Investments in Rural Mozambique?"	  				   *
*																			   *
*						Collective action failure 							   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A16: Impact on Collective Action Failure Outcomes
						"${out_tab}/tabA16-hh_collective_action.tex"
														
* ---------------------------------------------------------------------------- */

	* Load clean data
	use 	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
	
	* Clear estimates
	est clear 
	
	* Estimate ITT effects and store results
	foreach 	   outcomeVar in proposal groupproposal proposalspoke proposalpernow proposalperstart proposalknow_more {
		
		* Condition on sample who participated in (group) proposal
		if 		 "`outcomeVar'" == "groupproposal" {
			local sample "if el_proposal 	  == 1"
		}
		
		else if inlist("`outcomeVar'", "proposalspoke", "proposalpernow", "proposalperstart", "proposalknow_more") {
			local sample "if el_groupproposal == 1"
		}
		
		else {
			local sample ""
		}
		
		eststo     `outcomeVar' : reghdfe el_`outcomeVar'  	 treatment [pw=pweight] `sample' , abs(prov) cl(associd)
		sum     			  		      el_`outcomeVar' if treatment == 0 & e(sample) == 1
		estadd  scalar 				      mean		      =  r(mean)
		estadd  scalar 				      sd			  =  r(sd)
	
	}
							
	* Export formatted table in LaTeX
	#d	;
		esttab  using "${out_tab}/todelete.tex"
			,
				${esttabOptions}
		
				coeflabel(treatment 	  "\addlinespace[0.75em] Treatment")
				stats(N r2_a mean sd, lab("\addlinespace[0.75em] Number of observations"
										  "Adjusted R-squared"
										  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
										  "SD dep.\ var.\ control group")
									  fmt(0 %9.3f %9.3f %9.3f)
					 )
				b(%9.3f) se(%9.3f)
				
				 prehead("&(1)			&(2)   			&(3)			&(4)   			&(5)			  &(6)  			 \\		  "
						 "&Participated &Participated	&Talked with   	&\% of members  &\% of members    &HH more inclined  \\		  "
						 "&in proposal  &in group    	&other members	&in association	&expected to      &to contribute had \\		  "
						 "&  			&proposal†		&of proposal  	&that reached  	&reach their	  &they known other  \\		  "
						 "&	  			&				&about 	 		&saving goals‡ 	&saving goals in  &members would 	 \\		  "
						 "&	  			&				&contribution‡	&				&the beginning of &reach savings	 \\		  "
						 "&			  	& 				&				&				&the project‡ 	  &	objectives‡		 \\ \hline")
				postfoot("[0.25em] \hline \hline \\[-1.8ex]")
		;
	#d	cr
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex"  					   ///
				"${out_tab}/tabA16-hh_collective_action.tex" , ///
				from("[1em]") to("") replace
	erase		"${out_tab}/todelete.tex"
	
	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA16-hh_collective_action.tex":${out_tab}/tabA16-hh_collective_action.tex}"'

	
******************************** End of do-file ********************************	
