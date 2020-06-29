
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*				Average penalty outcomes in the treatment					   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Figure A2: Penalty Outcomes in Treated Schemes
						"${out_tab}/figA02-penalty_outcomes.png"
												
* ---------------------------------------------------------------------------- */

	* Load data
	use		"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear

	* Turn variables from question 5.24 of the household survey to percentage
	forv 	varNum = 1/3 {
	
		replace el_visitconseq_`varNum' = el_visitconseq_`varNum' * 100
	}
	
	* Plot vertical bar graph for treated communities
	#d	;
		gr bar el_visitconseq_1
			   el_visitconseq_2
			   el_visitconseq_3
			   
			   if treatment == 1
			   
			   ,
			   
			   ${graphOptions}
			   
			   ascat
			   
			   yvaroptions(relabel(1 `""Names of those who"
									   "did not meet their"
									   "goal was mentioned"
									   "at meetings""'
									   
								   2 `""Names of those who"
								       "did not meet their"
									   "goal was displayed"
									   "to the association""'
									   
								   3 `""Missing value"
									   "of contributions"
									   "were displaced""'
								   ))
			   ytitle("% of household")
			   
			   bar(1, color(${treatmentColor}%80))
			   blab(bar, format(%9.2f))
		;
	#d	cr
	
	* Export figure in .PNG format
	gr export "${out_fig}/figA02-hh_penalty_outcomes.png", width(5000) replace
	

******************************** End of do-file ********************************	
