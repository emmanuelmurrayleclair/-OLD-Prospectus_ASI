*** CODEFILE 6 ver2***

** ssc install egenmore

*******************************************************************************
*** Production function estimation (Grieco et al. 2016) - all Industries    ***
*******************************************************************************

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
*** 1. Prepare Inputs and Output for PFE
********************************************************************

* Merge with quantity dataset
*merge 1:1 IDnum year using Data/Panel_Data/Clean_data/ASI_PFquantities-panel
merge 1:1 IDnum year using Data/Panel_Data/Clean_data/ASI_PFquantities_allplants-panel
*merge 1:1 IDnum year using Data/Panel_Data/Clean_data/ASI_PFquantities_selectedInd-panel


* Keep active plants
drop if Y == 0 | K == 0 | M == 0 | PersonsTotal == 0 | Output == 0
drop _merge

* Energy (quantity in mmbtu and geometric mean)
gen E = oil_mmbtu+coal_mmbtu+gas_mmbtu+elecb_mmbtu
egen Egmean = gmean(E)
* Energy (spending in lakhs - hundred thousand rupees)
egen Espend = rowtotal(TotCoal TotOil TotGas PurchValElecBought)
replace Espend = Espend/100000
* Geometric mean of Energy spending
egen Espend_gmean = gmean(Espend)
gen Espend_norm = Espend/Espend_gmean
* Labor (spending in lakhs - hundred thousand rupees)
gen Lspend = TotalEmoluments
replace Lspend = Lspend/100000
* Geometric mean of Labor spending
egen Lspend_gmean = gmean(Lspend)
gen Lspend_norm = Lspend/Lspend_gmean



* Output (revenues in lakhs - hundred thousand rupees)
gen Yspend = TotalOutput
replace Yspend = Yspend/100000
gen LogY = log(Yspend)


/*
drop K
* Capital (deflated by year and normalized around geometric mean)
gen Kspend = Capital/100000
gen logKspend = log(Kspend)
reg logKspend
bysort year: reg logKspend
predict logK, residuals
gen Kqty = exp(logK)
egen Kgmean = gmean(Kqty)
gen K = Kqty/Kgmean
*/

/*
* Intermediates (deflated by year and normalized around geometric mean)
gen Mspend = (Inputs-Espend)/100000
gen logMspend = log(Mspend)
bysort year: reg logMspend
predict logM, residuals
gen Mqty = exp(logM)
egen Mgmean = gmean(Mqty)
gen M = Mqty/Mgmean
*/

/*
* Labor (deflated by year and normalized around geometric mean)
gen logLspend = log(Lspend)
bysort year: reg logLspend
predict logL, residuals
gen Lqty = exp(logL)
egen Lgmean = gmean(Lqty)
gen L = Lqty/Lgmean
*/


* Labor (Number of employees normalized around geometric mean)
gen Lqty = PersonsTotal
egen Lgmean = gmean(Lqty)
gen L = Lqty/Lgmean


* All variables used for PFE
gen KL = K/L
gen ML = M/L


* Keep active plants
keep if LogY != . & Lspend != . & Espend != . & KL != . & ML != .
keep if Lspend > 0 & Espend > 0


* Save data for matlab
preserve
	keep KL ML Lspend Espend LogY
	export delimited Output/PFEdata.txt,replace
restore

********************************************************************
*** 2. Perform PFE estimation
********************************************************************

