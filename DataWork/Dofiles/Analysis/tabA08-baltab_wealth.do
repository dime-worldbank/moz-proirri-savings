
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*						Balance checks by wealth							   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
		
		CREATES:	   	Table A8: Balance Table by Household Wealth Index
						"${out_tab}/tabA08-baltab_wealth.tex"								
														
* ---------------------------------------------------------------------------- */
		
	* Load data
	use 	  "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
	
	* Generate dummy for wealth index above the median
	sum							  el_wealth_index ,  d
	gen 	 wealth_aboveMedian = el_wealth_index > `r(p50)' if !mi(el_wealth_index)
	tab		 wealth_aboveMedian
	
	* Choose variables for balance (same as for Table 4)
	#d	;
	
		local assocVars  nbr_members
						 bl_communal_ha bl_irrigation_ha
						 bl_finlit_training finlit_years_ago
						 bl_animal_traction_assoc
						 bl_multicultivator bl_processing bl_silo
						 bl_mg_success bl_bank_account
		;
		
		local assocVars2 nbr_members
						 bl_communal_ha bl_irrigation_ha
						 bl_finlit_training
						 bl_animal_traction_assoc
						 bl_multicultivator bl_processing bl_silo
						 bl_mg_success bl_bank_account
		;

		local bl_hhVars  bl_hhsize  bl_rainfed_ha
		;
		local el_hhVars  el_headage el_headeduc el_headgender
						 el_durroof el_durwalls el_savingstart
		;
	#d	cr
	
	* Change balance variable to reflect both treatment and wealth
	gen 	wealth_treatment = .
	replace wealth_treatment = 1 if treatment == 0 & wealth_aboveMedian == 0
	replace wealth_treatment = 2 if treatment == 1 & wealth_aboveMedian == 0
	replace wealth_treatment = 3 if treatment == 0 & wealth_aboveMedian == 1
	replace wealth_treatment = 4 if treatment == 1 & wealth_aboveMedian == 1
		
	preserve

		#d	;
		
			// Household Baseline Survey
			// -------------------------
			iebaltab `bl_hhVars'
				,
				vce(cluster associd) grpvar(wealth_treatment) fixedeffect(prov)
				pttest starsnoadd
				rowvarlabels
				tblnonote
				browse replace
			;
		#d	cr
		
		* Drop title raws
		drop in  1/3
		
		* Replace parentheses for standard errors
		replace  v3 = subinstr(v3,"[","(",.)
		replace  v5 = subinstr(v5,"[","(",.)
		replace  v3 = subinstr(v3,"]",")",.)
		replace  v5 = subinstr(v5,"]",")",.)
		
		* Drop p-values we are not interest in
		drop 	     v11-v14
		rename	 v15 v11
		
		local 	 bl_hh_fileNum = 0
		
		dataout, save("${out_tab}/bl_hh_balance_`bl_hh_fileNum'.tex") 		///
				 replace tex nohead noauto
	
	restore
	
	preserve
	
		#d	;
		
			// Household Baseline Survey
			// -------------------------
			iebaltab `el_hhVars' [pw=pweight]
				,
				vce(cluster associd) grpvar(wealth_treatment) fixedeffect(prov)
				pttest starsnoadd
				rowvarlabels
				tblnonote
				browse replace
			;
		#d	cr
		
		* Drop title raws
		drop in   1/3
		
		* Replace parentheses for standard errors
		replace  v3 = subinstr(v3,"[","(",.)
		replace  v5 = subinstr(v5,"[","(",.)
		replace  v3 = subinstr(v3,"]",")",.)
		replace  v5 = subinstr(v5,"]",")",.)
		
		* Drop p-values we are not interest in
		drop 	     v11-v14
		rename	 v15 v11
		
		local 	 el_hh_fileNum = 0
		
		dataout, save("${out_tab}/el_hh_balance_`el_hh_fileNum'.tex") ///
				 replace tex nohead noauto
	
	restore
	
	cap  file close _all

	foreach level in bl_hh el_hh {
		
		* Remove lines from `dataout` export
		foreach lineToRemove in "\BSdocumentclass[]{article}"						///
								"\BSsetlength{\BSpdfpagewidth}{8.5in}" 				///
								"\BSsetlength{\BSpdfpageheight}{11in}"  			///
								"\BSbegin{document}" 								///
								"\BSbegin{tabular}{lcccccccccc}"					///
								"Variable"											///
								"\BShline"											///
								"\BSend{tabular}"									///
								"\BSend{document}" 									{
		
			filefilter "${out_tab}/`level'_balance_``level'_fileNum'.tex"			/// 
					   "${out_tab}/`level'_balance_`=``level'_fileNum'+1'.tex"		///
					   , from("`lineToRemove'") to("") replace
			erase	   "${out_tab}/`level'_balance_``level'_fileNum'.tex"
		
			local `level'_fileNum = ``level'_fileNum' + 1
		}
		
		* Add incipit and end of LaTeX table
		*(to be directly input in TeX document) without further formatting
		file open  `level'File														///
			 using "${out_tab}/`level'_balance_``level'_fileNum'.tex"				///
			 , text read		
															
		* Loop over lines of the original TeX file and save everything in a local
		local 	   `level'File ""											
		file read  `level'File line																	
		while r(eof) == 0 {    
			local 	  `level'File " ``level'File' `line' "
			file read `level'File line
		}
		file close `level'File
		
		* Erase original file
		erase "${out_tab}/`level'_balance_``level'_fileNum'.tex"
	}
	
	* Make final table
	file  open finalFile using "${out_tab}/tabA08-baltab_wealth.tex"	///
		, text write replace
		
	#d	;
	
		file write finalFile
			
			"\\[-1.8ex]\hline \hline \\[-1.8ex]"
			"& \multicolumn{4}{c}{\textit{Below median wealth index}}      & \multicolumn{4}{c}{\textit{Above median wealth index}}		  &         &		  \\" _n
			"  \cmidrule(lr){2-5} \cmidrule(lr){6-9}"																											  _n
			
			"& \multicolumn{2}{c}{(1)}	   & \multicolumn{2}{c}{(2)}  	   & \multicolumn{2}{c}{(3)}     & \multicolumn{2}{c}{(4)} 		  & (1)-(2) & (3)-(4) \\" _n
			"& \multicolumn{2}{c}{Control} & \multicolumn{2}{c}{Treatment} & \multicolumn{2}{c}{Control} & \multicolumn{2}{c}{Treatment}  & T-test  & T-test  \\" _n
			"Variable & N/[Clusters] & Mean/SE & N/[Clusters] & Mean/SE & N/[Clusters] & Mean/SE & N/[Clusters] & Mean/SE & P-value & P-value \\ \hline \\[-1.8ex]" _n
			
			"\multicolumn{11}{c}{\textbf{Panel A -- Household Level at Baseline}} \\[0.5ex] \hline 	 		 " _n
			"`bl_hhFile' 																    \hline \\[-1.8ex]" _n
			
			"\multicolumn{11}{c}{\textbf{Panel B -- Household Level at Endline}}  \\[0.5ex] \hline 	 		 " _n
			"`el_hhFile'"																					   _n
			"																	   	 \hline \hline \\[-1.8ex]" _n
		;
	#d	cr
	
	file close finalFile
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA08-baltab_wealth.tex":${out_tab}/tabA08-baltab_wealth.tex}"'

	
***************************** End of do-file ***********************************
