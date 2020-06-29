
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*				Impact on scheme equipment (success and value)				   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table 7: Impact on Equipment
						"${out_tab}/tab07-assoc_equipment.tex"
														
* ---------------------------------------------------------------------------- */
	
	* Load data
	use 	  	      "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta" , clear

	* Collapse outcome variables at the association level
	collapse (mean)   ad_d_equipment ad_success ad_proirri_cost, by(${assocIdVars})
		
	* Estimate regression on saving dummy with and without province fixed effects for each quarter
	est clear

	eststo 	  v0		: reg 	  ad_d_equipment treatment, cl(associd)
	estadd local provFE ""
	sum    	   					  ad_d_equipment if e(sample) == 1 & treatment == 0
	estadd scalar control_mean =  r(mean)
	estadd scalar control_sd   =  r(sd)
	estadd local provFE ""
		
	eststo 	  v0_prov   : reghdfe ad_d_equipment treatment, cl(associd) abs(prov)
	estadd local provFE "\checkmark"

	eststo 	  v1		: reg 	  ad_success treatment, cl(associd)
	estadd local provFE ""
	sum    	   					  ad_success if e(sample) == 1 & treatment == 0
	estadd scalar control_mean =  r(mean)
	estadd scalar control_sd   =  r(sd)
	estadd local provFE ""
		
	eststo 	  v1_prov   : reghdfe ad_success treatment, cl(associd) abs(prov)
	estadd local provFE "\checkmark"
	
	* Export (temporary) formatted table in LaTeX
	#d	;
		esttab 	v0 v0_prov
				v1 v1_prov	

				using     "${out_tab}/dummy.tex" ,
				
				${esttabOptions}
				
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  N r2_a control_mean control_sd provFE,
				  lab(	  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(0 %9.3f %9.3f %9.3f)
					 )
				b(%9.3f) se(%9.3f)
		;
	#d	cr

	* Clear estimates and do the same for saving values (in MZN)		
	est clear
	
	eststo 	  v0		: reg 	  ad_proirri_cost treatment, cl(associd)
	sum    	   					  ad_proirri_cost if e(sample) == 1 & treatment == 0
	estadd scalar control_mean =  r(mean)
	estadd scalar control_sd   =  r(sd)
	estadd local provFE ""
		
	eststo 	  v0_prov   : reghdfe ad_proirri_cost treatment, cl(associd) abs(prov)
	estadd local provFE "\checkmark"
	
	* Export (temporary) formatted table in LaTeX
	local 	fileNum = 0
	
	#d	;
		esttab 	v0
		        v0_prov		 		

				using     "${out_tab}/MZN_`fileNum'.tex" ,
				
				${esttabOptions}
				
				coeflabel(treatment "\addlinespace[0.75em] Treatment")
				stats(	  N r2_a control_mean control_sd provFE,
				  lab(	  "\addlinespace[0.75em] Number of observations"
						  "Adjusted R-squared"
						  "\addlinespace[0.75em] Mean dep.\ var.\ control group"
						  "SD dep.\ var.\ control group"
						  "\addlinespace[0.75em] Province fixed effects")
				  fmt(0 %9.3f %9.0f %9.0f)
					 )
				b(%9.0f) se(%9.0f)
		;
	#d	cr
		
	* Clean up temporary table	
	foreach rawName in "Treatment&" 					     ///
					   "            &    "				     ///
					   "Number of observations&"		     ///
					   "Adjusted R-squared&"			     ///
					   "Mean dep.\BS var.\BS control group&" ///
					   "SD dep.\BS var.\BS control group&"   ///
					   "Province fixed effects&"		  {
		
		filefilter  "${out_tab}/MZN_`fileNum'.tex" 	         ///
					"${out_tab}/MZN_`=`fileNum'+1'.tex"   ,  ///
					from("`rawName'") to("`rawName' & &")    replace	
		erase 		"${out_tab}/MZN_`fileNum'.tex" 
		
		local		fileNum = `fileNum' + 1
	}
		
	* Initiate final LaTeX file
	file open test  		   using "${out_tab}/todelete.tex", ///
		 text write replace
		
	* Append estimations in unique LaTeX file 								
	foreach  			panel    in 				dummy MZN_`fileNum' {			
		
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
			 
			 "&\multicolumn{2}{c}{Among all } &\multicolumn{2}{c}{Among schemes} 	   \\				   			       " _n
			 "&\multicolumn{2}{c}{schemes}	  &\multicolumn{2}{c}{that applied}  	   \\				   				   " _n
			 " \cmidrule(lr){2-3}			   \cmidrule(lr){4-5}														   " _n
			 "&(1) &(2)						  &(3) &(4) 							   \\ 		  \hline 		\\[-1.8ex] " _n
			 
			 "\multicolumn{5}{c}{\textbf{Panel A -- Probability to Get the Equipment}} \\ [0.5ex] \hline    			   " _n
			 "`dummy'    															   \\ 		  \hline 		\\[-1.8ex] " _n
			 
			 "\multicolumn{5}{c}{\textbf{Panel B -- Equipment Value}} 				   \\ [0.5ex] \hline    			   " _n
			 "`MZN_`fileNum'' 				    									   \\ 		  \hline \hline \\[-1.8ex] " _n
		;
	#d	cr
	
	file close test
	
	* Clean up table
	filefilter  "${out_tab}/todelete.tex" 			     ///
				"${out_tab}/tab07-assoc_equipment.tex" , ///
				from("[1em]") to("") replace	
	erase 		"${out_tab}/todelete.tex" 	
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tab07-assoc_equipment.tex":${out_tab}/tab07-assoc_equipment.tex}"'
	

******************************** End of do-file ********************************
