*** CODEFILE 5 ver1***

********************************************************************
*** Analysis for Cement, Steel and Iron, Paper, Glass, Aluminium ***
********************************************************************

* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
use Data/Panel_Data/Clean_data/ASI_PanelClean-selectedind, clear
set scheme burd
sort IDnum year
xtset IDnum year

* Data cleaning
rename TotCoal coal
rename TotOil oil
rename TotGas gas
rename PurchValOtherFuel otherf
replace otherf = 0 if otherf == .
rename PurchValElecBought elec
replace elec = 0 if elec == .
	
* Keep census plants (100 or more employees) - Not sure if Total Persons or Total Workers should be used
keep if PersonsTotal >= 100
* Define Entry, Exit and Incumbents as canonical definition in the literature
gen FirmStatus = 0
bysort IDnum: replace FirmStatus = 1 if Open == 1 & L.Open == 1
bysort IDnum: replace FirmStatus = 4 if Open == 1 & L.Open != 1 & F.Open != 1
bysort IDnum: replace FirmStatus = 2 if Open == 1 & L.Open != 1 & FirmStatus != 4
bysort IDnum: replace FirmStatus = 3 if Open == 1 & F.Open != 1 & FirmStatus != 4
replace FirmStatus = 0 if year == 2009 & FirmStatus == 2
replace FirmStatus = 0 if year == 2016 & FirmStatus == 3
lab def FirmStatus 0 "Unknown" 1 "Incumbents" 2 "Entry" 3 "Exit" 4 "Both Entry and Exit", replace 

**********************************************************************
*** 1. GRAPH OF FUEL SHARES ACROSS FIRM STATUS (ENTRY,EXIT,INCUMBENTS)                             
**********************************************************************

* Fuel shares corrected from industry and districts effects
egen DistrictNum = group(DistrictCode StateCode)
egen fuels = rsum(coal oil gas otherf)
foreach fuel in coal oil gas otherf {
	gen s_`fuel' = `fuel'/fuels
	reg s_`fuel' i.nic08_4d i.DistrictNum
	predict s_`fuel'_demean, residuals
}

/*
* Fuel shares relative to industry averages
egen fuels = rsum(coal oil gas otherf)
foreach fuel in coal oil gas otherf {
	gen s_`fuel' = `fuel'/fuels
	bysort nic08_4d year: egen s_`fuel'_indavg = mean(s_`fuel')
	gen s_`fuel'_demean = s_`fuel'-s_`fuel'_indavg
}
*/

