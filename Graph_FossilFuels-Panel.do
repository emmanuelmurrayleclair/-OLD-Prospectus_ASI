*** CODEFILE 5 ***

**** This file creates graphs/tables for reduced-form evidence of fuel switching

* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
use Data/Panel_Data/Clean_data/ASI_PanelCleanFinal.dta, clear
egen IDnum = group(ID)
xtset IDnum year
set scheme burd

***********************************************************
* 1. ORGANIZE DATA ON FOSSIL FUEL AND ENERGY CONSUMPTION
***********************************************************

* Keep years where we observe natural gas
keep if year >= 2009

*** Domestic Coal, Gas and Oil ***
rename PurchValCoal Coal
rename PurchValOil Oil
rename PurchValGas Gas
rename QtyConsCoal CoalQty
rename QtyConsGas GasQty
gen OilQty = Oil/p_oil_bar
* Replace missing values for 0 when plant is consuming some amount of fuel
replace Coal = 0 if Coal == . & (Oil > 0 | Gas > 0)
replace Oil = 0 if Oil == . & (Coal > 0 | Gas > 0)
replace Gas = 0 if Gas == . & (Oil > 0 | Coal > 0)
drop if Gas == . & Coal == 0 & Oil == 0

* Get quantities in mmBtu
rename p_oil_mmbtu poil_mmbtu
gen gas_mmbtu = GasQty*0.04739 if UnitCodeGas == 9 // Kg to mmbtu
gen coal_mmbtu = CoalQty*27.78 if UnitCodeCoal == 27 // ton to mmbtu
gen oil_mmbtu = Oil/poil_mmbtu
gen pgas_mmbtu = UnitPriceGas/0.04739 
gen pcoal_mmbtu = UnitPriceCoal/27.78
replace pgas_mmbtu = . if pgas_mmbtu == 0
replace pcoal_mmbtu = . if pcoal_mmbtu == 0
* For firms where only spending is available, use price index for that year
bysort year: egen pcoal_mmbtu_index = median(pcoal_mmbtu)
bysort year: egen pgas_mmbtu_index = median(pgas_mmbtu)
replace coal_mmbtu = Coal/pcoal_mmbtu_index if coal_mmbtu == . & Coal > 0
replace coal_mmbtu = Coal/pcoal_mmbtu_index if coal_mmbtu == 0 & Coal > 0
replace gas_mmbtu = Gas/pgas_mmbtu_index if gas_mmbtu == . & Gas > 0
replace gas_mmbtu = Gas/pgas_mmbtu_index if gas_mmbtu == 0 & Gas > 0
replace gas_mmbtu = 0 if gas_mmbtu == . & (oil_mmbtu > 0 | coal_mmbtu > 0)
replace oil_mmbtu = 0 if oil_mmbtu == . & (gas_mmbtu > 0 | coal_mmbtu > 0)
replace coal_mmbtu = 0 if coal_mmbtu == . & (oil_mmbtu > 0 | coal_mmbtu > 0)

