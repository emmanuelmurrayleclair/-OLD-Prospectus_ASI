*** CODEFILE 6 ver1***

********************************************************************
*** Analysis for Cement, Steel and Iron, Paper, Glass, Aluminium ***
********************************************************************

* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
use Data/Panel_Data/Clean_data/ASI_PanelClean-selectedind, clear
xtset IDnum year
set scheme burd
* Remove outliers (some extremely large natural gas prices)
su pgas_mmbtu, detail
keep if pgas_mmbtu < r(p99) | pgas_mmbtu ==.
* Keep plants with subsequent years only
egen max_gap = max(year - year[_n-1]), by(IDnum)
keep if max_gap == 1
* (Partially) balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 8
drop nyear
sort IDnum year
xtset IDnum year


********************************************************************
*** 1. DEFINE FUEL SWITCHING AND DESCRIPTIVE STATS ON SWITCHING
********************************************************************

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
	gen fuelswitch_to`fuel' = 1
	gen fuelswitch_off`fuel' = 1
}

* Count number of lags/leads for each plant/year pair
sort IDnum year
forvalues i = 1/7 {
	gen L`i'tag = 1 if L`i'.Open != .
	gen F`i'tag = 1 if F`i'.Open != .
}
egen nLags = rsum(L1tag L2tag L3tag L4tag L5tag L6tag L7tag)
egen nLeads = rsum(F1tag F2tag F3tag F4tag F5tag F6tag F7tag)
drop L1tag-F7tag

* Switching to a new fuel or switching off an old fuel (needs to be permanent)
foreach fuel in coal oil gas other elec {
	forvalues i = 1/7 {
		replace fuelswitch_to`fuel' = 0 if `fuel' > 0 & L`i'.`fuel' > 0 & nLags >= `i'
		replace fuelswitch_to`fuel' = 0 if `fuel' > 0 & F`i'.`fuel' == 0 & nLeads >= `i'
		replace fuelswitch_off`fuel' = 0 if `fuel' == 0 & L`i'.`fuel' == 0 & nLags >= `i'
		replace fuelswitch_off`fuel' = 0 if `fuel' == 0 & F`i'.`fuel' > 0 & nLeads >= `i'
	}
	replace fuelswitch_to`fuel' = 0 if nLags == 0
	replace fuelswitch_off`fuel' = 0 if nLags == 0
	replace fuelswitch_to`fuel' = 0 if `fuel' == 0
	replace fuelswitch_off`fuel' = 0 if `fuel' > 0
}
replace fuelswitch_to = 1 if fuelswitch_tocoal == 1 | fuelswitch_tooil == 1 | fuelswitch_togas == 1 | fuelswitch_tootherf == 1 | fuelswitch_toelec == 1
replace fuelswitch_off = 1 if fuelswitch_offcoal == 1 | fuelswitch_offoil == 1 | fuelswitch_offgas == 1 | fuelswitch_offotherf == 1 | fuelswitch_offelec == 1

sort IDnum year
order IDnum year fuelswitch_to fuelswitch_off coal oil gas otherf elec, last

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
* GRAPH : Proportion of plants switching to Gas vs Off Gas
preserve
	collapse (sum) fuelswitch_togas fuelswitch_offgas
	gen switch_gas = fuelswitch_togas + fuelswitch_offgas
	gen s_togas = fuelswitch_togas/switch_gas
	gen s_offgas = fuelswitch_offgas/switch_gas
	graph bar (asis) s_togas s_offgas
	graph export Output/Graphs/Switching/ProportionSwitch_ToAndOffGas-SelectedInd.pdf, replace
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
bysort IDnum: egen switch_tootherf_anyyear = max(fuelswitch_tootherf)
bysort IDnum: egen switch_offotherf_anyyear = max(fuelswitch_offotherf)
bysort IDnum: egen switch_toelec_anyyear = max(fuelswitch_toelec)
bysort IDnum: egen switch_offelec_anyyear = max(fuelswitch_offelec)

********************************************************************
*** 2. RELATIONSHIP BETWEEN SWITCHING AND OTHER VARIABLES
********************************************************************

