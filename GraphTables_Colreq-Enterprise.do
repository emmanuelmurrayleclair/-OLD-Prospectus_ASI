preserve
	*---------------------------
	* Set collateral constraint
	*---------------------------

	*First measure: implied by collateral requirement and debt level of firm
	gen colreq = k15a/k11 if (k15a > 0) & (k11 > 0) & (k13 == 1) // collateral requirement over loan amount
	gen colcons_implied = (n6a+n6b) - (colreq*k15c) if  (k15c > 0) & (n6a > 0) & (n6b > 0) // Total fixed assets minus (collateral requirement times total debt outstanding)
	su colcons_implied, detail
	gen colcons_implied_perc = 0 if colcons_implied <= r(p50) & (colcons_implied != .)
	replace colcons_implied_perc = 1 if (colcons_implied >= r(p50)) & (colcons_implied != .)
	*Second measaure: directly asked the firm
	gen colcons_direct = 1 if k17 == 4 // Firm explicitely said didn't apply for loan because collateral requirements were too high 
	replace colcons_direct = 0 if k17 == 1 // Firm explicitely said they are not financially constrained

	*----------------------
	* Outcomes of interest
	*----------------------
	
	* Labor share
	gen total_cost = n2a + n2e + n2f + n2b + n2ra + n2rb + n2j
	gen labor_cost = n2a
	gen labor_share = labor_cost/total_cost

	* Proportion of skilled and unskilled labor
	gen l_s = l4a/(l4a+l4b) if (l4a > 0) & (l4b > 0)
	gen l_us = l4b/(l4a+l4b) if (l4a > 0) & (l4b > 0)
	lab var l_s "proportion of skilled labor"
	lab var l_us "proportion of unskilled labor"

	* Average number of years of education for workers
	gen educ = l9a
	lab var educ "Average years of education"

	* Formal training programs (all skill levels)
	gen training = l10 // towards permanent, full-time workers
	lab var training "Firm has formal training program"

	* Formal training programs (proportion towards skilled labor)
	gen s_training_prop = SARl11a/(SARl11b + SARl11a) if (SARl11b > 0) & (SARl11a > 0)
	gen us_training_prop = 1-s_training_prop
	lab var s_training_prop "proportion of formal training towards skilled labor"
	lab var us_training_prop "proportion of formal training towards unskilled labor"

	*----------------------
	* Create graphs/tables
	*----------------------
	// 1) direct measure of collateral constraint 
	sort colcons_direct
	* Average years of education
	eststo clear
	by colcons_direct: eststo: estpost su educ
	esttab using Output/Tables/Colcons_Educ_EnterpriseSurvey.tex, cells("mean") label replace booktabs ///
		nonumber mtitles("Unconstrained" "constrained") ///
		title(Collateral constraint and education of workers)
	* Formal training (all skill level)
	eststo clear
	by colcons_direct: eststo: estpost su training
	esttab using Output/Tables/Colcons_Training_EnterpriseSurvey.tex, cells("mean") label replace booktabs ///
		nonumber mtitles("Unconstrained" "constrained") ///
		title(Collateral constraint and training)
	* Formal training (skilled labor)
	eststo clear
	by colcons_direct: eststo: estpost su s_training_prop
	esttab using Output/Tables/Colcons_sTraining_EnterpriseSurvey.tex, cells("mean") label replace booktabs ///
		nonumber mtitles("Unconstrained" "constrained") ///
		title(Collateral constraint and proportion of training towards skilled labor)
	* Labor share
	eststo clear
	by colcons_direct: eststo: estpost su labor_share
		esttab using Output/Tables/Colcons_LaborShare_EnterpriseSurvey.tex, cells("mean") label replace booktabs ///
		nonumber mtitles("Unconstrained" "constrained") ///
		title(Collateral constraint and labor share)
restore