*** Imported Coal, Gas and Oil ***
gen CoalImport = 0
gen OilImport = 0
gen GasImport = 0
gen CoalImport_mmbtu = 0
gen OilImport_mmbtu = 0
gen GasImport_mmbtu = 0
* 2009-2010 (ASICC product codes)
forvalues i = 1/5 {
	gen asiccImport`i'_3d = int(int(asiccImport`i'/10)/10)
	gen pcoal_mmbtu_import`i' = 0
}
forvalues i = 1/5 {
	replace CoalImport = CoalImport + PurchValImport`i' if asiccImport`i'_3d == 231
	replace pcoal_mmbtu_import`i' = UnitPriceImport`i'/27.78 if (asiccImport`i'_3d == 231 & UnitCodeImport`i' == 27)
	replace OilImport = OilImport + PurchValImport`i' if (asiccImport`i'_3d == 232 | asiccImport`i'_3d == 233 | asiccImport`i'_3d == 234 | asiccImport`i'_3d == 239)
	replace GasImport = GasImport + PurchValImport`i' if asiccImport`i'_3d == 241
}
* 2011-2016 (NPCMS product codes)
forvalues i = 1/5 {
	gen npcmsImport`i'_4d = int(int(int(npcmsImport`i'/10)/10)/10) if npcmsImport`i' >= 1000000
	gen npcmsImport`i'_3d = int(npcmsImport`i'_4d/10)
	replace npcmsImport`i'_4d = int(int(npcmsImport`i'/10)/10) if npcmsImport`i' < 100000
}
forvalues i = 1/5 {
	replace CoalImport = CoalImport + PurchValImport`i' if npcmsImport`i'_3d == 110 | npcmsImport`i'_4d == 1203 | npcmsImport`i'_3d == 331
	replace pcoal_mmbtu_import`i' = UnitPriceImport`i'/27.78 if (npcmsImport`i'_3d == 110 & UnitCodeImport`i' ==27) | (npcmsImport`i'_4d == 1203 & UnitCodeImport`i'==27) | (npcmsImport`i'_3d == 331 & UnitCodeImport`i' == 27)
	replace OilImport = OilImport + PurchValImport`i' if npcmsImport`i'_4d == 1201 | npcmsImport`i'_3d == 333 | npcmsImport`i'_3d == 334
	replace GasImport = GasImport + PurchValImport`i' if npcmsImport`i'_4d == 1202
}
forvalues i = 1/5 {
	replace pcoal_mmbtu_import`i' = . if pcoal_mmbtu_import`i' == 0
}
egen pcoal_mmbtu_import = rmean(pcoal_mmbtu_import1 pcoal_mmbtu_import2 pcoal_mmbtu_import3 pcoal_mmbtu_import4 pcoal_mmbtu_import5)
replace CoalImport_mmbtu = CoalImport/pcoal_mmbtu_import
replace OilImport_mmbtu = OilImport/poil_mmbtu
replace GasImport_mmbtu = GasImport/pgas_mmbtu_index
* For firms where only spending is available, use price index for that year
bysort year: egen pcoal_mmbtu_import_index = median(pcoal_mmbtu_import)
replace CoalImport_mmbtu = CoalImport/pcoal_mmbtu_import_index if CoalImport_mmbtu == . & CoalImport > 0 
replace CoalImport_mmbtu = CoalImport/pcoal_mmbtu_import_index if CoalImport_mmbtu == 0 & CoalImport > 0 
replace CoalImport_mmbtu = 0 if CoalImport_mmbtu == . & (OilImport_mmbtu > 0 | GasImport_mmbtu > 0)


*** Total (domestic plus imported) Coal, Gas and Oil ***
*replace CoalImport = . if CoalImport == 0 & (Coal==. & Oil==. & Gas==.)
*replace OilImport = . if OilImport == 0 & (Coal==. & Oil==. & Gas==.)
*replace GasImport = . if GasImport == 0 & (Coal==. & Oil==. & Gas==.)
*replace CoalImport_mmbtu = . if CoalImport_mmbtu == 0 & (coal_mmbtu==. & oil_mmbtu==. & gas_mmbtu==.)
*replace OilImport_mmbtu = . if OilImport_mmbtu == 0 & (coal_mmbtu==. & oil_mmbtu==. & gas_mmbtu==.)
*replace GasImport_mmbtu = . if GasImport_mmbtu == 0 & (coal_mmbtu==. & oil_mmbtu==. & gas_mmbtu==.)

egen TotCoal = rsum(Coal CoalImport)
egen TotOil = rsum(Oil OilImport)
egen TotGas = rsum(Gas GasImport)
egen TotCoal_mmbtu = rsum(coal_mmbtu CoalImport_mmbtu)
egen TotOil_mmbtu = rsum(oil_mmbtu OilImport_mmbtu)
egen TotGas_mmbtu = rsum(gas_mmbtu GasImport_mmbtu)

**************************************************************
* 1. PRELIMINARY GRAPHS ON FOSSIL FUEL AND ENERGY CONSUMPTION
**************************************************************

