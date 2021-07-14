
/*******************************************************************************
*																 			   *
* 	  				"Do Private Consultants Promote Savings					   *
*					 and Investments in Rural Mozambique?"	  				   *
*																			   *
*							Balance checks									   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table A3: Balance Table
						"${out_tab}/tabA03-baltab.tex"
													
* ---------------------------------------------------------------------------- *
*						Estimate and store statistics		   		   		   *
* ---------------------------------------------------------------------------- */
	
	* Load data
	use 	  "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear

	* Divide variables by level and time of data collection
	#d	;
	
		local assocVars  nbr_members
						 bl_communal_ha bl_irrigation_ha
						 bl_finlit_training bl_finlit_years_ago
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
	
	* Copy variable labels before collapse (we need them for the [rowvarlabels] option in [iebaltab])
	foreach         v of var * {
			local l`v' : var lab `v'
			if `"`l`v''"' == "" {
			local l`v'          "`v'"
		}
	}

	preserve
		
		* Collapse association-level variables
		collapse `assocVars' `bl_hhVars' `el_hhVars' , by(${assocIdVars})
	
		* Attach the saved labels
        foreach      v of var * {
            lab var `v' "`l`v''"
        }
		
		* Relabel averages at the association level
		lab var bl_hhsize 	   "Pre-intervention household size, average"
		lab var bl_rainfed_ha  "Pre-intervention rainfed land (ha), average"
		
		lab var el_headage 	   "Head of household’s age, average"
		lab var el_headeduc    "Head of household’s education level, average"
		lab var el_headgender  "Share of male heads of household"
		lab var el_durroof	   "Share of houses that have durable roof" 
		lab var el_durwalls	   "Share of houses that houses that have durable walls"
		lab var el_savingstart "How much money household saved pre-intervention (MZN), average"
		
		* Run regression on subset of variables, which are not conditional
		areg treatment 	  `assocVars2' , abs(prov) rob 
	
		scalar reg_F 	= `e(F)'
		scalar reg_F_N 	= `e(N)'
		
		testparm 		  `assocVars2'
		scalar test_F 	= `r(F)'
		scalar test_F_p = `r(p)'
		
		* Check p-value with Bonferroni adjustment
		test			  `assocVars2' , mtest(bonferroni)
		
		* Drop existing matrix
		cap mat drop ri_pvalues
		
		* Loop on outcome variables
		foreach var in `assocVars' `bl_hhVars' `el_hhVars' {
			
			* Compute randomization inference p-values
			ritest treatment _b[treatment]	         			   , 			///
			reps(${repsNum}) seed(${seedsNum}) strata(prov) nodots : 			///
			areg `var' treatment , abs(prov) rob 
			
			* And store them in a matrix (with a space before or after the cell)
			mat ri_pvalues = nullmat(ri_pvalues) \ r(p)
			mat ri_pvalues = nullmat(ri_pvalues) \ .
		}

		// Association Baseline Survey
		// ---------------------------
		#d	;
		
			iebaltab `assocVars' `bl_hhVars' `el_hhVars'
				,
			    vce(robust) grpvar(treatment) fixedeffect(prov)
				grplabels(1 Treatment @ 0 Control)
				pttest starsnoadd
				rowvarlabels
				tblnonote
				browse replace
			;
		#d	cr
	
		* Drop title rows
		drop in   1/3
		
		* Replace parentheses for standard errors
		replace   v3 = subinstr(v3,"[","(",.)
		replace   v5 = subinstr(v5,"[","(",.)
		replace   v3 = subinstr(v3,"]",")",.)
		replace   v5 = subinstr(v5,"]",")",.)
		
		* Retrieve RI p-values from matrix
		svmat 	 ri_pvalues
		
		* Generate p-values string to match `baltab` formatting
		gen		 v7 = string(ri_pvalues1, "%9.3f")
		drop				 ri_pvalues1
		replace  v7  = ""	 ///
			  if v7 == "."
			  
		* Start counter
		local 	 assoc_fileNum = 0
		
		* Save preliminary LaTeX file containing results
		dataout, save("${out_tab}/assoc_balance_`assoc_fileNum'.tex") 			///
				 replace tex nohead noauto
				
	restore
	
	* Do the same for variables from the household baseline survey
	areg treatment 	  `bl_hhVars', abs(prov) cl(associd)
	//now we cluster standard errors at the association level
	
	scalar reg_F 	= `e(F)'
	scalar reg_F_N 	= `e(N)'

	testparm 		  `bl_hhVars'
	scalar test_F 	= `r(F)'
	scalar test_F_p = `r(p)'
	
	test			  `bl_hhVars', mtest(bonferroni)
	
	preserve
	
		cap mat drop ri_pvalues
		
		foreach var of local bl_hhVars {
			
			ritest treatment _b[treatment]	         			  	, 			///
			reps(${repsNum}) seed(${seedsNum}) strata(prov) nodots  : 			///
			areg `var' treatment , abs(prov) cl(associd)
			
			mat ri_pvalues = nullmat(ri_pvalues) \ r(p)
			mat ri_pvalues = nullmat(ri_pvalues) \ .
		}

		#d	;
		
			// Household Baseline Survey
			// -------------------------
			iebaltab `bl_hhVars'
				,
				vce(cluster associd) grpvar(treatment) fixedeffect(prov)
				grplabels(1 Treatment @ 0 Control)
				pttest starsnoadd
				rowvarlabels
				tblnonote
				browse replace
			;
		#d	cr
		
		drop in  1/3
		
		replace  v3 = subinstr(v3,"[","(",.)
		replace  v5 = subinstr(v5,"[","(",.)
		replace  v3 = subinstr(v3,"]",")",.)
		replace  v5 = subinstr(v5,"]",")",.)
		
		svmat 	 ri_pvalues
		
		gen		 v7 = string(ri_pvalues1, "%9.3f")
		drop				 ri_pvalues1
		replace  v7  = ""	 ///
			  if v7 == "."
				
		local 	 bl_hh_fileNum = 0
		
		dataout, save("${out_tab}/bl_hh_balance_`bl_hh_fileNum'.tex") 			///
				 replace tex nohead noauto
	
	restore
	
	
	areg treatment 	  `el_hhVars' [pw=pweight] , abs(prov) cl(associd)

	scalar reg_F 	= `e(F)'
	scalar reg_F_N 	= `e(N)'

	testparm 		  `el_hhVars'
	scalar test_F 	= `r(F)'
	scalar test_F_p = `r(p)'
	
	test			  `el_hhVars'			   , mtest(bonferroni)
	
	preserve
	
		cap mat drop ri_pvalues
		
		foreach var of local el_hhVars {
			
			ritest treatment _b[treatment]	         			   		 , 		///
			reps(${repsNum}) seed(${seedsNum}) strata(prov) nodots force : 		///[ritest] does not allow weights unless force is used
			areg `var' treatment [pw=pweight],    abs(prov) cl(associd)
			
			mat ri_pvalues = nullmat(ri_pvalues) \ r(p)
			mat ri_pvalues = nullmat(ri_pvalues) \ .
		}

		#d	;
		
			// Household Endline Survey
			// ------------------------
			iebaltab `el_hhVars' [pw=pweight]
				,
			    vce(cluster associd) grpvar(treatment) fixedeffect(prov)
				grplabels(1 Treatment @ 0 Control)
				pttest starsnoadd
				rowvarlabels
				tblnonote
				browse replace
			;
		#d	cr
		
		drop in   1/3
		
		replace  v3 = subinstr(v3,"[","(",.)
		replace  v5 = subinstr(v5,"[","(",.)
		replace  v3 = subinstr(v3,"]",")",.)
		replace  v5 = subinstr(v5,"]",")",.)
		
		svmat 	 ri_pvalues
		
		gen		 v7 = string(ri_pvalues1, "%9.3f")
		drop				 ri_pvalues1
		replace  v7  = ""	 ///
			  if v7 == "."
				
		local 	 el_hh_fileNum = 0
		
		dataout, save("${out_tab}/el_hh_balance_`el_hh_fileNum'.tex") 			///
				 replace tex nohead noauto
	
	restore

