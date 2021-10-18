********************************************************************
*** Analysis for Cement, Steel and Iron, Paper, Glass, Aluminium ***
********************************************************************

set scheme burd

*keep if ind4d == 2394 | ind4d == 2410 | ind4d == 1701 | ind5d ==  24202 | ind5d == 23101
keep if ind4d == 2394 | ind4d == 2410 | ind4d == 1701 | ind4d ==  2420 //| ind4d == 2310
* Keep only consecutive observations
egen max_gap = max(yr - yr[_n-1]), by(plant_id)
keep if max_gap == 1
* Partially balance the panel
drop nyear
egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
drop if nyear < 4
*drop if nyear < 9
drop nyear
sort plant_id yr
xtset plant_id yr
*gen ind = ind4d if ind4d == 2394 | ind4d == 2410 | ind4d == 1701
*replace ind = ind5d if ind5d == 24202 | ind5d == 23101

***********************************
*** Analysis for all industries ***
***********************************

/*
* drop power plants and remove outliers
su SalesGross_tot, detail
keep if SalesGross_tot > r(p1) & SalesGross_tot < r(p99)
drop if ind3d == 351
* Keep only consecutive observations
egen max_gap = max(yr - yr[_n-1]), by(plant_id)
keep if max_gap == 1
* Partially balance the panel
drop nyear
egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
drop if nyear < 4
*su nyear
*keep if nyear == `r(max)'
drop nyear
sort plant_id yr
xtset plant_id yr
*/


/*
*** More cleaning ***
* Match change in age
by plant_id: gen agediff = age[_n]-age[_n-1]
replace agediff = 1 if agediff == .
replace agediff = . if agediff != 1
egen sum_agediff = total(agediff), by(plant_id)
su sum_agediff
keep if sum_agediff == `r(max)'
xtset plant_id yr
*/

*-------------------------
* Defining fuel switching
*-------------------------

* Define 4 switching categories (every case includes variation at the extensive margin)
/*
1. Single fuel other single fuel
2. Single fuel to mixing
3. Mixing to single
4. Mixing to mixing (new mix)
*/

/*
gen fuelswitch = 0
by plant_id: replace fuelswitch = 1 if (L.fuelmix100 == 0 & fuelmix100 == 0 & coal_s > 0 & L.coal_s == 0) ///
| (L.fuelmix100 == 0 & fuelmix100 == 0 & oil_s > 0 & L.oil_s == 0) ///
| (L.fuelmix100 == 0 & fuelmix100 == 0 & natgas_s > 0 & L.natgas_s == 0)
by plant_id: replace fuelswitch = 2 if L.fuelmix100 == 0 & fuelmix95 == 1
by plant_id: replace fuelswitch = 3 if L.fuelmix95 == 1 & fuelmix100 == 0
/*by plant_id: replace fuelswitch = 3 if (L.fuelmix100 == 1 & fuelmix100 == 0 & L.coal_s > 0 & coal_s == 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 0 & L.oil_s > 0 & oil_s == 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 0 & L.natgas_s > 0 & natgas_s == 0)*/
by plant_id: replace fuelswitch = 4 if (L.fuelmix95 == 1 & fuelmix95 == 1 & L.coal_s == 0 & coal_s > 0) ///
| (L.fuelmix95 == 1 & fuelmix95 == 1 & L.oil_s == 0 & oil_s > 0) ///
| (L.fuelmix95 == 1 & fuelmix95 == 1 & L.natgas_s == 0 & natgas_s > 0)
lab def fuelswitch 0 "No switching" 1 "Single to Single" 2 "Single to mixing" 3 "Mixing to single" 4 "Mixing to mixing", replace
lab val fuelswitch fuelswitch
* Dummy for switching in any category
gen fuelswitch_dum = 0
replace fuelswitch_dum = 1 if fuelswitch > 0
*/



gen fuelswitch = 0
by plant_id: replace fuelswitch = 1 if (L.fuelmix100 == 0 & fuelmix100 == 0 & coal_s > 0 & L.coal_s == 0) ///
| (L.fuelmix100 == 0 & fuelmix100 == 0 & oil_s > 0 & L.oil_s == 0) ///
| (L.fuelmix100 == 0 & fuelmix100 == 0 & natgas_s > 0 & L.natgas_s == 0)
by plant_id: replace fuelswitch = 2 if L.fuelmix100 == 0 & fuelmix100 == 1
by plant_id: replace fuelswitch = 3 if L.fuelmix100 == 1 & fuelmix100 == 0
/*by plant_id: replace fuelswitch = 3 if (L.fuelmix100 == 1 & fuelmix100 == 0 & L.coal_s > 0 & coal_s == 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 0 & L.oil_s > 0 & oil_s == 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 0 & L.natgas_s > 0 & natgas_s == 0)*/
by plant_id: replace fuelswitch = 4 if (L.fuelmix100 == 1 & fuelmix100 == 1 & L.coal_s == 0 & coal_s > 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 1 & L.oil_s == 0 & oil_s > 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 1 & L.natgas_s == 0 & natgas_s > 0)
lab def fuelswitch 0 "No switching" 1 "Single to Single" 2 "Single to mixing" 3 "Mixing to single" 4 "Mixing to mixing", replace
lab val fuelswitch fuelswitch
* Dummy for switching in any category
gen fuelswitch_dum = 0
replace fuelswitch_dum = 1 if fuelswitch > 0


/*
gen natgas_ = 0
gen coal_ = 0
gen oil_ = 0
gen _natgas = 0
gen _coal = 0
gen _oil = 0
forvalues i = 1/8 {
	by plant_id: replace natgas_ = 1 if natgas_s[_n] == 1 & natgas_s[_n+`i'] <= 0.3
	by plant_id: replace coal_ = 1 if coal_s[_n] == 1 & coal_s[_n+`i'] <= 0.3
	by plant_id: replace oil_ = 1 if oil_s[_n] == 1 & oil_s[_n+`i'] <= 0.3
	by plant_id: replace _natgas = 1 if natgas_s[_n] == 1 & natgas_s[_n-`i'] <= 0.3
	by plant_id: replace _coal = 1 if coal_s[_n] == 1 & coal_s[_n-`i'] <= 0.3
	by plant_id: replace _oil = 1 if oil_s[_n] == 1 & oil_s[_n-`i'] <= 0.3
}
gen switching = 0
replace switching = 1 if natgas_ == 1 | _natgas == 1 | coal_ == 1 | _coal==1 | oil_ == 1 | _oil == 1
gen ghg = gamma_coal*coal_mmbtu+gamma_oil*oil_mmbtu+gamma_natgas*natgas_mmbtu
preserve
	collapse (sum) ghg, by(switching)
restore
*/


* TABLE : Count the number of unique firms that switch in any category
preserve
	collapse (sum) fuelswitch_dum, by(plant_id)
	replace fuelswitch_dum = 1 if fuelswitch_dum > 1
	egen totswitch = total(fuelswitch_dum)
	gen totnoswitch = _N-totswitch
	file close _all
	file open TabSwitchers using Output/Tables/Switching/nSwitchers.tex, write replace
	file write TabSwitchers "& Firms who never swith & Firms who switch & Total \\ \midrule"_n
	su totswitch
	local s: di %12.0fc r(mean)
	local frac_s: di %12.2fc = r(mean)/_N
	su totnoswitch
	global ns: di %12.0fc r(mean)
	global frac_ns: di %12.2fc r(mean)/_N
	local N: di %12.0fc _N
	file write TabSwitchers "Number & $ns & `s' & `N' \\"_n
	file write TabSwitchers "Fraction & $frac_ns & `frac_s' & 1 \\"_n
	file write TabSwitchers "\bottomrule"
	file close _all