* Graph comparing aggregate share of imported vs domestic spending on each fuel (all indsutries)
preserve
	collapse (sum) Coal Oil Gas CoalImport OilImport GasImport TotCoal TotOil TotGas, by(year)
	gen sd_coal = Coal/TotCoal
	gen si_coal = CoalImport/TotCoal
	gen sd_oil = Oil/TotOil
	gen si_oil = OilImport/TotOil
	gen sd_gas = Gas/TotGas
	gen si_gas = GasImport/TotGas
	keep sd_coal si_coal sd_oil si_oil sd_gas si_gas year
	reshape long sd_ si_, i(year) j(fuel) string
	lab var sd_ "Domestic Share"
	lab var si_ "Imported Share"
	graph bar (mean) sd_ si_, over(fuel) legend(order(1 "Domestic Share" 2 "Import Share")) stack
	graph export Output\Graphs\FuelImportShare_allind.pdf, replace 
restore
* Graph comparing aggregate share of imported vs domestic spending on each fuel (selected industries)
preserve
	keep if nic08_4d == 2394 | nic08_4d == 2410 | nic08_4d == 1701 | nic08_4d ==  2420 | nic08_4d == 2310
	collapse (sum) Coal Oil Gas CoalImport OilImport GasImport TotCoal TotOil TotGas, by(year)
	gen sd_coal = Coal/TotCoal
	gen si_coal = CoalImport/TotCoal
	gen sd_oil = Oil/TotOil
	gen si_oil = OilImport/TotOil
	gen sd_gas = Gas/TotGas
	gen si_gas = GasImport/TotGas
	keep sd_coal si_coal sd_oil si_oil sd_gas si_gas year
	reshape long sd_ si_, i(year) j(fuel) string
	lab var sd_ "Domestic Share"
	lab var si_ "Imported Share"
	graph bar (mean) sd_ si_, over(fuel) legend(order(1 "Domestic Share" 2 "Import Share")) stack
	graph export Output\Graphs\FuelImportShare_selectedind.pdf, replace 
restore

egen energytot = rsum(TotCoal TotOil TotGas PurchValOtherFuel PurchValElecBought)
egen fueltot = rsum(TotCoal TotOil TotGas PurchValOtherFuel)
egen fueltot_mmbtu = rsum(TotCoal_mmbtu TotOil_mmbtu TotGas_mmbtu)
* Graph: aggregate fuel spending shares (all industries)
preserve
	collapse (sum) TotCoal TotOil TotGas PurchValElecBought PurchValOtherFuel energytot fueltot, by(year) 
	gen s_coal = TotCoal/energytot
	gen s_oil = TotOil/energytot
	gen s_gas = TotGas/energytot
	gen s_otherf = PurchValOtherFuel/energytot
	gen s_elec = PurchValElecBought/energytot
	graph twoway (connected s_coal year) (connected s_oil year) (connected s_gas year) (connected s_elec year) (connected s_otherf year), ///
	legend(label(1 "Coal") label(2 "Oil") label(3 "Gas") label(4 "Electricity") label(5 "Other Fuel")) ytitle("Spending Share") xtitle("Year") xlabel(2009[1]2016)
	graph export Output\Graphs\EnergyShares_Year-allind.pdf, replace 
	replace s_coal = TotCoal/fueltot
	replace s_oil = TotOil/fueltot
	replace s_gas = TotGas/fueltot
	graph twoway (connected s_coal year) (connected s_oil year) (connected s_gas year), ///
	legend(label(1 "Coal") label(2 "Oil") label(3 "Gas")) ytitle("Spending Share") xtitle("Year") xlabel(2009[1]2016)
	graph export Output\Graphs\FuelShares_Year-allind.pdf, replace 
restore
* Graph: aggregate fuel quantity shares (all industries)
preserve
	collapse (sum) TotCoal_mmbtu TotOil_mmbtu TotGas_mmbtu fueltot_mmbtu, by(year) 
	gen s_coal = TotCoal_mmbtu/fueltot_mmbtu
	gen s_oil = TotOil_mmbtu/fueltot_mmbtu
	gen s_gas = TotGas_mmbtu/fueltot_mmbtu
	graph twoway (connected s_coal year) (connected s_oil year) (connected s_gas year), ///
	legend(label(1 "Coal") label(2 "Oil") label(3 "Gas")) ytitle("Quantity Share (mmbtu)") xtitle("Year") xlabel(2009[1]2016)
	graph export Output\Graphs\FuelQtyShares_Year-allind.pdf, replace 
