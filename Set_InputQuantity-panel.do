*****************************************************************************************
*** Get normalized quantities of Intermediates, capital and Output using price data   ***
*****************************************************************************************

*** Import Data (Balanced panel of all manufacturing industries) ****

* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
*use Data/Panel_Data/Clean_data/ASI_PanelClean-selectedind, clear
use Data/Panel_Data/Clean_data/ASI_PanelClean-allind, clear
xtset IDnum year
set scheme burd
* Remove outliers
su pgas_mmbtu, detail
keep if pgas_mmbtu < r(p99) | pgas_mmbtu ==.
*su Capital, detail
*drop if Capital > r(p99 )
* Keep manufacturing plants only
drop if nic08_3d >= 351

/*
* Keep plants with subsequent years only
egen max_gap = max(year - year[_n-1]), by(IDnum)
keep if max_gap == 1
* Balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 8
drop nyear
*/

sort IDnum year
xtset IDnum year
drop _merge

********************************************************************
*** 1. Get (normalized) quantity of Capital
********************************************************************

* Deflate each component of capital by year and normalize around geometric mean
foreach vars in Land Building PlantMachine Transport Computer Pollution OtherFixCap WIP {
	replace `vars'Close = `vars'Close/100000
	gen log`vars' = log(`vars'Close)
	bysort year: reg log`vars'
	predict log`vars'_qty, residuals
	gen `vars'_qty = exp(log`vars'_qty)
	egen `vars'_gmean = gmean(`vars'_qty)
	gen `vars'_norm = `vars'_qty/`vars'_gmean
}
* Get (normalized by industry) capital quantity
egen K_norm = rsum(Land_norm Building_norm PlantMachine_norm Transport_norm Computer_norm Pollution_norm OtherFixCap_norm WIP_norm)
egen K_gmean = gmean(K_norm)
gen K = K_norm/K_gmean
lab var K "Normalized capital quantity (see paper for details)"

********************************************************************
*** 2. Get (normalized) quantity of materials
********************************************************************

* Get input quantities
forvalues i = 1/10 {
	gen SpendingInput`i' = QtyConsInput`i'*UnitPriceInput`i'
}
forvalues i = 1/5 {
	gen SpendingImport`i' = QtyConsImport`i'*UnitPriceImport`i'
}
egen SpendingInput = rsum(SpendingInput1 SpendingInput2 SpendingInput3 SpendingInput4 SpendingInput5 SpendingInput6 SpendingInput7 ///
SpendingInput8 SpendingInput9 SpendingInput10)
egen SpendingImport = rsum(SpendingImport1 SpendingImport2 SpendingImport3 SpendingImport4 SpendingImport5)
egen PurchvalInput_true = rsum(PurchValInput1 PurchValInput2 PurchValInput3 PurchValInput4 PurchValInput5 PurchValInput6 PurchValInput7 ///
PurchValInput8 PurchValInput9 PurchValInput10)
egen PurchvalImport_true = rsum(PurchValImport1 PurchValImport2 PurchValImport3 PurchValImport4 PurchValImport5)
gen InputsResiduals = (PurchvalInput_true-SpendingInput) + (PurchvalImport_true-SpendingImport)
replace InputsResiduals = 0 if InputsResiduals < 0
* Combine imports and inputs
forvalues i = 1/5 {
	local j = `i'+10
	rename QtyConsImport`i' QtyConsInput`j'
	rename asiccImport`i' asiccInput`j'
	rename npcmsImport`i' npcmsInput`j'
}
* Organize around geometric mean by product codes
egen uniqueid = group(year IDnum)
reshape long QtyConsInput asiccInput npcmsInput, i(uniqueid) j(prod_num)
gen prodcodeInput = asiccInput
replace prodcodeInput = npcmsInput if prodcodeInput == .
egen QtyInput_gmean = gmean(QtyConsInput), by(prodcodeInput)
gen QtyInput_norm = QtyConsInput/QtyInput_gmean
reshape wide QtyConsInput asiccInput npcmsInput QtyInput_gmean QtyInput_norm prodcodeInput, i(uniqueid) j(prod_num)
* Deflate by year part of intermediates were prices are unobserved 
foreach vars in PurchValTotalBasicItem PurchValChemical PurchValPacking PurchValConsumable InputsResiduals {
	replace `vars' = `vars'/100000
	gen Log`vars' = log(`vars')
	bysort year: reg Log`vars'
	predict Log`vars'_def, residuals
	gen `vars'_qty = exp(Log`vars'_def)
	egen `vars'_gmean = gmean(`vars'_qty)
}
foreach vars in TotalBasicItem Chemical Packing Consumable {
	gen `vars'_norm = PurchVal`vars'_qty/PurchVal`vars'_gmean
}
gen InputsResiduals_norm = InputsResiduals_qty/InputsResiduals_gmean
* Get (normalized by industry) intermediate quantity
egen Mnew_qty = rsum(TotalBasicItem_norm Chemical_norm Packing_norm Consumable_norm QtyInput_norm1 QtyInput_norm1 QtyInput_norm2 QtyInput_norm3 QtyInput_norm4 ///
QtyInput_norm5 QtyInput_norm6 QtyInput_norm7 QtyInput_norm8 QtyInput_norm9 QtyInput_norm10 QtyInput_norm11 QtyInput_norm12 QtyInput_norm13 QtyInput_norm14 QtyInput_norm15)
egen Mnew_gmean = gmean(Mnew_qty)
gen M = Mnew_qty/Mnew_gmean
lab var M "Normalized intermediates quantity (see paper for details)"
drop uniqueid 