restore
* TABLE : Count the number of unique firms that switch in each category (not mutual exclusive)
preserve
	forvalues i = 1/4 {
			gen switch`i' = 1 if fuelswitch == `i'
		}
	collapse (sum) switch1 switch2 switch3 switch4, by(plant_id)
	forvalues i = 1/4 {
		replace switch`i' = 1 if switch`i' > 1
		egen tot`i' = total(switch`i')
	}
	* 1. Cross table between single to mixing and mixing to single
	lab def switch2 0 "No" 1 "Yes", replace
	lab def switch3 0 "No" 1 "Yes", replace
	lab val switch2 switch2
	lab val switch3 switch3
	eststo clear
	estpost tab switch2 switch3
	esttab using "Output/Tables/Switching/nSwitchers_category_excl.tex", ///
	cell(b(fmt(0))) collabels(none) unstack noobs nonumber nomtitle booktabs ///
	eqlabels(, lhs("Single to Mix (Row)/Mix to Single (Column)")) varlabels(, blist(Total)) replace
	* 2. In each category (not mutually exclusive)
	file close _all
	file open TabSwitchers using Output/Tables/Switching/nSwitchers_category.tex, write replace
	file write TabSwitchers "& Never switch & Single to Single & Single to Mix & Mix to single & Mix to Mix & Number of Firms \\ \midrule"_n
	file write TabSwitchers "Number & $ns & "
	forvalues i = 1/4 {
		su tot`i'
		local s: di %12.0fc r(mean)
		file write TabSwitchers "`s' & "
	}
	local N: di %12.0fc _N
	file write TabSwitchers "`N' \\"_n
	file write TabSwitchers "Fraction & $frac_ns & "
	forvalues i = 1/4 {
		su tot`i'
		local frac_s: di %12.2fc r(mean)/_N
		file write TabSwitchers "`frac_s' & "
	}
	local N: di %12.0fc _N
	file write TabSwitchers "N/A \\"_n
	file write TabSwitchers "\bottomrule"
	file close _all
restore


*----------------------------------------------------------------------
* Quantify how much energy is due to switching towards different fuels
*----------------------------------------------------------------------

* Normalize total energy to the level of 2009 (first year) for each plant
by plant_id: gen totfuel_2009 = totfuel_mmbtu[1]
gen energy_norm = totfuel_mmbtu/totfuel_2009
gen natgas_mmbtu_norm = natgas_mmbtu/energy_norm
gen oil_mmbtu_norm = oil_mmbtu/energy_norm
gen coal_mmbtu_norm = coal_mmbtu/energy_norm

*GRAPH: ONE WAY SWITCHING BEHAVIOR (increase due to new fuel)
preserve
	by plant_id: gen switch_natgas = natgas_mmbtu_norm if (L.natgas_s == 0 & natgas_s > 0) 
	by plant_id: gen switch_coal = coal_mmbtu_norm if (L.coal_s == 0 & coal_s > 0) 
	by plant_id: gen switch_oil = oil_mmbtu_norm if (L.oil_s == 0 & oil_s > 0)
	collapse (sum) switch_natgas switch_coal switch_oil, by(yr)
	su yr
	drop if yr == `r(min)'
	replace switch_natgas = switch_natgas/1000000
	replace switch_oil = switch_oil/1000000
	replace switch_coal = switch_coal/1000000
	* Graph by year
	graph twoway (connected switch_natgas yr) (connected switch_oil yr) (connected switch_coal yr), ///
	graphregion(color(white)) xlabel(2010[1]2017) ytitle("Energy (billion btu)") xtitle("Year") ///
	legend(label(1 "Switch to Natural Gas") label(2 "Switch to Oil") label(3 "Switch to Coal"))
	graph export Output/Graphs/Switching/SwitchIncrease_year.pdf, replace
	* Graph coal only
	graph twoway (connected switch_coal yr), ///
	graphregion(color(white)) xlabel(2010[1]2017) ytitle("Energy (billion btu)") xtitle("Year") ///
	legend(label(1 "Switch to Coal")) yline(0) ylabel(0(20)100)
	graph export Output/Graphs/Switching/SwitchIncrease_Coal_year.pdf, replace
restore
*GRAPH: ONE WAY SWITCHING BEHAVIOR (decrease due to dropping fuel)
preserve
	by plant_id: gen switch_natgas = -L.natgas_mmbtu_norm if (L.natgas_s > 0 & natgas_s == 0) 
	by plant_id: gen switch_coal = -L.coal_mmbtu_norm if (L.coal_s > 0 & coal_s == 0) 
	by plant_id: gen switch_oil = -L.oil_mmbtu_norm if (L.oil_s > 0 & oil_s == 0)
	collapse (sum) switch_natgas switch_coal switch_oil, by(yr)
	su yr
	drop if yr == `r(min)'
	replace switch_natgas = switch_natgas/1000000
	replace switch_oil = switch_oil/1000000
	replace switch_coal = switch_coal/1000000
	* Graph by year
	graph twoway (connected switch_natgas yr) (connected switch_oil yr) (connected switch_coal yr), ///
	graphregion(color(white)) xlabel(2010[1]2017) ytitle("Energy (billion btu)") xtitle("Year") ///
	legend(label(1 "Switch off Natural Gas") label(2 "Switch off Oil") label(3 "Switch off Coal"))
	graph export Output/Graphs/Switching/SwitchDecrease_year.pdf, replace
	* Graph coal only
	graph twoway (connected switch_coal yr), ///
	graphregion(color(white)) xlabel(2010[1]2017) ytitle("Energy (billion btu)") xtitle("Year") ///
	legend(label(1 "Switch off Coal")) yline(0) ylabel(0(-20)-100)
	graph export Output/Graphs/Switching/SwitchDecrease_Coal_year.pdf, replace
restore
*GRAPH: SWITCH TO AND OFF FUELS (ALL YEARS)
preserve
	gen switch = 0
	by plant_id: gen switch_natgas = natgas_mmbtu if (L.natgas_s == 0 & natgas_s > 0)
	by plant_id: replace switch = 1 if (L.natgas_s == 0 & natgas_s > 0)
	by plant_id: gen switch_oil = oil_mmbtu if (L.oil_s == 0 & oil_s > 0)
	by plant_id: replace switch = 1 if (L.oil_s == 0 & oil_s > 0)
	by plant_id: gen switch_coal = coal_mmbtu if (L.coal_s == 0 & coal_s > 0)
	by plant_id: replace switch = 1 if (L.coal_s == 0 & coal_s > 0)
	
	by plant_id: replace switch_natgas = -L.natgas_mmbtu if (L.natgas_s > 0 & natgas_s == 0)
	by plant_id: replace switch = 2 if (L.natgas_s > 0 & natgas_s == 0)
	by plant_id: replace switch_oil = -L.oil_mmbtu if (L.oil_s > 0 & oil_s == 0)
	by plant_id: replace switch = 2 if (L.oil_s > 0 & oil_s == 0)
	by plant_id: replace switch_coal = -L.coal_mmbtu if (L.coal_s > 0 & coal_s == 0)
	by plant_id: replace switch = 2 if (L.coal_s > 0 & coal_s == 0)
	
	collapse (sum) switch_natgas switch_oil switch_coal, by(switch)
	drop if switch == 0
	replace switch_natgas = switch_natgas/1000
	replace switch_oil = switch_oil/1000
	replace switch_coal = switch_coal/1000
	lab var switch_natgas "Natural Gas"
	lab var switch_coal "Coal"
	lab var switch_oil "Oil"
	lab def switch 1 "Switching to" 2 "Switching off", replace
	lab val switch switch
	graph bar (asis) switch_coal, over(switch) bargap(10) ytitle("Billion btu")
	graph export Output/Graphs/Switching/Switching_Coal.pdf, replace
restore