restore
* Graph: aggregate fuel spending shares (selected industries)
preserve
	keep if nic08_4d == 2394 | nic08_4d == 2410 | nic08_4d == 1701 | nic08_4d ==  2420 | nic08_4d == 2310
	collapse (sum) TotCoal TotOil TotGas PurchValElecBought PurchValOtherFuel energytot fueltot, by(year) 
	gen s_coal = TotCoal/energytot
	gen s_oil = TotOil/energytot
	gen s_gas = TotGas/energytot
	gen s_otherf = PurchValOtherFuel/energytot
	gen s_elec = PurchValElecBought/energytot
	graph twoway (connected s_coal year) (connected s_oil year) (connected s_gas year) (connected s_elec year) (connected s_otherf year), ///
	legend(label(1 "Coal") label(2 "Oil") label(3 "Gas") label(4 "Electricity") label(5 "Other Fuel")) ytitle("Spending Share") xtitle("Year") xlabel(2009[1]2016)
	graph export Output\Graphs\EnergyShares_Year-selectedind.pdf, replace 
	replace s_coal = TotCoal/fueltot
	replace s_oil = TotOil/fueltot
	replace s_gas = TotGas/fueltot
	graph twoway (connected s_coal year) (connected s_oil year) (connected s_gas year), ///
	legend(label(1 "Coal") label(2 "Oil") label(3 "Gas")) ytitle("Spending Share") xtitle("Year") xlabel(2009[1]2016)
	graph export Output\Graphs\FuelShares_Year-selectedind.pdf, replace 
restore
* Graph: aggregate fuel quantity shares (selected industries)
preserve
	keep if nic08_4d == 2394 | nic08_4d == 2410 | nic08_4d == 1701 | nic08_4d ==  2420 | nic08_4d == 2310
	collapse (sum) TotCoal_mmbtu TotOil_mmbtu TotGas_mmbtu fueltot_mmbtu, by(year) 
	gen s_coal = TotCoal_mmbtu/fueltot_mmbtu
	gen s_oil = TotOil_mmbtu/fueltot_mmbtu
	gen s_gas = TotGas_mmbtu/fueltot_mmbtu
	graph twoway (connected s_coal year) (connected s_oil year) (connected s_gas year), ///
	legend(label(1 "Coal") label(2 "Oil") label(3 "Gas")) ytitle("Quantity Share (mmbtu)") xtitle("Year") xlabel(2009[1]2016)
	graph export Output\Graphs\FuelQtyShares_Year-selectedind.pdf, replace 
restore

* Graph for domestic fossil fuel prices (natural gas, coal and oil)
preserve
	collapse (median) pgas_mmbtu pcoal_mmbtu poil_mmbtu, by(year)
	graph twoway (connected pgas_mmbtu year) (connected pcoal_mmbtu year) (connected poil_mmbtu year), ///
	xlabel(2009[1]2016) ytitle("Median price (rupee per mmBtu)") xtitle("Year") ///
	legend(label(1 "Natural gas") label(2 "Coal") label(3 "Oil")) 
	graph export Output\Graphs\FuelPrices_Year.pdf, replace 
restore
* Convert electricity units (kwh) to mBbtu
gen elecb_mmbtu = QtyConsElecBought*0.003412 if UnitCodeElecBought == 28
gen pelecb_mmbtu = UnitPriceElecBought/0.003412 if UnitCodeElecBought == 28
gen eleco_mmbtu = QtyConsElecOwn*0.003412 if UnitCodeElecOwn == 28
* Graph for energy prices
preserve
	collapse (median) pgas_mmbtu pcoal_mmbtu poil_mmbtu pelecb_mmbtu, by(year)
	graph twoway (connected pgas_mmbtu year) (connected pcoal_mmbtu year) (connected poil_mmbtu year) ///
	(connected pelecb_mmbtu year), xlabel(2009[1]2016) ytitle("Median price (rupee per mmBtu)") xtitle("Year") ///
	graphregion(color(white)) legend(label(1 "Natural gas") label(2 "Coal") label(3 "Oil") label(4 "Electricity"))
	graph export Output\Graphs\EnergyPrices_Year.pdf, replace 
