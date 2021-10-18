*** CODEFILE 7 ver2***

********************************************************************
*** Analysis for Cement, Steel and Iron, Paper, Glass, Aluminium ***
********************************************************************

* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
use Data/Panel_Data/Clean_data/ASI_PanelClean-Allind, clear
xtset IDnum year
set scheme burd
* Remove outliers (some extremely large natural gas prices)
su pgas_mmbtu, detail
keep if pgas_mmbtu < r(p99) | pgas_mmbtu ==.

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

drop if DistrictCode == 99
/*
* Keep plants with subsequent years only
egen max_gap = max(year - year[_n-1]), by(IDnum)
keep if max_gap == 1
* (Partially) balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 8
drop nyear
sort IDnum year
xtset IDnum year
*/

***********************************************************************
*** 1. RELATIONSHIP BETWEEN ACCESS TO GAS PIPELINE AND GAS CONSUMPTION
***********************************************************************

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
4 "Direct Access, Zone 4" 5 "Indirect Access, Zone 1" 6 "IndirectAccess, Zone 2" 7 "Indirect Access, Zone 3" 8 "Indirect Access, Zone 4", modify
lab val PipelineAccess PipelineAccess

gen lnpgas = log(pgas_mmbtu)
tab PipelineAcces, su(lnpgas)
gen logGas_mmbtu = log(TotGas_mmbtu)
tab PipelineAcces, su(logGas_mmbtu)

* Intensive margin (conditional on using natural gas)
reg lnpgas i.PipelineAccess
reg lnpgas i.Connection i.Zone
reg logGas_mmbtu i.PipelineAccess
reg logGas_mmbtu i.Connection i.Zone

* Extensive margin (probability of using natural gas)
gen I_Gas = 0
replace I_Gas = 1 if gas > 0 
probit I_Gas i.PipelineAccess 

***********************************************************************
*** 2. SET SPATIAL DATA FOR DISTRICTS (USED TO MAKE GEOGRAPHICAL GRAPHS)
***********************************************************************
shp2dta using "Data/Spatial Data/IND_adm2", database("Data/Spatial Data/inddistdb") coordinates("Data/Spatial Data/inddistcoord") genid(id)
use "Data/Spatial Data/inddistdb.dta",clear
rename NAME_1 StateCode
replace StateCode = "Andaman & N. Island" if StateCode == "Andaman and Nicobar"
replace StateCode = "Chandigarh(U.T.)" if StateCode == "Chandigarh"
replace StateCode = "Chattisgarh" if StateCode == "Chhattisgarh"
replace StateCode = "Dadra & Nagar Haveli" if StateCode == "Dadra and Nagar Haveli"
replace StateCode = "Daman & Diu" if StateCode == "Daman and Diu"
replace StateCode = "Jammu & Kashmir" if StateCode == "Jammu and Kashmir"
replace StateCode = "Pondicherry" if StateCode == "Puducherry"
replace StateCode = "Telegana" if StateCode == "Telangana"

rename NAME_2 dist
rename dist = "24-Parganas North" if dist == "North 24 Parganas"
rename dist = "24-Parganas South" if dist == "South 24 Parganas"
















