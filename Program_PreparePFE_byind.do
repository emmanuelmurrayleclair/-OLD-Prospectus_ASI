*** CODEFILE 6 ver2***

** ssc install egenmore

********************************************************************
*** Preparation for PFE (Grieco et al. 2016) - all Industries    ***
********************************************************************

* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
use Data/Panel_Data/Clean_data/ASI_PanelClean-selectedind, clear
*use Data/Panel_Data/Clean_data/ASI_PanelClean-allind, clear
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
*merge 1:1 IDnum year using Data/Panel_Data/Clean_data/ASI_PFquantities_byind-panel
merge 1:1 IDnum year using Data/Panel_Data/Clean_data/ASI_PFquantities_byind_selectedInd-panel

* Keep active plants
drop if Y == 0 | K == 0 | M == 0 | PersonsTotal == 0 | TotalOutput == 0
drop _merge

* Energy (quantity in mmbtu and geometric mean)
gen E = oil_mmbtu+coal_mmbtu+gas_mmbtu+elecb_mmbtu
egen Egmean = gmean(E), by(nic08_3d)
* Energy (spending in lakhs - hundred thousand rupees)
egen Espend = rowtotal(TotCoal TotOil TotGas PurchValElecBought)
replace Espend = Espend/100000
* Geometric mean of Energy spending
egen Espend_gmean = gmean(Espend), by(nic08_3d)
gen Espend_norm = Espend/Espend_gmean
* Labor (spending in lakhs - hundred thousand rupees)
gen Lspend = TotalEmoluments
replace Lspend = Lspend/100000
* Geometric mean of Labor spending
egen Lspend_gmean = gmean(Lspend), by(nic08_3d)
gen Lspend_norm = Lspend/Lspend_gmean
* Output (revenues in lakhs - hundred thousand rupees)
gen Yspend = TotalOutput
replace Yspend = Yspend/100000
gen LogY = log(Yspend)

/*
* Capital (deflated by year and normalized around geometric mean)
gen Kspend = Capital/100000
gen logKspend = log(Kspend)
reg logKspend
bysort year: reg logKspend
predict logK, residuals
gen Kqty = exp(logK)
egen Kgmean = gmean(Kqty), by(nic08_2d)
gen K = Kqty/Kgmean
*/
/*
* Intermediates (deflated by year and normalized around geometric mean)
gen Mspend = (TotalInputs-Espend)/100000
gen logMspend = log(Mspend)
bysort year: reg logMspend
predict logM, residuals
gen Mqty = exp(logM)
egen Mgmean = gmean(Mqty), by(nic08_2d)
gen M = Mqty/Mgmean
*/
/*
* Labor (deflated by year and normalized around geometric mean)
gen logLspend = log(Lspend)
bysort year: reg logLspend
predict logL, residuals
gen Lqty = exp(logL)
egen Lgmean = gmean(Lqty), by(nic08_2d)
gen L = Lqty/Lgmean
*/
* Labor (Number of employees normalized around geometric mean)
gen Lqty = PersonsTotal
egen Lgmean = gmean(Lqty), by(nic08_3d)
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

/*
* Pool all industries together
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
nl pfe1 @ LogY Lspend Espend KL ML, parameters(rho akal amal sig) initial(rho 2 akal 2 amal 2 sig 3)
*/

* Initial guess of elasticity of substitution across plants
global rho = 1.1

