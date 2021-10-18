set scheme burd

rename plantid plant_id
rename year yr
xtset plant_id yr
egen nyear = total(inrange(yr, 2011, 2018)), by(plant_id)
keep if nyear == 8

rename natgas natgas_mmbtu
rename oil oil_mmbtu
rename coal coal_mmbtu
rename fueltot fueltot_mmbtu
rename s_natgas natgas_s
rename s_oil oil_s
rename s_coal coal_s

*** Emission factors ***
* Coal
gen gamma_coal = 98.02503 + 25*(11/1000) + 298*(1.6/1000)
lab var gamma_coal "Emission Factor - Coal"
* Oil
gen gamma_oil = 71.19316 + 25*(3/1000) + 298*(0.6/1000)
lab var gamma_oil "Emission Factor - Oil"
* Natural Gas
gen gamma_natgas = 53.06 + (25/1000) + 298*(0.1/1000)
lab var gamma_natgas "Emission Factor - Natural Gas"

preserve
	collapse (sum) oil_mmbtu natgas_mmbtu coal_mmbtu fueltot_mmbtu, by(yr)
	gen oil_s = oil_mmbtu/fueltot_mmbtu
	gen natgas_s = natgas_mmbtu/fueltot_mmbtu
	gen coal_s = coal_mmbtu/fueltot_mmbtu
	graph twoway (connected natgas_s yr) (connected coal_s yr) (connected oil_s yr), ///
	graphregion(color(white)) legend(label(1 "Natural Gas") label(2 "Coal") label(3 "Oil")) ///
	xlabel(2011[1]2018)
	graph export Output/Graphs/USPlants/EnergyQuantityShare_year.pdf, replace
restore

* Define mixing relative to different thresholds:
gen fuelmix100 = 0
replace fuelmix100 = 1 if (coal_s != 1 & coal_s != .) & (oil_s != 1 & oil_s !=.) & (natgas_s != 1 & natgas_s !=.)
lab var fuelmix100 "Mixing between fuels"
gen fuelmix95 = 0
replace fuelmix95 = 1 if (coal_s < 0.95 & coal_s != .) & (oil_s < 0.95 & oil_s !=.) & (natgas_s < 0.95 & natgas_s !=.)
lab var fuelmix95 "Mixing betwen fuels, 95%"
gen fuelmix99 = 0
replace fuelmix99 = 1 if(coal_s < 0.99 & coal_s != .) & (oil_s < 0.99 & oil_s !=.) & (natgas_s < 0.99 & natgas_s !=.)
lab var fuelmix99 "Mixing betwen fuels, 99%"
gen fuelmix98 = 0
replace fuelmix98 = 1 if (coal_s < 0.98 & coal_s != .) & (oil_s < 0.98 & oil_s !=.) & (natgas_s < 0.98& natgas_s !=.)
lab var fuelmix98 "Mixing betwen fuels, 98%"
gen fuelmix90 = 0
replace fuelmix90 = 1 if (coal_s < 0.90 & coal_s != .) & (oil_s < 0.90 & oil_s !=.) & (natgas_s < 0.90 & natgas_s !=.)
lab var fuelmix90 "Mixing betwen fuels, 90%"

* Define switching
gen fuelswitch = 0
by plant_id: replace fuelswitch = 1 if (L.fuelmix100 == 0 & fuelmix100 == 0 & coal_s > 0 & L.coal_s == 0) ///
| (L.fuelmix100 == 0 & fuelmix100 == 0 & oil_s > 0 & L.oil_s == 0) ///
| (L.fuelmix100 == 0 & fuelmix100 == 0 & natgas_s > 0 & L.natgas_s == 0)
by plant_id: replace fuelswitch = 2 if L.fuelmix100 == 0 & fuelmix100 == 1
by plant_id: replace fuelswitch = 3 if L.fuelmix100 == 1 & fuelmix100 == 0
by plant_id: replace fuelswitch = 4 if (L.fuelmix100 == 1 & fuelmix100 == 1 & L.coal_s == 0 & coal_s > 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 1 & L.oil_s == 0 & oil_s > 0) ///
| (L.fuelmix100 == 1 & fuelmix100 == 1 & L.natgas_s == 0 & natgas_s > 0)
lab def fuelswitch 0 "No switching" 1 "Single to Single" 2 "Single to mixing" 3 "Mixing to single" 4 "Mixing to mixing", replace
lab val fuelswitch fuelswitch
* Dummy for switching in any category
gen fuelswitch_dum = 0
replace fuelswitch_dum = 1 if fuelswitch > 0

* TABLE : Count the number of unique firms that switch in any category
preserve
	collapse (sum) fuelswitch_dum, by(plant_id)
	replace fuelswitch_dum = 1 if fuelswitch_dum > 1
	egen totswitch = total(fuelswitch_dum)
	gen totnoswitch = _N-totswitch
	file close _all
	file open TabSwitchers using "Output/Tables/USPlants/nSwitchers.tex", write replace
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
	esttab using "Output/Tables/USPlants/nSwitchers_category_excl.tex", ///
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
by plant_id: gen totfuel_2009 = fueltot_mmbtu[1]
gen energy_norm = fueltot_mmbtu/totfuel_2009
gen natgas_mmbtu_norm = natgas_mmbtu/energy_norm
gen oil_mmbtu_norm = oil_mmbtu/energy_norm
gen coal_mmbtu_norm = coal_mmbtu/energy_norm

*--------------------------------------------
* Aggregate GHG emissions and decomposition
*--------------------------------------------

* GHG emissions (total)
gen ghg = gamma_oil*oil_mmbtu + gamma_coal*coal_mmbtu + gamma_natgas*natgas_mmbtu
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
	xlabel(2011[1]2018) ytitle("CO2e (billion tonnes)")
	graph export Output/Graphs/USPlants/AggGHG_year_BalancedPanel.pdf, replace
restore


*** GRAPH DECOMPOSITION OF CHANGE IN AGGREGATE GHG EMISSIONS - SWITCHING VS NOT SWITCHING (NEW)***
preserve
	xtset plant_id yr
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
	graph twoway (connected Diff_ghg_norm_switch yr if yr > 2011) (connected Diff_ghg_norm_noswitch yr if yr > 2011), graphregion(color(white)) yline(0) ///
	xlabel(2012[1]2018) legend(label(1 "Due to switching") label(2 "Not due to switching")) ytitle("CO2e (Billion tonnes)")
	graph export Output/Graphs/USPlants/GHGDiffDecomp_year_BalancedPanel.pdf, replace
	*** GRAPH: FRACTION OF CHANGE BETWEEN SWITCHING AND NO SWITCHING (ABSOLUTE VALUE) ***
	gen abs_switch = abs(Diff_ghg_norm_switch)
	gen abs_noswitch = abs(Diff_ghg_norm_noswitch)
	gen total_switch = abs_switch+abs_noswitch
	gen frac_switch = abs_switch/total_switch
	gen frac_noswitch = abs_noswitch/total_switch
	gen zero = 0
	gen perc1 = 1
	graph twoway (rarea zero frac_switch yr if yr > 2011) (rarea frac_switch perc1 yr if yr > 2011), ///
	legend(label(1 "Due to switching") label(2 "Not due to switching") pos(1)) graphregion(color(white)) ///
	xlabel(2012[1]2018)
	graph export Output/Graphs/USPlants/GHGDiffDecomp_BalancedPanel.pdf, replace
restore



























