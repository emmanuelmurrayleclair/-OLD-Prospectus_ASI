*** CODEFILE 4 ver2***

********************************************************************
*** Analysis for Cement, Steel and Iron, Paper, Glass, Aluminium ***
********************************************************************

* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
use Data/Panel_Data/Clean_data/ASI_PanelClean-allind, clear
xtset IDnum year
set scheme burd
* Drop plants with only one observation
drop if nic08_3d == 351 // drop power plants
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 6
drop nyear
sort IDnum year
xtset IDnum year

********************************************************************
*** 1. DEFINE FUEL SWITCHING AND DESCRIPTIVE STATS ON SWITCHING
********************************************************************

* Only three main fuels
/*
rename TotCoal_mmbtu Coal_mmbtu
rename TotOil_mmbtu Oil_mmbtu
rename TotGas_mmbtu Gas_mmbtu
gen fuelswitch_to = 0
gen fuelswitch_off = 0
* Switching to a new fuel
by IDnum: replace fuelswitch_to = 1 if (L.Coal_mmbtu == 0 & Coal_mmbtu > 0 & Oil_mmbtu < L.Oil_mmbtu) | (L.Coal_mmbtu == 0 & Coal_mmbtu > 0 & Gas_mmbtu < L.Gas_mmbtu)
by IDnum: replace fuelswitch_to = 1 if (L.Oil_mmbtu == 0 & Oil_mmbtu > 0 & Coal_mmbtu < L.Coal_mmbtu) | (L.Oil_mmbtu == 0 & Oil_mmbtu > 0 & Gas_mmbtu < L.Gas_mmbtu)
by IDnum: replace fuelswitch_to = 1 if (L.Gas_mmbtu == 0 & Gas_mmbtu > 0 & Oil_mmbtu < L.Oil_mmbtu) | (L.Gas_mmbtu == 0 & Gas_mmbtu > 0 & Coal_mmbtu < L.Coal_mmbtu)
* Switching off previous fuel
by IDnum: replace fuelswitch_off = 1 if (L.Coal_mmbtu > 0 & Coal_mmbtu == 0 & Oil_mmbtu > L.Oil_mmbtu) | (L.Coal_mmbtu > 0 & Coal_mmbtu == 0 & Gas_mmbtu > L.Gas_mmbtu)
by IDnum: replace fuelswitch_off = 1 if (L.Oil_mmbtu > 0 & Oil_mmbtu == 0 & Coal_mmbtu > L.Coal_mmbtu) | (L.Oil_mmbtu > 0 & Oil_mmbtu == 0 & Gas_mmbtu > L.Gas_mmbtu)
by IDnum: replace fuelswitch_off = 1 if (L.Gas_mmbtu > 0 & Gas_mmbtu == 0 & Oil_mmbtu > L.Oil_mmbtu) | (L.Gas_mmbtu > 0 & Gas_mmbtu == 0 & Coal_mmbtu > L.Coal_mmbtu)
gen fuelswitch = 0
replace fuelswitch = 1 if fuelswitch_to == 1 | fuelswitch_off == 1
*/

* Including Electricity and other fuels
rename TotCoal coal
rename TotOil oil
rename TotGas gas
rename PurchValOtherFuel otherf
replace otherf = 0 if otherf == .
rename PurchValElecBought elec
replace elec = 0 if elec == .
gen fuelswitch_to = 0
gen fuelswitch_off = 0
foreach fuel in coal oil gas otherf elec {
	gen fuelswitch_to`fuel' = 0
	gen fuelswitch_off`fuel' = 0
}
* Switching to a new fuel
by IDnum: replace fuelswitch_tocoal = 1 if (L.coal == 0 & coal > 0 & oil < L.oil) | (L.coal == 0 & coal > 0 & gas < L.gas) ///
 | (L.coal == 0 & coal > 0 & otherf < L.otherf) | (L.coal == 0 & coal > 0 & elec < L.elec)
replace fuelswitch_to = 1 if fuelswitch_tocoal == 1
by IDnum: replace fuelswitch_tooil = 1 if (L.oil == 0 & oil > 0 & coal < L.coal) | (L.oil == 0 & oil > 0 & gas < L.gas) ///
 | (L.oil == 0 & oil > 0 & otherf < L.otherf) | (L.oil == 0 & oil > 0 & elec < L.elec)
replace fuelswitch_to = 1 if fuelswitch_tooil == 1
by IDnum: replace fuelswitch_togas = 1 if (L.gas == 0 & gas > 0 & coal < L.coal) | (L.gas == 0 & gas > 0 & oil < L.oil) ///
 | (L.gas == 0 & gas > 0 & otherf < L.otherf) | (L.gas == 0 & gas > 0 & elec < L.elec)
replace fuelswitch_to = 1 if fuelswitch_togas == 1
by IDnum: replace fuelswitch_toelec = 1 if (L.elec == 0 & elec > 0 & coal < L.coal) | (L.elec == 0 & elec > 0 & oil < L.oil) ///
 | (L.elec == 0 & elec > 0 & otherf < L.otherf) | (L.elec == 0 & elec > 0 & gas < L.gas)
