*dbtb // debt at beginning of yeaar
*dbte // debt at end of year
*onbalb  // Other net balances beginning of year
*opprft // Other net balances end of year
*cheb // cash and cash equivalent - beginning of year
*chee // cash and cash equivalent - end of year
*fyear // Current year
*emp // nEmployees (thousands)
*naicsh // industry

encode gvkey, gen(idnum)
encode city, gen(citynum)
drop city

keep dbtb dbte onbalb opprft cheb chee fyear emp naicsh city idnum
gen naics5d = int(naicsh/10) if naicsh > 99999
gen naics4d = int(naics5d/10) if naics5d > 9999
gen naics3d = int(naics4d/10) if naics4d > 999 
replace emp = emp*1000

* Keep manufacturing firms only
keep if naics3d > 300 & naics3d < 400
drop naics4d naics5d naicsh

* Set panel
duplicates drop idnum fyear, force
xtset idnum fyear

* Rename variables
rename dbtb debt_open
rename dbte debt_close
rename onbalb netbalance_open
rename opprft netbalance_close
rename cheb cash_open
rename chee cash_close

* Reshape to wide
reshape wide cash_open cash_close debt_open debt_close emp netbalance_open netbalance_close city naics3d, i(idnum) j(fyear)