program drop nlpfe
program nlpfe	
    version 16
    
    syntax varlist(min=5 max=5) if, at(name)
    local LogY: word 1 of `varlist'
    local Lspend: word 2 of `varlist'
    local Espend: word 3 of `varlist'
	local KL: word 4 of `varlist'
	local ML: word 5 of `varlist'

    // Define parameters
    tempname rho akal amal sig
    *scalar `rho' = `at'[1,1]
    scalar `akal' = `at'[1,1]
    scalar `amal' = `at'[1,2]
	scalar `sig' = `at'[1,3]

    // Some temporary variables (functions within CES)
    tempvar kterm mterm constant
    generate double `kterm' = exp(ln(`akal'))*(`KL'^((`sig'-1)/`sig')) `if'
    generate double `mterm' = exp(ln(`amal'))*(`ML'^((`sig'-1)/`sig')) `if'
	*generate double `constant' = ln(`rho'/(`rho'-1)) `if'
	generate double `constant' = ln(${rho}/(${rho}-1)) `if'

    // Now fill in dependent variable
    replace `LogY' = `constant' + ln(`Lspend'*(1+`kterm'+`mterm') + `Espend') `if'
end

* drop industries with too little plants
*drop if nic08_3d == 116 | nic08_3d == 130 | nic08_3d == 146 | nic08_3d == 149 | nic08_3d == 311

* Perform estimation of rho
local iter = 1
mat rho_guesses = J(50,2,.)
egen ind_group = group(nic08_3d)
su ind_group
mat ind_rss = J(r(max),1,.) // Matrix to store the residuals sum of squares for each industry
forvalues i = 1.6(0.1)6 {
	global rho = `i'
	levelsof nic08_3d, local(ind)
	local iter_ind = 1
	foreach j of local ind {
		nl pfe @ LogY Lspend Espend KL ML if nic08_3d == `j', parameters(akal amal sig) initial(akal 2 amal 2 sig 2)
		mat ind_rss[`iter_ind',1] = e(rss)
		local ++iter_ind
	}
	mat rho_guesses[`iter',1] = ${rho}
	matsum ind_rss, c(sum_ind_rss)
	mat rho_guesses[`iter',2] = sum_ind_rss
	local ++iter
}
* Save estimates of rho matrix for later use
svmat rho_guesses
preserve
	keep rho_guesses1 rho_guesses2
	save Output/rho_guesses.dta, replace
restore


* Save rho that minimizes rss (MANUALLY FOR NOW, UPDATE LATER)
global rho = 2.7
* Get parameter estimates by industry at optimal rho
su ind_group
foreach vars in akal amal aeal sig {
	mat `vars' = J(r(max),1,.)
}
local iter_ind = 1
levelsof nic08_3d, local(ind)
foreach j of local ind {
	nl pfe @ LogY Lspend Espend KL ML if nic08_3d == `j', parameters(akal amal sig) initial(akal 2 amal 2 sig 2)
	mat akal[`iter_ind',1] = _b[/akal]
	mat amal[`iter_ind',1] = _b[/amal]
	mat sig[`iter_ind',1] = _b[/sig]
	predict log_uhat`j' if nic08_3d == `j', residuals 
	local ++iter_ind
}
*egen log_uhat = rsum(log_uhat170 log_uhat231 log_uhat239 log_uhat241 log_uhat242)

*egen log_uhat = rsum(log_uhat10-log_uhat33)
*drop log_uhat10-log_uhat33

* Recover ae/al from optimality condition
preserve
	collapse (mean) Espend_gmean Lspend_gmean, by(nic08_3d)
	mkmat Espend_gmean
	mkmat Lspend_gmean
restore
local iter_ind = 1
levelsof nic08_3d, local(ind)
foreach j of local ind {
	mat aeal[`iter_ind',1] = Espend_gmean[`iter_ind',1]/Lspend_gmean[`iter_ind',1]
	local ++iter_ind
}
* Recover structural parameters (rho,sigma,alpha_l,alpha_k,alpha_m,alpha_e)
su ind_group
mat param_struc = J(r(max),7,.)
local iter_ind = 1
levelsof nic08_3d, local(ind)
foreach j of local ind {
	mat param_struc[`iter_ind',1] = `j'
	mat param_struc[`iter_ind',2] = ${rho}
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
	rename param_struc1 nic08_3d
	rename param_struc2 rho
	rename param_struc3 sig
	rename param_struc4 al
	rename param_struc5 ak
	rename param_struc6 am
	rename param_struc7 ae
	drop if nic08_3d == .
	tempfile param_est
	save `param_est'
restore
merge m:1 nic08_3d using `param_est'
drop _merge*
replace am = 0 if am < 0

********************************************************************
*** 2. Get E, measures of productivity
********************************************************************

*gen uhat = exp(log_uhat)
* E as in the model
gen E_struc = ((Espend/Lspend)^(sig/(sig-1)))*((al/ae)^(sig/(sig-1)))*L
* sum_f e_f (quantity of fuel actually consumed)
egen E_mmbtu = rsum(coal_mmbtu oil_mmbtu gas_mmbtu elecb_mmbtu) 
egen Emmbtu_gmean = gmean(E_mmbtu), by(nic08_3d)
gen Eqty = E_mmbtu/Emmbtu_gmean
gen lterm = (al*(L)^((sig-1)/sig))
gen mterm = (am*(M)^((sig-1)/sig))
gen kterm = (ak*(K)^((sig-1)/sig))
gen eterm = (ae*(E_struc)^((sig-1)/sig))
gen eterm_mmbtu = (ae*(Eqty)^((sig-1)/sig))
gen ces_func = (lterm+mterm+kterm+eterm)^(sig/(sig-1))
gen ces_func_Emmbtu = (lterm+mterm+kterm+eterm_mmbtu)^(sig/(sig-1))


* TFP excluding fuel productivity
gen z = Y/ces_func
gen logz = log(z)
* TFP including fuel productivity
gen TFP = Y/ces_func_Emmbtu
gen logTFP = log(TFP)

/*
* TFPR excluding fuel productivity
gen logYres = LogY-ces_func
reg logYres i.nic08_3d
predict logTFPR, residuals 
gen logTFPR_persistent = logTFPR-log_uhat
* TFPR including fuel productivity
gen logYres_all = LogY-ces_func_Emmbtu
reg logYres_all i.nic08_3d
predict logTFPR_all, residuals
gen logTFPR_all_persistent = logTFPR_all-log_uhat
*/

* Fuel productivity terms
foreach fuel in gas oil coal elecb {
	gen gam_`fuel' = `fuel'_mmbtu/E_struc
	gen lngam_`fuel' = log(gam_`fuel')
}
graph drop _all
foreach fuel in gas oil coal elecb {
	graph twoway hist lngam_`fuel', xtitle(`fuel') xline(10) name(gam_`fuel', replace)
}
gr combine gam_gas gam_oil gam_coal gam_elecb
graph export Output/Graphs/Post_PFE/FuelProductivity_dist.pdf, replace



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


* Balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 8
drop nyear