preserve
	drop if year == 2009 | year == 2016
	collapse (mean) s_coal_demean s_oil_demean s_gas_demean s_otherf_demean, by(year FirmStatus)
	drop if FirmStatus == 0
	graph twoway (connected s_coal_demean year if FirmStatus == 1) (connected s_coal_demean year if FirmStatus == 2) ///
	(connected s_coal_demean year if FirmStatus == 3)  (connected s_coal_demean year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Coal relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelCoalShare_year-SelectedInd.pdf, replace
	graph twoway (connected s_gas_demean year if FirmStatus == 1) (connected s_gas_demean year if FirmStatus == 2) ///
	(connected s_gas_demean year if FirmStatus == 3)  (connected s_gas_demean year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Natural Gas relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelGasShare_year-SelectedInd.pdf, replace
	graph twoway (connected s_oil_demean year if FirmStatus == 1) (connected s_oil_demean year if FirmStatus == 2) ///
	(connected s_oil_demean year if FirmStatus == 3)  (connected s_oil_demean year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Oil relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelOilShare_year-SelectedInd.pdf, replace
	graph twoway (connected s_otherf_demean year if FirmStatus == 1) (connected s_otherf_demean year if FirmStatus == 2) ///
	(connected s_otherf_demean year if FirmStatus == 3)  (connected s_otherf_demean year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Other fuel relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelOtherfShare_year-SelectedInd.pdf, replace
restore

/*
preserve
	drop if year == 2009 | year == 2016
	collapse (mean) s_coal s_oil s_gas s_otherf, by(year FirmStatus)
	drop if FirmStatus == 0
	graph twoway (connected s_coal year if FirmStatus == 1) (connected s_coal year if FirmStatus == 2) ///
	(connected s_coal year if FirmStatus == 3)  (connected s_coal year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Coal relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelCoalShare_year-SelectedInd.pdf, replace
	graph twoway (connected s_gas year if FirmStatus == 1) (connected s_gas year if FirmStatus == 2) ///
	(connected s_gas year if FirmStatus == 3)  (connected s_gas year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Natural Gas relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelGasShare_year-SelectedInd.pdf, replace
	graph twoway (connected s_oil year if FirmStatus == 1) (connected s_oil year if FirmStatus == 2) ///
	(connected s_oil year if FirmStatus == 3)  (connected s_oil year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Oil relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelOilShare_year-SelectedInd.pdf, replace
	graph twoway (connected s_otherf year if FirmStatus == 1) (connected s_otherf year if FirmStatus == 2) ///
	(connected s_otherf year if FirmStatus == 3)  (connected s_otherf year if FirmStatus == 4), yline(0) ///
	ytitle("Share of Other fuel relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/RelOtherfShare_year-SelectedInd.pdf, replace
restore

foreach ind in 1701 2310 2394 2410 2420 {
	preserve
		drop if year == 2009 | year == 2016
		drop if nic08_4d != `ind'
		collapse (mean) s_coal s_oil s_gas s_otherf, by(year FirmStatus)
		graph twoway (connected s_coal year if FirmStatus == 1) (connected s_coal year if FirmStatus == 2) ///
		(connected s_coal year if FirmStatus == 3)  (connected s_coal year if FirmStatus == 4), yline(0) ///
		ytitle("Share of Coal relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
		graph export Output/Graphs/EntryExit/RelCoalShare_year-ind`ind'.pdf, replace
		graph twoway (connected s_gas year if FirmStatus == 1) (connected s_gas year if FirmStatus == 2) ///
		(connected s_gas year if FirmStatus == 3)  (connected s_gas year if FirmStatus == 4), yline(0) ///
		ytitle("Share of Natural Gas relative to industry average") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
		graph export Output/Graphs/EntryExit/RelGasShare_year-ind`ind'.pdf, replace
	restore
}
*/

**********************************************************************
*** 2. GRAPH OF VARIATION IN ENERGY USEAGE/EMISSIONS ACROSS FIRM TYPES                             
**********************************************************************

gen ghg = (gamma_coal*coal_mmbtu)+(gamma_oil*oil_mmbtu)+(gamma_natgas*gas_mmbtu)
preserve
	collapse(sum) fueltot_mmbtu ghg, by(year FirmStatus)
	drop if year == 2009 | year == 2016
	drop if FirmStatus == 0
	bysort year: egen fueltot_mmbtu_sum = total(fueltot_mmbtu)
	bysort year: egen ghg_sum = total(ghg)
	gen fueltot_mmbtu_s = fueltot_mmbtu/fueltot_mmbtu_sum
	gen ghg_s = ghg/ghg_sum
	graph twoway (connected fueltot_mmbtu_s year if FirmStatus == 1) (connected fueltot_mmbtu_s year if FirmStatus == 2) ///
	(connected fueltot_mmbtu_s  year if FirmStatus == 3) (connected fueltot_mmbtu_s year if FirmStatus == 4), ///
	ytitle("Energy (mmbtu)") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/EnergyConsumption_year-SelectedInd.pdf, replace
	graph twoway (connected ghg_s year if FirmStatus == 1) (connected ghg_s year if FirmStatus == 2) ///
	(connected ghg_s year if FirmStatus == 3) (connected ghg_s year if FirmStatus == 4), ///
	ytitle("GHG emssions (CO2e)") legend(label(1 "Incumbents") label(2 "Entry") label(3 "Exit") label(4 "Entry and Exit"))
	graph export Output/Graphs/EntryExit/GHGEmission_year-SelectedInd.pdf, replace
restore