/*
*GRAPHS: TWOWAYS SWITCHING BEHAVIOR
* Define switching between fuels
preserve
	egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
	drop if nyear < 9
	drop nyear
	xtset plant_id yr
	replace natgas_mmbtu_norm = natgas_mmbtu
	replace oil_mmbtu_norm = oil_mmbtu
	replace coal_mmbtu_norm = coal_mmbtu
	by plant_id: gen coal_natgas = natgas_mmbtu_norm if L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 & L.natgas_mmbtu_norm == 0 & L.oil_mmbtu_norm == 0
	by plant_id: replace coal_natgas = natgas_mmbtu_norm*L.coal_s if L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 & L.natgas_mmbtu_norm == 0 & L.oil_mmbtu_norm > 0
	by plant_id: gen natgas_coal = coal_mmbtu_norm if L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 & L.coal_mmbtu_norm == 0 & L.oil_mmbtu_norm == 0
	by plant_id: replace natgas_coal = coal_mmbtu_norm*L.natgas_s if L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 & L.coal_mmbtu_norm == 0 & L.oil_mmbtu_norm > 0
	by plant_id: gen oil_natgas = natgas_mmbtu_norm if L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 & L.natgas_mmbtu_norm == 0 & L.coal_mmbtu_norm == 0
	by plant_id: replace oil_natgas = natgas_mmbtu_norm*L.oil_s if L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 & L.natgas_mmbtu_norm == 0 & L.coal_mmbtu_norm > 0
	by plant_id: gen natgas_oil = oil_mmbtu_norm if L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 & L.oil_mmbtu_norm == 0 & L.coal_mmbtu_norm == 0
	by plant_id: replace natgas_oil = oil_mmbtu_norm*L.natgas_s if L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 & L.oil_mmbtu_norm == 0 & L.coal_mmbtu_norm > 0
	by plant_id: gen coal_oil = oil_mmbtu_norm if L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 & L.oil_mmbtu_norm == 0 & L.natgas_mmbtu_norm == 0 
	by plant_id: replace coal_oil = oil_mmbtu_norm*L.coal_s if L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 & L.oil_mmbtu_norm == 0 & L.natgas_mmbtu_norm > 0 
	by plant_id: gen oil_coal = coal_mmbtu_norm if L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 & L.coal_mmbtu_norm == 0 & L.natgas_mmbtu_norm == 0
	by plant_id: replace oil_coal = coal_mmbtu_norm*L.oil_s if L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 & L.coal_mmbtu_norm == 0 & L.natgas_mmbtu_norm > 0
	
	/*
	by plant_id: gen coal_natgas = Natgas if L.Coal > 0 & Coal  == 0 & L.Natgas == 0 & L.Oil == 0
	by plant_id: replace coal_natgas = Natgas*L.coal_s if L.Coal > 0 & Coal == 0 & L.Natgas == 0 & L.Oil > 0
	by plant_id: gen natgas_coal = Coal if L.Natgas > 0 & Natgas == 0 & L.Coal == 0 & L.Oil == 0
	by plant_id: replace natgas_coal = Coal*L.natgas_s if L.Natgas > 0 & Natgas == 0 & L.Coal == 0 & L.Oil > 0
	by plant_id: gen oil_natgas = Natgas if L.Oil > 0 & Oil == 0 & L.Natgas == 0 & L.Coal == 0
	by plant_id: replace oil_natgas = Natgas*L.oil_s if L.Oil > 0 & Oil == 0 & L.Natgas == 0 & L.Coal > 0
	by plant_id: gen natgas_oil = Oil if L.Natgas > 0 & Natgas == 0 & L.Oil == 0 & L.Coal == 0
	by plant_id: replace natgas_oil = Oil*L.natgas_s if L.Natgas > 0 & Natgas == 0 & L.Oil == 0 & L.Coal > 0
	by plant_id: gen coal_oil = Oil if L.Coal > 0 & Coal == 0 & L.Oil == 0 & L.Natgas == 0 
	by plant_id: replace coal_oil = Oil*L.coal_s if L.Coal > 0 & Coal == 0 & L.Oil == 0 & L.Natgas > 0 
	by plant_id: gen oil_coal = Coal if L.Oil > 0 & Oil == 0 & L.Coal == 0 & L.Natgas == 0
	by plant_id: replace oil_coal = Coal*L.oil_s if L.Oil > 0 & Oil == 0 & L.Coal == 0 & L.Natgas > 0
	*/
	
	drop if yr == 2009
	/*
	by plant_id: gen coal_natgas = L.coal_mmbtu_norm-coal_mmbtu_norm if ///
	(L.coal_s > 0 & L.natgas_s == 0 & natgas_s > 0) & (L.coal_mmbtu_norm-coal_mmbtu_norm <= natgas_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: replace coal_natgas = L.coal_mmbtu_norm-coal_mmbtu_norm if ///
	(L.coal_s > 0 & L.natgas_s == 0 & natgas_s > 0) & (L.coal_mmbtu_norm-coal_mmbtu_norm > natgas_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: gen natgas_coal = coal_mmbtu_norm if ///
	(L.coal_s == 0 & L.natgas_s > 0 & coal_s > 0) & (L.natgas_mmbtu_norm-natgas_mmbtu_norm > coal_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: replace natgas_coal = L.natgas_mmbtu_norm-natgas_mmbtu_norm if ///
	(L.coal_s == 0 & L.natgas_s > 0 & coal_s > 0) & (L.natgas_mmbtu_norm-natgas_mmbtu_norm <= coal_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: gen oil_natgas = natgas_mmbtu_norm if ///
	(L.oil_s > 0 & L.natgas_s == 0 & natgas_s > 0) & (L.oil_mmbtu_norm-oil_mmbtu_norm > natgas_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: replace oil_natgas = L.oil_mmbtu_norm-oil_mmbtu_norm if ///
	(L.oil_s > 0 & L.natgas_s == 0 & natgas_s > 0) & (L.oil_mmbtu_norm-oil_mmbtu_norm <= natgas_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: gen natgas_oil = oil_mmbtu_norm if ///
	(L.oil_s == 0 & L.natgas_s > 0 & oil_s > 0) & (L.natgas_mmbtu_norm-natgas_mmbtu_norm > oil_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: replace natgas_oil = L.natgas_mmbtu_norm-natgas_mmbtu_norm if ///
	(L.oil_s == 0 & L.natgas_s > 0 & oil_s > 0) & (L.natgas_mmbtu_norm-natgas_mmbtu_norm <= oil_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: gen coal_oil = oil_mmbtu_norm if ///
	(L.coal_s > 0 & L.oil_s == 0 & oil_s > 0) & (L.coal_mmbtu_norm-coal_mmbtu_norm > oil_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: replace coal_oil = L.coal_mmbtu_norm-coal_mmbtu_norm if ///
	(L.coal_s > 0 & L.oil_s == 0 & oil_s > 0) & (L.coal_mmbtu_norm-coal_mmbtu_norm <= oil_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: gen oil_coal = coal_mmbtu_norm if ///
	(L.coal_s == 0 & L.oil_s > 0 & coal_s > 0) & (L.oil_mmbtu_norm-oil_mmbtu_norm > coal_mmbtu_norm) & fuelswitch_dum==1
	by plant_id: replace oil_coal = L.oil_mmbtu_norm-oil_mmbtu_norm if ///
	(L.coal_s == 0 & L.oil_s > 0 & coal_s > 0) & (L.oil_mmbtu_norm-oil_mmbtu_norm <= coal_mmbtu_norm) & fuelswitch_dum==1
	*/
	local vars coal_natgas natgas_coal oil_natgas natgas_oil coal_oil oil_coal
	foreach v of local vars {
		replace `v' = 0 if `v' == .
	}
	collapse (sum) coal_natgas natgas_coal oil_natgas natgas_oil coal_oil oil_coal, by(yr)
	su yr
	drop if yr == `r(min)'
	local vars coal_natgas natgas_coal oil_natgas natgas_oil coal_oil oil_coal
	foreach v of local vars {
		replace `v' = `v'/1000000
	}
	*GRAPHS BY YEAR
	*1. Coal and Natural Gas
	graph twoway (connected coal_natgas yr) (connected natgas_coal yr), ///
	graphregion(color(white)) xlabel(2010[1]2017) ytitle("Energy (billion btu)") xtitle("Year") ///
	legend(label(1 "Coal to Natural Gas") label(2 "Natural Gas to Coal")) yline(0)
	graph export Output/Graphs/Switching/SwitchCoalNatgas_year.pdf, replace
	*2. Oil and Natural Gas
	graph twoway (connected oil_natgas yr) (connected natgas_oil yr), ///
	graphregion(color(white)) xlabel(2010[1]2017) ytitle("Energy (billion btu)") xtitle("Year") ///
	legend(label(1 "Oil to Natural Gas") label(2 "Natural Gas to Oil")) yline(0)
	graph export Output/Graphs/Switching/SwitchOilNatgas_year.pdf, replace
	*3 Coal and Oil
	graph twoway (connected coal_oil yr) (connected oil_coal yr), ///
	graphregion(color(white)) xlabel(2010[1]2017) ytitle("Energy (billion btu)") xtitle("Year") ///
	legend(label(1 "Coal to Oil") label(2 "Oil to Coal")) yline(0)
	graph export Output/Graphs/Switching/SwitchCoalOil_year.pdf, replace
	*GRAPHS ALL YEARS
	collapse (sum) coal_natgas natgas_coal oil_natgas natgas_oil coal_oil oil_coal
restore
*/

*------------------------------------------------------------------
* Aggregate GHG emissions and decomposition (fully balanced panel)
*------------------------------------------------------------------

* GHG emissions (total)
gen ghg = gamma_oil*oil_mmbtu + gamma_coal*coal_mmbtu + gamma_natgas*natgas_mmbtu
*bysort plant_id (yr): replace ghg = 0 if _n == 1
* GHG emissions (normalized by keep energy constant across years)
gen ghg_norm = gamma_oil*oil_mmbtu_norm + gamma_coal*coal_mmbtu_norm + gamma_natgas*natgas_mmbtu_norm
*** GRAPH AGGREGATE GHG EMISSIONS ***
preserve
	*** GRAPHS AGGREGATE GHG EMISSIONS ***
	collapse (sum) ghg ghg_norm, by(yr)
	replace ghg = ghg/1000000000
	replace ghg_norm = ghg_norm/1000000000
	graph twoway (connected ghg yr) (connected ghg_norm yr), graphregion(color(white)) ///
	legend(label(1 "Agg GHG") label(2 "Agg GHG (2009 energy level)")) ///
	xlabel(2009[1]2018) ytitle("CO2e (billion tonnes)")
	graph export Output/Graphs/Switching/AggGHG_year_BalancedPanel.pdf, replace