* ---------------------------------------------------------------------------- *
*							Format and export table				   		   	   *
* ---------------------------------------------------------------------------- *
	
	cap  file close _all
	
	foreach level in assoc bl_hh el_hh {
		
		* Remove lines from `dataout` export
		foreach lineToRemove in "\BSdocumentclass[]{article}"					///
								"\BSsetlength{\BSpdfpagewidth}{8.5in}" 			///
								"\BSsetlength{\BSpdfpageheight}{11in}"  		///
								"\BSbegin{document}" 							///
								"\BSbegin{tabular}{lcccccc}"					///
								"Variable"										///
								"\BShline"										///
								"\BSend{tabular}"								///
								"\BSend{document}" 								{
		
			filefilter "${out_tab}/`level'_balance_``level'_fileNum'.tex"		/// 
					   "${out_tab}/`level'_balance_`=``level'_fileNum'+1'.tex"	///
					   , from("`lineToRemove'") to("") replace
			erase	   "${out_tab}/`level'_balance_``level'_fileNum'.tex"
		
			local `level'_fileNum = ``level'_fileNum' + 1
		}
		
		* Add incipit and end of LaTeX table
		*(to be directly input in TeX document) without further formatting
		file open  `level'File													///
			 using "${out_tab}/`level'_balance_``level'_fileNum'.tex"			///
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
	file  open finalFile using "${out_tab}/tabA03-baltab.tex"	///
		, text write replace
		
	#d	;
	
		file write finalFile
			"\\[-1.8ex]\hline \hline \\[-1.8ex]"
			"& \multicolumn{2}{c}{(1)}	   & \multicolumn{2}{c}{(2)}  	   & (1)-(2) & Randomization \\							 " _n
			"& \multicolumn{2}{c}{Control} & \multicolumn{2}{c}{Treatment} & T-test  & Inference  	 \\							 " _n
			"Variable & N/[Clusters] & Mean/SE  & N/[Clusters] & Mean/SE   & P-value & P-value		 \\ 	   \hline \\[-1.8ex] " _n
			
			"\multicolumn{7}{c}{\textbf{Panel A -- Association Level}} 					      		 \\[0.5ex] \hline 		  	 " _n
			"`assocFile' 																			    	   \hline \\[-1.8ex] " _n
			
			"\multicolumn{7}{c}{\textbf{Panel B -- Household Level at Baseline}} 	 			     \\[0.5ex] \hline 	 		 " _n
			"`bl_hhFile' 																					   \hline \\[-1.8ex] " _n
			
			"\multicolumn{7}{c}{\textbf{Panel C -- Household Level at Endline}} 	 			     \\[0.5ex] \hline 	 		 " _n
			"`el_hhFile'																					   \hline	 	     " _n
			"																				     	   		   \hline \\[-1.8ex] " _n
		;
	#d	cr
	
	file close finalFile

	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tabA03-baltab.tex":${out_tab}/tabA03-baltab.tex}"'

	
***************************** End of do-file ***********************************
