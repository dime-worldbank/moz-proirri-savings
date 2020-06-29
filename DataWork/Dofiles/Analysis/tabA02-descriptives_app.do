
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
		
		CREATES:	   	Table A2: Descriptive Statistics – Appendix Outcome Variables
						"${out_tab}/tabA02-descriptives_app.tex"
												
* ---------------------------------------------------------------------------- *
*								Association level							   *			
* ---------------------------------------------------------------------------- */
	
	use 	  "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
	
	local     hh_bp_vars bp_v2_boxvalue_cumul bp_v3_boxvalue_cumul bp_v4_boxvalue_cumul ///
						 bp_v?_boxvalue_ihs bp_v?_boxvalue_w95 bp_v?_boxvalue_t95
	
	local	  hh_el_vars el_d_owncattle el_d_owntraction el_d_owncart el_d_owntractor el_d_ownplough el_d_ownmotocult el_d_ownseeder el_d_owntrailer el_d_ownmotorpump el_d_ownelecpump	///
						 ${credVars}																																					///
						 ${inputVars}																																					///
						 ${costVars}
						 	
	* Form matrices with statistics
	foreach varGroup in hh_bp hh_el {
				
		foreach stat in mean sd min max N {
			
			cap	mat drop `stat'
			
			foreach var of varlist ``varGroup'_vars' {
				
				sum			 `var' 		  , d		
				scalar  	 `stat'_value = r(`stat')
				mat 		 `stat'       = nullmat(`stat') \ `stat'_value
			}
		}
		
		* Join columns
		mat 	 `varGroup' = ( mean , sd , min , max, N )
		mat list `varGroup'
	}
	
	clear
	
	svmat   hh_bp
	
	gen     v1 = "Cumulative savings -- Second quarter"  		 in  1
	replace v1 = "Cumulative savings -- Third quarter"       				   		 in  2
	replace v1 = "Cumulative savings -- Fouth quarter"       				   	 	 in  3
	replace v1 = "\addlinespace[0.75em] IHS of savings -- First quarter"   			 in  4
	replace v1 = "IHS of savings -- Second quarter" 						    	 in  5
	replace v1 = "IHS of savings -- Third quarter" 						   			 in  6
	replace v1 = "IHS of savings -- Fourth quarter" 						    	 in  7
	replace v1 = "\addlinespace[0.75em] Savings winsorized at 95% -- First quarter" in  8
	replace v1 = "Savings winsorized at 95% -- Second quarter"					     in  9
	replace v1 = "Savings winsorized at 95% -- Third quarter"					     in 10
	replace v1 = "Savings winsorized at 95% -- Fourth quarter"					     in 11
	replace v1 = "\addlinespace[0.75em] Savings trimmed at 95% -- First quarter" 	 in 12
	replace v1 = "Savings trimmed at 95% -- Second quarter"					     in 13
	replace v1 = "Savings trimmed at 95% -- Third quarter"					     	 in 14
	replace v1 = "Savings trimmed at 95% -- Fourth quarter"					     in 15
	
	gen 	v2 = string(hh_bp1, "%9.0f")
	replace v2 = string(hh_bp1, "%9.3f") if regexm(v1, "IHS")
	gen 	v3 = string(hh_bp2, "%9.0f")
	replace v3 = string(hh_bp2, "%9.3f") if regexm(v1, "IHS")
	gen 	v4 = string(hh_bp3, "%9.0f")
	gen 	v5 = string(hh_bp4, "%9.0f")
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
			
				filefilter "${out_tab}/descriptive_hh_bp_`fileNum_hh_bp'.tex"			/// 
						   "${out_tab}/descriptive_hh_bp_`=`fileNum_hh_bp'+1'.tex"	///
						   , from("`lineToRemove'") to("") replace
				erase	   "${out_tab}/descriptive_hh_bp_`fileNum_hh_bp'.tex"
			
				local fileNum_hh_bp = `fileNum_hh_bp' + 1
			}
	
	clear
	
	svmat   hh_el
	
	gen     v1 = "\addlinespace[0.75em] Owns cattle"  in 1
	replace v1 = "Owns animal traction"				  in 2
	replace v1 = "Owns cart"						  in 3
	replace v1 = "Owns tractor"						  in 4
	replace v1 = "Owns plough"						  in 5
	replace v1 = "Owns motocultivator"				  in 6
	replace v1 = "Owns seeder"						  in 7
	replace v1 = "Owns trailer"						  in 8
	replace v1 = "Owns motorpump"					  in 9
	replace v1 = "Owns electrict pump"				  in 10
	
	replace v1 = "\addlinespace[0.75em] Received credit"		 	  in 11
	replace v1 = "Received credit for agricultural inputs"		 	  in 12
	replace v1 = "Received credit for other commercial goods"	 	  in 13
	replace v1 = "Received credit for agricultural machinery"	 	  in 14
	
	replace v1 = "\addlinespace[0.75em] Used organic fertilizers" 	  in 15
	replace v1 = "Used chemical fertilizers"						  in 16
	replace v1 = "Used pesticides"									  in 17
	replace v1 = "\addlinespace[0.75em] Costs of organic fertilizers" in 18
	replace v1 = "Costs of chemical fertilizers"					  in 19
	replace v1 = "Costs of pesticides"								  in 20
	
	replace v1 = "\addlinespace[0.75em] Costs of workers" 	  		  in 21
	replace v1 = "Costs of seeds"						 	  		  in 22
	replace v1 = "Costs of equipment rent" 	  		  				  in 23
	replace v1 = "Costs of plot rent" 	  		  					  in 24
	replace v1 = "Costs of livestock" 	  		  					  in 25
	
	gen 	v2 = string(hh_el1, "%9.3f")
	gen 	v3 = string(hh_el2, "%9.3f")
	
	gen 	v4 = string(hh_el3, "%9.3f")
	replace v4 = subinstr(v4,".000","",.)
	gen 	v5 = string(hh_el4, "%9.3f")
	replace v5 = subinstr(v5,".000","",.)	
	
	forv varNum = 2/5 {
		
		replace v`varNum' = string(hh_el`=`varNum'-1', "%9.0f") if regexm(v1, "Costs")
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
	file open descriptive  using "${out_tab}/descriptive_app.tex", ///
		 text write replace

	* Append estimations in unique LaTeX file 								
	foreach varGroup in hh_bp hh_el {
			
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
			 "`hh_bp' 																	 	    			    " _n
			 "`hh_el'																	\hline 					" _n
			 "																		    \hline \\[-1.8ex]		" _n
		;
	#d	cr
	
		file close descriptive
	
	filefilter "${out_tab}/descriptive_app.tex"		/// 
			   "${out_tab}/descriptive_app_ed.tex"	///
			 , from("\BS{") to("{") replace
	erase	   "${out_tab}/descriptive_app.tex"
			
	filefilter "${out_tab}/descriptive_app_ed.tex"		/// 
			   "${out_tab}/tabA02-descriptives_app.tex"	///
			 , from("\BS}") to("}") replace
	erase	   "${out_tab}/descriptive_app_ed.tex"
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA02-descriptives_app.tex":${out_tab}/tabA02-descriptives_app.tex}"'

	
***************************** End of do-file ***********************************
