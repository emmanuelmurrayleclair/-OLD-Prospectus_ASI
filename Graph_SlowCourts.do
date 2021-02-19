preserve

keep yr dsl f10 c1 c12 d1 d3 d4 e1 e6 j* k1 k2
keep if d1 == 15 // Total current liabilities
keep if c1 == 10 // Total capital
keep if e1 == 10 // All workers
keep if j1 == 12 // Total of product sold

*Remove duplicates
sort dsl
by dsl: gen dup = cond(_N==1,0,_n)
drop if dup > 1

*--------------------------------------------
* Effect of court speed on debt/interest rate
*--------------------------------------------

* Total fixed assets (opening)

* Total libabilities (opening and change - merasure of loan take-up)

* Ratio of debt to capital (opening and change)

* Implied interest rate

*--------------------------------------------
* Effect of court speed on labor productivity
*--------------------------------------------
gen SalesPerWorker = j7/e6


*----------------------------------------
* Effect of court speed on GHG emissions
*----------------------------------------



restore