restore

*Emission intensity of energy sources
* Coal
gen gamma_coal = 98.02503 + 25*(11/1000) + 298*(1.6/1000)
lab var gamma_coal "Emission Factor - Coal"
* Oil
gen gamma_oil = 71.19316 + 25*(3/1000) + 298*(0.6/1000)
lab var gamma_oil "Emission Factor - Oil"
* Natural Gas
gen gamma_natgas = 53.06 + (25/1000) + 298*(0.1/1000)
lab var gamma_natgas "Emission Factor - Natural Gas"
* Electricity
gen gamma_elec = (0.526+0.017)*gamma_coal+0.17+0.065*gamma_natgas

/*
* Remove outliers
su p_natgas_mmbtu, detail
replace p_natgas_mmbtu = . if p_natgas_mmbtu > r(p99)
su natgas_mmbtu, detail
replace natgas_mmbtu = . if natgas_mmbtu > r(p99)
gen labor_revprod = SalesGross_tot/nEmployees_tot
*/

* Save dataset with all industries
save Data/Panel_Data/Clean_data/ASI_PanelClean-allind, replace

*** Summary Statistics: Fuel Switching ***
preserve
* Balance panel so we don't significantly underestimate fuel switching
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 8
drop nyear
sort IDnum year
* Define adding a fuel to the mix in current period
foreach fuel in TotCoal TotOil TotGas elecb {
	gen fuelswitch_to`fuel' = 0
	replace fuelswitch_to`fuel' = 1 if `fuel'_mmbtu > 0 & L.`fuel'_mmbtu == 0
	gen fuelswitch_off`fuel' = 0
	replace fuelswitch_off`fuel' = 1 if `fuel'_mmbtu == 0 & L.`fuel'_mmbtu > 0 & L.`fuel'_mmbtu != . & `fuel'_mmbtu != .
}
rename fuelswitch_toTotCoal fuelswitch_tocoal
rename fuelswitch_toTotGas fuelswitch_togas
rename fuelswitch_toTotOil fuelswitch_tooil
rename fuelswitch_offTotCoal fuelswitch_offcoal
rename fuelswitch_offTotGas fuelswitch_offgas
rename fuelswitch_offTotOil fuelswitch_offoil
* Drop first year because I don't observe switching for that period
drop if year == 2009
gen fuelswitch_to = 0
replace fuelswitch_to = 1 if fuelswitch_tocoal == 1 | fuelswitch_tooil ==  1 | fuelswitch_togas == 1 | fuelswitch_toelecb == 1
gen fuelswitch_off = 0
replace fuelswitch_off = 1 if fuelswitch_offcoal == 1 | fuelswitch_offoil ==  1 | fuelswitch_offgas == 1 | fuelswitch_offelecb == 1
* Tag plants that add a fuel to their mix
bysort IDnum: egen switch_to_anyyear = max(fuelswitch_to)
bysort IDnum: egen switch_togas_anyyear = max(fuelswitch_togas)
bysort IDnum: egen switch_tocoal_anyyear = max(fuelswitch_tocoal)
bysort IDnum: egen switch_tooil_anyyear = max(fuelswitch_tooil)
bysort IDnum: egen switch_toelec_anyyear = max(fuelswitch_toelecb)
* Tag plants that drop a fuel from their mix
bysort IDnum: egen switch_off_anyyear = max(fuelswitch_off)
bysort IDnum: egen switch_offgas_anyyear = max(fuelswitch_offgas)
bysort IDnum: egen switch_offcoal_anyyear = max(fuelswitch_offcoal)
bysort IDnum: egen switch_offoil_anyyear = max(fuelswitch_offoil)
bysort IDnum: egen switch_offelec_anyyear = max(fuelswitch_offelecb)
* TABLE: fraction of unique plants that switch to and off fuels
collapse (mean) switch_to_anyyear switch_togas_anyyear switch_tooil_anyyear switch_tocoal_anyyear switch_toelec_anyyear ///
switch_off_anyyear switch_offgas_anyyear switch_offoil_anyyear switch_offcoal_anyyear switch_offelec_anyyear, by(IDnum)
lab var switch_to_anyyear "Adds a New Fuel"
lab def switch_to_anyyear 0 "No" 1 " Yes"
lab val switch_to_anyyear switch_to_anyyear
lab var switch_togas_anyyear "Adds Natural Gas"
lab def switch_togas_anyyear 0 "No" 1 " Yes"
lab val switch_togas_anyyear switch_togas_anyyear
lab var switch_off_anyyear "Drops an Existing Fuel"
lab def switch_off_anyyear 0 "No" 1 " Yes"
lab val switch_off_anyyear switch_to_anyyear
lab var switch_offcoal_anyyear "Drops Coal"
lab def switch_offcoal_anyyear 0 "No" 1 " Yes"
lab val switch_offcoal_anyyear switch_offcoal_anyyear
tabout switch_to_anyyear using "Output/Tables/Switching/nadd_fuels.tex", replace c(freq col) style(tex)
tabout switch_togas_anyyear using "Output/Tables/Switching/nadd_gas.tex", replace c(freq col) style(tex)
tabout switch_off_anyyear using "Output/Tables/Switching/ndrops_fuels.tex", replace c(freq col) style(tex)
tabout switch_offcoal_anyyear using "Output/Tables/Switching/ndrops_coal.tex", replace c(freq col) style(tex)
restore