program drop nlpfe1
program nlpfe1	
    version 16
    
    syntax varlist(min=5 max=5) if, at(name)
    local LogY: word 1 of `varlist'
    local Lspend: word 2 of `varlist'
    local Espend: word 3 of `varlist'
	local KL: word 4 of `varlist'
	local ML: word 5 of `varlist'

    // Define parameters
    tempname rho akal amal sig
    scalar `rho' = `at'[1,1]
    scalar `akal' = `at'[1,2]
    scalar `amal' = `at'[1,3]
	scalar `sig' = `at'[1,4]

    // Some temporary variables (functions within CES)
    tempvar kterm mterm constant
    generate double `kterm' = `akal'*(`KL'^((`sig'-1)/`sig')) `if'
    generate double `mterm' = `amal'*(`ML'^((`sig'-1)/`sig')) `if'
	generate double `constant' = ln(`rho'/(`rho'-1)) `if'

    // Now fill in dependent variable
    replace `LogY' = `constant' + ln(`Lspend'*(1+`kterm'+`mterm') + `Espend') `if'
end
* Perform estimation of pfe parameters
nl pfe1 @ LogY Lspend Espend KL ML, parameters(rho akal amal sig) initial(rho 2 akal 2 amal 2 sig 3)
mat akal = _b[/akal]
mat amal = _b[/amal]
mat sig = _b[/sig]
mat rho = _b[/rho]
mat cov = e(V)
scalar var_rho = cov[1,1]
scalar var_akal = cov[2,2]
scalar var_amal = cov[3,3]
scalar var_sig = cov[4,4]

predict log_uhat, residuals
* Recover ae/al from optimality condition
preserve
	collapse (mean) Espend_gmean Lspend_gmean
	mkmat Espend_gmean
	mkmat Lspend_gmean
restore
mat aeal = Espend_gmean[1,1]/Lspend_gmean[1,1]
* Recover structural parameters (rho,sigma,alpha_l,alpha_k,alpha_m,alpha_e)
mat param_struc = J(1,6,.)
mat param_struc[1,1] = rho[1,1] // rho
mat param_struc[1,2] = sig[1,1] // sigma
mat param_struc[1,3] = 1/(1+akal[1,1]+amal[1,1]+aeal[1,1]) // al
mat param_struc[1,4] = param_struc[1,3]*akal[1,1] // ak
mat param_struc[1,5] = param_struc[1,3]*amal[1,1] // am
mat param_struc[1,6] = param_struc[1,3]*aeal[1,1] // ae
* Save parameters in data
gen constant = 1
preserve
	svmat param_struc
	keep param_struc1-param_struc6
	rename param_struc1 rho
	rename param_struc2 sig
	rename param_struc3 al
	rename param_struc4 ak
	rename param_struc5 am
	rename param_struc6 ae
	gen constant = 1
	keep if rho != .
	tempfile param_est
	save `param_est'
restore
merge m:1 constant using `param_est'
drop _merge* constant

***************************************************************************
*** 2. Get Bootstrap standard errors and create table for parameter values
***************************************************************************
local nrep 100
set seed 420
mat param_struc_boot = J(`nrep',6,.)
forvalues i=1/`nrep'{
	preserve
	keep IDnum year KL ML Lspend Espend LogY Espend_gmean Lspend_gmean
	bsample /* Sample entire dataset with replacement*/
	display _newline(2) `i' /* Display iteration number */
	* Perform estimation with bootstrap sample
	nl pfe @ LogY Lspend Espend KL ML, parameters(rho akal amal sig) initial(rho 1.5 akal 2 amal 2 sig 2)
	scalar akal_boot = _b[/akal]
	scalar amal_boot = _b[/amal]
	scalar sig_boot = _b[/sig]
	scalar rho_boot = _b[/rho]
	* Recover ae/al from optimality condition
	su Espend_gmean
	scalar Espend_gmean = r(mean)
	su Lspend_gmean
	scalar Lspend_gmean = r(mean)
	scalar aeal_boot = Espend_gmean/Lspend_gmean
	* Recover structural parameters (rho,sigma,alpha_l,alpha_k,alpha_m,alpha_e)
	mat param_struc_boot[`i',1] = rho_boot
	mat param_struc_boot[`i',2] = sig_boot
	mat param_struc_boot[`i',3] = 1./(1+akal_boot+amal_boot+aeal_boot)
	mat param_struc_boot[`i',4] = param_struc_boot[`i',3]*akal_boot
	mat param_struc_boot[`i',5] = param_struc_boot[`i',3]*amal_boot
	mat param_struc_boot[`i',6] = param_struc_boot[`i',3]*aeal_boot
	restore
}
* Bootstrap confidence intervals
mata:
nrep 100
param_boot = st_matrix("param_struc_boot")
param_boot_lb = J(1,6,.)
param_boot_ub = J(1,6,.)
for (i=1;i<=6;i++) {
	param_boot_lb[.,i] = mm_quantile(param_boot[.,i],1,0.05)
	param_boot_ub[.,i] = mm_quantile(param_boot[.,i],1,0.95)
}
st_matrix("param_boot_lb",param_boot_lb)
st_matrix("param_boot_ub",param_boot_ub)
end
* TABLE: PFE results
file close _all
file open PFE_results using Output/Tables/Post_PFE/PFE_results-AllIndPooled.tex, write replace
file write PFE_results "& Log Revenues \\"_n
file write PFE_results "\hline"_n

file write PFE_results "$\hat\rho$"
local rho: di %3.2f param_struc[1,1]
file write PFE_results "&`rho' \\"_n
local rho_lb: di %3.2f param_boot_lb[1,1]
file write PFE_results "&[`rho_lb',"
local rho_ub: di %3.2f param_boot_ub[1,1]
file write PFE_results "`rho_ub'] \\"_n

file write PFE_results "$\hat\sigma$"
local sig: di %3.2f param_struc[1,2]
file write PFE_results "&`sig' \\"_n
local sig_lb: di %3.2f param_boot_lb[1,2]
file write PFE_results "&[`sig_lb',"
local sig_ub: di %3.2f param_boot_ub[1,2]
file write PFE_results "`sig_ub'] \\"_n

file write PFE_results "$\hat\alpha_l$"
local al: di %3.2f param_struc[1,3]
file write PFE_results "&`al' \\"_n
local al_lb: di %3.2f param_boot_lb[1,3]
file write PFE_results "&[`al_lb',"
local al_ub: di %3.2f param_boot_ub[1,3]
file write PFE_results "`al_ub'] \\"_n

file write PFE_results "$\hat\alpha_k$"
local ak: di %3.2f param_struc[1,4]
file write PFE_results "&`ak' \\"_n
local ak_lb: di %3.2f param_boot_lb[1,4]
file write PFE_results "&[`ak_lb',"
local ak_ub: di %3.2f param_boot_ub[1,4]
file write PFE_results "`ak_ub'] \\"_n

file write PFE_results "$\hat\alpha_m$"
local am: di %3.2f param_struc[1,5]
file write PFE_results "&`am' \\"_n
local am_lb: di %3.2f param_boot_lb[1,5]
file write PFE_results "&[`am_lb',"
local am_ub: di %3.2f param_boot_ub[1,5]
file write PFE_results "`am_ub'] \\"_n

file write PFE_results "$\hat\alpha_e$"
local ae: di %3.2f param_struc[1,6]
file write PFE_results "&`ae' \\"_n
local ae_lb: di %3.2f param_boot_lb[1,6]
file write PFE_results "&[`ae_lb',"
local ae_ub: di %3.2f param_boot_ub[1,6]
file write PFE_results "`ae_ub'] \\"_n

file write PFE_results "\hline"_n
file write PFE_results "\(N\)"
su IDnum
local obs: di %3.0f r(N)
file write PFE_results "&`obs' \\"_n
file close _all

********************************************************************
*** 2. Get E, measures of productivity
********************************************************************

gen uhat = exp(log_uhat)
* E as in the model
gen E_struc = ((Espend/Lspend)^(sig/(sig-1)))*((al/ae)^(sig/(sig-1)))*L
gen E_struc1 = L*((Espend*al)/(Lspend*ae))^(sig/(sig-1))
* sum_f e_f (quantity of fuel actually consumed)
egen E_mmbtu = rsum(coal_mmbtu oil_mmbtu gas_mmbtu elecb_mmbtu) 
egen Emmbtu_gmean = gmean(E_mmbtu)
gen Eqty = E_mmbtu/Emmbtu_gmean
gen lterm = (al*(L)^((sig-1)/sig))
gen mterm = (am*(M)^((sig-1)/sig))
gen kterm = (ak*(K)^((sig-1)/sig))
gen eterm = (ae*(E_struc)^((sig-1)/sig))
gen eterm_mmbtu = (ae*(Eqty)^((sig-1)/sig))
gen ces_func = (lterm+mterm+kterm+eterm)^(sig/(sig-1))
gen ces_func_Emmbtu = (lterm+mterm+kterm+eterm_mmbtu)^(sig/(sig-1))

* Hicks-neutral productivity (z in model)
gen z = Y/ces_func
gen logz = log(z)
* TFP (includes fuel productivity)
gen TFP = Y/ces_func_Emmbtu
gen logTFP = log(TFP)

* TFPR excluding fuel productivity
gen logYres = LogY-ces_func
reg logYres
predict logTFPR, residuals 
gen logTFPR_persistent = logTFPR-log_uhat
* TFPR including fuel productivity
gen logYres_all = LogY-ces_func_Emmbtu
reg logYres_all
predict logTFPR_all, residuals
gen logTFPR_all_persistent = logTFPR_all-log_uhat


* Fuel productivity terms
foreach fuel in gas oil coal elecb {
	gen gam_`fuel' = `fuel'_mmbtu/E_struc
	gen lngam_`fuel' = log(gam_`fuel')
	gen lnavgprod_`fuel' = -lngam_`fuel'
}
graph drop _all
* Drop outliers for graph (very few observations, find better solution later)
foreach fuel in gas oil coal elecb {
	drop if (lngam_`fuel' < -10 & lngam_`fuel' != .) | (lngam_`fuel' > 20 & lngam_`fuel' != .)
}
foreach fuel in gas oil coal elecb {
	su lngam_`fuel'
	local rmean: di %10.2f r(mean)
	graph twoway hist lngam_`fuel', xtitle(`fuel' (mean = `rmean')) xline(5) xlabel(-10[5]20) name(gam_`fuel', replace)
}
gr combine gam_gas gam_oil gam_coal gam_elecb
graph export Output/Graphs/Post_PFE/FuelGamma_dist.pdf, replace

********************************************************************
*** 2. Relationship between PFE estimates and fuel switching
********************************************************************
sort IDnum year
* Define adding a fuel to the mix in current period
foreach fuel in coal oil gas elecb {
	gen fuelswitch_to`fuel' = 0
	replace fuelswitch_to`fuel' = 1 if `fuel'_mmbtu > 0 & L.`fuel'_mmbtu == 0
}
gen fuelswitch_to = 0
replace fuelswitch_to = 1 if fuelswitch_tocoal == 1 | fuelswitch_tooil ==  1 | fuelswitch_togas == 1 | fuelswitch_toelecb == 1
* Tag plants that add a fuel to their mix
bysort IDnum: egen switch_to_anyyear = max(fuelswitch_to)
bysort IDnum: egen switch_togas_anyyear = max(fuelswitch_togas)
bysort IDnum: egen switch_tocoal_anyyear = max(fuelswitch_tocoal)
bysort IDnum: egen switch_tooil_anyyear = max(fuelswitch_tooil)
bysort IDnum: egen switch_toelec_anyyear = max(fuelswitch_toelecb)

*GRAPH: effect of TFP last period on probability of adding natural gas
eststo clear
quietly probit fuelswitch_togas L.logTFP
margins, dydx(*) post
eststo mdl1: margins
esttab using "Output/Tables/Post_PFE/SwitchingProbit_me-AllInd.tex", se noconstant title("Marginal effects, probability of adding natural gas (current year)") ///
star(+ 0.1 * 0.05 ** 0.01 *** 0.001) replace

* Balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 8
drop nyear