* Number of output
egen nProduct = rownonmiss(ExFactoryValueOutput1 ExFactoryValueOutput2 ExFactoryValueOutput3 ExFactoryValueOutput4 ExFactoryValueOutput5 ///
ExFactoryValueOutput6 ExFactoryValueOutput7 ExFactoryValueOutput8 ExFactoryValueOutput9 ExFactoryValueOutput10 ExFactoryValueOther)
* Change in number of products (output)
bysort IDnum: gen Delta_nProduct = nProduct-L.nProduct
* District indicator
egen DistrictNum = group(DistrictCode StateCode)
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
foreach fuel in coal oil gas otherf elec {
	lab def fuelswitch_to`fuel' 0 "Not Switching" 1 "Switching", replace
	lab var fuelswitch_to`fuel' "Switching to `fuel' in current year"
	lab def fuelswitch_off`fuel' 0 "Not Switching" 1 "Switching", replace
	lab var fuelswitch_off`fuel' "Switching off `fuel' in current year"
	lab def switch_to`fuel'_anyyear 0 "Not Switching" 1 "Switching", replace
	lab var switch_to`fuel'_anyyear "Switching to `fuel' in any year"
	lab def switch_off`fuel'_anyyear 0 "Not Switching" 1 "Switching", replace
	lab var switch_off`fuel'_anyyear "Switching off `fuel' in current year"
}
lab val fuelswitch fuelswitch
lab val fuelswitch_to fuelswitch_to
lab val fuelswitch_off fuelswitch_off
lab val switch_anyyear switch_anyyear
lab val switch_to_anyyear switch_to_anyyear
lab val switch_off_anyyear switch_off_anyyear

* Investment
gen I = Capital-L.Capital
gen logI = log(I)
reg I fuelswitch_to
reg I fuelswitch_togas
reg logI fuelswitch_to
reg logI fuelswitch_togas


* Production function estimation
* ACF (energy fixed)
acfest logY, free(logL) state(logK logEner) proxy(logM) i(IDnum) t(year)
predict prod_est_acfEfixed, omega
* ACF (energy free)
acfest logY, free(logL logEner) state(logK) proxy(logM) i(IDnum) t(year)
predict prod_est_acfEfree, omega
* FE
xtreg logY logL logK logEner logM , fe
predict prod_est_fe, ue
* OLS
reg logY logL logK logEner logM
predict prod_est_ols, residuals
/* 
levelsof nic08_4d, local(in)
foreach i of local in {
	reg logY logL logK logEner logM if nic08_4d == `i'
	predict prod_est`i' if nic08_4d == `i', residuals
	*replace prod_est`i' = prod_est`i' + _cons if nic08_4d== `i'
	replace prod_est`i' = prod_est`i' if nic08_4d== `i'
	replace prod_est`i' = 0 if prod_est`i' ==.
}
gen prod_est_ols = prod_est1701 + prod_est2394 + prod_est2410 + prod_est2310 + prod_est2420
*/

********************************************************************
*** 3. TABLES FOR RELATIONSHIP BETWEEN SWITCHING AND PRODUCTIVITY
********************************************************************

* Table: Effect of switching to any fuel on productivity 
eststo clear
eststo mdl1: reg prod_est_ols i.fuelswitch_to i.nic08_4d i.DistrictNum
eststo mdl2: reg prod_est_ols i.switch_to_anyyear i.nic08_4d i.DistrictNum
eststo mdl3: reg prod_est_fe i.fuelswitch_to i.nic08_4d i.DistrictNum
eststo mdl4: reg prod_est_fe i.switch_to_anyyear i.nic08_4d i.DistrictNum
eststo mdl5: reg prod_est_acfEfree i.fuelswitch_to i.nic08_4d i.DistrictNum
eststo mdl6: reg prod_est_acfEfree i.switch_to_anyyear i.nic08_4d i.DistrictNum
eststo mdl7: reg prod_est_acfEfixed i.fuelswitch_to i.nic08_4d i.DistrictNum
eststo mdl8: reg prod_est_acfEfixed i.switch_to_anyyear i.nic08_4d i.DistrictNum
esttab using "Output/Tables/Switching/Switching_toanyfuel-SelectedInd.tex", label wide ///
	 unstack mtitles("OLS" "" "FE" "" "ACF (Energy Free)" "" "ACF (Energy Fixed)" "") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Relationship between productivity and switching to natural gas") indicate("industry dummies = *nic08_4d" "district dummies = *DistrictNum") nocons ///
	 addnotes("In last two columns, productivity estimate comes from PFE using ACF method by treating Energy as fixed input within year") replace
