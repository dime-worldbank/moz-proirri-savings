
/*******************************************************************************
*																 			   *
* 				"Transforming Agriculture through Savings:					   *
*	 			  Experimental Evidence from Mozambique			   		       *
*																			   *
*							Experimental sample								   *
*																 			   *
********************************************************************************
	
		WRITTEN BY:  	Matteo Ruzzante [mruzzante@worldbank.org]
		
		REQUIRES:   	"${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta"
						
		CREATES:	   	Table 2: Sample
						"${out_tab}/tab02-sample.tex"
												
* ---------------------------------------------------------------------------- *
*							Count observations 				   		   		   *
* ---------------------------------------------------------------------------- */

	* Load clean data
	use		 "${dt_fin}/PROIRRI Financial Literacy - Savings paper data.dta", clear
		
	* Count number of associations per treatment arm...
	distinct associd    if treatment == 1
	scalar 	 t_assoc     = r(ndistinct)
	distinct associd 	if treatment == 0
	scalar 	 c_assoc     = r(ndistinct)

	*... and in total
	scalar   total_assoc = t_assoc + c_assoc
		
	* Count number of households in the box pick-up data
	count if treatment  == 1
	scalar 	 t_box 		 = r(N)
	count if treatment  == 0
	scalar 	 c_box 		 = r(N)
	scalar   total_box   = t_box + c_box
	
	* Count number of households in the endline survey
	count if treatment == 1 & data_endline == 1
	scalar 	 t_el 		= r(N)
	count if treatment == 0 & data_endline == 1
	scalar 	 c_el 	  	= r(N)
	scalar   total_el	= t_el + c_el
	
* ---------------------------------------------------------------------------- *
*							Format and export table			   		   		   *
* ---------------------------------------------------------------------------- *

	* Create single LaTex table with two panels (associations and households)
	cap file close sample
		file open  sample using "${out_tab}/tab02-sample.tex", write replace
		
	#d	;
		file write sample
			"\begin{adjustbox}{max width=\textwidth}"								 					  _n
				"\begin{tabular}{lccc} \hline \hline"  				  		  		 					  _n
				
					"								  & Treatment   &   Control   &   Total 		 \\ " _n
					"			  					  \cmidrule(lr){2-3}          \cmidrule(lr){4-4}    " _n
					
					"\textbf{Associations} 			  &" (t_assoc) "&" (c_assoc) "&" (total_assoc) " \\ " _n
					"\\[-0.5em] " 																		  _n
					
					"\textbf{Households}  			 											     \\ " _n
					"\hspace{2em} Box pick-up data 	  &" (t_box)   "&" (c_box)   "&" (total_box)   " \\ " _n 
					"\hspace{2em} Endline survey data &" (t_el)    "&" (c_el)    "&" (total_el)    " \\ " _n 
					
				"\hline \hline \end{tabular}"										 					  _n
			"\end{adjustbox}"														 					  _n
		;
	#d	cr
	
	file close sample

	* Add link to the file ([filefilter] does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out_tab}/tab02-sample.tex":${out_tab}/tab02-sample.tex}"'

	
******************************** End of do-file ********************************	
