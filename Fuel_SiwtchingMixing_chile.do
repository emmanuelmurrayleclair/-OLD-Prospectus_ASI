clear
use "D:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data\ChileAnalysis2.dta"
cd "D:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI"
xtset id year

*********************
*** Energy Shares ***
*********************

*** AGGREGATED (COAL, OIL NATGAS) ***
* Generate total fuel consumed
gen oil = petrval+diesval+benzval+parafval
gen natgas = lgasval+pgasval
gen coal = coalval+cokeval
gen fueltot_3f = oil+natgas+coal
* Fuel shares
gen coal_s = coal/fueltot_3f
gen oil_s = oil/fueltot_3f
gen natgas_s = natgas/fueltot_3f

*** DISAGGREGATED ***
* Generate total fuel and energy consumed
gen fueltot = coalval+cokeval+petrval+diesval+benzval+parafval+lgasval+pgasval+ofuelval+fwoodval
gen energytot = fueltot+elecbval+(elecgvol-elecsval)+ofuelval
* Electricity shares
gen s_elec = (elecbval+(elecgvol-elecsval))/energytot
drop if s_elec < 0 | s_elec > 1
* Fuel shares
gen s_coal = coalval/fueltot
gen s_coke = cokeval/fueltot
gen s_petr = petrval/fueltot
gen s_dies = diesval/fueltot
gen s_benz = benzval/fueltot
gen s_paraf = parafval/fueltot
gen s_lgas = lgasval/fueltot
gen s_pgas = pgasval/fueltot
gen s_oth = ofuelval/fueltot
gen s_wood = fwoodval/fueltot
* Fuel shares wrt total energy
gen se_coal = coalval/energytot
gen se_coke = cokeval/energytot
gen se_petr = petrval/energytot
gen se_dies = diesval/energytot
gen se_benz = benzval/energytot
gen se_paraf = parafval/energytot
gen se_lgas = lgasval/energytot
gen se_pgas = pgasval/energytot
gen se_oth = ofuelval/energytot
gen se_wood = fwoodval/energy
* Graph that compares average shares of each fuel
graph hbar (mean) se_coal se_coke se_petr se_dies se_benz se_paraf se_lgas se_pgas se_oth se_wood s_elec, ///
blabel(name) legend(off) scheme(s2manual) yvar(relabel(1 "Coal" 2 "Coke" 3 "Petrol" 4 "Diesel" 5 "Benzine" ///
 6 "Parafine" 7 "Liquid gas" 8 "Pipeline gas" 9 "Other" 10 "Wood" 11 "Elec")) 
graph export Output/Graphs/EnergyShares_Chile.pdf, replace
gen elecval = (elecbval+(elecgvol-elecsval))
graph hbar (mean) coalval cokeval petrval diesval benzval parafval lgasval pgasval ofuelval fwoodval elecval, ///
blabel(name) legend(off) scheme(s2manual) yvar(relabel(1 "Coal" 2 "Coke" 3 "Petrol" 4 "Diesel" 5 "Benzine" ///
 6 "Parafine" 7 "Liquid gas" 8 "Pipeline gas" 9 "Other" 10 "Wood" 11 "Elec")) 
graph export Output/Graphs/EnergySpending_Chile.pdf, replace

**************
*** Mixing ***
**************

*** AGGREGATED ***
* Define mixing relative to different thresholds:
gen fuelmix100_3f = 0
replace fuelmix100_3f = 1 if coal_s != 1 & oil_s != 1 & natgas_s != 1
gen fuelmix95_3f = 0
replace fuelmix95_3f = 1 if coal_s < 0.95 & oil_s < 0.95 & natgas_s < 0.95
gen fuelmix99_3f = 0
replace fuelmix99_3f = 1 if coal_s < 0.99 & oil_s < 0.99 & natgas_s < 0.99
gen fuelmix98_3f = 0
replace fuelmix98_3f = 1 if coal_s < 0.98 & oil_s < 0.98 & natgas_s < 0.98