* Table: Effect of switching to natural gas on productivity 
eststo clear
eststo mdl1: reg prod_est_ols i.fuelswitch_togas i.nic08_4d i.DistrictNum
eststo mdl2: reg prod_est_ols i.switch_togas_anyyear i.nic08_4d i.DistrictNum
eststo mdl3: reg prod_est_fe i.fuelswitch_togas i.nic08_4d i.DistrictNum
eststo mdl4: reg prod_est_fe i.switch_togas_anyyear i.nic08_4d i.DistrictNum
eststo mdl5: reg prod_est_acfEfree i.fuelswitch_togas i.nic08_4d i.DistrictNum
eststo mdl6: reg prod_est_acfEfree i.switch_togas_anyyear i.nic08_4d i.DistrictNum
eststo mdl7: reg prod_est_acfEfixed i.fuelswitch_togas i.nic08_4d i.DistrictNum
eststo mdl8: reg prod_est_acfEfixed i.switch_togas_anyyear i.nic08_4d i.DistrictNum
esttab using "Output/Tables/Switching/Switching_togas-SelectedInd.tex", label wide ///
	 unstack mtitles("OLS" "" "FE" "" "ACF (Energy Free)" "" "ACF (Energy Fixed)" "") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Relationship between productivity and switching to natural gas") indicate("industry dummies = *nic08_4d" "district dummies = *DistrictNum") nocons ///
	 addnotes("In last two columns, productivity estimate comes from PFE using ACF method by treating Energy as fixed input within year") replace
* Table: Effect of switching off natural gas on productivity 
eststo clear
eststo mdl1: reg prod_est_ols i.fuelswitch_offgas i.nic08_4d i.DistrictNum
eststo mdl2: reg prod_est_ols i.switch_offgas_anyyear i.nic08_4d i.DistrictNum
eststo mdl3: reg prod_est_fe i.fuelswitch_offgas i.nic08_4d i.DistrictNum
eststo mdl4: reg prod_est_fe i.switch_offgas_anyyear i.nic08_4d i.DistrictNum
eststo mdl5: reg prod_est_acfEfree i.fuelswitch_offgas i.nic08_4d i.DistrictNum
eststo mdl6: reg prod_est_acfEfree i.switch_offgas_anyyear i.nic08_4d i.DistrictNum
eststo mdl7: reg prod_est_acfEfixed i.fuelswitch_offgas i.nic08_4d i.DistrictNum
eststo mdl8: reg prod_est_acfEfixed i.switch_offgas_anyyear i.nic08_4d i.DistrictNum
esttab using "Output/Tables/Switching/Switching_offgas-SelectedInd.tex", label wide ///
	 unstack mtitles("OLS" "" "FE" "" "ACF (Energy Free)" "" "ACF (Energy Fixed)" "") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Relationship between productivity and switching off natural gas") indicate("industry dummies = *nic08_4d" "district dummies = *DistrictNum") nocons ///
	 addnotes("In last two columns, productivity estimate comes from PFE using ACF method by treating Energy as fixed input within year") replace
* Table: Effect of switching to coal on productivity 
eststo clear
eststo mdl1: reg prod_est_ols i.fuelswitch_tocoal i.nic08_4d i.DistrictNum
eststo mdl2: reg prod_est_ols i.switch_tocoal_anyyear i.nic08_4d i.DistrictNum
eststo mdl3: reg prod_est_fe i.fuelswitch_tocoal i.nic08_4d i.DistrictNum
eststo mdl4: reg prod_est_fe i.switch_tocoal_anyyear i.nic08_4d i.DistrictNum
eststo mdl5: reg prod_est_acfEfree i.fuelswitch_tocoal i.nic08_4d i.DistrictNum
eststo mdl6: reg prod_est_acfEfree i.switch_tocoal_anyyear i.nic08_4d i.DistrictNum
eststo mdl7: reg prod_est_acfEfixed i.fuelswitch_tocoal i.nic08_4d i.DistrictNum
eststo mdl8: reg prod_est_acfEfixed i.switch_tocoal_anyyear i.nic08_4d i.DistrictNum
esttab using "Output/Tables/Switching/Switching_tocoal-SelectedInd.tex", label wide ///
	 unstack mtitles("OLS" "" "FE" "" "ACF (Energy Free)" "" "ACF (Energy Fixed)" "") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Relationship between productivity and switching to coal") indicate("industry dummies = *nic08_4d" "district dummies = *DistrictNum") nocons ///
	 addnotes("In last two columns, productivity estimate comes from PFE using ACF method by treating Energy as fixed input within year") replace
