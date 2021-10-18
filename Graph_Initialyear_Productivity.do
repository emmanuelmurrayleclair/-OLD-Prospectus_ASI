preserve

	*Keep relevant variables for the graph
	keep yr dsl b6 e6_10 j*_12 
	*keep if e1 == 10 // Total for number of employees
	*keep if j1 == 12 // Total for products sold

	*Drop 0 observations
	drop if (e6_10 == 0) | (e6_10==.)  // No workers
	drop if (j7_12 == 0) | (j7_12 == .) // No sales

	gen SalesPerWorker = j7_12/e6_10

	tempfile short long
	save `short'
	drop if b6 < 1935 | b6 > 1960
	egen avgSalesPerWorker = mean(SalesPerWorker), by(b6)
	sort b6
	graph twoway (connected avgSalesPerWorker b6), xline(1947, lcolor(blue) lpattern(dot)) xtitle("Year of creation") ytitle("Sales per employees") xlabel(1935[3]1960) graphregion(color(white))
	graph export Output/Graphs/Initialyear_SalesPerWorker_short.pdf, replace
	save `long'
	use `short'
	drop if b6 < 1887 | b6 > 2017
	egen avgSalesPerWorker = mean(SalesPerWorker), by(b6)
	sort b6
	graph twoway (connected avgSalesPerWorker b6), xline(1947, lcolor(blue) lpattern(dot)) xtitle("Year of creation") ytitle("Sales per employees") xlabel(1887[10]2017) graphregion(color(white))
	graph export Output/Graphs/Initialyear_SalesPerWorker_long.pdf, replace

restore

* With confidence intervals
/*
mat coefs = J(24,4,.)
reg SalesPerWorker i.b6, robust
forvalues i = 1936/1960 {
	local j = `i'-1935
	mat coefs[`j',1] = _b[`i'.b6]
	mat coefs[`j',2] = _b[`i'.b6] -(1.96*_se[`i'.b6])
	mat coefs[`j',3] = _b[`i'.b6] +(1.96*_se[`i'.b6])
	mat coefs[`j',4] = `i'
}
svmat coefs
graph twoway (connected coefs1 coefs4) (rcap coefs2 coefs3 coefs4), xline(1947, lcolor(blue) lpattern(dot)) xtitle("Year of creation") ytitle("Sales per employees") xlabel(1935[3]1960)
*/
	