**************************************************************
* 2. GRAPHS ON EVIDENCE OF MIXING BETWEEN FUELS
**************************************************************

*** SELECTED INDUSTRIES ***
keep if nic08_4d == 2394 | nic08_4d == 2410 | nic08_4d == 1701 | nic08_4d ==  2420 | nic08_4d == 2310

gen coal_s = TotCoal_mmbtu/fueltot_mmbtu
gen gas_s = TotGas_mmbtu/fueltot_mmbtu
gen oil_s = TotOil_mmbtu/fueltot_mmbtu
gen anyfuel = 1 if TotCoal_mmbtu > 0 | TotGas_mmbtu > 0 | TotOil_mmbtu > 0 | elecb_mmbtu > 0
* Define mixing relative to different thresholds:
gen fuelmix100 = 0
replace fuelmix100 = 1 if (coal_s != 1 & coal_s != .) & (oil_s != 1 & oil_s !=.) & (gas_s != 1 & gas_s !=.) & (elec_s = )
lab var fuelmix100 "Mixing between fuels"
gen fuelmix95 = 0
replace fuelmix95 = 1 if (coal_s < 0.95 & coal_s != .) & (oil_s < 0.95 & oil_s !=.) & (gas_s < 0.95 & gas_s !=.)
lab var fuelmix95 "Mixing betwen fuels, 95%"
gen fuelmix99 = 0
replace fuelmix99 = 1 if(coal_s < 0.99 & coal_s != .) & (oil_s < 0.99 & oil_s !=.) & (gas_s < 0.99 & gas_s !=.)
lab var fuelmix99 "Mixing betwen fuels, 99%"
gen fuelmix98 = 0
replace fuelmix98 = 1 if (coal_s < 0.98 & coal_s != .) & (oil_s < 0.98 & oil_s !=.) & (gas_s < 0.98& gas_s !=.)
lab var fuelmix98 "Mixing betwen fuels, 98%"
gen fuelmix90 = 0
replace fuelmix90 = 1 if (coal_s < 0.90 & coal_s != .) & (oil_s < 0.90 & oil_s !=.) & (gas_s < 0.90 & gas_s !=.)
lab var fuelmix90 "Mixing betwen fuels, 90%"