* Table: Effect of switching off coal on productivity 
eststo clear 
eststo mdl1: reg prod_est_ols i.fuelswitch_offcoal i.nic08_4d i.DistrictNum
eststo mdl2: reg prod_est_ols i.switch_offcoal_anyyear i.nic08_4d i.DistrictNum
eststo mdl3: reg prod_est_fe i.fuelswitch_offcoal i.nic08_4d i.DistrictNum
eststo mdl4: reg prod_est_fe i.switch_offcoal_anyyear i.nic08_4d i.DistrictNum
eststo mdl5: reg prod_est_acfEfree i.fuelswitch_offcoal i.nic08_4d i.DistrictNum
eststo mdl6: reg prod_est_acfEfree i.switch_offcoal_anyyear i.nic08_4d i.DistrictNum
eststo mdl7: reg prod_est_acfEfixed i.fuelswitch_offcoal i.nic08_4d i.DistrictNum
eststo mdl8: reg prod_est_acfEfixed i.switch_offcoal_anyyear i.nic08_4d i.DistrictNum
esttab using "Output/Tables/Switching/Switching_offcoal-SelectedInd.tex", label wide ///
	 unstack mtitles("OLS" "" "FE" "" "ACF (Energy Free)" "" "ACF (Energy Fixed)" "") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Relationship between productivity and switching off coal") indicate("industry dummies = *nic08_4d" "district dummies = *DistrictNum") nocons ///
	 addnotes("In last two columns, productivity estimate comes from PFE using ACF method by treating Energy as fixed input within year") replace

	 
***********************************************************************
*** 4. TABLE CONDITIONAL PROBABILTIY OF SWITCHING TO GAS
***********************************************************************

* Label variables that define proximity to gas pipelines
replace Connection = 0 if Connection == .
lab def Connection 0 "No Connection", add
replace Zone = 0 if Zone == .
gen PipelineAccess = 0
replace PipelineAccess = 1 if Connection == 1 & Zone == 1
replace PipelineAccess = 2 if Connection == 1 & Zone == 2
replace PipelineAccess = 3 if Connection == 1 & Zone == 3
replace PipelineAccess = 4 if Connection == 1 & Zone == 4
replace PipelineAccess = 5 if Connection == 2 & Zone == 1
replace PipelineAccess = 6 if Connection == 2 & Zone == 2
replace PipelineAccess = 7 if Connection == 2 & Zone == 3
replace PipelineAccess = 8 if Connection == 2 & Zone == 4
lab def PipelineAccess 0 "No Connection"  1 "Direct Access, Zone 1" 2 "Direct Access, Zone 2" 3 "Direct Access, Zone 3" ///
4 "Direct Access, Zone 4" 5 "Indirect Access, Zone 1" 6 "Indirect Access, Zone 2" 7 "Indirect Access, Zone 3" 8 "Indirect Access, Zone 4", modify
lab val PipelineAccess PipelineAccess

* Table: Conditional Probability of Switching to Gas
eststo clear
eststo mdl1: probit fuelswitch_togas i.PipelineAccess Delta_nProduct i.nic08_4d
eststo mdl2: probit switch_togas_anyyear i.PipelineAccess nProduct i.nic08_4d
esttab using "Output/Tables/Switching/CondProbability_SwitchingGas-SelectedInd.tex", label wide ///
	 unstack mtitles("Plant Switching Current Year" "Plant Switching Any Year") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Conditional Probability of Switching to Gas") indicate(industry dummies = *nic08_4d) nocons replace