restore

/*
*** GRAPH DECOMPOSITION OF CHANGE IN AGGREGATE GHG EMISSIONS - SWITCHING VS NOT SWITCHING (OLD)***
preserve
	egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
	drop if nyear < 9
	drop nyear
	* Total variation in GHG
	by plant_id: gen ghg_diff_norm = D.ghg_norm
	* Decompose variation between "across technologies" and "within technologies"
	local vars coal oil natgas
	foreach v of local vars {
		by plant_id: gen Diff_`v' = D.`v'_mmbtu_norm
		by plant_id: gen Diff_`v'_noswitch = D.`v'_mmbtu_norm if (L.`v'_mmbtu_norm > 0 & `v'_mmbtu_norm > 0)
		gen Diff_`v'_switch = Diff_`v' if Diff_`v'_noswitch == .
		replace Diff_`v'_switch = 0 if Diff_`v'_switch == .
		replace Diff_`v'_noswitch = 0 if Diff_`v'_noswitch == .
	}
	
	local vars coal oil natgas
	foreach v of local vars {
		by plant_id: gen `v'_noswitch = `v'_mmbtu_norm if (L.`v'_mmbtu_norm > 0 & `v'_mmbtu_norm > 0)
	}
	/*
	by plant_id: replace natgas_switch = L.coal_mmbtu_norm if (L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 & L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm > 0 & oil_mmbtu_norm == 0)
	by plant_id: replace natgas_switch = L.coal_mmbtu_norm*natgas_s if (L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 ///
	& L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm > 0 & L.oil_mmbtu_norm > 0 & oil_mmbtu_norm > 0)
	by plant_id: replace natgas_switch = L.oil_mmbtu_norm if (L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 & L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm > 0 & coal_mmbtu_norm == 0)
	by plant_id: replace natgas_switch = L.oil_mmbtu_norm*natgas_s if (L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 ///
	& L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm > 0 & L.coal_mmbtu_norm > 0 & coal_mmbtu_norm > 0)
	
	by plant_id: replace oil_switch = L.coal_mmbtu_norm if (L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 & L.oil_mmbtu_norm > 0 & oil_mmbtu_norm > 0 & natgas_mmbtu_norm == 0)
	by plant_id: replace oil_switch = L.coal_mmbtu_norm*oil_s if (L.coal_mmbtu_norm > 0 & coal_mmbtu_norm == 0 ///
	& L.oil_mmbtu_norm > 0 & oil_mmbtu_norm > 0 & L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm > 0)
	by plant_id: replace oil_switch = L.natgas_mmbtu_norm if (L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 & L.oil_mmbtu_norm > 0 & oil_mmbtu_norm > 0 & coal_mmbtu_norm == 0)
	by plant_id: replace oil_switch = L.natgas_mmbtu_norm*oil_s if (L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 ///
	& L.oil_mmbtu_norm > 0 & oil_mmbtu_norm > 0 & L.coal_mmbtu_norm > 0 & coal_mmbtu_norm > 0)
	
	by plant_id: replace coal_switch = L.natgas_mmbtu_norm if (L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 & L.coal_mmbtu > 0 & coal_mmbtu_norm > 0 & oil_mmbtu_norm == 0)
	by plant_id: replace coal_switch = L.natgas_mmbtu_norm*coal_s if (L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm == 0 ///
	& L.coal_mmbtu_norm > 0 & coal_mmbtu_norm > 0 & L.oil_mmbtu_norm > 0 & oil_mmbtu_norm > 0)
	by plant_id: replace coal_switch = L.oil_mmbtu_norm if (L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 & L.coal_mmbtu > 0 & coal_mmbtu_norm > 0 & natgas_mmbtu_norm == 0)
	by plant_id: replace coal_switch = L.oil_mmbtu_norm*coal_s if (L.oil_mmbtu_norm > 0 & oil_mmbtu_norm == 0 ///
	& L.coal_mmbtu_norm > 0 & coal_mmbtu_norm > 0 & L.natgas_mmbtu_norm > 0 & natgas_mmbtu_norm > 0)
	*/
	
	local vars coal oil natgas
	foreach v of local vars {
		replace `v'_noswitch = 0 if `v'_noswitch == .
		*gen `v'_noswitch = `v'_mmbtu_norm if (`v'_mmbtu_norm > 0 & L.`v'_mmbtu_norm > 0)
		gen `v'_switch = `v'_mmbtu_norm-`v'_noswitch
		replace `v'_switch = 0 if `v'_switch == .
	}
	gen ghg_norm_switch = gamma_oil*oil_switch + gamma_coal*coal_switch + gamma_natgas*natgas_switch
	gen ghg_norm_noswitch = gamma_oil*oil_noswitch + gamma_coal*coal_noswitch + gamma_natgas*natgas_noswitch
	collapse (sum) ghg_norm_switch ghg_norm_noswitch oil_switch oil_noswitch coal_switch coal_noswitch ///
	natgas_switch natgas_noswitch, by(yr)
	* kg CO2e to million tonnes
	replace ghg_norm_switch = ghg_norm_switch/1000000000
	replace ghg_norm_noswitch = ghg_norm_noswitch/1000000000
	* mmbtu to billion btu
	local vars coal oil natgas
	foreach v of local vars {
		replace `v'_switch = `v'_switch/1000000
		replace `v'_noswitch = `v'_noswitch/1000000
	}
	*** GRAPH: DECOMPOSITION OF GHG EMISSIONS ***
	graph twoway (connected ghg_norm_switch yr) (connected ghg_norm_noswitch yr), graphregion(color(white)) ///
	xlabel(2009[1]2018) legend(label(1 "Due to switching") label(2 "Not due to switching")) ytitle("CO2e (Billion tonnes)")
	graph export Output/Graphs/Switching/GHGDecomp_year_BalancedPanel.pdf, replace
	*** GRAPH: DECOMPOSITION OF CHANGE IN GHG EMISSIONS ***
	tsset yr
	gen ghg_diff_switch = D.ghg_norm_switch
	gen ghg_diff_noswitch = D.ghg_norm_noswitch
	graph twoway (connected ghg_diff_switch yr if yr > 2009) (connected ghg_diff_noswitch yr if yr > 2009), graphregion(color(white)) yline(0) ///
	xlabel(2010[1]2018) legend(label(1 "Due to switching") label(2 "Not due to switching")) ytitle("CO2e (Billion tonnes)")
	graph export Output/Graphs/Switching/GHGDiffDecomp_year_BalancedPanel.pdf, replace
	*** GRAPH: FRACTION OF CHANGE BETWEEN SWITCHING AND NO SWITCHING (ABSOLUTE VALUE) ***
	gen abs_switch = abs(ghg_diff_switch)
	gen abs_noswitch = abs(ghg_diff_noswitch)
	gen total_switch = abs_switch+abs_noswitch
	gen frac_switch = abs_switch/total_switch
	gen frac_noswitch = abs_noswitch/total_switch
	gen zero = 0
	gen perc1 = 1
	graph twoway (rarea zero frac_switch yr if yr > 2009) (rarea frac_switch perc1 yr if yr > 2009), ///
	legend(label(1 "Due to switching") label(2 "Not due to switching") pos(1)) graphregion(color(white)) ///
	xlabel(2010[1]2017)
	graph export Output/Graphs/Switching/GHGDiffDecomp_BalancedPanel.pdf, replace
	*** GRAPH: DECOMPOSITION OF FUEL USAGE ***
	* Natural Gas
	graph twoway (connected natgas_switch yr) (connected natgas_noswitch yr), graphregion(color(white)) ///
	xlabel(2009[1]2018) legend(label(1 "Due to switching") label(2 "Not due to switching")) ytitle("billion btu")
	graph export Output/Graphs/Switching/NatgasDecomp_year_BalancedPanel.pdf, replace
	* Oil
	graph twoway (connected oil_switch yr) (connected oil_noswitch yr), graphregion(color(white)) ///
	xlabel(2009[1]2018) legend(label(1 "Due to switching") label(2 "Not due to switching")) ytitle("billion btu")
	graph export Output/Graphs/Switching/OilDecomp_year_BalancedPanel.pdf, replace
	* Coal
	graph twoway (connected coal_switch yr) (connected coal_noswitch yr), graphregion(color(white)) ///
	xlabel(2009[1]2018) legend(label(1 "Due to switching") label(2 "Not due to switching")) ytitle("billion btu")
	graph export Output/Graphs/Switching/CoalDecomp_year_BalancedPanel.pdf, replace
