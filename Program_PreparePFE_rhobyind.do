*** CODEFILE 6 ver2***

** ssc install egenmore

********************************************************************
*** Preparation for PFE (Grieco et al. 2016) - all Industries    ***
********************************************************************

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
drop _merge

/*
* Keep plants with subsequent years only
egen max_gap = max(year - year[_n-1]), by(IDnum)
keep if max_gap == 1
* Balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 8
drop nyear
sort IDnum year
xtset IDnum year
*/

********************************************************************
*** 1. Prepare Inputs and Output for PFE
********************************************************************

* Energy (spending in lakhs - hundred thousand rupees, deflated by year)
egen Espend_nominal1 = rowtotal(TotCoal TotOil TotGas PurchValElecBought)
replace Espend_nominal = Espend
gen logEspend_nominal = log(Espend_nominal)
*reg logEspend_nominal i.year
*predict logEspend, residuals
gen logEspend = logEspend_nominal
gen Espend = exp(logEspend)
* Geometric mean of Energy spending
egen Espend_gmean = gmean(Espend), by(nic08_2d)
gen Espend_norm = Espend/Espend_gmean
* Labor (spending in lakhs - hundred thousand rupees, deflated by year)
gen Lspend_nominal = TotalEmoluments
replace Lspend_nominal = Lspend
gen logLspend_nominal = log(Lspend_nominal)
*reg logLspend_nominal i.year i.nic08_3d
*predict logLspend, residuals
gen logLspend = logLspend_nominal
gen Lspend = exp(logLspend)
* Geometric mean of Labor spending
egen Lspend_gmean = gmean(Lspend), by(nic08_2d)
gen Lspend_norm = Lspend/Lspend_gmean

* Output (revenues in lakhs - hundred thousand rupees, deflated by year)
gen Yspend = TotalOutput
replace Yspend = Yspend
gen logY_nominal = log(Yspend)
*reg logY_nominal i.year
*predict LogY, residuals
gen LogY = logY_nominal
gen Yqty = exp(LogY)
egen Ygmean = gmean(Yqty), by(nic08_2d)
gen Y = Yqty/Ygmean

* Capital (normalized around geometric mean)
gen Kspend = Capital
gen logKspend_nominal = log(Kspend)
*reg logKspend_nominal i.year i.nic08_3d
*predict logKspend, residuals
gen logKspend = logKspend_nominal
gen Kqty = exp(logKspend)
egen Kgmean = gmean(Kqty), by(nic08_2d)
gen K = Kqty/Kgmean

* Intermediates normalized around geometric mean)
gen Mspend_nominal = (Inputs-Espend_nominal1)
gen logMspend_nominal = log(Mspend)
*reg logMspend i.year i.nic08_3d
*predict logMspend, residuals
gen logMspend = logMspend_nominal
gen Mspend = exp(logMspend)
egen Mspend_gmean = gmean(Mspend), by(nic08_2d)
gen Mspend_norm = Mspend/Mspend_gmean
gen M = Mspend_norm

* Labor (Number of employees normalized around geometric mean)
gen Lqty = PersonsTotal
egen Lgmean = gmean(Lqty), by(nic08_2d)
gen L = Lqty/Lgmean

* All variables used for PFE
gen KL = K/L
gen KM = K/M
gen LM = L/M

/*
* Keep active plants
keep if LogY != . & Lspend != . & Espend != . & Mspend != . & KL != .
keep if Lspend > 0 & Espend > 0 & Mspend > 0
*/

* Keep active plants
keep if LogY != . & Lspend != . & Espend != . & Mspend != . & KL != . & KM != . & LM != .
keep if Lspend > 0 & Espend > 0 & Mspend > 0

********************************************************************
*** 2. Perform PFE estimation
********************************************************************