***********************************************************************
*** 5. RELATIONSHIP BETWEEN PRODUCTIVITY AND PROXIMITY TO GAS PIPELINE
***********************************************************************

* Effect of pipeline proximity on productivity conditional on using natural gas
eststo clear
eststo mdl1: reg prod_est_ols i.PipelineAccess if gas > 0
eststo mdl2: reg prod_est_fe i.PipelineAccess if gas > 0
eststo mdl3: reg prod_est_acfEfixed i.PipelineAccess if gas > 0
eststo mdl4: reg prod_est_acfEfree i.PipelineAccess if gas > 0
esttab using "Output/Tables/Productivity_PipelineAccess-SelectedInd.tex", label wide ///
	 unstack mtitles("OLS" "FE" "ACF (Energy Free)" "ACF (Energy Fixed)") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Effect of Pipeline Proximity on Productivity for plants who use Gas") nocons ///
	 addnotes("In last two columns, productivity estimate comes from PFE using ACF method by treating Energy as fixed input within year") replace
	 
***********************************************************************
*** 6. TABLE FOR GAS USEAGE AND ENERGY EFFICIENCY
***********************************************************************
* Energy Efficiency
egen energy_mmbtu = rsum(TotGas_mmbtu TotCoal_mmbtu TotOil_mmbtu elecb_mmbtu eleco_mmbtu)
egen energy_spending = rsum(gas coal oil elec otherf)
gen EnergyEfficiency_mmbtu = energy_mmbtu/Output
gen logEnergyEfficiency_mmbtu = log(EnergyEfficiency_mmbtu)
gen EnergyEfficiency = energy_spending/Output
gen logEnergyEfficiency = log(EnergyEfficiency)
* Indicator for fuel useage
gen I_gas_mmbtu =  0
replace I_gas_mmbtu = 1 if TotGas_mmbtu > 0
lab var I_gas_mmbtu "Natural Gas - mmbtu"
gen I_gas = 0
replace I_gas = 1 if gas > 0
lab var I_gas "Natural Gas"
gen I_oil_mmbtu =  0
replace I_oil_mmbtu = 1 if TotOil_mmbtu > 0
lab var I_oil_mmbtu "Oil - mmbtu"
gen I_oil = 0
replace I_oil = 1 if oil > 0
lab var I_oil "Oil"
gen I_coal_mmbtu =  0
replace I_coal_mmbtu = 1 if TotCoal_mmbtu > 0
lab var I_coal_mmbtu "Coal - mmbtu"
gen I_coal = 0
replace I_coal = 1 if coal > 0
lab var I_coal "Coal"
gen I_elec_mmbtu =  0
replace I_elec_mmbtu = 1 if elecb_mmbtu > 0 | eleco_mmbtu > 0
lab var I_elec_mmbtu "Electricity - mmbtu"
gen I_elec = 0
replace I_elec = 1 if elec > 0
lab var I_elec "Electricity"
gen I_otherf = 0
replace I_otherf = 1 if otherf > 0
lab var I_otherf "Other Fuel"
* Indicator for period post switching to natural gas
gen fuelswitch_togas_post = 0
gen YearofSwitch = year if fuelswitch_togas == 1
bysort IDnum: egen YearofSwitch_tag = max(YearofSwitch)
replace fuelswitch_togas_post = 1 if year >= YearofSwitch_tag
lab var fuelswitch_togas_post "Years Post switching to Gas"

eststo clear
eststo mdl1: reg logEnergyEfficiency_mmbtu i.I_gas_mmbtu i.I_oil_mmbtu i.I_coal_mmbtu i.I_elec_mmbtu i.fuelswitch_togas_post i.nic08_4d
eststo mdl2: reg logEnergyEfficiency i.I_gas i.I_oil i.I_coal i.I_elec i.I_otherf i.fuelswitch_togas_post i.nic08_4d
esttab using "Output/Tables/Switching/EnergyIntensity_Switching-SelectedInd.tex", label wide ///
	 unstack mtitles("Energy Intensity (mmbtu)" "Energy Intensity (Spending)") booktabs star(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
	 p title("Effect of different fuel useage on energy efficiency") indicate(industry dummies = *nic08_4d) nocons replace


