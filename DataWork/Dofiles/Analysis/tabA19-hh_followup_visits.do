
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*							Follow-up visits 								   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A19: Summary Statistics on Follow-Up Visits
						"${out_tab}/tabA19-hh_followup_visits.tex"
														
* ---------------------------------------------------------------------------- *
*						Prepare data and definte variables			  	   	   *
* ---------------------------------------------------------------------------- */

	* Load data
	use 	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
	
	* Add vertical space before first variable
	lab var el_visits "\addlinespace[0.75em] Knew of visit from the trainers"	//(5.19)	
	
	* Clear estimates
	est clear 
	
	* Export formatted summary table in LaTeX
	#d	;
		
		local   varlist el_visits el_one_meeting el_two_meeting el_three_meeting
					    el_visitgoals el_visitreview el_visitupdate el_visituseful
					    el_helpfultreat_12 el_trustinfo el_trustmg
		;
		
		estpost sum `varlist' if treatment == 1
		;
		
		esttab  using
			    "${out_tab}/tabA19-hh_followup_visits.tex"
				,
				
				replace
				
			    cells("mean(fmt(%9.2f) lab(Mean))
					     sd(fmt(%9.2f) lab(SD  ))
						min(fmt(%9.0f) lab(Min ))
						max(fmt(%9.0f) lab(Max ))
					  count(fmt(%9.0f) lab(N   ))")
						 
				nonumber noobs
				nomtitles
				label
						   
				modelwidth(11 25)
				varwidth(	  15)
				
				 prehead("& (1) & (2) & (3) & (4) & (5) \\")
				postfoot("[0.25em] \hline \hline \\[-1.8ex]")
		;
	#d	cr

	
***************************** End of do-file ***********************************
