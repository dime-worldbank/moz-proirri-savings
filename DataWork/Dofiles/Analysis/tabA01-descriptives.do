
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*				  Descriptive statistics and data sources					   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
		
		CREATES:	   	Table A1: Descriptive Statistics – Main Outcome Variables
						"${out_tab}/tabA01-descriptives.tex"
												
* ---------------------------------------------------------------------------- *
*								Association level							   *			
* ---------------------------------------------------------------------------- */
	
	* Load data
	use 	  "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
		 	
	preserve
	
		collapse (sum) bp_v0_target 								///
					   bp_v?_boxvalue bp_final_cont 			 	///
				(mean) ad_d_equipment ad_success ad_proirri_cost	///
					   el_shock_mean  el_penalty_mean				///
				  , by(${assocIdVars})
				
		local     	   assoc_bp_vars bp_v0_target   bp_v?_boxvalue  bp_final_cont
		local	  	   assoc_ad_vars ad_d_equipment ad_success 		ad_proirri_cost 
		local		   assoc_el_vars el_shock_mean  el_penalty_mean
		
		foreach varGroup in assoc_bp assoc_ad assoc_el {
			
			foreach stat in mean sd min max N {
			
				cap	mat drop `stat'
				
				foreach var of varlist ``varGroup'_vars' {
					
					sum			 `var' 		  , d		
					scalar  	 `stat'_value = r(`stat')
					mat 		 `stat'       = nullmat(`stat') \ `stat'_value
				}
			}
			
		mat 	 `varGroup' = ( mean , sd , min , max, N )
		mat list `varGroup'
	}
		
	restore

	clear
	
	svmat   assoc_bp
	
	gen     v1 = "\addlinespace[0.75em] Total scheme target value of savings"   in 1
	replace v1 = "Total scheme savings -- First quarter"      					in 2
	replace v1 = "Total scheme savings -- Second quarter"     					in 3
	replace v1 = "Total scheme savings -- Third quarter"      					in 4
	replace v1 = "Total scheme savings -- Forth quarter"      					in 5
	replace v1 = "Total scheme savings -- Final contribution" 					in 6
	
	gen 	v2 = string(assoc_bp1, "%9.0f")
	gen 	v3 = string(assoc_bp2, "%9.0f")
	
	gen 	v4 = string(assoc_bp3, "%9.0f")
	replace v4 = subinstr(v4,".000","",.)
	gen 	v5 = string(assoc_bp4, "%9.0f")
	replace v5 = subinstr(v5,".000","",.)
	
	gen 	v6 = string(assoc_bp5, "%9.0f")
	
	gen		v7 = "Box pick-up data"
	
	drop 	assoc_bp?
	
	local 	fileNum_assoc_bp = 0
	
	dataout, save("${out_tab}/descriptive_assoc_bp_`fileNum_assoc_bp'.tex") ///
			 replace tex nohead noauto
			 
	* Remove lines from `dataout` export
	foreach lineToRemove in "\BSdocumentclass[]{article}"			///
							"\BSsetlength{\BSpdfpagewidth}{8.5in}" 	///
							"\BSsetlength{\BSpdfpageheight}{11in}"  ///
							"\BSbegin{document}" 					///
							"\BSend{document}" 						///
							"\BSbegin{tabular}{lcccccc}"			///
							"Variable"								///
							"\BShline"								///
							"\BSend{tabular}"						{
			
				filefilter "${out_tab}/descriptive_assoc_bp_`fileNum_assoc_bp'.tex"			/// 
						   "${out_tab}/descriptive_assoc_bp_`=`fileNum_assoc_bp'+1'.tex"	///
						   , from("`lineToRemove'") to("") replace
				erase	   "${out_tab}/descriptive_assoc_bp_`fileNum_assoc_bp'.tex"
			
				local fileNum_assoc_bp = `fileNum_assoc_bp' + 1
			}
			
	clear
	
	svmat   assoc_ad 
	
	gen     v1 = "\addlinespace[0.75em] Probability to get the equipment -- Among all schemes" in 1
	replace v1 = "Probability to get the equipment -- Among schemes that applied" 			   in 2
	replace v1 = "Equipment value" 												  			   in 3
	
	gen 	v2 = string(assoc_ad1, "%9.3f")	
	gen 	v3 = string(assoc_ad2, "%9.3f")
	
	gen 	v4 = string(assoc_ad3, "%9.3f")
	replace v4 = subinstr(v4,".000","",.)
	gen 	v5 = string(assoc_ad4, "%9.3f")
	replace v5 = subinstr(v5,".000","",.)
	
	forv varNum = 2/5 {
		
		replace v`varNum' = string(assoc_ad`=`varNum'-1', "%9.0f") if v1 == "Equipment value"
	}
	
	gen 	v6 = string(assoc_ad5, "%9.0f")
	
	gen		v7 = "Administrative project data"
	
	drop 	assoc_ad?
	
	local 	fileNum_assoc_ad = 0
	
	dataout, save("${out_tab}/descriptive_assoc_ad_`fileNum_assoc_ad'.tex") ///
			 replace tex nohead noauto
			 
	* Remove lines from `dataout` export
	foreach lineToRemove in "\BSdocumentclass[]{article}"			///
							"\BSsetlength{\BSpdfpagewidth}{8.5in}" 	///
							"\BSsetlength{\BSpdfpageheight}{11in}"  ///
							"\BSbegin{document}" 					///
							"\BSend{document}" 						///
							"\BSbegin{tabular}{lcccccc}"			///
							"Variable"								///
							"\BShline"								///
							"\BSend{tabular}"						{
			
				filefilter "${out_tab}/descriptive_assoc_ad_`fileNum_assoc_ad'.tex"		/// 
						   "${out_tab}/descriptive_assoc_ad_`=`fileNum_assoc_ad'+1'.tex"	///
						   , from("`lineToRemove'") to("") replace
				erase	   "${out_tab}/descriptive_assoc_ad_`fileNum_assoc_ad'.tex"
			
				local fileNum_assoc_ad = `fileNum_assoc_ad' + 1
			}
	
	clear
	
	svmat   assoc_el
	
	gen     v1 = "\addlinespace[0.75em] Communal shock exposure" in 1
	replace v1 = "Share of reported penalty outcomes" 		   	 in 2
	
	gen 	v2 = string(assoc_el1, "%9.3f")
	gen 	v3 = string(assoc_el2, "%9.3f")
	
	gen 	v4 = string(assoc_el3, "%9.0f")
	replace v4 = subinstr(v4,".000","",.)
	gen 	v5 = string(assoc_el4, "%9.0f")
	replace v5 = subinstr(v5,".000","",.)
	
	gen 	v6 = string(assoc_el5, "%9.0f")
	
	gen		v7 = "Household endline survey"
	
	drop 	assoc_el?
	
	local 	fileNum_assoc_el = 0
	
	dataout, save("${out_tab}/descriptive_assoc_el_`fileNum_assoc_el'.tex") ///
			 replace tex nohead noauto
			 
	* Remove lines from `dataout` export
	foreach lineToRemove in "\BSdocumentclass[]{article}"			///
							"\BSsetlength{\BSpdfpagewidth}{8.5in}" 	///
							"\BSsetlength{\BSpdfpageheight}{11in}"  ///
							"\BSbegin{document}" 					///
							"\BSend{document}" 						///
							"\BSbegin{tabular}{lcccccc}"			///
							"Variable"								///
							"\BShline"								///
							"\BSend{tabular}"						{
			
				filefilter "${out_tab}/descriptive_assoc_el_`fileNum_assoc_el'.tex"		/// 
						   "${out_tab}/descriptive_assoc_el_`=`fileNum_assoc_el'+1'.tex"	///
						   , from("`lineToRemove'") to("") replace
				erase	   "${out_tab}/descriptive_assoc_el_`fileNum_assoc_el'.tex"
			
				local fileNum_assoc_el = `fileNum_assoc_el' + 1
			}
			
* ---------------------------------------------------------------------------- *
*								Household level								   *			
* ---------------------------------------------------------------------------- *
	
	use 	  "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
	
	local     hh_bp_vars bp_v?_d_saved bp_d_saved bp_v?_boxvalue bp_final_cont bp_final_gap
	local	  hh_el_vars el_d_usecattle el_d_usetraction el_d_usecart   el_d_usetractor ///
						 el_d_useplough el_d_usemotocult el_d_useseeder el_d_usetrailer ///
						 el_d_usemotorpump el_d_useelecpump 							///
						 el_wealth_index
						 
	* Household level. Box pick-up data	
	foreach varGroup in hh_bp hh_el {
						
		foreach stat in mean sd min max N {
		
			cap	mat drop `stat'
			
			foreach var of varlist ``varGroup'_vars' {
				
				sum			 `var' 		  , d		
				scalar  	 `stat'_value = r(`stat')
				mat 		 `stat'       = nullmat(`stat') \ `stat'_value
			}
		}
		
		mat 	 `varGroup' = ( mean , sd , min , max, N )
		mat list `varGroup'
	}
	
	clear
	
	svmat   hh_bp
	
	gen     v1 = "\addlinespace[0.75em] Saved in the first quarter"    in  1
	replace v1 = "Saved in the second quarter"      				   in  2
	replace v1 = "Saved in the third quarter"       				   in  3
	replace v1 = "Saved in the fouth quarter"       				   in  4
	replace v1 = "Saved in one of the quarters"      				   in  5
	replace v1 = "\addlinespace[0.75em] Savings -- First quarter" 	   in  6
	replace v1 = "Savings -- Second quarter" 						   in  7
	replace v1 = "Savings -- Third quarter" 						   in  8
	replace v1 = "Savings -- Fourth quarter" 						   in  9
	replace v1 = "\addlinespace[0.75em] Savings -- Final contribution" in 10
	replace v1 = "Savings -- Final gap from target"					   in 11
	
	gen 	v2 = string(hh_bp1, "%9.3f")
	gen 	v3 = string(hh_bp2, "%9.3f")
	
	gen 	v4 = string(hh_bp3, "%9.3f")
	replace v4 = subinstr(v4,".000","",.)
	gen 	v5 = string(hh_bp4, "%9.3f")
	replace v5 = subinstr(v5,".000","",.)
	
	forv varNum = 2/5 {
		
		replace v`varNum' = string(hh_bp`=`varNum'-1', "%9.0f") if regexm(v1, "Savings --")
	}
	
	gen 	v6 = string(hh_bp5, "%9.0f")
	
	gen		v7 = "Box pick-up data"
	
	drop 	hh_bp?
	
	local 	fileNum_hh_bp = 0
	
	dataout, save("${out_tab}/descriptive_hh_bp_`fileNum_hh_bp'.tex") ///
			 replace tex nohead noauto
			 
	* Remove lines from `dataout` export
	foreach lineToRemove in "\BSdocumentclass[]{article}"			///
							"\BSsetlength{\BSpdfpagewidth}{8.5in}" 	///
							"\BSsetlength{\BSpdfpageheight}{11in}"  ///
							"\BSbegin{document}" 					///
							"\BSend{document}" 						///
							"\BSbegin{tabular}{lcccccc}"			///
							"Variable"								///
							"\BShline"								///
							"\BSend{tabular}"						{
			
				filefilter "${out_tab}/descriptive_hh_bp_`fileNum_hh_bp'.tex"		/// 
						   "${out_tab}/descriptive_hh_bp_`=`fileNum_hh_bp'+1'.tex"	///
						   , from("`lineToRemove'") to("") replace
				erase	   "${out_tab}/descriptive_hh_bp_`fileNum_hh_bp'.tex"
			
				local fileNum_hh_bp = `fileNum_hh_bp' + 1
			}
	
	clear
	
	svmat   hh_el
	
	gen     v1 = "\addlinespace[0.75em] Used cattle"  in 1
	replace v1 = "Used animal traction"				  in 2
	replace v1 = "Used cart"						  in 3
	replace v1 = "Used tractor"						  in 4
	replace v1 = "Used plough"						  in 5
	replace v1 = "Used motocultivator"				  in 6
	replace v1 = "Used seeder"						  in 7
	replace v1 = "Used trailer"						  in 8
	replace v1 = "Used motorpump"					  in 9
	replace v1 = "Used electrict pump"				  in 10
	replace v1 = "\addlinespace[0.75em] Wealth index" in 11
	
	gen 	v2 = string(hh_el1, "%9.3f")
	gen 	v3 = string(hh_el2, "%9.3f")
	
	gen 	v4 = string(hh_el3, "%9.3f")
	replace v4 = subinstr(v4,".000","",.)
	gen 	v5 = string(hh_el4, "%9.3f")
	replace v5 = subinstr(v5,".000","",.)
	
	forv varNum = 2/5 {
		
		replace v`varNum' = string(hh_el`=`varNum'-1', "%9.0f") if regexm(v1, "Savings --")
	}
	
	gen 	v6 = string(hh_el5, "%9.0f")
	
	gen		v7 = "Household endline survey"
	
	drop 	hh_el?
	
	local 	fileNum_hh_el = 0
	
	dataout, save("${out_tab}/descriptive_hh_el_`fileNum_hh_el'.tex") ///
			 replace tex nohead noauto
			 
	* Remove lines from `dataout` export
	foreach lineToRemove in "\BSdocumentclass[]{article}"			///
							"\BSsetlength{\BSpdfpagewidth}{8.5in}" 	///
							"\BSsetlength{\BSpdfpageheight}{11in}"  ///
							"\BSbegin{document}" 					///
							"\BSend{document}" 						///
							"\BSbegin{tabular}{lcccccc}"			///
							"Variable"								///
							"\BShline"								///
							"\BSend{tabular}"						{
			
				filefilter "${out_tab}/descriptive_hh_el_`fileNum_hh_el'.tex"			/// 
						   "${out_tab}/descriptive_hh_el_`=`fileNum_hh_el'+1'.tex"	///
						   , from("`lineToRemove'") to("") replace
				erase	   "${out_tab}/descriptive_hh_el_`fileNum_hh_el'.tex"
			
				local fileNum_hh_el = `fileNum_hh_el' + 1
			}

			
* ---------------------------------------------------------------------------- *			
*									Final table								   *
* ---------------------------------------------------------------------------- *

	* Initiate final LaTeX file
	file open descriptive  using "${out_tab}/todelete.tex", ///
		 text write replace

	* Append estimations in unique LaTeX file 								
	foreach varGroup in assoc_bp assoc_ad assoc_el hh_bp hh_el {
			
		file open `varGroup' using "${out_tab}/descriptive_`varGroup'_`fileNum_`varGroup''.tex", ///
			 text read
																					
		* Loop over lines of the LaTeX file and save everything in a local		
		local `varGroup' ""														
			file read  `varGroup' line										
		while r(eof)==0 { 														
			local `varGroup' `" ``varGroup'' `line' "'								
			file read  `varGroup' line										
		}																		
			file close `varGroup'											
		
		erase "${out_tab}/descriptive_`varGroup'_`fileNum_`varGroup''.tex" 								
	}																			

	* Append all locals as strings, add footnote and end of LaTeX environments
	#d	;
		file write descriptive
			 
			 "& (1) & (2) & (3) & (4) & (5) & (6) \\" _n
			 "& Mean & SD & Min & Max & N & \multicolumn{1}{c}{\textit{Data source}} \\ \hline \\[-1.8ex]		" _n
			 "\multicolumn{7}{c}{\textbf{Panel A -- Association Level}} 			 		   \\[0.5ex] \hline " _n
			 "`assoc_bp' 																		 				" _n
			 "`assoc_ad' 																		 				" _n
			 "`assoc_el' 														[0.5ex] \hline \\[-1.8ex] 	    " _n
			 "\multicolumn{7}{c}{\textbf{Panel B -- Household Level}} 			 		  	   \\[0.5ex] \hline " _n
			 "`hh_bp' 																	 	    			    " _n
			 "`hh_el'																	\hline 					" _n
			 "																		    \hline \\[-1.8ex]		" _n
		;
	#d	cr
	
		file close descriptive
	
	filefilter "${out_tab}/todelete.tex"			/// 
			   "${out_tab}/todelete2.tex"			///
			 , from("\BS{") to("{") replace
	erase	   "${out_tab}/todelete.tex"
			
	filefilter "${out_tab}/todelete2.tex"			/// 
			   "${out_tab}/tabA01-descriptives.tex"	///
			 , from("\BS}") to("}") replace
	erase	   "${out_tab}/todelete2.tex"
	
	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA01-descriptives.tex":${out_tab}/tabA01-descriptives.tex}"'
	
	
***************************** End of do-file ***********************************