restore
*/

*** GRAPH DECOMPOSITION OF CHANGE IN AGGREGATE GHG EMISSIONS - SWITCHING VS NOT SWITCHING (NEW)***
preserve
	xtset plant_id yr
	egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
	drop if nyear < 9
	drop nyear
	* Total variation in GHG
	by plant_id: gen ghg_diff_norm = D.ghg_norm
	* Decompose variation between "across technologies" and "within technologies"
	local vars coal oil natgas
	foreach v of local vars {
		by plant_id: gen Diff_`v' = D.`v'_mmbtu_norm
		by plant_id: gen Diff_`v'_noswitch = D.`v'_mmbtu_norm if (L.`v'_mmbtu_norm > 0 & `v'_mmbtu_norm > 0)
		gen Diff_`v'_switch = Diff_`v' if Diff_`v'_noswitch == .
		replace Diff_`v'_switch = 0 if Diff_`v'_switch == .
		replace Diff_`v'_noswitch = 0 if Diff_`v'_noswitch == .
	}
	gen Diff_ghg_norm_switch = ghg_diff_norm  if (Diff_coal_switch != 0) | (Diff_oil_switch != 0) | (Diff_natgas_switch != 0)
	gen Diff_ghg_norm_noswitch = ghg_diff_norm if Diff_ghg_norm_switch == .
	
	collapse (sum) Diff_ghg_norm_switch Diff_ghg_norm_noswitch, by(yr)
	* kg CO2e to million tonnes
	replace Diff_ghg_norm_switch = Diff_ghg_norm_switch/1000000000
	replace Diff_ghg_norm_noswitch = Diff_ghg_norm_noswitch/1000000000
	graph twoway (connected Diff_ghg_norm_switch yr if yr > 2009) (connected Diff_ghg_norm_noswitch yr if yr > 2009), graphregion(color(white)) yline(0) ///
	xlabel(2010[1]2018) legend(label(1 "Due to switching") label(2 "Not due to switching")) ytitle("CO2e (Billion tonnes)")
	graph export Output/Graphs/Switching/GHGDiffDecomp_year_BalancedPanel.pdf, replace
	*** GRAPH: FRACTION OF CHANGE BETWEEN SWITCHING AND NO SWITCHING (ABSOLUTE VALUE) ***
	gen abs_switch = abs(Diff_ghg_norm_switch)
	gen abs_noswitch = abs(Diff_ghg_norm_noswitch)
	gen total_switch = abs_switch+abs_noswitch
	gen frac_switch = abs_switch/total_switch
	gen frac_noswitch = abs_noswitch/total_switch
	gen zero = 0
	gen perc1 = 1
	graph twoway (rarea zero frac_switch yr if yr > 2009) (rarea frac_switch perc1 yr if yr > 2009), ///
	legend(label(1 "Due to switching") label(2 "Not due to switching") pos(1)) graphregion(color(white)) ///
	xlabel(2010[1]2017)
	graph export Output/Graphs/Switching/GHGDiffDecomp_BalancedPanel.pdf, replace
restore



*** GRAPH OF CHANGE IN AGGREGATE GHG EMISSIONS (OFF AND TO EACH FUEL) ***
* To new fuel
preserve
	egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
	drop if nyear < 9
	drop nyear
	* Total variation in GHG
	by plant_id: gen ghg_diff_norm = D.ghg_norm
	gen to_fuel = 0
	replace to_fuel = 1 if L.coal_mmbtu == 0 & coal_mmbtu > 0
	replace to_fuel = 2 if L.natgas_mmbtu == 0 & natgas_mmbtu > 0
	replace to_fuel = 3 if L.oil_mmbtu == 0 & oil_mmbtu > 0
	collapse (sum) ghg_diff_norm, by(to_fuel yr)
	replace ghg_diff_norm = ghg_diff_norm/1000000000
	graph twoway (connected ghg_diff_norm yr if to_fuel == 1) (connected ghg_diff_norm yr if to_fuel == 2) ///
	(connected ghg_diff_norm yr if to_fuel == 3), xlabel(2010[1]2017) legend(label(1 "To Coal") label(2 "To Natural Gas") label(3 "To Oil")) ///
	ytitle("CO2e (Billion tonnes)")
	graph export Output/Graphs/Switching/GHGDiff_ToFuel_year_BalancedPanel.pdf, replace
restore
* Off old fuel
preserve
	egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
	drop if nyear < 9
	drop nyear
	* Total variation in GHG
	by plant_id: gen ghg_diff_norm = D.ghg_norm
	gen off_fuel = 0
	replace off_fuel = 1 if L.coal_mmbtu > 0 & coal_mmbtu == 0
	replace off_fuel = 2 if L.natgas_mmbtu > 0 & natgas_mmbtu == 0
	replace off_fuel = 3 if L.oil_mmbtu > 0 & oil_mmbtu == 0
	collapse (sum) ghg_diff_norm, by(off_fuel yr)
	replace ghg_diff_norm = ghg_diff_norm/1000000000
	graph twoway (connected ghg_diff_norm yr if off_fuel == 1) (connected ghg_diff_norm yr if off_fuel == 2) ///
	(connected ghg_diff_norm yr if off_fuel == 3), xlabel(2010[1]2017) legend(label(1 "Off Coal") label(2 "Off Natural Gas") label(3 "Off Oil")) ///
	ytitle("CO2e (Billion tonnes)")
	graph export Output/Graphs/Switching/GHGDiff_OffFuel_year_BalancedPanel.pdf, replace
restore

*---------------------------------------------------
* Relationship between switching and other variables
*---------------------------------------------------


* Probability of switching at any point conditional on industry 
bysort plant_id: egen fuelswitch_anytime = sum(fuelswitch_dum)
replace fuelswitch_anytime = 1 if fuelswitch_anytime > 1
/*
* Drop industries where firms never switch or always switch
bysort ind3d: egen fuelswitch_byind = mean(fuelswitch_anytime)
drop if fuelswitch_byind == 0 | fuelswitch_byind == 1
egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
*su nyear
*keep if nyear == `r(max)'	
drop if nyear < 4
drop nyear
*/

*** TABLES: EFFECT OF SWITCHING ON REVENUES (PROXY FOR PRODUCTIVITY) ***
* Measure of Energy (quantity)
replace coal_mmbtu = 0 if coal_mmbtu == .
replace natgas_mmbtu = 0 if natgas_mmbtu == .
replace oil_mmbtu = 0 if oil_mmbtu == .
replace elecb_mmbtu = 0 if elecb_mmbtu == .
gen fuel_mmbtu = oil_mmbtu + natgas_mmbtu + coal_mmbtu 
gen F = fuel_mmbtu
* Measure of electricity
gen E = elecb_mmbtu
* Inputs in production technology
rename nEmployees_tot L
gen Lspend = Wages_tot
replace Import = 0 if Import == .
gen Mspend = TotInput+Import-Energy
rename TotFixedAsset_Gross_Open Kspend
replace Kspend = TotFixedAsset_Net_Open if K == 0
rename ElecBought Espend
rename SalesGross_tot Yspend
gen Fspend = Coal+Natgas+Oil
* Measure of debt capacity (net worth, leverage)
rename TotInventory_Open inv
rename TotalLiabilities_Open liab
gen networth = Kspend+inv-liab
gen leverage = liab/(Kspend+inv)
* Cash on hands
rename cash_Open cash
* Sales per worker (proxy for productivity)
gen SalesPerWorker = Y/L
* Convert units from rupees to lakhs (100,000 rupees)
replace Mspend = Mspend/100000
replace Espend = Espend/100000
replace Kspend = Kspend/100000
replace Lspend = Lspend/100000
replace Fspend = Fspend/100000
replace Yspend = Yspend/100000
gen EnerSpend = Espend+Fspend
replace SalesPerWorker = SalesPerWorker/100000
replace cash = cash/100000
replace networth = networth/100000
* Revenue production function
gen logL = log(Lspend)
gen logK = log(Kspend)
gen logE = log(Espend)
gen logM = log(Mspend)
gen logF = log(Fspend)
gen logY = log(Yspend)
gen logEner = log(EnerSpend)
lab var logY "Sales"
lab val logY logY
lab var logK "Capital Spending"
lab val logK logK
lab var logL "Labor Spending"
lab val logL logL
lab var logM "Intermediate Spending"
lab val logM logM
lab var logE "Electricity Spending"
lab val logE logE
lab var logF "Fuel Spending"
lab val logF logF
lab def fuelswitch_dum 0 "Not Switching" 1 "Switching", replace
lab val fuelswitch_dum fuelswitch_dum