*** GRAPH: PROPORTION OF SPECIFIC SINGLE FUEL USE AND MIXING ***
gen gas_only = 1 if (gas_s > 0) & (coal_s == 0) & (oil_s == 0) 
gen oil_only = 1 if (gas_s == 0) & (coal_s == 0) & (oil_s > 0) 
gen coal_only = 1 if (gas_s == 0) & (coal_s > 0) & (oil_s == 0) 
gen mixing = 1 if (anyfuel == 1) & (gas_only == .) & (oil_only == .) & (coal_only == .) 
su anyfuel, detail
mat fuelcount = r(sum)
su gas_only, detail
mat gasonly = r(sum)
mat gasonly = gasonly[1,1]/fuelcount[1,1]
su oil_only, detail
mat oilonly = r(sum)
mat oilonly = oilonly[1,1]/fuelcount[1,1]
su coal_only, detail
mat coalonly = r(sum)
mat coalonly = coalonly[1,1]/fuelcount[1,1]
su mixing, detail
mat mixing = r(sum)
mat mixing = mixing[1,1]/fuelcount[1,1]
mat xaxis_specificfuel = (1\2\3\4)
mat specific_fuelprop = (gasonly\coalonly\oilonly\mixing)
svmat xaxis_specificfuel 
svmat specific_fuelprop
graph bar (asis) specific_fuelprop1, over(xaxis_specificfuel1, ///
relabel(1 "Natural gas only" 2 "Coal only" 3 "Oil only" 4 "Mixing")) ///
ytitle("Fraction of firms") graphregion(color(white))
graph export Output\Graphs\Fueltype_Firmprop.pdf, replace 

*** GRAPH: PROPORTION OF SINGLE FUEL USE VS MIXING ***
gen single_fuel = 0
replace single_fuel = 1 if fuelmix100 == 0
preserve
	collapse (sum) fuelmix100 single_fuel
	lab var fuelmix100 "Mixing"
	lab var single_fuel "Single Fuel use"
	gen mix_single_total = fuelmix100 + single_fuel
	replace fuelmix100 = fuelmix100/mix_single_total
	replace single_fuel = single_fuel/mix_single_total
	graph bar (asis) fuelmix100 single_fuel, bargap(100) blabel(name)
	graph export Output\Graphs\MixingSingle_Firmprop.pdf, replace 
restore

*** GRAPH: DISTRIBUTION OF FUEL QUANTITY USE WITH AND WITHOUT MIXING ***
egen energy_mix = rsum(TotGas_mmbtu TotOil_mmbtu TotCoal_mmbtu)
gen logEnergy_mix = log(energy_mix)
lab var logEnergy_mix "log(Energy) - mmBtu"
twoway (hist logEnergy_mix if fuelmix95 == 0, frac lcolor(gs12) fcolor(gs12)) ///
 (hist logEnergy_mix if fuelmix95 == 1, frac lcolor(red) fcolor(none)), ///
 legend(label(1 "Singe Fuel plants") label(2 "Multiple Fuels plants"))  graphregion(color(white))
 graph export Output/Graphs/Energy_Mixing-Dist.pdf, replace