********************************************************************
*** 2. Get (normalized) output quantity
********************************************************************

* Get input quantities
forvalues i = 1/10 {
	gen RevenueOutput`i' = QtyManufOutput`i'*NetSaleValueUnitOutput`i'
}
egen RevOutput_product = rsum(RevenueOutput1 RevenueOutput2 RevenueOutput3 RevenueOutput4 RevenueOutput5 RevenueOutput6 RevenueOutput7 ///
RevenueOutput8 RevenueOutput9 RevenueOutput10)
* Organize output quantities around geometric mean by product codes
egen uniqueid = group(year IDnum)
reshape long QtyManufOutput asiccOutput npcmsOutput, i(uniqueid) j(prod_num)
gen prodcodeOutput = asiccOutput
replace prodcodeOutput = npcmsOutput if prodcodeOutput == .
egen QtyOutput_gmean = gmean(QtyManufOutput), by(prodcodeOutput)
gen QtyOutput_norm = QtyManufOutput/QtyOutput_gmean
reshape wide QtyManufOutput asiccOutput npcmsOutput QtyOutput_gmean QtyOutput_norm prodcodeOutput, i(uniqueid) j(prod_num)

* Deflate by year for outputs where prices are unobserved
replace IncomeServicesManuf = 0 if IncomeServicesManuf == .
replace IncomeServicesNonManuf = 0 if IncomeServicesNonManuf == .
replace IncomeServices = IncomeServicesManuf + IncomeServicesNonManuf if year > 2014
foreach vars in ExFactoryValueOther IncreaseStockSemiFinished OwnConstruction IncomeServices IncomeServicesManuf IncomeServicesNonManuf ElectricitySold NetSaleValueGoodsResold {
	replace `vars' = 0 if `vars' < 0
	replace `vars' = `vars'/100000
	gen log`vars' = log(`vars')
	bysort year: reg log`vars'
	predict log`vars'_def, residuals
	gen `vars'_qty = exp(log`vars'_def)
	egen `vars'_gmean = gmean(`vars'_qty)
	gen `vars'_norm = `vars'_qty/`vars'_gmean
}
* Get (normalized by industry) Output quantity
egen Ynew_qty = rsum(QtyOutput_norm1 QtyOutput_norm2 QtyOutput_norm3 QtyOutput_norm4 QtyOutput_norm5 QtyOutput_norm6 QtyOutput_norm7 ///
QtyOutput_norm8 QtyOutput_norm9 QtyOutput_norm10 ExFactoryValueOther_norm IncreaseStockSemiFinished_norm OwnConstruction_norm ///
IncomeServices_norm IncomeServicesManuf_norm IncomeServicesNonManuf_norm ElectricitySold_norm NetSaleValueGoodsResold_norm)


/*
foreach vars in ExFactoryValueOther IncreaseStockSemiFinished OwnConstruction {
	replace `vars' = 0 if `vars' < 0
	replace `vars' = `vars'/100000
	gen log`vars' = log(`vars')
	bysort year: reg log`vars'
	predict log`vars'_def, residuals
	gen `vars'_qty = exp(log`vars'_def)
	egen `vars'_gmean = gmean(`vars'_qty)
	gen `vars'_norm = `vars'_qty/`vars'_gmean
}
* Get (normalized by industry) Output quantity
egen Ynew_qty = rsum(QtyOutput_norm1 QtyOutput_norm2 QtyOutput_norm3 QtyOutput_norm4 QtyOutput_norm5 QtyOutput_norm6 QtyOutput_norm7 ///
QtyOutput_norm8 QtyOutput_norm9 QtyOutput_norm10 ExFactoryValueOther_norm IncreaseStockSemiFinished_norm OwnConstruction_norm)
*/

egen Ynew_gmean = gmean(Ynew_qty)
gen Y = Ynew_qty/Ynew_gmean
lab var Y "Normalized Output quantity (see paper for details)"
drop uniqueid


*** Save data ***
keep IDnum year Y K M
*save Data/Panel_Data/Clean_data/ASI_PFquantities_byind-panel, replace
*save Data/Panel_Data/Clean_data/ASI_PFquantities_byind_selectedInd-panel, replace
*save Data/Panel_Data/Clean_data/ASI_PFquantities_selectedInd-panel, replace
*save Data/Panel_Data/Clean_data/ASI_PFquantities-panel, replace
save Data/Panel_Data/Clean_data/ASI_PFquantities_allplants-panel, replace










