
/*******************************************************************************
*																 			   *
* 	  "Private Consultants Promote Agricultural Investments in Mozambique"	   *
*																			   *
*						Mix of items applied for							   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Figure 1: Applications to Matching Grants: Mix of Items
						"${out_fig}/fig01-assoc_item_mix.png"
												
* ---------------------------------------------------------------------------- */

	* Load data
	use		 "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
		
	* Collapse string containing the mix of items at the association level
	collapse (firstnm) ad_items, by(${assocIdVars})
	
	* Generate mix of items by association
	list 												 associd 									 					 ad_items
	//ites are expressed in Portuguese as from the original grant application
	
	gen     mix_animal					    	= inlist(associd, 38)											  if !mi(ad_items)
	gen		mix_post							= inlist(associd, 70)											  if !mi(ad_items)
	gen	 	mix_animal_landprep		 			= inlist(associd, 10, 11, 12, 13, 14, 15, 16, 17, 20, 21, 22, 72) if !mi(ad_items)
	gen     mix_animal_landprep_grow 			= inlist(associd, 23, 24, 25, 26, 27, 28) 						  if !mi(ad_items)
	gen     mix_landprep_tractor_transport 	    = inlist(associd, 29, 37, 46)									  if !mi(ad_items)
	gen     mix_tractor_seeder_post				= inlist(associd, 43)											  if !mi(ad_items)
	gen     mix_anim_prep_tractor_trans_post 	= inlist(associd, 48)											  if !mi(ad_items)
	gen		mix_landprep_tractor_post			= inlist(associd, 71)											  if !mi(ad_items)
	
	#d	;
		local mixVars mix_animal_landprep
					  mix_animal_landprep_grow
					  mix_landprep_tractor_transport
				      mix_tractor_seeder_post
				      mix_anim_prep_tractor_trans_post
				      mix_landprep_tractor_post
				      mix_animal
				      mix_post
		;
	#d	cr
	
	* Turn dummy variables into percentage
	foreach var of local mixVars {
		
		replace `var' = `var' * 100
	}
	
	* Plot horizontal bars by catergory
	#d	;
		gr hbar `mixVars'
			,
				${graphOptions}
				
			    ascat
			    
				yvaroptions(relab(1 `"Cattle + land preparation equipment"'
								  2 `" "Cattle + land preparation equipment"  "+ growing phase equipment" "'
								  3 `" "Tractor + land preparation equipment" "+ transportation" 		  "'
								  4 `" "Tractor + land preparation equipment" "+ transportation" 		  "'
								  5 `" "Tractor + land preparation equipment" "+ post-harvest" 			  "'
								  6 `" "Tractor + seeder" 					  "+ post-harvest equipment"  "'
								  7 `"Only cattle"'
								  8 `"Only post-harvest equipment"'
								 )
							  lab(labsize(*.85))
							)
				
			    ytitle("% of associations", margin(t+3 l-1))
			    
				bar(1, color(midblue%50))
			    blab(bar, format(%9.2f))
				
				graphregion(margin(r+2))		
		;
	#d	cr
	
	* Export figure in .PNG format
	gr export "${out_fig}/fig01-assoc_item_mix.png", width(5000) replace


***************************** End of do-file ***********************************