* Further balance the panel
drop if logL == . | logK == . | logEner == . | logY == . | logM == . 
drop max_gap
egen max_gap = max(yr - yr[_n-1]), by(plant_id)
keep if max_gap == 1
*drop nyear
egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
drop if nyear < 4


/*
* Estimate of productivity (OLS)
levelsof ind4d, local(in)
foreach i of local in {
	reg logY logL logK logEner logM if ind4d == `i'
	predict prod_est`i' if ind4d == `i', residuals
	replace prod_est`i' = prod_est`i' + _cons if ind4d == `i'
	replace prod_est`i' = 0 if prod_est`i' ==.
}
gen prod_est_ols = prod_est1701 + prod_est2394 + prod_est2410 + prod_est2310 + prod_est2420
*/

/* 
reg logY logEner logM logF logL
predict prod_est, residuals
*/

/*
* Estimate of productivity (FE)
levelsof ind4d, local(in)
foreach i of local in {
	xtreg logY logL logK logEner logM if ind4d == `i', fe
	predict prod_est`i' if ind4d == `i', ue
	replace prod_est`i' = 0 if prod_est`i' ==.
}
gen prod_est = prod_est1701 + prod_est2394 + prod_est2410 + prod_est2310 + prod_est2420
*xtreg logY logE logM logF logL, fe
*predict prod_est, ue
*/

/*
* Estimate of productivity (ACF)
levelsof ind4d, local(in)
foreach i of local in {
	acfest logY if ind4d == `i', free(logL) state(logK logEner) proxy(logM) i(plant_id) t(yr)
	predict prod_est`i' if ind4d == `i',omega
	replace prod_est`i' = prod_est`i' + _cons if ind4d == `i'
	replace prod_est`i' = 0 if prod_est`i' ==.
}
gen prod_est = prod_est1701 + prod_est2394 + prod_est2410 + prod_est2310 + prod_est2420
*/

* ACF (energy fixed)
acfest logY, free(logL) state(logK logEner) proxy(logM) i(plant_id) t(yr)
predict prod_est, omega
reg prod_est i.ind4d
predict prod_est_within_ind, residuals
reg prod_est i.ind4d logF
predict prod_est_within_ind_fuelspend, residuals

* ACF (energy free)
acfest logY, free(logL logEner) state(logK) proxy(logM) i(plant_id) t(yr)
predict prod_est_Efree, omega
reg prod_est_Efree i.ind4d
predict prod_est_Efree_within, residuals

* FE
xtreg logY logL logK logEner logM, fe
predict prod_est_fe, ue
reg prod_est_fe i.ind4d
predict prod_est_fe_within, residuals

* OLS
reg logY logL logK logEner logM i.ind4d
predict prod_est_ols_within, residuals


/*
* Remove outliers
su prod_est, detail
keep if prod_est > r(p1) & prod_est < r(p99)
egen nyear = total(inrange(yr, 2009, 2017)), by(plant_id)
su nyear
keep if nyear == `r(max)'
drop nyear
sort plant_id yr
xtset plant_id yr
*/

* TABLE: Switching current or next period
sort plant_id yr
xtset plant_id yr
by plant_id: gen F_fuelswitch_dum = F.fuelswitch_dum
lab def F_fuelswitch_dum 0 "Not Switching" 1 "Switching", replace
lab val F_fuelswitch_dum F_fuelswitch_dum 
gen F_fuelswitch = F.fuelswitch
lab def F_fuelswitch 0 "No Switching" 1 "Single to Single" 2 "Single to Mixing" 3 "Mixing to Single" 4 "Mixing to Mixing", replace
lab val F_fuelswitch F_fuelswitch
eststo clear
eststo mdl1: reg prod_est i.fuelswitch_dum	
eststo mdl2: reg prod_est i.fuelswitch_dum i.ind4d
eststo mdl3: reg prod_est i.F_fuelswitch_dum 
eststo mdl4: reg prod_est i.F_fuelswitch_dum i.ind4d
esttab using "Output/Tables/Switching/Switching_RevProd.tex", label wide ///
	 unstack mtitles("Switching Current Year" " " "Switching Next Year" " ") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Relationship between productivity and fuel switching") indicate(industry dummies = *ind4d) ///
	 addnotes("Productivity estimate comes from PFE using ACF method") replace
* TABLE: Switching in any period (entire firm)
by plant_id: egen totalswitch = sum(fuelswitch)
replace totalswitch = 1 if totalswitch > 1
lab def totalswitch 0 "Not a switcher" 1 "Switcher", replace
lab val totalswitch totalswitch
eststo clear
eststo mdl1: reg prod_est i.totalswitch
eststo mdl2: reg prod_est i.totalswitch i.ind4d
esttab using "Output/Tables/Switching/Switchers_RevProd.tex", label wide ///
	 unstack nomtitle booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) indicate(industry dummies = *ind4d) ///
	 p title("Relationship between productivity and switching at least once") ///
	 addnotes("Productivity estimate comes from PFE using ACF method") replace