replace fuelswitch_to = 1 if fuelswitch_toelec == 1
by IDnum: replace fuelswitch_tootherf= 1 if (L.otherf == 0 & otherf > 0 & coal < L.coal) | (L.otherf == 0 & otherf > 0 & oil < L.oil) ///
 | (L.otherf == 0 & otherf > 0 & elec < L.elec) | (L.otherf == 0 & otherf > 0 & gas < L.gas)
replace fuelswitch_to = 1 if fuelswitch_tootherf == 1
* Switching off previous fuel
by IDnum: replace fuelswitch_offcoal = 1 if (L.coal > 0 & coal == 0 & oil > L.oil) | (L.coal > 0 & coal == 0 & gas > L.gas) ///
 | (L.coal > 0 & coal == 0 & otherf > L.otherf) | (L.coal > 0 & coal == 0 & elec > L.elec)
replace fuelswitch_off = 1 if fuelswitch_offcoal == 1
by IDnum: replace fuelswitch_offoil = 1 if (L.oil > 0 & oil == 0 & coal > L.coal) | (L.oil > 0 & oil == 0 & gas > L.gas) ///
 | (L.oil > 0 & oil == 0 & otherf > L.otherf) | (L.oil > 0 & oil == 0 & elec > L.elec)
replace fuelswitch_off = 1 if fuelswitch_offoil == 1
by IDnum: replace fuelswitch_offgas = 1 if (L.gas > 0 & gas == 0 & coal > L.coal) | (L.gas > 0 & gas == 0 & oil > L.oil) ///
 | (L.gas > 0 & gas == 0 & otherf > L.otherf) | (L.gas > 0 & gas == 0 & elec > L.elec)
replace fuelswitch_off = 1 if fuelswitch_offgas == 1
by IDnum: replace fuelswitch_offelec = 1 if (L.elec > 0 & elec == 0 & coal > L.coal) | (L.elec > 0 & elec == 0 & oil > L.oil) ///
 | (L.elec > 0 & elec == 0 & otherf > L.otherf) | (L.elec > 0 & elec == 0 & gas > L.gas)
replace fuelswitch_off = 1 if fuelswitch_offelec == 1
by IDnum: replace fuelswitch_offotherf= 1 if (L.otherf > 0 & otherf == 0 & coal > L.coal) | (L.otherf > 0 & otherf == 0 & oil > L.oil) ///
 | (L.otherf > 0 & otherf == 0 & elec > L.elec) | (L.otherf > 0 & otherf == 0 & gas > L.gas)
replace fuelswitch_off = 1 if fuelswitch_offotherf == 1

* TABLE : Count the number of unique firms that switch in any category
preserve
	collapse (sum) fuelswitch_to fuelswitch_off, by(IDnum)
	replace fuelswitch_to = 1 if fuelswitch_to >= 1
	replace fuelswitch_off = 1 if fuelswitch_off >= 1
	gen fuelswitch_both = 1 if fuelswitch_to == 1 & fuelswitch_off == 1
	file open TabSwitchers using Output/Tables/Switching/nSwitchers.tex, write replace
	file write TabSwitchers "& Plants who switch to new fuel & Plants who switch off existing fuel & Plants who do both \\ \midrule"_n
	su fuelswitch_to if fuelswitch_to == 1
	local frac_to: di %12.2f r(N)/_N
	su fuelswitch_off if fuelswitch_off == 1
	local frac_off: di %12.2f r(N)/_N
	su fuelswitch_both if fuelswitch_both == 1
	local frac_both: di %12.2f r(N)/_N
	file write TabSwitchers "`frac_to' & `frac_off' & `frac_both' \\"_n
	file write TabSwitchers "\bottomrule"
	file close _all
restore

* GRAPH : Proportion of plants switching to and off each fuel
preserve
	collapse (sum) fuelswitch_to* fuelswitch_off*
	gen to_coal = fuelswitch_tocoal/fuelswitch_to
	gen to_oil = fuelswitch_tooil/fuelswitch_to
	gen to_gas = fuelswitch_togas/fuelswitch_to
	gen to_elec = fuelswitch_toelec/fuelswitch_to
	gen to_otherf = fuelswitch_tootherf/fuelswitch_to
	gen off_coal = fuelswitch_offcoal/fuelswitch_off
	gen off_oil = fuelswitch_offoil/fuelswitch_off
	gen off_gas = fuelswitch_offgas/fuelswitch_off
	gen off_elec = fuelswitch_offelec/fuelswitch_off
	gen off_otherf = fuelswitch_offotherf/fuelswitch_off
	graph bar (asis) to_coal to_oil to_gas to_elec to_otherf
	graph export Output/Graphs/Switching/ProportionSwitch_toFuels-selectedind.pdf, replace
	graph bar (asis) off_coal off_oil off_gas off_elec off_otherf
	graph export Output/Graphs/Switching/ProportionSwitch_offFuels-selectedind.pdf, replace