program drop nlpfe
program nlpfe	
    version 16
    
    syntax varlist(min=5 max=5) if, at(name)
    local LogY: word 1 of `varlist'
    local Lspend: word 2 of `varlist'
    local Espend: word 3 of `varlist'
	local Mspend: word 4 of `varlist'
	local KL: word 5 of `varlist'

    // Define parameters
    tempname rho akal sig
	scalar `rho' = `at'[1,1]
    scalar `akal' = `at'[1,2]
	scalar `sig' = `at'[1,3]

    // Some temporary variables (functions within CES)
    tempvar kterm rhoterm //sigterm
	generate double `kterm' = `akal'*((`KL')^`sig') `if' 
	generate double `rhoterm' = `rho' `if'

    // Now fill in dependent variable
    replace `LogY' = `rhoterm' + ln(`Lspend'*(1+`kterm') + `Espend' + `Mspend') `if'
end

* Perform estimation of pfe parameters
local iter = 1
egen ind_group = group(nic08_2d)
su ind_group
foreach vars in rho akal amal aeal sig {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	nl pfe @ LogY Lspend Espend Mspend KL if nic08_2d == `j', parameters(rho akal sig) initial(rho 1 akal 0.5 sig 0.5)
	mat akal[`iter_ind',1] = _b[/akal]
	mat sig[`iter_ind',1] = 1/(-1*(_b[/sig]-1))
	scalar rhoterm = exp(_b[/rho])
	mat rho[`iter_ind',1] = rhoterm/(rhoterm-1)
	predict log_uhat`j' if nic08_2d == `j', residuals 
	local ++iter_ind
}

* Recover ae/al from optimality condition
preserve
	collapse (mean) Espend_gmean Lspend_gmean Mspend_gmean, by(nic08_2d)
	mkmat Espend_gmean
	mkmat Lspend_gmean
	mkmat Mspend_gmean
restore
local iter_ind = 1
levelsof nic08_2d, local(ind)
foreach j of local ind {
	mat aeal[`iter_ind',1] = Espend_gmean[`iter_ind',1]/Lspend_gmean[`iter_ind',1]
	mat amal[`iter_ind',1] = Mspend_gmean[`iter_ind',1]/Lspend_gmean[`iter_ind',1]
	local ++iter_ind
}
* Recover structural parameters (rho,sigma,alpha_l,alpha_k,alpha_m,alpha_e)
su ind_group
mat param_struc = J(r(max),7,.)
local iter_ind = 1
levelsof nic08_2d, local(ind)
foreach j of local ind {
	mat param_struc[`iter_ind',1] = `j'
	mat param_struc[`iter_ind',2] = rho[`iter_ind',1] 
	mat param_struc[`iter_ind',3] = sig[`iter_ind',1]
	mat param_struc[`iter_ind',4] = 1./(1+akal[`iter_ind',1]+amal[`iter_ind',1]+aeal[`iter_ind',1])
	mat param_struc[`iter_ind',5] = param_struc[`iter_ind',4]*akal[`iter_ind',1]
	mat param_struc[`iter_ind',6] = param_struc[`iter_ind',4]*amal[`iter_ind',1]
	mat param_struc[`iter_ind',7] = param_struc[`iter_ind',4]*aeal[`iter_ind',1]
	local ++iter_ind
}
* Save parameters in data
preserve
	svmat param_struc
	keep param_struc1-param_struc7
	rename param_struc1 nic08_2d
	rename param_struc2 rho
	rename param_struc3 sig
	rename param_struc4 al
	rename param_struc5 ak
	rename param_struc6 am
	rename param_struc7 ae
	drop if nic08_2d == .
	tempfile param_est
	save `param_est'
restore
merge m:1 nic08_2d using `param_est'
drop _merge*
* Recover E_struc and M_struc from ratio of FOC
gen E_struc = (((Espend/Lspend)*(al/ae))^(sig/(sig-1)))*L
gen M_struc = (((Mspend/Lspend)*(al/am))^(sig/(sig-1)))*L

* Get average elasticities
egen E_mmbtu = rsum(TotCoal_mmbtu TotOil_mmbtu TotGas_mmbtu elecb_mmbtu) 
egen Emmbtu_gmean = gmean(E_mmbtu)
gen Eqty = E_mmbtu/Emmbtu_gmean
gen lterm = (al*(L)^((sig-1)/sig))
gen mterm = (am*(M_struc)^((sig-1)/sig))
gen kterm = (ak*(K)^((sig-1)/sig))
gen eterm = (ae*(E_struc)^((sig-1)/sig))
gen eterm_mmbtu = (ae*(Eqty)^((sig-1)/sig))
gen Q = lterm+mterm+kterm+eterm
gen Q_mmbtu = lterm+mterm+kterm+eterm_mmbtu
gen ces_func = (lterm+mterm+kterm+eterm)^(sig/(sig-1))
gen ces_func_Emmbtu = (lterm+mterm+kterm+eterm_mmbtu)^(sig/(sig-1))
* labor
gen eps_l = lterm/Q
* capital
gen eps_k = kterm/Q
* intermediates
gen eps_m = mterm/Q
* energy
gen eps_e = eterm/Q

* TABLE: average elasticities (selected industries)\
preserve
keep if nic08_2d == 13 | nic08_2d ==  17 | nic08_2d ==  20 | nic08_2d ==  23 | nic08_2d ==  24
file close _all
file open PFE_elasticities using Output/Tables/Post_PFE/PFE_avgElast-SelectedInd.tex, write replace
file write PFE_elasticities "& Textile & Paper & Chemical & Glass/Cement & Basic Metal\\"_n
file write PFE_elasticities "\hline"_n
file write PFE_elasticities "$\bar\epsilon_{y,l}$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su eps_l if nic08_2d == `j'
	local param: di %3.2f r(mean)
	file write PFE_elasticities "&`param'"
}
file write PFE_elasticities " \\"_n
file write PFE_elasticities "$\bar\epsilon_{y,k}$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su eps_k if nic08_2d == `j'
	local param: di %3.2f r(mean)
	file write PFE_elasticities "&`param'"
}
file write PFE_elasticities " \\"_n
file write PFE_elasticities "$\bar\epsilon_{y,m}$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su eps_m if nic08_2d == `j'
	local param: di %3.2f r(mean)
	file write PFE_elasticities "&`param'"
}
file write PFE_elasticities " \\"_n
file write PFE_elasticities "$\bar\epsilon_{y,e}$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su eps_e if nic08_2d == `j'
	local param: di %3.2f r(mean)
	file write PFE_elasticities "&`param'"
}
file write PFE_elasticities "\\"_n
file close _all
restore

/*
* Save data for matlab
levelsof nic08_2d, local(ind)
foreach j of local ind {
	preserve
		keep KL Lspend Espend Mspend LogY Espend_gmean Lspend_gmean Mspend_gmean nic08_2d
		keep if nic08_2d == `j'
		export delimited Output/PFEdata`j'.txt,replace
	restore
}
*/

************************************************************************************************
*** 2. Get Bootstrap standard errors and create table for parameter values (selected industries)
************************************************************************************************
local nrep 499
set seed 420
su ind_group
levelsof nic08_2d, local(ind)
foreach j of local ind {
	mat param_struc_boot_`j' = J(`nrep',7,.)
}
forvalues i=1/`nrep'{
	preserve
	keep if nic08_2d == 13 | nic08_2d ==  17 | nic08_2d ==  20 | nic08_2d ==  23 | nic08_2d ==  24
	keep IDnum year KL Lspend Espend Mspend LogY nic08_2d ind_group Espend_gmean Lspend_gmean Mspend_gmean
	bsample, strata(nic08_2d)/* Sample with replacement within each industry*/
	display _newline(2) `i' /* Display iteration number */
	* Perform estimation with bootstrap sample
	levelsof nic08_2d, local(ind)
	su ind_group
	foreach vars in rho akal amal aeal sig {
		mat `vars'_boot = J(r(max),1,.)
	}
	local iter_ind = 1
	foreach j of local ind {
		nl pfe @ LogY Lspend Espend Mspend KL if nic08_2d == `j', parameters(rho akal sig) initial(rho 1 akal 0.5 sig 0.5)
		mat akal_boot[`iter_ind',1] = _b[/akal]
		mat sig_boot[`iter_ind',1] = 1/(-1*(_b[/sig]-1))
		scalar rhoterm = exp(_b[/rho])
		mat rho_boot[`iter_ind',1] = rhoterm/(rhoterm-1)
		local ++iter_ind
	}
	* Recover ae/al from optimality condition
	su ind_group
	mat Espend_gmean = J(r(max),1,.)
	mat Lspend_gmean = J(r(max),1,.)
	mat Mspend_gmean = J(r(max),1,.)
	local iter_ind = 1
	levelsof nic08_2d, local(ind)
	foreach j of local ind {
		su Espend_gmean if nic08_2d == `j'
		mat Espend_gmean[`iter_ind',1] = r(mean)
		su Lspend_gmean if nic08_2d == `j'
		mat Lspend_gmean[`iter_ind',1] = r(mean)
		su Mspend_gmean if nic08_2d == `j'
		mat Mspend_gmean[`iter_ind',1] = r(mean)
		local ++iter_ind
	}
	local iter_ind = 1
	levelsof nic08_2d, local(ind)
	foreach j of local ind {
		mat aeal_boot[`iter_ind',1] = Espend_gmean[`iter_ind',1]/Lspend_gmean[`iter_ind',1]
		mat amal_boot[`iter_ind',1] = Mspend_gmean[`iter_ind',1]/Lspend_gmean[`iter_ind',1]
		local ++iter_ind
	}
	* Recover structural parameters (rho,sigma,alpha_l,alpha_k,alpha_m,alpha_e)
	local iter_ind = 1
	levelsof nic08_2d, local(ind)
	foreach j of local ind {
		mat param_struc_boot_`j'[`i',1] = `j'
		mat param_struc_boot_`j'[`i',2] = rho_boot[`iter_ind',1] 
		mat param_struc_boot_`j'[`i',3] = sig_boot[`iter_ind',1]
		mat param_struc_boot_`j'[`i',4] = 1./(1+akal_boot[`iter_ind',1]+amal_boot[`iter_ind',1]+aeal_boot[`iter_ind',1])
		mat param_struc_boot_`j'[`i',5] = param_struc_boot_`j'[`i',4]*akal_boot[`iter_ind',1]
		mat param_struc_boot_`j'[`i',6] = param_struc_boot_`j'[`i',4]*amal_boot[`iter_ind',1]
		mat param_struc_boot_`j'[`i',7] = param_struc_boot_`j'[`i',4]*aeal_boot[`iter_ind',1]
		local ++iter_ind
	}
	restore
}
* Bootstrap confidence intervals
mata:
nrep 499
param_boot13 = st_matrix("param_struc_boot_13")
param_boot17 = st_matrix("param_struc_boot_17")
param_boot20 = st_matrix("param_struc_boot_20")
param_boot23 = st_matrix("param_struc_boot_23")
param_boot24 = st_matrix("param_struc_boot_24")
param_boot_lb13 = J(1,6,.)
param_boot_ub13 = J(1,6,.)
param_boot_lb17 = J(1,6,.)
param_boot_ub17 = J(1,6,.)
param_boot_lb20 = J(1,6,.)
param_boot_ub20 = J(1,6,.)
param_boot_lb23 = J(1,6,.)
param_boot_ub23 = J(1,6,.)
param_boot_lb24 = J(1,6,.)
param_boot_ub24 = J(1,6,.)
for (i=1;i<=6;i++) {
	param_boot_lb13[.,i] = mm_quantile(param_boot13[.,i+1],1,0.05)
	param_boot_ub13[.,i] = mm_quantile(param_boot13[.,i+1],1,0.95)
	param_boot_lb17[.,i] = mm_quantile(param_boot17[.,i+1],1,0.05)
	param_boot_ub17[.,i] = mm_quantile(param_boot17[.,i+1],1,0.95)
	param_boot_lb20[.,i] = mm_quantile(param_boot20[.,i+1],1,0.05)
	param_boot_ub20[.,i] = mm_quantile(param_boot20[.,i+1],1,0.95)
	param_boot_lb23[.,i] = mm_quantile(param_boot23[.,i+1],1,0.05)
	param_boot_ub23[.,i] = mm_quantile(param_boot23[.,i+1],1,0.95)
	param_boot_lb24[.,i] = mm_quantile(param_boot24[.,i+1],1,0.05)
	param_boot_ub24[.,i] = mm_quantile(param_boot24[.,i+1],1,0.95)
}
st_matrix("param_boot_lb",(param_boot_lb13 \ param_boot_lb17 \ param_boot_lb20\ param_boot_lb23 \ param_boot_lb24))
st_matrix("param_boot_ub",(param_boot_ub13 \ param_boot_ub17 \ param_boot_ub20 \ param_boot_ub23 \ param_boot_ub24))
end
* TABLE: PFE results
preserve
keep if nic08_2d == 13 | nic08_2d ==  17 | nic08_2d ==  20 | nic08_2d ==  23 | nic08_2d ==  24
file close _all
file open PFE_results using Output/Tables/Post_PFE/PFE_results-SelectedInd.tex, write replace
file write PFE_results "& Textile & Paper & Chemical & Glass/Cement & Basic Metal\\"_n
file write PFE_results "\hline"_n

file write PFE_results "$\hat\rho$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su rho if nic08_2d == `j'
	local rho: di %3.2f r(mean)
	file write PFE_results "&`rho'"
}
file write PFE_results " \\"_n
forvalues i = 1/5 {
	local rho_lb: di %3.2f param_boot_lb[`i',1]
	file write PFE_results "&[`rho_lb',"
	local rho_ub: di %3.2f param_boot_ub[`i',1]
	file write PFE_results "`rho_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\sigma$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su sig if nic08_2d == `j'
	local sig: di %3.2f r(mean)
	file write PFE_results "&`sig'"
}
file write PFE_results "\\"_n
forvalues i = 1/5 {
	local sig_lb: di %3.2f param_boot_lb[`i',2]
	file write PFE_results " &[`sig_lb',"
	local sig_ub: di %3.2f param_boot_ub[`i',2]
	file write PFE_results "`sig_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_l$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su al if nic08_2d == `j'
	local al: di %3.2f r(mean)
	file write PFE_results "&`al'"
}
file write PFE_results "\\"_n
forvalues i = 1/5 {
	local al_lb: di %3.2f param_boot_lb[`i',3]
	file write PFE_results " &[`al_lb',"
	local al_ub: di %3.2f param_boot_ub[`i',3]
	file write PFE_results "`al_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_k$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su ak if nic08_2d == `j'
	local ak: di %3.2f r(mean)
	file write PFE_results "&`ak'"
}
file write PFE_results "\\"_n
forvalues i = 1/5 {
	local ak_lb: di %3.2f param_boot_lb[`i',4]
	file write PFE_results "&[`ak_lb',"
	local ak_ub: di %3.2f param_boot_ub[`i',4]
	file write PFE_results "`ak_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_m$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su am if nic08_2d == `j'
	local am: di %3.2f r(mean)
	file write PFE_results "&`am'"
}
file write PFE_results "\\"_n
forvalues i = 1/5 {
	local am_lb: di %3.2f param_boot_lb[`i',5]
	file write PFE_results "&[`am_lb',"
	local am_ub: di %3.2f param_boot_ub[`i',5]
	file write PFE_results "`am_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_e$"
levelsof nic08_2d, local(ind)
foreach j of local ind {
	su ae if nic08_2d == `j'
	local ae: di %3.2f r(mean)
	file write PFE_results "&`ae'"
}
file write PFE_results "\\"_n
forvalues i = 1/5 {
	local ae_lb: di %3.2f param_boot_lb[`i',6]
	file write PFE_results " &[`ae_lb',"
	local ae_ub: di %3.2f param_boot_ub[`i',6]
	file write PFE_results "`ae_ub']"
}
file write PFE_results "\\"_n
file write PFE_results "\hline"_n
file write PFE_results "\(N\)"
foreach ind in 13 17 20 23 24 {
	su IDnum if nic08_2d == `ind'
	local obs: di %3.0f r(N)
	file write PFE_results "&`obs'"
}
file write PFE_results "\\"_n
file close _all
restore

********************************************************************
*** 2. Get E, measures of productivity
********************************************************************
egen log_uhat = rsum(log_uhat10 log_uhat11 log_uhat12 log_uhat13 log_uhat14 log_uhat15 log_uhat16 log_uhat17 ///
log_uhat18 log_uhat19 log_uhat20 log_uhat21 log_uhat22 log_uhat23 log_uhat24 log_uhat25 log_uhat26 log_uhat27 ///
log_uhat28 log_uhat29 log_uhat30 log_uhat31 log_uhat32 log_uhat33)
gen uhat = exp(log_uhat)

* TFPR excluding fuel productivity (Hicks-neutral)
gen TFPR_hicksn = Yspend/ces_func
gen logTFPR_hicksn = log(TFPR_hicksn)
* TFPR including fuel productivity
gen TFPR = Yspend/ces_func_Emmbtu
gen logTFPR = log(TFPR)
reg logTFPR i.nic08_2d
predict logTFPR_norm, residuals

* TFP excluding fuel productivity (hicks-neutral)
reg LogY i.year#i.nic08_2d i.nic08_2d
predict rev_deflated, residuals
gen logces_func = log(ces_func)
gen logTFP_hicksn = (rev_deflated-log_uhat)*(rho/(rho-1)) - logces_func
* TFP including fuel productivity
foreach fuel in gas oil coal elecb {
	gen gam_`fuel' = `fuel'_mmbtu/E_struc
	gen lngam_`fuel' = log(gam_`fuel')
}
egen gam_fuels = rsum(gam_oil gam_coal gam_gas gam_elec)
gen log_gam_fuel = log(gam_fuels)
reg log_gam_fuel i.nic08_2d // remove industry specific scale
predict log_gam_fuel_noindscale, residuals
foreach fuel in gas oil coal elecb {
	gen tilde_gam_`fuel' = gam_`fuel'/gam_fuel // decomposition of scale and relative fuel productivity
	gen log_tilde_gam_`fuel' = log(tilde_gam_`fuel')
}
egen sum_tilde_gam_fuels = rsum(tilde_gam_gas tilde_gam_oil tilde_gam_coal tilde_gam_elecb)
gen logsum_tilde_gam_fuels = log(sum_tilde_gam_fuels)
gen log_fuelprod = log_gam_fuel_noindscale-logsum_tilde_gam_fuels // (inverse) log fuel productivity
gen logTFP = logTFP_hicksn - eps_e*log_fuelprod

* GRAPH: Fuel productivity terms
reg log_gam_fuel i.nic08_2d
predict Ebar, xb
gen lnEbar = log(Ebar) 
foreach fuel in gas oil coal elecb {
	gen lngam_`fuel'_noindscale = lngam_`fuel'-lnEbar
}
* Drop outliers for fuel productivity graphs and tables (find better method later)
preserve
su E_struc, detail
drop if E_struc > r(p95)
su M_struc, detail
drop if M_struc > r(p95)
graph drop _all
keep if nic08_2d == 13 | nic08_2d ==  17 | nic08_2d ==  20 | nic08_2d ==  23 | nic08_2d ==  24

graph twoway (hist lngam_coal_noindscale, frac lcolor(gs12) fcolor(gs12) width(`BinWidth') start(`MinVal')) ///
	(hist lngam_gas_noindscale, frac lcolor(red) fcolor(none) width(`BinWidth') start(`MinVal')), ///
	legend(label(1 "Coal") label(2 "Natural Gas")) 
graph export Output/Graphs/Post_PFE/FuelGamma_GasCoaldist-SelectedInd.pdf, replace

foreach fuel in gas oil coal elecb {
	su lngam_`fuel'_noindscale
	local rmean: di %10.2f r(mean)
	hist lngam_`fuel'_noindscale if lngam_`fuel'_noindscale > -20 & lngam_`fuel'_noindscale < 20, xtitle(`fuel') xtitle(`fuel' (mean = `rmean')) xline(5) xlabel(-20[5]20) name(gam_`fuel', replace)
}
gr combine gam_gas gam_oil gam_coal gam_elecb
graph export Output/Graphs/Post_PFE/FuelGamma_dist-SelectedInd.pdf, replace
restore

********************************************************************
*** 2. Relationship between PFE estimates and fuel switching
********************************************************************
sort IDnum year
* Define adding a fuel to the mix in current period
foreach fuel in TotCoal TotOil TotGas elecb {
	gen fuelswitch_to`fuel' = 0
	replace fuelswitch_to`fuel' = 1 if `fuel'_mmbtu > 0 & L.`fuel'_mmbtu == 0
}
rename fuelswitch_toTotCoal fuelswitch_tocoal
rename fuelswitch_toTotGas fuelswitch_togas
rename fuelswitch_toTotOil fuelswitch_tooil
rename fuelswitch_offTotCoal fuelswitch_offcoal
rename fuelswitch_offTotGas fuelswitch_offgas
rename fuelswitch_offTotOil fuelswitch_offoil
gen fuelswitch_to = 0
replace fuelswitch_to = 1 if fuelswitch_tocoal == 1 | fuelswitch_tooil ==  1 | fuelswitch_togas == 1 | fuelswitch_toelecb == 1
* Tag plants that add a fuel to their mix
bysort IDnum: egen switch_to_anyyear = max(fuelswitch_to)
bysort IDnum: egen switch_togas_anyyear = max(fuelswitch_togas)
bysort IDnum: egen switch_tocoal_anyyear = max(fuelswitch_tocoal)
bysort IDnum: egen switch_tooil_anyyear = max(fuelswitch_tooil)
bysort IDnum: egen switch_toelec_anyyear = max(fuelswitch_toelecb)

*GRAPH: effect of TFP last period and alpha_e on probability of switching fuel 
preserve
su E_struc, detail
drop if E_struc > r(p95)
su M_struc, detail
drop if M_struc > r(p95)
keep if nic08_2d == 13 | nic08_2d ==  17 | nic08_2d ==  20 | nic08_2d ==  23 | nic08_2d ==  24
eststo clear
quietly probit fuelswitch_to L.logTFP ae
margins, dydx(*) post
eststo mdl1, title("All fuels"): margins
quietly probit fuelswitch_togas L.logTFP ae
margins, dydx(*) post
eststo mdl2, title("Natural Gas"): margins
quietly probit fuelswitch_tocoal L.logTFP ae
margins, dydx(*) post
eststo mdl3, title("Coal"): margins
quietly probit fuelswitch_tooil L.logTFP ae
margins, dydx(*) post
eststo mdl4, title("Oil"): margins
quietly probit fuelswitch_toelecb L.logTFP ae
margins, dydx(*) post
eststo mdl5, title("Electricity"): margins
esttab using "Output/Tables/Post_PFE/SwitchingProbit_me-SelectedInd.tex", se noconstant title("Marginal effects, probability of adding fuel (current year)") ///
star(+ 0.1 * 0.05 ** 0.01 *** 0.001) mtitles replace
restore


* Balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 6
drop nyear


