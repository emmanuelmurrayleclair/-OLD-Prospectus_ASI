
foreach var of varlist * {
	replace `var' = 0 if missing(`var')
}

egen id = group(first_yr state yr ind3d LongTermDebt OutstandingLoans PollutionControl ShortTermDebt TotFixedAsset_Gross TotFuels TotInventory TotWorkingCapital TotalLiabilities)
sort id 

foreach var of varlist LongTermDebt OutstandingLoans PollutionControl ShortTermDebt TotFixedAsset_Gross TotFuels TotInventory TotWorkingCapital TotalLiabilities {
	su `var', detail
	replace `var' = (`var'/r(p99))*100
	su `var', detail 
}

local varnames LongTermDebt OutstandingLoans ShortTermDebt TotFuels TotInventory TotWorkingCapital TotalLiabilities
foreach var of local varnames {
	gen `var'_diff = (`var'_Open-`var'_Close)*100/(`var'_Close+`var'_Open) 
}

egen avg_diff = rowmean(LongTermDebt_diff OutstandingLoans_diff ShortTermDebt_diff TotFuels_diff TotInventory_diff TotWorkingCapital_diff TotalLiabilities_diff)

***************** Example 1 of matching plants between two years ************************
use "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data\Panel_Identifier\2002_open.dta", clear
*1. join observation between two years based on time-invariant variables (create a set of potential matches for each firm)
joinby state urb ind2d using "Data/Panel_Identifier\2001_close.dta"
sort dsl // (for each dsl there is a least one match )
*2. Create a dummy var that takes 1 if the open variable is within (+/-) 5% of the close variable in the previous year
local vars LongTermDebt OutstandingLoans PollutionControl_Gross PollutionControl_Net ShortTermDebt TotFixedAsset_Gross TotFixedAsset_Net TotFuels TotInventory TotWorkingCapital TotalLiabilities
foreach v of local vars {
	gen `v' = 1 if `v'_Close <= (0.05*`v'_Open+`v'_Open) & `v'_Close >= (`v'_Open-0.05*`v'_Open)
	replace `v' = 0 if `v'_Close > (0.05*`v'_Open+`v'_Open) | `v'_Close < (`v'_Open-0.05*`v'_Open)
	replace `v' = . if `v'_Close ==. | `v'_Open ==.
}
*3. Compute average match quality
egen avgmatch_dummy = rowmean(LongTermDebt OutstandingLoans PollutionControl_Gross PollutionControl_Net ShortTermDebt TotFixedAsset_Gross TotFixedAsset_Net TotFuels TotInventory TotWorkingCapital TotalLiabilities)
keep if avgmatch_dummy > 0
*4. Rank matches by absolute difference in number of workers (Managers and non-Managers)
gen nEmployee_diff = abs(nEmployees_Managers_2002-nEmployees_Managers_2001) + abs(nEmployees_NonManagers_2002-nEmployees_NonManagers_2001)
drop LongTermDebt OutstandingLoans PollutionControl_Gross PollutionControl_Net ShortTermDebt TotFixedAsset_Gross TotFixedAsset_Net TotFuels TotInventory TotWorkingCapital TotalLiabilities


************** Example 2 of matching plants between two years **************************
use "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data\Panel_Identifier\2002_open.dta", clear
*1. join observation between two years based on time-invariant variables (create a set of potential matches for each firm)
joinby state urb ind2d using "Data/Panel_Identifier\2001_close.dta"
sort dsl // (for each dsl there is a least one match )
*2. Create percentage difference between closing and opening value of each variable
local vars LongTermDebt OutstandingLoans PollutionControl_Gross PollutionControl_Net ShortTermDebt TotFixedAsset_Gross TotFixedAsset_Net TotFuels TotInventory TotWorkingCapital TotalLiabilities
foreach v of local vars {
	gen `v'_diff = (`v'_Open-`v'_Close)/(`v'_Open+`v'_Close)*100
	replace `v'_diff = . if `v'_Open == . | `v'_Close == .
}
*3. Compute average of percentage difference
egen avgdiff = rowmean(nEmployee_diff LongTermDebt_diff OutstandingLoans_diff PollutionControl_Gross_diff PollutionControl_Net_diff ShortTermDebt_diff TotFixedAsset_Gross_diff TotFixedAsset_Net_diff TotFuels_diff TotInventory_diff TotWorkingCapital_diff TotalLiabilities_diff)
*4. Keep matches that have less than (+/-) 10% average difference
replace avgdiff = abs(avgdiff)
keep if avgdiff <= 10
*4. Rank matches by absolute difference in number of workers (Managers and non-Managers)
gen nEmployee_diff = abs(nEmployees_Managers_2002-nEmployees_Managers_2001) + abs(nEmployees_NonManagers_2002-nEmployees_NonManagers_2001)
drop if nEmployee_diff == .
drop LongTermDebt_diff OutstandingLoans_diff PollutionControl_Gross_diff PollutionControl_Net_diff ShortTermDebt_diff TotFixedAsset_Gross_diff TotFixedAsset_Net_diff TotFuels_diff TotInventory_diff TotWorkingCapital_diff TotalLiabilities_diff


***************** Example 3 of matching plants between two years ************************
use "Data\Panel_Identifier\2003_open.dta", clear
*1. join observation between two years based on time-invariant variables (create a set of potential matches for each firm)
joinby state urb ind1d using "Data/Panel_Identifier\2002_close.dta"
sort dsl // (for each dsl there is a least one match )
*2. Create a dummy var that takes 1 if the open variable is within (+/-) 0.5% of the close variable in the previous year
local vars TotCurAsset TotFixedAsset_Gross TotalLiabilities TotInventory 
foreach v of local vars {
	drop if (`v'_Close ==. & `v'_Open !=.) | (`v'_Open ==. & `v'_Close !=.)
	gen `v' = 1 if `v'_Close <= (0.005*`v'_Open+`v'_Open) & `v'_Close >= (`v'_Open-0.005*`v'_Open)
	replace `v' = 0 if `v'_Close > (0.005*`v'_Open+`v'_Open) | `v'_Close < (`v'_Open-0.005*`v'_Open) | (`v'_Close ==. & `v'_Open ==.)
}
*3. Compute match average across variables and keep non-zero matches
egen avgmatch_dummy = rowmean(TotFixedAsset_Gross TotWorkingCapital TotalLiabilities)
*replace avgmatch_dummy = . if TotFixedAsset_Gross ==. | TotWorkingCapital ==. | TotalLiabilities ==.
keep if avgmatch_dummy > 0 & avgmatch_dummy != .
*5. Define match quality (percentage difference in number of workers and opening/closing values)
gen nEmployees_2003 = nEmployees_Managers_2003+nEmployees_NonManagers_2003
gen nEmployees_2002 = nEmployees_Managers_2002+nEmployees_NonManagers_2002
gen nEmployees_Managers_diff = nEmployees_Managers_2003-nEmployees_Managers_2002
gen nEmployees_NonManagers_diff = nEmployees_NonManagers_2003-nEmployees_NonManagers_2002
gen nEmployees_diff = nEmployees_2003-nEmployees_2002
gen nEmployees_Managers_diffavg = (nEmployees_Managers_2003+nEmployees_Managers_2002)/2
gen nEmployees_NonManagers_diffavg = (nEmployees_NonManagers_2003+nEmployees_NonManagers_2002)/2
gen nEmployees_diffavg = (nEmployees_2003+nEmployees_2002)/2
gen nEmployees_Managers_percdiff = abs(100*(nEmployees_Managers_diff/nEmployees_Managers_diffavg))
gen nEmployees_NonManagers_percdiff = abs(100*(nEmployees_NonManagers_diff/nEmployees_NonManagers_diffavg))
gen nEmployees_percdiff = abs(100*(nEmployees_diff/nEmployees_diffavg))

local vars TotFixedAsset_Gross TotWorkingCapital TotalLiabilities
foreach v of local vars {
	gen `v'_diff = `v'_Open-`v'_Close
	gen `v'_avgdiff = (`v'_Open+`v'_Close)/2
	gen `v'_percdiff = abs(100*(`v'_diff/`v'_avgdiff))
	*replace `v'_diff = . if `v'_Open == . | `v'_Close == .
}
egen avgdiff = rowmean(TotFixedAsset_Gross_percdiff TotWorkingCapital_percdiff TotalLiabilities_percdiff)
drop if nEmployees_Managers_percdiff == .
drop if nEmployees_NonManagers_percdiff == .
*5. Measure of overall difference
gen nEmployees_totdiff = (nEmployees_Managers_percdiff + nEmployees_NonManagers_percdiff)/2
gen totdiff = (avgdiff + nEmployees_totdiff)/2
keep if totdiff < 30
bysort dsl: egen mindiff = min(totdiff)
*6. Keep the smallest difference for each plant
keep if totdiff == mindiff



local vars Land_Gross Land_Net Bldg_Gross Bldg_Net
foreach v of local vars {
	drop if (`v'_Close ==. & `v'_Open !=.) | (`v'_Open ==. & `v'_Close !=.)
	gen `v' = 1 if `v'_Close <= (0.005*`v'_Open+`v'_Open) & `v'_Close >= (`v'_Open-0.005*`v'_Open)
	replace `v' = 0 if `v'_Close > (0.005*`v'_Open+`v'_Open) | `v'_Close < (`v'_Open-0.005*`v'_Open) | (`v'_Close ==. & `v'_Open ==.)
}
egen avgmatch_dummy = rowmean(Land_Gross Land_Net Bldg_Gross Bldg_Net)


gen Land = 1 if Land_Net_Close <= (0.005*Land_Gross_Open+Land_Gross_Open) & Land_Net_Close >= (Land_Gross_Open-0.005*Land_Gross_Open)
replace Land = 0 if Land_Net_Close > (0.005*Land_Gross_Open+Land_Gross_Open) | Land_Net_Close < (Land_Gross_Open-0.005*Land_Gross_Open) | (Land_Net_Close ==. & Land_Gross_Open ==.)