restore

* Tag plants that switch at least once
gen fuelswitch = 0
replace fuelswitch = 1 if fuelswitch_to == 1 | fuelswitch_off == 1
bysort IDnum: egen switch_anyyear = max(fuelswitch)
bysort IDnum: egen switch_to_anyyear = max(fuelswitch_to)
bysort IDnum: egen switch_off_anyyear = max(fuelswitch_off)

bysort IDnum: egen switch_togas_anyyear = max(fuelswitch_togas)
bysort IDnum: egen switch_offgas_anyyear = max(fuelswitch_offgas)
bysort IDnum: egen switch_tocoal_anyyear = max(fuelswitch_tocoal)
bysort IDnum: egen switch_offcoal_anyyear = max(fuelswitch_offcoal)
bysort IDnum: egen switch_tooil_anyyear = max(fuelswitch_tooil)
bysort IDnum: egen switch_offoil_anyyear = max(fuelswitch_offoil)


********************************************************************
*** 2. RELATIONSHIP BETWEEN SWITCHING AND OTHER VARIABLES
********************************************************************

* Measure of Energy (quantity)
gen F = fueltot_mmbtu
* Measure of electricity
gen E = elecb_mmbtu
* Inputs in production technology (Intermediate inputs and energy separately)
gen L = PersonsTotal
gen Lspend = TotalEmoluments
gen Espend = elec
egen Fspend = rsum(coal gas oil otherf)
gen Mspend = TotalInputs-Espend-Fspend
gen Kspend = Capital
gen Yspend = TotalOutput
* Sales per worker (proxy for productivity)
gen SalesPerWorker = Yspend/L
* Convert units from rupees to lakhs (100,000 rupees)
replace Mspend = Mspend/100000
replace Espend = Espend/100000
replace Kspend = Kspend/100000
replace Lspend = Lspend/100000
replace Fspend = Fspend/100000
replace Yspend = Yspend/100000
gen EnerSpend = Espend+Fspend
replace SalesPerWorker = SalesPerWorker/100000
* Prepare Revenue production function estimation
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
lab def fuelswitch 0 "Not Switching" 1 "Switching", replace
lab def fuelswitch_to 0 "Not Switching" 1 "Switching", replace
lab def fuelswitch_off 0 "Not Switching" 1 "Switching", replace
lab def switch_anyyear 0 "Not Switching" 1 "Switching", replace
lab def switch_to_anyyear 0 "Not Switching" 1 "Switching", replace
lab def switch_off_anyyear 0 "Not Switching" 1 "Switching", replace
lab val fuelswitch fuelswitch
lab val fuelswitch_to fuelswitch_to
lab val fuelswitch_off fuelswitch_off
lab val switch_anyyear switch_anyyear
lab val switch_to_anyyear switch_to_anyyear
lab val switch_off_anyyear switch_off_anyyear


* Production function estimation
* ACF (energy fixed)
acfest logY, free(logL) state(logK logEner) proxy(logM) i(IDnum) t(year)
predict prod_est, omega
reg prod_est i.nic08_4d
predict prod_est_acf, residuals
reg prod_est_acf i.fuelswitch
reg prod_est_acf i.fuelswitch_to
reg prod_est_acf i.fuelswitch_off
reg prod_est_acf i.switch_anyyear
reg prod_est_acf i.switch_to_anyyear
reg prod_est_acf i.switch_off_anyyear

* ACF (energy free)
acfest logY, free(logL logEner) state(logK) proxy(logM) i(IDnum) t(year)
predict prod_est_Efree, omega
reg prod_est_Efree i.nic08_4d
predict prod_est_acfEfree, residuals
reg prod_est_acfEfree i.fuelswitch
reg prod_est_acfEfree i.fuelswitch_to
reg prod_est_acfEfree i.fuelswitch_off
reg prod_est_acfEfree i.switch_anyyear
reg prod_est_acfEfree i.switch_to_anyyear
reg prod_est_acfEfree i.switch_off_anyyear

* FE
xtreg logY logL logK logEner logM , fe
predict prod_est_fe, ue
reg prod_est_fe i.nic08_4d
predict prod_est_fe_res, residuals
reg prod_est_fe_res i.fuelswitch
reg prod_est_fe_res i.fuelswitch_to
reg prod_est_fe_res i.fuelswitch_off
reg prod_est_fe_res i.switch_anyyear
reg prod_est_fe_res i.switch_to_anyyear
reg prod_est_fe_res i.switch_off_anyyear

* OLS
reg logY logL logK logEner logM i.nic08_4d
predict prod_est_ols_within, residuals
reg prod_est_ols_within i.fuelswitch
reg prod_est_ols_within i.fuelswitch_to
reg prod_est_ols_within i.fuelswitch_off
reg prod_est_ols_within i.switch_anyyear
reg prod_est_ols_within i.switch_to_anyyear
reg prod_est_ols_within i.switch_off_anyyear

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