*** DISAGGREGATED ***
* Define mixing relative to different thresholds:
gen fuelmix100 = 0
replace fuelmix100 = 1 if s_coal != 1 & s_coke != 1 & s_petr != 1 & s_dies != 1 & s_benz != 1 ///
& s_paraf != 1 & s_lgas != 1 & s_pgas != 1 & s_oth != 1 & s_wood != 1
gen fuelmix95 = 0
replace fuelmix95 = 1 if s_coal < 0.95 & s_coke < 0.95 & s_petr < 0.95 & s_dies < 0.96 & s_benz < 0.95 ///
& s_paraf < 0.95 & s_lgas < 0.95 & s_pgas < 0.95 & s_oth < 0.95  & s_wood < 0.95
gen fuelmix99 = 0
replace fuelmix99 = 1 if s_coal < 0.99 & s_coke < 0.99 & s_petr < 0.99 & s_dies < 0.99 & s_benz < 0.99 ///
& s_paraf < 0.99 & s_lgas < 0.99 & s_pgas < 0.99 & s_oth < 0.99 & s_wood < 0.99
gen fuelmix98 = 0
replace fuelmix98 = 1 if s_coal < 0.98 & s_coke < 0.98 & s_petr < 0.98 & s_dies < 0.98 & s_benz < 0.98 ///
& s_paraf < 0.98 & s_lgas < 0.98 & s_pgas < 0.98 & s_oth < 0.98 & s_wood < 0.98
* Define number of fuels firms typically mix
local vars s_coal s_coke s_petr s_dies s_benz s_paraf s_lgas s_pgas s_oth s_wood
gen nMixing = 0
foreach v of local vars {
	replace nMixing = nMixing + 1 if `v' < 0.95 & `v' > 0.05
}


****************************
*** Relevant observables ***
****************************

* Age
egen firstyear=min(year), by(id)
gen age = year-firstyear

* Sales
*salegds

* Size (average number of workers)
*avgemps

* Size (total number of workers)

* Profit
*netprof

* Exports
*exports

* Revenue productivity
gen revprod = salegds/totalcnt

**********************
*** Fuel switching ***
**********************

order id year coal_s oil_s natgas_s, last
* Replace fuel shares of firms who don't use any fuel
replace coal_s = 0 if coal_s == .
replace oil_s = 0 if oil_s == .
replace natgas_s = 0 if natgas_s == .


* Fully balanced panel
egen nyear = total(inrange(year, 1979, 1996)), by(id)
keep if nyear == 18

* Remove firms with non-consecutive years
*by id (year), sort: drop if year[_N]-year[1]+1 != _N


*** AGGREGATED ***
* Define switching when firms go from using a single fuel to another fuel or to mixing
gen fuel_switch_gradual = 0
gen fuel_switch = 0
local vars coal_s oil_s natgas_s
foreach v of local vars {
	* Includes gradual switching
	gen `v'_diff = abs(`v'-L.`v')
	replace fuel_switch_gradual = 1 if `v'_diff >= 0.25 & `v'_diff != .
	replace fuel_switch = 1 if `v'_diff >= 0.9 & `v'_diff != .
	*su year
	*local nyear = r(max)-r(min)	
	*forvalues i = 1/`nyear' {
	*	by id: 	replace fuel_switch = 1 if (`v' >= 0.99 & `v'[_n+`i'] <= 0.01)
	*}
	*replace fuel_switch = 1 if (`v' >= 0.99 & `v'[_n+1] <= 0.01)
	*replace fuel_switch = 1 if (`v' < 0.99 & L.`v' >= 0.99) & (L.`v' != . & `v' != .)
}
* Tag all firms that switch at some point
bysort id: egen avg_fuelswitch_gradual = mean(fuel_switch_gradual)
replace avg_fuelswitch_gradual = 1 if avg_fuelswitch_gradual > 0
bysort id: egen avg_fuelswitch = mean(fuel_switch)
replace avg_fuelswitch = 1 if avg_fuelswitch > 0


probit fuel_switch_gradual age revprod totalcnt

* Define switching when a firm switched for years following switching
su year
local nyear = r(max)-r(min)
forvalues i = 1/`nyear' {
	replace fuel_switch = 1 if L`i'.fuel_switch == 1
}
probit fuel_switch i.age avgemps revprod

preserve
	su year
	local nyear = r(max)-r(min)
	forvalues i = 1/`nyear' {
		by id: drop if fuel_switch == 0 & L`i'.fuel_switch == 1
	}
	
	local nyear = `r(max)'-`r(min)'
	by id: drop if fuel_switch == 0 & L.fuel_switch == 1
	by id: drop if fuel_switch == 0 & L1.fuel_switch == 1
	by id: drop if fuel_switch == 0 & L2.fuel_switch == 1
	by id: drop if fuel_switch == 0 & L.fuel_switch == 1
	by id: drop if fuel_switch == 0 & L.fuel_switch == 1
	by id: drop if fuel_switch == 0 & L.fuel_switch == 1
	by id: drop if fuel_switch == 0 & L.fuel_switch == 1
restore
 


* Define switching:


* Share of aggregated fuels (coal, oil and natural gas) wrt total fuels
gen s_coal = (s_coaldis + s_coke)/fueltot
gen s_oil = ()

* Define switching
