
/*******************************************************************************
*																 			   *
* 	  				"Do Private Consultants Promote Savings					   *
*					 and Investments in Rural Mozambique?"	  				   *
*																			   *
*	   Kernel densities of aggregate saving value at the association level	   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Figure A3: Distribution of Total Saving Values at the Association Level
						"${out_tab}/figA03-assoc_savingsValue_kdensity.png"
												
* ---------------------------------------------------------------------------- */

	* Load data
	use		"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear
	
	* Sum savings within association
	collapse  (sum)  bp_v4_boxvalue_cumul* 									, by(associd treatment)
	
	* Plot kernel densities
	#d	;
		tw (kdensity bp_v4_boxvalue_cumul if treatment == 0 & bp_v4_boxvalue_cumul_w95 > 0 , color(${controlColor}%80)	   lwidth(*2.5) lpattern(dash) )
		   (kdensity bp_v4_boxvalue_cumul if treatment == 1 & bp_v4_boxvalue_cumul_w95 > 0 , color(${treatmentColor}%80) lwidth(*2.5)			   )
				,
				${graphOptions}
				ytitle("Kernel density estimates")
				ylab(, angle(horizontal) nogrid)
				xtitle("MZN")
				xscale(titlegap(2))				
				legend(order(1 "Control" 2 "Treatment") cols(1) position(1) ring(0) textfirst)
				graphregion(margin(r+4))
		;
	#d	cr
	
	* Export figure in .PNG format
	gr export "${out_fig}/figA03-assoc_savingsValue_kdensity.png", width(5000) replace

	
***************************** End of do-file ***********************************