*** GRAPH : PROPORTION OF SINGLE FUEL USE ABOVE THRESHOLD ***
gen prop_singlef_100 = 1 if (gas_s == 1 & gas_s != .) | (oil_s == 1 &  oil_s !=.) | (coal_s == 1 & coal_s !=.) 
gen prop_singlef_99 = 1 if (gas_s >= 0.99 & gas_s != .) | (oil_s >= 0.99 &  oil_s !=.) | (coal_s >= 0.99 & coal_s !=.) 
gen prop_singlef_95 = 1 if (gas_s >= 0.95 & gas_s != .) | (oil_s >= 0.95 &  oil_s !=.) | (coal_s >= 0.95 & coal_s !=.) 
gen prop_singlef_90 = 1 if (gas_s >= 0.90 & gas_s != .) | (oil_s >= 0.90 &  oil_s !=.) | (coal_s >= 0.90 & coal_s !=.) 
su prop_singlef_100, detail
mat fuelcount_100 = r(sum)
mat fuelcount_100 = fuelcount_100[1,1]/fuelcount[1,1]
su prop_singlef_99, detail
mat fuelcount_99 = r(sum)
mat fuelcount_99 = fuelcount_99[1,1]/fuelcount[1,1]
su prop_singlef_95, detail
mat fuelcount_95 = r(sum)
mat fuelcount_95 = fuelcount_95[1,1]/fuelcount[1,1]
su prop_singlef_90, detail
mat fuelcount_90 = r(sum)
mat fuelcount_90 = fuelcount_90[1,1]/fuelcount[1,1]
mat xaxis = (90\95\99\100)
mat fuelprop = (fuelcount_90\fuelcount_95\fuelcount_99\fuelcount_100)
svmat xaxis
svmat fuelprop
graph bar (asis) fuelprop1, over(xaxis1, relabel(1 ">90 %" 2 ">95 %" 3 ">99 %" 4 "100 %")) ytitle("Fraction of firms") graphregion(color(white))
graph export Output\Graphs\FuelThreshold_FirmProp.pdf, replace  

/*
*** TABLE: EFFECT OF MULTIPLE OUTPUTS ON MIXING ***
* Revenue productivity of labor
*gen labor_revprod = SalesGross_tot/nEmployees_tot
lab var labor_revprod "Sales Per Worker"
lab var nEmployees_tot "Total number of Workers"
* Number of products firm makes
gen nofproducts = 0
replace nofproducts = 1 if QtyManuf_o1 != . & QtyManuf_o2 !=.
replace nofproducts = 2 if QtyManuf_o1 != . & QtyManuf_o2 !=. & QtyManuf_o3 !=.
replace nofproducts = 3 if QtyManuf_o1 != . & QtyManuf_o2 !=. & QtyManuf_o3 !=. ///
& QtyManuf_o4 !=.
replace nofproducts = 4 if QtyManuf_o1 != . & QtyManuf_o2 !=. & QtyManuf_o3 !=. ///
& QtyManuf_o4 !=. & QtyManuf_o5 !=.
* Indicator for being multiproduct	
gen multiproduct = 0
replace multiproduct = 1 if QtyManuf_o1 != . & QtyManuf_o2 !=.
lab var multiproduct "Multiple Outputs"
* Logit effect of being a multiproduct firm on mixing

eststo clear
logit fuelmix99 multiproduct if labor_revprod != . & nEmployees_tot != .
margins, dydx(multiproduct) post
eststo mdl1, title("No controls"): margins
logit fuelmix99 multiproduct i.ind2d if labor_revprod != . & nEmployees_tot != .
margins, dydx(multiproduct) post
eststo mdl2, title("Industry dummies"): margins
logit fuelmix99 multiproduct i.ind2d labor_revprod nEmployees_tot
margins, dydx(multiproduct) post
eststo mdl3, title("Control for size and Gross output per worker"): margins
esttab using Output/Tables/Mixing/MultProd.tex, mtitles label replace booktabs
*/

**************************************************************
* 3. GRAPHS ON GHG EMISSIONS
**************************************************************

preserve
	replace TotCoal_mmbtu = 0 if TotCoal_mmbtu == .
	replace TotGas_mmbtu = 0 if TotGas_mmbtu == .
	replace TotOil_mmbtu = 0 if TotOil_mmbtu == .
	gen ghg = (gamma_coal*TotCoal_mmbtu)+(gamma_oil*TotOil_mmbtu)+(gamma_natgas*TotGas_mmbtu)
	collapse (sum) ghg, by(year)
	replace ghg = ghg/100000000
	*** GRAPH OF AGGREGATE GHG EMISSIONS ***
	graph twoway (connected ghg year), graphregion(color(white)) xlabel(2009[1]2016) ytitle("CO2e (Million tonnes)")
	graph export Output/Graphs/AggGHG_year_UnbalancedPanel.pdf, replace
restore

* Save dataset for selected industries
save Data/Panel_Data/Clean_data/ASI_PanelClean-selectedind, replace

