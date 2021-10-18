preserve
	keep yr dsl awgt a5 a7 a16 f10 c12_10 c13_10 d3_12 d4_12 d3_15 d3_4 d4_15 d3_7 d4_7 d3_11 d4_11 e6_10 e8_10 e6_7 e8_7 e6_6 e6_6 j*_12 k1 k2 colreq

	*----------------------------------------------------------
	* Define how constrained the firm might be (measure of debt capacity)
	*----------------------------------------------------------
	
	* Total fixed assets/capital (opening)
	rename c12_10 k
	drop if k < 0
	* Total inventory (opening)
	rename d3_7 inv
	drop if inv < 0
	* Total assets that can be used as collateral (capital + inventory)
	gen tot_asset = k + inv
	* Debt (opening)
	rename d3_12 debt
	drop if debt < 0
	* inverse leverage (asset over debt)
	gen inv_leverage = tot_asset/debt
	su inv_leverage, detail
	drop if inv_leverage > r(p99) // drop outliers
	* fraction of capital that can be used as collateral
	replace colreq = colreq/100
	gen theta = 1/colreq
	* Debt capacity (proxy of firm's collateral constraint)
	gen debt_cap = theta*tot_asset-debt
	//gen debt_cap = tot_asset-debt
	
	* Define a dummy variable for firms that are in the bottom 25% and top 75% percentile of their debt capacity
	su debt_cap, detail
	gen debt_cap_perc = 0 if debt_cap >= r(p75) // least constrained firms
	replace debt_cap_perc = 1 if debt_cap <= r(p25) // most constrained firms
	sort debt_cap_perc
	*-----------------------------------------------------------
	* Relationshp between collateral constraint and labor share
	*-----------------------------------------------------------
	eststo clear
	* Labor cost
	gen labor_cost = e8_10
	* Total input cost
	gen input_cost = labor_cost + k
	* Labor share
	gen labor_share = labor_cost/input_cost
	lab var labor_share "Labor Share"
	* Create table
	by debt_cap_perc: eststo: estpost su labor_share
		esttab using Output/Tables/Colcons_LaborShare_ASI.tex, cells("mean") label replace booktabs ///
		nonumber mtitles("Least constrained" "Most constrained") ///
		title(Collateral constraint and labor share)
	
	*---------------------------------------------------------------------------------------------
	* Relationshp between collateral constraint and proportion of skilled labor (managerial staff)
	*---------------------------------------------------------------------------------------------
	eststo clear
	*Proportion of "skilled" labor
	gen ls_prop = e6_7/e6_10
	lab var ls_prop "Proportion of skilled workers"
	* Create table
	by debt_cap_perc: eststo: estpost su ls_prop
		esttab using Output/Tables/Colcons_sLaborProp_ASI.tex, cells("mean") label replace booktabs ///
		nonumber mtitles("Least constrained" "Most constrained") ///
		title(Collateral constraint and proportion of "skilled" labor)
	
	*------------------------------------------------------------------------------------------------
	* Relationshp between collateral constraint and sales per worker (proxy for labor productivity)
	*------------------------------------------------------------------------------------------------
	eststo clear
	gen Sales = j7_12
	replace Sales = Sales/1000
	gen nWorkers = e6_10
	gen SalesPerWorker = Sales/nWorkers
	lab var SalesPerWorker "Sales per worker (thousand rupees)"
	* Create table
	by debt_cap_perc: eststo: estpost su SalesPerWorker
		esttab using Output/Tables/Colcons_SalesPerWorker_ASI.tex, cells("mean") label replace booktabs ///
		nonumber mtitles("Least constrained" "Most constrained") ///
		title(Collateral constraint and sales per worker)
	
	
	/*
	*---------------------------------------------------------------------------
	* Relationshp between collateral requirement and data of high court creation
	*---------------------------------------------------------------------------
	eststo clear
	rename k2 CourtHist
	lab var colreq "Collateral requirement"
	
	* Create graph
	graph twoway (lfit colreq CourtHist) (scatter colreq CourtHist), xtitle("Date of High Court creation") ytitle("Collateral requirement (percentage)") ///
	graphregion(color(white)) legend(off)
	graph export Output/Graphs/CourtHist_Colreq.pdf, replace
	
	* Create table
	eststo: reg colreq CourtHist, robust
	esttab using Output/Tables/CourtHist_Colreq.tex, label replace booktabs ///
	nonumbers mtitles("First Stage") ///
	title(First stage of Court History on collateral requirement)
	
	
	*-------------------------------------------------------------
	* Relationshp between collateral requirement and labor share
	*-------------------------------------------------------------
	eststo clear
	* Labor cost
	gen labor_cost = e8_10
	* Total input cost
	gen input_cost = labor_cost + k
	* Labor share
	gen labor_share = labor_cost/input_cost
	lab var labor_share "Labor Share"
	*OLS
	eststo: reg labor_cost colreq i.a5, robust
	*IV
	eststo: xi: ivreg labor_cost i.a5 (colreq = CourtHist), robust
	* Create table
	esttab using Output/Tables/ColReq_LaborShare.tex, label replace booktabs noconstant ///
	nonumbers mtitles("OLS" "IV") ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	indicate(industry dummies = _Ia5*) ///
	title(Effect of collateral requirement on labor share)
	
	*---------------------------------------------------------------------------------------
	* Relationshp between collateral requirement and labor productivity (revenue per worker)
	*---------------------------------------------------------------------------------------
	eststo clear
	gen Sales = j7_12
	gen nWorkers = e6_10
	gen SalesPerWorker = Sales/nWorkers
	lab var SalesPerWorker "Sales per worker"
	*OLS
	eststo: reg SalesPerWorker colreq i.a5, robust
	*IV
	eststo: xi: ivreg SalesPerWorker i.a5 (colreq = CourtHist), robust
	* Create table
	esttab using Output/Tables/ColReq_LaborProd.tex, label replace booktabs noconstant ///
	nonumbers mtitles("OLS" "IV") ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	indicate(industry dummies = _Ia5*) ///
	title(Effect of collateral requirement on productivity of labor)
	
	*------------------------------------------------------
	* Relationshp between collateral requirement and wages
	*------------------------------------------------------
	eststo clear
	gen Wages = labor_cost/nWorkers
	lab var Wages "Wages"
	*OLS
	eststo: reg Wages colreq i.a5, robust
	*IV
	eststo: xi: ivreg Wages i.a5 (colreq = CourtHist), robust
	* Create table
	esttab using Output/Tables/ColReq_Wages.tex, label replace booktabs noconstant ///
	nonumbers mtitles("OLS" "IV") ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	indicate(industry dummies = _Ia5*) ///
	title(Effect of collateral requirement on wages)
*/
	/*
	*-----------------------------------------------------------------
	* Relationship between imperfect contract enforcement and leverage
	*-----------------------------------------------------------------

	* Total fixed assets (opening)
	rename c12_10 cap_open
	* Total libabilities (opening and change - measure of loan take-up)
	rename d4_15 debt_close
	* Ratio of debt to capital (opening and change)
	gen leverage = debt_close/cap_open 
	drop if leverage > 100
	drop if leverage < 0
	drop if leverage == .
	
	* Regressions
	reg leverage i.ind4d k1, robust
	reg leverage i.ind4d k2, robust
	
	* Create scatter plot
	egen avgLeveragePerState = mean(leverage), by(a7)
	egen medLeveragePerState = median(leverage), by(a7)
	
	scatter medLeveragePerState k2, msymbol(circle_hollow)


	*--------------------------------------------------------
	* Effect of imperfect contract enforcement on labor share
	*--------------------------------------------------------
	* Raw materials, fuels, and other intermediates
	gen intermediate = d3_4
	* Total labor cost (in wages/salaries)
	gen labor_cost = e8_10
	* Number of employees
	gen workers = e6_10
	* Total input spending
	gen total_input = cap_open + labor_cost // + intermediate
	* Labor share
	gen labor_share = labor_cost/total_input
	* Sales per worker (idea about labor productivity) 
	gen SalesPerWorker = j7_12/workers
	
	* Regressiosn
	reg labor_share k1, robust
	reg labor_share k2, robust
	ivreg labor_share (k1=k2), robust

	reg SalesPerWorker k1, robust
	reg SalesPerWorker k2, robust
	ivreg SalesPerWorker (k1=k2), robust

	*----------------------------------------
	* Effect of court speed on GHG emissions
	*----------------------------------------
	*/
	
restore