*** GRAPH: AVERAGE REVENUE PRODUCTIVITY FOR SWITCHERS VS NON-SWITCHERS ***
* Standard errors for confidence intervals
local vars prod_est prod_est_within_ind prod_est_within_ind_fuelspend
foreach v of local vars {
	gen se_`v' = `v'
	gen n_`v' = `v'
}
*1. Switching at any period
preserve
	collapse (mean) (prod_est prod_est_within_ind prod_est_within_ind_fuelspend) (semean) ///
	(se_prod_est se_prod_est_within_ind se_prod_est_within_ind_fuelspend) ///
	(count) (n_prod_est n_prod_est_within_ind n_prod_est_within_ind_fuelspend), by(yr totalswitch)
	local vars prod_est prod_est_within_ind prod_est_within_ind_fuelspend
	foreach v of local vars {
		gen lb_`v' = `v' - invttail(n_`v'-1,0.025)*se_`v'
		gen ub_`v' = `v' + invttail(n_`v'-1,0.025)*se_`v'
	}
	graph twoway (connected prod_est yr if totalswitch == 0) (connected prod_est yr if totalswitch== 1) ///
	(rcap lb_prod_est ub_prod_est yr if totalswitch == 0, color(navy)) (rcap lb_prod_est ub_prod_est yr if totalswitch== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitching_year.pdf, replace
	graph twoway (connected prod_est_within_ind yr if totalswitch == 0) (connected prod_est_within_ind yr if totalswitch== 1) ///
	(rcap lb_prod_est_within_ind ub_prod_est_within_ind yr if totalswitch == 0, color(navy)) ///
	(rcap lb_prod_est_within_ind ub_prod_est_within_ind yr if totalswitch== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitching_year-withinInd.pdf, replace
	graph twoway (connected prod_est_within_ind_fuelspend yr if totalswitch == 0) (connected prod_est_within_ind_fuelspend yr if totalswitch== 1) ///
	(rcap lb_prod_est_within_ind_fuelspend ub_prod_est_within_ind_fuelspend yr if totalswitch == 0, color(navy)) ///
	(rcap lb_prod_est_within_ind_fuelspend ub_prod_est_within_ind_fuelspend yr if totalswitch== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitching_year-withinInd-fuelspend.pdf, replace
restore
*2. Switching next period
preserve
	collapse (mean) (prod_est prod_est_within_ind prod_est_within_ind_fuelspend) (semean) ///
	(se_prod_est se_prod_est_within_ind se_prod_est_within_ind_fuelspend) ///
	(count) (n_prod_est n_prod_est_within_ind n_prod_est_within_ind_fuelspend), by(yr F_fuelswitch_dum)
	local vars prod_est prod_est_within_ind prod_est_within_ind_fuelspend
	foreach v of local vars {
		gen lb_`v' = `v' - invttail(n_`v'-1,0.025)*se_`v'
		gen ub_`v' = `v' + invttail(n_`v'-1,0.025)*se_`v'
	}
	graph twoway (connected prod_est yr if F_fuelswitch_dum == 0) (connected prod_est yr if F_fuelswitch_dum== 1) ///
	(rcap lb_prod_est ub_prod_est yr if F_fuelswitch_dum == 0, color(navy)) (rcap lb_prod_est ub_prod_est yr if F_fuelswitch_dum== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingNextPeriod_year.pdf, replace
	graph twoway (connected prod_est_within_ind yr if F_fuelswitch_dum == 0) (connected prod_est_within_ind yr if F_fuelswitch_dum== 1) ///
	(rcap lb_prod_est_within_ind ub_prod_est_within_ind yr if F_fuelswitch_dum == 0, color(navy)) ///
	(rcap lb_prod_est_within_ind ub_prod_est_within_ind yr if F_fuelswitch_dum== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingNextPeriod_year-withinInd.pdf, replace
	graph twoway (connected prod_est_within_ind_fuelspend yr if F_fuelswitch_dum == 0) (connected prod_est_within_ind_fuelspend yr if F_fuelswitch_dum== 1) ///
	(rcap lb_prod_est_within_ind_fuelspend ub_prod_est_within_ind_fuelspend yr if F_fuelswitch_dum == 0, color(navy)) ///
	(rcap lb_prod_est_within_ind_fuelspend ub_prod_est_within_ind_fuelspend yr if F_fuelswitch_dum == 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingNextPeriod_year-withinInd-fuelspend.pdf, replace
restore
*3. Switching current period
preserve
	collapse (mean) (prod_est prod_est_within_ind prod_est_within_ind_fuelspend) (semean) ///
	(se_prod_est se_prod_est_within_ind se_prod_est_within_ind_fuelspend) ///
	(count) (n_prod_est n_prod_est_within_ind n_prod_est_within_ind_fuelspend), by(yr fuelswitch_dum)
	local vars prod_est prod_est_within_ind prod_est_within_ind_fuelspend
	foreach v of local vars {
		gen lb_`v' = `v' - invttail(n_`v'-1,0.025)*se_`v'
		gen ub_`v' = `v' + invttail(n_`v'-1,0.025)*se_`v'
	}
	graph twoway (connected prod_est yr if fuelswitch_dum == 0) (connected prod_est yr if fuelswitch_dum== 1) ///
	(rcap lb_prod_est ub_prod_est yr if fuelswitch_dum == 0, color(navy)) (rcap lb_prod_est ub_prod_est yr if fuelswitch_dum== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingCurrentPeriod_year.pdf, replace
	graph twoway (connected prod_est_within_ind yr if fuelswitch_dum == 0) (connected prod_est_within_ind yr if fuelswitch_dum== 1) ///
	(rcap lb_prod_est_within_ind ub_prod_est_within_ind yr if fuelswitch_dum == 0, color(navy)) ///
	(rcap lb_prod_est_within_ind ub_prod_est_within_ind yr if fuelswitch_dum== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingCurrentPeriod_year-withinInd.pdf, replace
	graph twoway (connected prod_est_within_ind_fuelspend yr if fuelswitch_dum == 0) (connected prod_est_within_ind_fuelspend yr if fuelswitch_dum== 1) ///
	(rcap lb_prod_est_within_ind_fuelspend ub_prod_est_within_ind_fuelspend yr if fuelswitch_dum == 0, color(navy)) ///
	(rcap lb_prod_est_within_ind_fuelspend ub_prod_est_within_ind_fuelspend yr if fuelswitch_dum== 1, color("178 34 34")), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher") label(3 "95% CI") label(4 "95% CI")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingCurrentPeriod_year-withinInd-fuelspend.pdf, replace
restore

* GRAPH: different in productivity across all years
preserve
	collapse (mean) prod_est_within_ind, by(totalswitch)
	lab var prod_est_within_ind "Mean of Productivity Estimate"
	graph dot (asis) prod_est_within_ind, over(totalswitch) title("Any period") name(g1)
restore
preserve
	collapse (mean) prod_est_within_ind, by(fuelswitch_dum)
	lab var prod_est_within_ind "Mean of Productivity Estimate"
	graph dot (asis) prod_est_within_ind, over(fuelswitch_dum) title("Year of switching") name(g2)
restore
preserve
	collapse (mean) prod_est_within_ind, by(F_fuelswitch_dum)
	lab var prod_est_within_ind "Mean of Productivity Estimate"
	graph dot (asis) prod_est_within_ind, over(F_fuelswitch_dum) title("Year before switching") name(g3)
restore
graph combine g1 g2 g3
graph export Output/Graphs/Switching/RevProd-withinInd-Switching.pdf, replace
graph drop  g1 g2 g3


* TABLE: t-test of difference between means (ACF)
eststo clear
estpost ttest prod_est_within_ind, by(totalswitch)
mat e1 = e(b)
mat list e1
estpost ttest prod_est_within_ind, by(fuelswitch_dum)
mat e2 = e(b)
mat list e2
estpost ttest prod_est_within_ind, by(F_fuelswitch_dum)
mat e3 = e(b)
mat list e3
estadd mat e1
estadd mat e2
estadd mat e3
esttab 
lab var prod_est_within_ind "Difference in mean productivity"
eststo clear
eststo mdl1, title("Any period"): estpost ttest prod_est_within_ind, by(totalswitch)
eststo mdl2, title("Year of switching"): estpost ttest prod_est_within_ind, by(fuelswitch_dum)
eststo mdl3, title("Year before switching"): estpost ttest prod_est_within_ind, by(F_fuelswitch_dum)
esttab mdl1 mdl2 mdl3 using "Output/Tables/Switching/Ttest_ProductivityDiff.tex", ///
title("T-test for Difference in mean productivity (non-switchers minus switchers)") mtitles label replace

* TABLE: t-test of difference between means (ACF, energy free)
eststo clear
estpost ttest prod_est_Efree_within, by(totalswitch)
mat e1 = e(b)
mat list e1
estpost ttest prod_est_Efree_within, by(fuelswitch_dum)
mat e2 = e(b)
mat list e2
estpost ttest prod_est_Efree_within, by(F_fuelswitch_dum)
mat e3 = e(b)
mat list e3
estadd mat e1
estadd mat e2
estadd mat e3
esttab 
lab var prod_est_Efree_within "Difference in mean productivity"
eststo clear
eststo mdl1, title("Any period"): estpost ttest prod_est_Efree_within, by(totalswitch)
eststo mdl2, title("Year of switching"): estpost ttest prod_est_Efree_within, by(fuelswitch_dum)
eststo mdl3, title("Year before switching"): estpost ttest prod_est_Efree_within, by(F_fuelswitch_dum)
esttab mdl1 mdl2 mdl3 using "Output/Tables/Switching/Ttest_ProductivityDiff_Efree.tex", ///
title("T-test for Difference in mean productivity (non-switchers minus switchers) - FE (Energy free)") mtitles label replace

* TABLE: t-test of difference between means (FE)
eststo clear
estpost ttest prod_est_fe_within, by(totalswitch)
mat e1 = e(b)
mat list e1
estpost ttest prod_est_fe_within, by(fuelswitch_dum)
mat e2 = e(b)
mat list e2
estpost ttest prod_est_fe_within, by(F_fuelswitch_dum)
mat e3 = e(b)
mat list e3
estadd mat e1
estadd mat e2
estadd mat e3
esttab 
lab var prod_est_fe_within "Difference in mean productivity"
eststo clear
eststo mdl1, title("Any period"): estpost ttest prod_est_fe_within, by(totalswitch)
eststo mdl2, title("Year of switching"): estpost ttest prod_est_fe_within, by(fuelswitch_dum)
eststo mdl3, title("Year before switching"): estpost ttest prod_est_fe_within, by(F_fuelswitch_dum)
esttab mdl1 mdl2 mdl3 using "Output/Tables/Switching/Ttest_ProductivityDiff_FE.tex", ///
title("T-test for Difference in mean productivity (non-switchers minus switchers) - FE") mtitles label replace

* TABLE: t-test of difference between means (OLS)
eststo clear
estpost ttest prod_est_ols_within, by(totalswitch)
mat e1 = e(b)
mat list e1
estpost ttest prod_est_ols_within, by(fuelswitch_dum)
mat e2 = e(b)
mat list e2
estpost ttest prod_est_ols_within, by(F_fuelswitch_dum)
mat e3 = e(b)
mat list e3
estadd mat e1
estadd mat e2
estadd mat e3
esttab 
lab var prod_est_ols_within "Difference in mean productivity"
eststo clear
eststo mdl1, title("Any period"): estpost ttest prod_est_ols_within, by(totalswitch)
eststo mdl2, title("Year of switching"): estpost ttest prod_est_ols_within, by(fuelswitch_dum)
eststo mdl3, title("Year before switching"): estpost ttest prod_est_ols_within, by(F_fuelswitch_dum)
esttab mdl1 mdl2 mdl3 using "Output/Tables/Switching/Ttest_ProductivityDiff_OLS.tex", ///
title("T-test for Difference in mean productivity (non-switchers minus switchers) - OLS") mtitles label replace

/*
*2. Switching next period
preserve
	collapse (mean) prod_est prod_est_within_ind prod_est_within_ind_fuelspend, by(yr F_fuelswitch_dum)
	graph twoway (connected prod_est yr if F_fuelswitch_dum == 0) (connected prod_est yr if F_fuelswitch_dum== 1), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingNextPeriod_year.pdf, replace
	graph twoway (connected prod_est_within_ind yr if F_fuelswitch_dum == 0) (connected prod_est_within_ind yr if F_fuelswitch_dum== 1), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingNextPeriod_year-withinInd.pdf, replace
	graph twoway (connected prod_est_within_ind_fuelspend yr if F_fuelswitch_dum == 0) (connected prod_est_within_ind_fuelspend yr if F_fuelswitch_dum== 1), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingNextPeriod_year-withinInd-fuelspend.pdf, replace
restore
*3. Switching current period
preserve
	collapse (mean) prod_est prod_est_within_ind prod_est_within_ind_fuelspend, by(yr fuelswitch_dum)
	graph twoway (connected prod_est yr if fuelswitch_dum == 0) (connected prod_est yr if fuelswitch_dum== 1), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingCurrentPeriod_year.pdf, replace
	graph twoway (connected prod_est_within_ind yr if fuelswitch_dum == 0) (connected prod_est_within_ind yr if fuelswitch_dum== 1), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingCurrentPeriod_year-withinInd.pdf, replace
	graph twoway (connected prod_est_within_ind_fuelspend yr if fuelswitch_dum == 0) (connected prod_est_within_ind_fuelspend yr if fuelswitch_dum== 1), graphregion(color(white)) ///
	legend(label(1 "Not a Switcher") label(2 "Switcher")) xlabel(2009[1]2017) xtitle("Year") ytitle("log Revenue productivity (ACF)")
	graph export Output/Graphs/Switching/RevProdSwitchingCurrentPeriod_year-withinInd-fuelspend.pdf, replace
restore
*/

*** TABLE: EFFECT OF VARIABLES ON SWITCHING ***
lab var networth "Net Worth"
lab val networth networth
lab var cash "Cash on Hand"
lab val cash cash
lab var  SalesPerWorker "Sales Per Worker"
lab val SalesPerWorker SalesPerWorker
lab var  L "Number of workers"
lab val L L
lab var  E "Electicity"
lab val E E
lab var age "Age"
lab val age age
lab var  F "Fuels"
lab val F F

gen logLeverage = log(leverage)
lab var logLeverage "Leverage (Debt to Assets)"
lab val logLeverage logLeverage
gen logNetworth = log(networth)
lab var logNetworth "Net Worth"
lab val logNetworth logNetworth
gen logCash = log(cash)
lab var logCash "Cash"
lab val logCash logCash
gen logSalesPerWorker = log(SalesPerWorker)
lab var logSalesPerWorker "Sales per Worker"
lab val logSalesPerWorker logSalesPerWorker
gen logAge = log(age)
lab var logAge "Age"
lab val logAge logAge
gen logLqty = log(L)
lab var logLqty "Number of workers"
lab val logLqty logLqty
gen logEqty = log(E)
lab var logEqty "Electricity"
lab val logEqty logEqty
gen logFqty = log(F)
lab var logFqty "Fuels"
lab val logFqty logEqty

* Log prices
bysort yr: egen avg_p_natgas_mmbtu = mean(p_natgas_mmbtu)
replace p_natgas_mmbtu = avg_p_natgas_mmbtu if p_natgas_mmbtu == .
bysort yr: egen avg_p_coal_mmbtu = mean(p_coal_mmbtu)
replace p_coal_mmbtu = avg_p_coal_mmbtu if p_coal_mmbtu == .
gen logP_oil_mmbtu = log(p_oil_mmbtu)
lab var logP_oil_mmbtu "Price of Oil"
lab val logP_oil_mmbtu logP_oil_mmbtu
gen logP_natgas_mmbtu = log(p_natgas_mmbtu)
lab var logP_natgas_mmbtu "Price of Natural Gas"
lab val logP_natgas_mmbtu logP_natgas_mmbtu
gen logP_coal_mmbtu = log(p_coal_mmbtu)
lab var logP_coal_mmbtu "Price of Coal"
lab val logP_coal_mmbtu logP_coal_mmbtu

lab var prod_est "Revenue productivity (ACF)"
lab val prod_est prod_est 

* Table 1: Switching same year
eststo clear
quietly probit fuelswitch_dum colreq logCash logEqty logFqty logLqty logAge if yr > 2009  // logEqty logFqty logLqty logAge
margins, dydx(*) post
eststo mdl1, title("Same period"): margins
quietly probit fuelswitch_dum colreq logCash logEqty logFqty logLqty logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu if yr > 2009 // logEqty logFqty logLqty logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu
margins, dydx(*) post
eststo mdl2, title("Same period"): margins
quietly probit fuelswitch_dum colreq logCash logEqty logFqty logLqty logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu i.ind4d if yr > 2009 // logEqty logFqty logLqty logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu i.ind4d
margins, dydx(*) post
eststo mdl3, title("Same period"): margins
esttab using "Output/Tables/Switching/SwitchingProbit_me.tex", title("Marginal effects, probability of switching (current period)") ///
star(+ 0.1 * 0.05 ** 0.01 *** 0.001) mtitles indicate(industry dummies = *ind4d) label replace ///
addnotes("All independent variables are in logs")

* Table 2: Switching next year
sort plant_id yr
xtset plant_id yr
eststo clear
quietly probit F.fuelswitch_dum colreq logCash logEqty logFqty logLqty logAge if yr > 2009 // logEqty logFqty logLqty logAge
margins, dydx(*) post
eststo mdl1, title("Next period"): margins
quietly probit F.fuelswitch_dum colreq logCash logEqty logFqty logLqty logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu if yr > 2009 // logEqty logFqty logLqty
margins, dydx(*) post
eststo mdl2, title("Next period"): margins
quietly probit F.fuelswitch_dum colreq logCash logEqty logFqty logLqty logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu i.ind4d if yr > 2009 // logEqty logFqty logLqty 
margins, dydx(*) post
eststo mdl3, title("Next period"): margins
esttab using "Output/Tables/Switching/SwitchingProbit_me_lag.tex", title("Marginal effects, probability of switching (next period)") ///
star(+ 0.1 * 0.05 ** 0.01 *** 0.001) mtitles indicate(industry dummies = *ind4d) ///
addnotes("All independent variables are in logs") label replace

/*
* Calculate polluting intensity of one unit of energy
gen pol_intensity = (gamma_oil*oil_s) + (gamma_natgas*natgas_s) + (gamma_coal*coal_s)
lab var pol_intensity "CO2e per mmbtu"
lab val pol_intensity pol_intensity
*/

* Table 2: Switching at any time
eststo clear
quietly probit totalswitch colreq logCash logEqty logFqty logLqty logAge if yr > 2009 // logEqty logFqty logLqty pol_intensity 
margins, dydx(*) post
eststo mdl1, title("any period"): margins
quietly probit totalswitch colreq logCash logEqty logFqty logLqty logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu if yr > 2009 // logEqty logFqty logLqty logP_natgas_mmbtu logP_coal_mmbtu
margins, dydx(*) post
eststo mdl2, title("any period"): margins
quietly probit totalswitch colreq logCash logEqty logFqty logLqty  logAge logP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu i.ind4d if yr > 2009 // logEqty logFqty logLqtylogP_oil_mmbtu logP_natgas_mmbtu logP_coal_mmbtu i.ind4d
margins, dydx(*) post
eststo mdl3, title("any period"): margins
esttab using "Output/Tables/Switching/SwitchingProbit_me_anyperiod.tex", title("Marginal effects, probability of switching (any period)") ///
star(+ 0.1 * 0.05 ** 0.01 *** 0.001) mtitles indicate(industry dummies = *ind4d) label replace ///
addnotes("All independent variables are in logs")

*----------------------------------------------------------------------------------------------------------------
* Investigate why productivity decreases prob of switching fuels after accounting for industry and fuel spending
*----------------------------------------------------------------------------------------------------------------



gen switchnatgas = 0
replace switchnatgas = 1 if fuelswitch_dum == 1 & L.natgas_mmbtu_norm == 0 & natgas_mmbtu_norm > 0
gen switchoil = 0
replace switchoil = 1 if fuelswitch_dum == 1 & L.oil_mmbtu_norm == 0 & oil_mmbtu_norm > 0
gen switchcoal = 0
replace switchcoal = 1 if fuelswitch_dum == 1 & L.coal_mmbtu_norm == 0 & coal_mmbtu_norm > 0






