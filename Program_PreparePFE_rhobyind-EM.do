*** CODEFILE 6 ver2***

** ssc install egenmore

//131 (textile) 170 (paper) 239 (cement) 241 (steel and iron)

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
drop if nic08_3d == 142 | nic08_3d == 164 | nic08_3d == 182 | nic08_3d == 268 | nic08_3d == 322
*/

********************************************************************
*** 1. Prepare Inputs and Output for PFE
********************************************************************

* Nominal to real
foreach item in TotCoal TotOil TotGas PurchValElecBought TotalEmoluments TotalOutput Capital Inputs {
	quietly replace `item' = `item'*1.080291971 if year == 2010
	quietly replace `item' = `item'*1.218978102 if year == 2011
	quietly replace `item' = `item'*1.343065693 if year == 2012
	quietly replace `item' = `item'*1.459854015 if year == 2013
	quietly replace `item' = `item'*1.605839416 if year == 2014
	quietly replace `item' = `item'*1.751824818 if year == 2015
	quietly replace `item' = `item'*1.854014599 if year == 2016
}

* Energy (spending in lakhs)
*local be = 0.00001
local be = 0.000000004
*local be = 1
egen Espend_nominal = rowtotal(TotCoal TotOil TotGas PurchValElecBought)
gen Espend = Espend_nominal*`be'
*gen Espend = Espend_nominal
gen logEspend = log(Espend)
* Geometric mean of Energy spending
egen Egmean = gmean(Espend), by(nic08_4d)
gen Espend_norm = Espend/Egmean
gen E = Espend_norm

* Labor (spending in lakhs)
gen Lspend_nominal = TotalEmoluments
su Espend_nominal
local sde = r(sd)
su Lspend_nominal
local sdl = r(sd)
local bl = (`be'*`sde')/`sdl'
*gen Lspend = Lspend_nominal*`bl'
gen Lspend = Lspend_nominal*`be'
*gen Lspend = Lspend_nominal
gen logLspend = log(Lspend)
* Geometric mean of Labor spending
egen Lgmean = gmean(Lspend), by(nic08_4d)
gen L = Lspend/Lgmean

* Output (revenues in lakhs)
gen Yspend_nominal = TotalOutput
su Yspend_nominal
local sdy = r(sd)
local bout = (`be'*`sde')/`sdy'
*gen Yspend = Yspend_nominal*`bout'
gen Yspend = Yspend_nominal*`be'
*gen Yspend = Yspend_nominal
gen LogY = log(Yspend)
* Geometric mean of revenues
egen Ygmean = gmean(Yspend), by(nic08_4d)
gen Y = Yspend/Ygmean

* Capital (value in lakhs)
gen Kspend_nominal = Capital
su Kspend_nominal
local sdk = r(sd)
local bk = (`be'*`sde')/`sdk'
*gen Kspend = Kspend_nominal*`bk'
gen Kspend = Kspend_nominal*`be'
*gen Kspend = Kspend_nominal
gen logKspend = log(Kspend)
* Geometric mean of Capital
egen Kgmean = gmean(Kspend), by(nic08_4d)
gen K = Kspend/Kgmean

* Intermediates normalized around geometric mean)
gen Mspend_nominal = (Inputs-Espend_nominal)
su Mspend_nominal
local sdm = r(sd)
local bm = (`be'*`sde')/`sdm'
*gen Mspend = Mspend_nominal*`bm'
gen Mspend = Mspend_nominal*`be'
*gen Mspend = Mspend_nominal
gen logMspend = log(Mspend)
* Geometric mean of Intermediates
egen Mgmean = gmean(Mspend), by(nic08_4d)
gen Mspend_norm = Mspend/Mgmean
gen M = Mspend_norm

/*
* Labor (Number of employees normalized around geometric mean)
gen Lqty = PersonsTotal
egen Lgmean = gmean(Lqty), by(nic08_2d)
replace L = Lqty/Lgmean
*/

* Keep active plants
keep if LogY != . & Lspend != . & Espend != . & Mspend != . & Kspend != .
keep if Lspend > 0 & Espend > 0 & Mspend > 0 & Kspend > 0 & Yspend > 0

* All variables used for PFE
gen KL = K/L
gen KM = K/M
gen LM = L/M

su KM, detail
drop if KM >= r(p95)
su LM, detail
drop if LM >= r(p95)

foreach vars in M L K Y E {
	drop `vars'gmean
	drop `vars'
	egen `vars'gmean = gmean(`vars'spend), by(nic08_4d)
	gen `vars' = `vars'spend/`vars'gmean
}
drop KM LM KL
gen KL = K/L
gen KM = K/M
gen LM = L/M

drop if nic08_4d == 116 | nic08_4d == 130 | nic08_4d == 146 | nic08_4d == 149 | nic08_4d == 311 | nic08_4d == 321 

/*
su KM 
local sdkm = r(sd)
local bkm = (`be'*`sde')/`sdkm'
replace KM = KM*`bkm'
su LM 
local sdlm = r(sd)
local blm = (`be'*`sde')/`sdlm'
replace LM = LM*`blm'
*/

/*
su KM, detail
drop if KM > r(p95) | KM < r(p5)
su LM, detail
drop if LM > r(p95) | LM < r(p5)
*/

/*
* Keep active plants
keep if LogY != . & Lspend != . & Espend != . & Mspend != . & KL != .
keep if Lspend > 0 & Espend > 0 & Mspend > 0
*/
/*
* Save data for matlab
levelsof nic08_3d, local(ind)
foreach j of local ind {
	preserve
		keep LogY Espend Mspend KM LM Espend_gmean Lspend_gmean Mspend_gmean nic08_3d
		keep if nic08_3d == `j'
		export delimited Output/PFEdata`j'.txt,replace
	restore
}
*/

********************************************************************
*** 2. Perform PFE estimation
********************************************************************

/*
* drop industries with too little plants
drop if nic08_3d == 116 | nic08_3d == 130 | nic08_3d == 146 | nic08_3d == 149 | nic08_3d == 311
*/


* Unconstrained - RF parameters
program drop gmm_prod
program gmm_prod
	version 16

	syntax varlist [if], at(name) rhs(varlist) lhs(varname)
	
	local m1: word 1 of `varlist'
	local m2: word 2 of `varlist'
	local m3: word 3 of `varlist'
	local m4: word 4 of `varlist'

	local logy: word 1 of `lhs'
	local Espend: word 1 of `rhs'
	local Mspend: word 2 of `rhs'
	local KM: word 3 of `rhs'
	local LM: word 4 of `rhs'

	tempname rho akm alm sig
	scalar `rho'=`at'[1,1] 
	scalar `akm'=`at'[1,2]
	scalar `alm'=`at'[1,3]
	scalar `sig'=`at'[1,4]
	
	tempvar kterm lterm func res del_akm del_alm del_sig
	
	quietly gen double `kterm' = exp(`akm')*(`KM'^(`sig')) `if' 
	quietly gen double `lterm' = exp(`alm')*(`LM'^(`sig')) `if'
	quietly gen double `func' = `Mspend'*(1+`kterm'+`lterm')+`Espend' `if'
	quietly gen double `res' = `logy' - `rho' - ln(`func') `if'
	
	quietly gen double `del_akm' = (exp(`akm')*(`KM'^(`sig'))*`Mspend')/`func' `if'
	quietly gen double `del_alm' = (exp(`alm')*(`LM'^(`sig'))*`Mspend')/`func' `if'
	quietly gen double `del_sig' = (`Mspend'*(exp(`akm')*ln(`KM')*(`KM'^(`sig')) + exp(`alm')*ln(`LM')*(`LM'^(`sig'))))/`func' `if'
	
	quietly replace `m1' = `res' `if'
	quietly replace `m2' = `res'*`del_akm' `if'
	quietly replace `m3' = `res'*`del_alm' `if'
	quietly replace `m4' = `res'*`del_sig' `if'
end

* Constrained - RF parameters
program drop gmm_prod
program gmm_prod
	version 16

	syntax varlist [if], at(name) rhs(varlist) lhs(varname)
	
	local m1: word 1 of `varlist'
	local m2: word 2 of `varlist'
	local m3: word 3 of `varlist'
	local m4: word 4 of `varlist'

	local logy: word 1 of `lhs'
	local Espend: word 1 of `rhs'
	local Mspend: word 2 of `rhs'
	local KM: word 3 of `rhs'
	local LM: word 4 of `rhs'

	tempname rho akm alm sig
	scalar `rho'=`at'[1,1] 
	scalar `akm'=`at'[1,2]
	scalar `alm'=`at'[1,3]
	scalar `sig'=`at'[1,4]
	
	tempvar kterm lterm func res del_akm del_alm del_sig sigterm
	
	quietly gen double `sigterm' = 1-exp(`sig')
	quietly gen double `kterm' = exp(`akm')*(`KM'^(`sigterm')) `if' 
	quietly gen double `lterm' = exp(`alm')*(`LM'^(`sigterm')) `if'
	quietly gen double `func' = `Mspend'*(1+`kterm'+`lterm')+`Espend' `if'
	quietly gen double `res' = `logy' - exp(`rho') - ln(`func') `if'
	
	quietly gen double `del_akm' = (exp(`akm')*(`KM'^(`sigterm'))*`Mspend')/`func' `if'
	quietly gen double `del_alm' = (exp(`alm')*(`LM'^(`sigterm'))*`Mspend')/`func' `if'
	quietly gen double `del_sig' = (`Mspend'*(exp(`akm')*exp(`sig')*ln(`KM')*(`KM'^(`sigterm')) + exp(`alm')*exp(`sig')*ln(`LM')*(`LM'^(`sigterm'))))/`func' `if'
	
	quietly replace `m1' = `res' `if'
	quietly replace `m2' = `res'*`del_akm' `if'
	quietly replace `m3' = `res'*`del_alm' `if'
	quietly replace `m4' = `res'*`del_sig' `if'

end
mat test3 = [2,-4,-3.5,-0.5,-1.0642,0.5]
gmm gmm_prod if nic08_2d == 17, one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Espend_gmean Mspend_gmean) from(test3)

* Unconstrained - structural parameters
program drop gmm_prod
program gmm_prod
	version 16

	syntax varlist [if], at(name) rhs(varlist) lhs(varname)
	
	local m1: word 1 of `varlist'
	local m2: word 2 of `varlist'
	local m3: word 3 of `varlist'
	local m4: word 4 of `varlist'
	local m5: word 5 of `varlist'
	local m6: word 6 of `varlist'
	local m7: word 7 of `varlist'

	local logy: word 1 of `lhs'
	local Espend: word 1 of `rhs'
	local Mspend: word 2 of `rhs'
	local KM: word 3 of `rhs'
	local LM: word 4 of `rhs'
	local Espend_gmean: word 5 of `rhs'
	local Mspend_gmean: word 6 of `rhs'

	tempname rho ak al am ae sig
	scalar `rho'=`at'[1,1] 
	scalar `ak'=`at'[1,2]
	scalar `al'=`at'[1,3]
	scalar `am'=`at'[1,4]
	scalar `ae'=`at'[1,5]
	scalar `sig'=`at'[1,6]
	
	tempvar kterm lterm func res del_ak del_al del_am del_sig ak1 al1 am1 ae1 rhoterm sigterm
	
	quietly gen double `ak1'= exp(`ak') `if'
	quietly gen double `al1'= exp(`al') `if'
	quietly gen double `am1'= exp(`am') `if'
	quietly gen double `ae1'= exp(`ae') `if'
	*quietly gen double `rhoterm' = ln(`rho'/(`rho'-1)) `if'
	quietly gen double `sigterm' = `sig' //(`sig'-1)/`sig' `if'
	
	quietly gen double `kterm' = (`ak1'/`am1')*(`KM'^(`sigterm')) `if' 
	quietly gen double `lterm' = (`al1'/`am1')*(`LM'^(`sigterm')) `if'
	quietly gen double `func' = `Mspend'*(1+`kterm'+`lterm')+`Espend' `if'
	quietly gen double `res' = `logy' - `rho' - ln(`func') `if'
	
	quietly gen double `del_ak' = -1*((`KM'^(`sigterm'))*(`Mspend'*`ak1'/`am1'))/`func' `if'
	quietly gen double `del_al' = -1*((`LM'^(`sigterm'))*(`Mspend'*`al1'/`am1'))/`func' `if'
	*quietly gen double `del_am' = ((`LM'^(`sigterm'))*`Mspend'*(`al1'/(`am1'^2)) + (`KM'^(`sigterm'))*`Mspend'*(`ak1'/(`am1')^2))/`func' `if'
	quietly gen double `del_am' = ((`LM'^(`sigterm'))*`Mspend'*(`al1'/`am1') + (`KM'^(`sigterm'))*`Mspend'*(`ak1'/`am1'))/`func' `if'
	*quietly gen double `del_sig' = -1*(`Mspend'*(`ak1'/`am1')*(ln(`KM')/(`sig'^2))*(`KM'^(`sigterm')) + (`al1'/`am1')*(ln(`LM')/(`sig'^2))*(`LM'^(`sigterm')))/`func' `if'
	quietly gen double `del_sig' = -1*(`Mspend'*(`ak1'/`am1')*ln(`KM')*(`KM'^(`sig')) + (`al1'/`am1')*ln(`LM')*(`LM'^(`sig')))/`func' `if'
	
	quietly replace `m1' = `res' `if' //*(1/(`rho'*(`rho-1'))) `if'
	quietly replace `m2' = `res'*`del_ak' `if'
	quietly replace `m3' = `res'*`del_al' `if'
	quietly replace `m4' = `res'*`del_am' `if'
	quietly replace `m5' = `res'*`del_sig' `if'
	quietly replace `m6' = `ak1'+`al1'+`ae1'+`am1'-1 `if'
	quietly replace `m7' = (`Espend_gmean'/`Mspend_gmean')-(`ae1'/`am1') `if'
end
mat test3 = [0.5,-1.6,-1.5,-0.5,-0.5,0.5]
*drop if nic08_3d == 181
* Perform estimation of pfe parameters
local iter = 1
egen ind_group = group(nic08_3d)
su ind_group
foreach vars in rho_def ak_def al_def ae_def am_def sig_def {
	mat `vars' = J(r(max),2,.)
}
levelsof nic08_3d, local(ind)
local iter_ind = 1
foreach j of local ind {
	gmm gmm_prod if nic08_3d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) conv_maxiter(100)
	scalar rho = exp(_b[/rho])
	mat rho_def[`iter_ind',1] = rho/(rho-1)
	mat ak_def[`iter_ind',1] = exp(_b[/ak])
	mat al_def[`iter_ind',1] = exp(_b[/al])
	mat am_def[`iter_ind',1] = exp(_b[/am])
	mat ae_def[`iter_ind',1] = exp(_b[/ae])
	scalar sig = _b[/sig]
	mat sig_def[`iter_ind',1] = 1/(1-sig)
	mat cov_def_`j' = e(V)
	*predict log_uhat_def`j' if nic08_2d == `j', residuals 
	local ++iter_ind
}
gen converge_nr = 0
su ind_group
foreach vars in rho_nr ak_nr al_nr ae_nr am_nr sig_nr {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	gmm gmm_prod if nic08_2d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) technique(nr) conv_maxiter(100)
	if converge_nr == 1 {
		scalar rho = exp(_b[/rho])
		mat rho_nr[`iter_ind',1] = rho/(rho-1)
		mat ak_nr[`iter_ind',1] = exp(_b[/ak])
		mat al_nr[`iter_ind',1] = exp(_b[/al])
		mat am_nr[`iter_ind',1] = exp(_b[/am])
		mat ae_nr[`iter_ind',1] = exp(_b[/ae])
		mat sig = _b[/sig]
		mat sig_nr[`iter_ind',1] = 1/(1-sig)
		mat cov_nr_`j' = e(V)
	}
	*predict log_uhat_nr`j' if nic08_2d == `j', residuals 
	local ++iter_ind
}
gen converge_dfp = 0
su ind_group
foreach vars in rho_dfp ak_dfp al_dfp ae_dfp am_dfp sig_dfp {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	gmm gmm_prod if nic08_2d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) technique(dfp) conv_maxiter(100)
	replace converge_dfp = e(converged)
	if converge_dfp == 1 {
		scalar rho = exp(_b[/rho])
		mat rho_dfp[`iter_ind',1] = rho/(rho-1)
		mat ak_dfp[`iter_ind',1] = exp(_b[/ak])
		mat al_dfp[`iter_ind',1] = exp(_b[/al])
		mat am_dfp[`iter_ind',1] = exp(_b[/am])
		mat ae_dfp[`iter_ind',1] = exp(_b[/ae])
		scalar sig = _b[/sig]
		mat sig_dfp[`iter_ind',1] = 1/(1-sig)
		mat cov_dfp_`j' = e(V)
		*predict log_uhat_dfp`j' if nic08_2d == `j', residuals 
	}
	local ++iter_ind
}
gen converge_bfgs = 0
su ind_group
foreach vars in rho_bfgs ak_bfgs al_bfgs ae_bfgs am_bfgs sig_bfgs {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	capture gmm gmm_prod if nic08_2d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) technique(bfgs) conv_maxiter(100)
	replace converge_bfgs = e(converged)
	if converge_bfgs == 1 {
		scalar rho = exp(_b[/rho])
		mat rho_bfgs[`iter_ind',1] = rho/(rho-1)
		mat ak_bfgs[`iter_ind',1] = exp(_b[/ak])
		mat al_bfgs[`iter_ind',1] = exp(_b[/al])
		mat am_bfgs[`iter_ind',1] = exp(_b[/am])
		mat ae_bfgs[`iter_ind',1] = exp(_b[/ae])
		scalar sig = _b[/sig]
		mat sig_bfgs[`iter_ind',1] = 1/(1-sig)
		mat cov_bfgs_`j' = e(V)
	}
	*predict log_uhat_bfgs`j' if nic08_2d == `j', residuals 
	local ++iter_ind
}


gmm gmm_prod if nic08_2d == 17, one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3)


* Unconstrained - structural parameters
program drop gmm_prod
program gmm_prod
	version 16

	syntax varlist [if], at(name) rhs(varlist) lhs(varname)
	
	local m1: word 1 of `varlist'
	local m2: word 2 of `varlist'
	local m3: word 3 of `varlist'
	local m4: word 4 of `varlist'
	local m5: word 5 of `varlist'
	local m6: word 6 of `varlist'
	local m7: word 7 of `varlist'

	local logy: word 1 of `lhs'
	local Espend: word 1 of `rhs'
	local Mspend: word 2 of `rhs'
	local KM: word 3 of `rhs'
	local LM: word 4 of `rhs'
	local Espend_gmean: word 5 of `rhs'
	local Mspend_gmean: word 6 of `rhs'

	tempname rho ak al am ae sig
	scalar `rho'=`at'[1,1] 
	scalar `ak'=`at'[1,2]
	scalar `al'=`at'[1,3]
	scalar `am'=`at'[1,4]
	scalar `ae'=`at'[1,5]
	scalar `sig'=`at'[1,6]
	
	tempvar kterm lterm func res del_ak del_al del_am del_sig ak1 al1 am1 ae1 sigterm //rhoterm
	
	quietly gen double `ak1'= exp(`ak') `if'
	quietly gen double `al1'= exp(`al') `if'
	quietly gen double `am1'= exp(`am') `if'
	quietly gen double `ae1'= exp(`ae') `if'
	quietly gen double `sigterm' = (`sig'-1)/`sig' `if'
	
	quietly gen double `kterm' = (`ak1'/`am1')*(`KM'^(`sigterm')) `if' 
	quietly gen double `lterm' = (`al1'/`am1')*(`LM'^(`sigterm')) `if'
	quietly gen double `func' = `Mspend'*(1+`kterm'+`lterm')+`Espend' `if'
	*quietly gen double `rhoterm' = exp(`rho') `if'
	quietly gen double `res' = `logy' - `rho' - ln(`func') `if'
	
	quietly gen double `del_ak' = -1*((`KM'^(`sigterm'))*(`Mspend'*`ak1'/`am1'))/`func' `if'
	quietly gen double `del_al' = -1*((`LM'^(`sigterm'))*(`Mspend'*`al1'/`am1'))/`func' `if'
	quietly gen double `del_am' = ((`LM'^(`sigterm'))*`Mspend'*(`al1'/`am1') + (`KM'^(`sigterm'))*`Mspend'*(`ak1'/`am1'))/`func' `if'
	*quietly gen double `del_sig' = -1*(`Mspend'*(`ak1'/`am1')*ln(`KM')*(`KM'^(`sig')) + (`al1'/`am1')*ln(`LM')*(`LM'^(`sig')))/`func' `if'
	quietly gen double `del_sig' = -1*(`Mspend'*(`ak1'/`am1')*(ln(`KM')/(`sig'^2))*(`KM'^(`sigterm')) + (`al1'/`am1')*(ln(`LM')/(`sig'^2))*(`LM'^(`sigterm')))/`func' `if'
	
	quietly replace `m1' = `res' `if'
	quietly replace `m2' = `res'*`del_ak' `if'
	quietly replace `m3' = `res'*`del_al' `if'
	quietly replace `m4' = `res'*`del_am' `if'
	quietly replace `m5' = `res'*`del_sig' `if'
	quietly replace `m6' = `ak1'+`al1'+`ae1'+`am1'-1 `if'
	quietly replace `m7' = (`Espend_gmean'/`Mspend_gmean')-(`ae1'/`am1') `if'
end
mat test3 = [0.5,-1.6,-1.5,-0.5,-0.5,2]
* Perform estimation of pfe parameters
local iter = 1
egen ind_group = group(nic08_2d)
su ind_group
foreach vars in rho_def ak_def al_def ae_def am_def sig_def {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	capture gmm gmm_prod if nic08_2d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) conv_maxiter(100)
	scalar rho = exp(_b[/rho])
	mat rho_def[`iter_ind',1] = rho/(rho-1)
	mat ak_def[`iter_ind',1] = exp(_b[ak])
	mat al_def[`iter_ind',1] = exp(_b[al])
	mat am_def[`iter_ind',1] = exp(_b[am])
	mat ae_def[`iter_ind',1] = exp(_b[ae])
	scalar sig = _b[/sig]
	mat sig_def[`iter_ind',1] = 1/(1-sig)
	predict log_uhat_def`j' if nic08_2d == `j', residuals 
	local ++iter_ind
}
su ind_group
foreach vars in rho_nr ak_nr al_nr ae_nr am_nr sig_nr {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	capture gmm gmm_prod if nic08_2d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) technique(nr) conv_maxiter(100)
	scalar rho = exp(_b[/rho])
	mat rho_nr[`iter_ind',1] = rho/(rho-1)
	mat ak_nr[`iter_ind',1] = exp(_b[ak])
	mat al_nr[`iter_ind',1] = exp(_b[al])
	mat am_nr[`iter_ind',1] = exp(_b[am])
	mat ae_nr[`iter_ind',1] = exp(_b[ae])
	scalar sig = _b[/sig]
	mat sig_nr[`iter_ind',1] = 1/(1-sig)
	predict log_uhat_nr`j' if nic08_2d == `j', residuals
	local ++iter_ind
}
su ind_group
foreach vars in rho_dfp ak_dfp al_dfp ae_dfp am_dfp sig_dfp {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	capture gmm gmm_prod if nic08_2d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) technique(dfp) conv_maxiter(100)
	scalar rho = exp(_b[/rho])
	mat rho_dfp[`iter_ind',1] = rho/(rho-1)
	mat ak_dfp[`iter_ind',1] = exp(_b[ak])
	mat al_dfp[`iter_ind',1] = exp(_b[al])
	mat am_dfp[`iter_ind',1] = exp(_b[am])
	mat ae_dfp[`iter_ind',1] = exp(_b[ae])
	scalar sig = _b[/sig]
	mat sig_dfp[`iter_ind',1] = 1/(1-sig)
	predict log_uhat_dfp`j' if nic08_2d == `j', residuals 
	local ++iter_ind
}
su ind_group
foreach vars in rho_bfgs ak_bfgs al_bfgs ae_bfgs am_bfgs sig_bfgs {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_2d, local(ind)
local iter_ind = 1
foreach j of local ind {
	capture gmm gmm_prod if nic08_2d == `j', one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3) technique(bfgs) conv_maxiter(100)
	scalar rho = exp(_b[/rho])
	mat rho_bfgs[`iter_ind',1] = rho/(rho-1)
	mat ak_bfgs[`iter_ind',1] = exp(_b[ak])
	mat al_bfgs[`iter_ind',1] = exp(_b[al])
	mat am_bfgs[`iter_ind',1] = exp(_b[am])
	mat ae_bfgs[`iter_ind',1] = exp(_b[ae])
	scalar sig = _b[/sig]
	mat sig_bfgs[`iter_ind',1] = 1/(1-sig)
	predict log_uhat_bfgs`j' if nic08_2d == `j', residuals 
	local ++iter_ind
}



gmm gmm_prod if nic08_2d == 23, one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Egmean Mgmean) from(test3)


* Constrained - structural parameters
program drop gmm_prod
program gmm_prod
	version 16

	syntax varlist [if], at(name) rhs(varlist) lhs(varname)
	
	local m1: word 1 of `varlist'
	local m2: word 2 of `varlist'
	local m3: word 3 of `varlist'
	local m4: word 4 of `varlist'
	local m5: word 5 of `varlist'
	local m6: word 6 of `varlist'
	local m7: word 7 of `varlist'

	local logy: word 1 of `lhs'
	local Espend: word 1 of `rhs'
	local Mspend: word 2 of `rhs'
	local KM: word 3 of `rhs'
	local LM: word 4 of `rhs'
	local Espend_gmean: word 5 of `rhs'
	local Mspend_gmean: word 6 of `rhs'

	tempname rho ak al am ae sig
	scalar `rho'=`at'[1,1] 
	scalar `ak'=`at'[1,2]
	scalar `al'=`at'[1,3]
	scalar `am'=`at'[1,4]
	scalar `ae'=`at'[1,5]
	scalar `sig'=`at'[1,6]
	
	tempvar kterm lterm func res del_ak del_al del_am del_sig ak1 al1 am1 ae1 rhoterm sigterm
	
	quietly gen double `ak1'= exp(`ak') `if'
	quietly gen double `al1'= exp(`al') `if'
	quietly gen double `am1'= exp(`am') `if'
	quietly gen double `ae1'= exp(`ae') `if'
	quietly gen double `sigterm' = 1-exp(`sig') `if'
	quietly gen double `rhoterm' = exp(`rho') `if'
	
	quietly gen double `kterm' = (`ak1'/`am1')*(`KM'^(`sigterm')) `if' 
	quietly gen double `lterm' = (`al1'/`am1')*(`LM'^(`sigterm')) `if'
	quietly gen double `func' = `Mspend'*(1+`kterm'+`lterm')+`Espend' `if'
	quietly gen double `res' = `logy' - `rhoterm' - ln(`func') `if'
	
	quietly gen double `del_ak' = -1*((`KM'^(`sigterm'))*(`Mspend'*`ak1'/`am1'))/`func' `if'
	quietly gen double `del_al' = -1*((`LM'^(`sigterm'))*(`Mspend'*`al1'/`am1'))/`func' `if'
	quietly gen double `del_am' = ((`LM'^(`sigterm'))*`Mspend'*(`al1'/`am1') + (`KM'^(`sigterm'))*`Mspend'*(`ak1'/`am1'))/`func' `if'
	quietly gen double `del_sig' = (`Mspend'*(`ak1'/`am1')*ln(`KM')*(exp(`sig'))*(`KM'^`sigterm') + `Mspend'*(`al1'/`am1')*ln(`LM')*(exp(`sig'))*(`LM'^`sigterm'))/`func' `if'
	
	quietly replace `m1' = `res' `if'
	quietly replace `m2' = `res'*`del_ak' `if'
	quietly replace `m3' = `res'*`del_al' `if'
	quietly replace `m4' = `res'*`del_am' `if'
	quietly replace `m5' = `res'*`del_sig' `if'
	quietly replace `m6' = `ak1'+`al1'+`ae1'+`am1'-1 `if'
	quietly replace `m7' = (`Espend_gmean'/`Mspend_gmean')-(`ae1'/`am1') `if'
end
mat test3 = [0.5,-4,-3.5,-0.5,-1.0642,-0.5]
gmm gmm_prod if nic08_2d == 17, one nequations(7) parameters(rho ak al am ae sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM Espend_gmean Mspend_gmean) from(test3)

gen x1 = KM
gen x2 = LM
gen x3 = Mspend
gen x4 = Espend
gen y = LogY
gmm gmm_prod, nequations(1) parameters(b1 b2 b3 b4) instruments(x1 x2 x3) hasderivatives


mat M = (0,5,0.5,0.5,0.5)
gmm_prod LogY Espend Mspend KM LM iden, lhs(LogY) rhs(Espend Mspend KM LM iden) at(M)

gen iden = 1
mat test3 = [2,.05,.1,.5]
gmm gmm_prod if nic08_2d == 24, one nequations(4) parameters(rho akm alm sig) winitial(identity) lhs(LogY) rhs(Espend Mspend KM LM) from(test3)

program drop gmm_prod
program gmm_prod
	version 11

	syntax varlist [if], at(name) rhs(varlist)
	
	local m1: word 1 of `varlist'
	local m2: word 2 of `varlist'
	local m3: word 3 of `varlist'
	local m4: word 4 of `varlist'
	local m5: word 5 of `varlist'

	local vg: word 1 of `rhs'
	local l: word 2 of `rhs'
	local k: word 3 of `rhs'
	local l2: word 4 of `rhs'
	local k2: word 5 of `rhs'
	local lk: word 6 of `rhs'
	local vg_1: word 7 of `rhs'
	local l_1: word 8 of `rhs'
	local k_1: word 9 of `rhs'
	local l2_1: word 10 of `rhs'
	local k2_1: word 11 of `rhs'
	local lk_1: word 12 of `rhs'

	tempname al ak al2 ak2 alk
	scalar `al'=`at'[1,1] 
	scalar `ak'=`at'[1,2]
	scalar `al2'=`at'[1,3]
	scalar `ak2'=`at'[1,4]
	scalar `alk'=`at'[1,5]

	tempvar w w_1 w2_1 w3_1 csi

	quietly gen double `w'=`vg'-`al'*`l'-`ak'*`k'-`al2'*`l2'-`ak2'*`k2'-`alk'*`lk' `if'
	quietly gen double `w_1'=`vg_1'-`al'*`l_1'-`ak'*`k_1'-`al2'*`l2_1'-`ak2'*`k2_1'-`alk'*`lk_1' `if'
	quietly gen double `w2_1'=`w_1'*`w_1' `if'
	quietly gen double `w3_1'=`w2_1'*`w_1' `if'
	quietly reg `w' `w_1' `w2_1' `w3_1' `if'
	quietly predict `csi' `if', resid
	
	quietly replace `m1'=`l'*`csi' `if'	
	quietly replace `m2'=`k'*`csi' `if'	
	quietly replace `m3'=`l2'*`csi' `if'	
	quietly replace `m4'=`k2'*`csi' `if'	
	quietly replace `m5'=`lk'*`csi' `if'	

end
gen vg = LogY
gen l = L
gen k = K
gen l2 = l^2
gen k2 = k^2
gen lk = l*k
gen vg_1 = vg
gen l_1 = L
gen k_1 = K
gen l2_1 = l^2
gen k2_1 = k^2
gen lk_1 = l*k
gmm gmm_prod, one nequations(5) parameters(al ak al2 ak2 alk) winitial(identity) rhs(vg l k l2 k2 lk vg_1 l_1 k_1 l2_1 k2_1 lk_1)



/*
program drop nlpfe1
program nlpfe1	
    version 16
    
    syntax varlist(min=6 max=6) if, at(name)
    local LogY: word 1 of `varlist'
    local Espend: word 2 of `varlist'
	local Mspend: word 3 of `varlist'
	local K: word 4 of `varlist'
	local L: word 5 of `varlist'
	local M: word 6 of `varlist'

    // Define parameters
    tempname rho akam alam sig
	scalar `rho' = `at'[1,1]
    scalar `akam' = `at'[1,2]
	scalar `alam' = `at'[1,3]
	scalar `sig' = `at'[1,4]

    // Some temporary variables (functions within CES)
    tempvar mterm1 mterm2 klterm rhoterm // rhoterm //sigterm
	gen double `mterm1' = (`Mspend'+`Espend')*((`M')^`sig') `if'
	gen double `mterm2' = `sig'*ln(`M') `if'
	gen double `klterm' = `Mspend'*((`akam'*(`K')^`sig') + (`alam'*(`L')^`sig')) `if'
	generate double `rhoterm' = ln(`rho') `if'
	*generate double `rhoterm' = `rho'/(`rho-1') `if'

    // Now fill in dependent variable
    replace `LogY' = `rhoterm' + ln(`mterm1'+`klterm') - `mterm2' `if'
end
*/

program drop nlpfe1
program nlpfe1	
    version 16
    
    syntax varlist(min=5 max=5) if, at(name)
    local LogY: word 1 of `varlist'
    local Espend: word 2 of `varlist'
	local Mspend: word 3 of `varlist'
	local KM: word 4 of `varlist'
	local LM: word 5 of `varlist'

    // Define parameters
    tempname rho akam alam sig
	scalar `rho' = `at'[1,1]
    scalar `akam' = `at'[1,2]
	scalar `alam' = `at'[1,3]
	scalar `sig' = `at'[1,4]

    // Some temporary variables (functions within CES)
    tempvar kterm lterm rhoterm // rhoterm //sigterm
	generate double `kterm' = `akam'*((`KM')^(`sig')) `if' 
	generate double `lterm' = `alam'*((`LM')^(`sig')) `if' 
	generate double `rhoterm' = exp(`rho') `if'

    // Now fill in dependent variable
    replace `LogY' = `rhoterm' + ln(`Mspend'*(1+`kterm'+`lterm') + `Espend') `if'
end


program drop nlpfe1
program nlpfe1	
    version 16
    
    syntax varlist(min=5 max=5) if, at(name)
    local LogY: word 1 of `varlist'
    local Espend: word 2 of `varlist'
	local Mspend: word 3 of `varlist'
	local KM: word 4 of `varlist'
	local LM: word 5 of `varlist'

    // Define parameters
    tempname rho akam alam sig nu
	scalar `rho' = `at'[1,1]
    scalar `akam' = `at'[1,2]
	scalar `alam' = `at'[1,3]
	scalar `sig' = `at'[1,4]
	scalar `nu' = `at'[1,5]

    // Some temporary variables (functions within CES)
    tempvar kterm lterm rhoterm sigterm 
	generate double `sigterm' = `sig' `if' //(`sig'-1)/`sig' `if'	
	generate double `kterm' = `akam'*((`KM')^(`sigterm')) `if' 
	generate double `lterm' = `alam'*((`LM')^(`sigterm')) `if' 
	generate double `rhoterm' = ln(`rho'/(`rho'-1)) `if'
	*generate double `rhoterm' = `rho'/(`rho-1') `if'

    // Now fill in dependent variable
    replace `LogY' = `rho' + ln((`Mspend'/`nu')*(1+`kterm'+`lterm') + `Espend') `if'
end

* Perform estimation of pfe parameters
*drop if nic08_3d == 116 | nic08_3d == 130 | nic08_3d == 146 | nic08_3d == 149 | nic08_3d == 268 | nic08_3d == 311
local iter = 1
egen ind_group = group(nic08_4d)
su ind_group
foreach vars in rho akam alam aeam sig nu {
	mat `vars' = J(r(max),1,.)
}
levelsof nic08_4d, local(ind)
local iter_ind = 1
foreach j of local ind {
	capture nl pfe1 @ LogY Espend Mspend KM LM if nic08_4d == `j', parameters(rho akam alam sig nu) initial(rho 1.5 akam 0.5 alam 0.5 sig 0.5 nu 1.1) vce(robust) iterate(100)
	mat nu[`iter_ind',1] = _b[/nu]
	mat akam[`iter_ind',1] = _b[/akam]
	mat alam[`iter_ind',1] = _b[/alam]
	mat sig[`iter_ind',1] = 1/(-1*(_b[/sig]-1))
	scalar rhoterm = exp(_b[/rho])
	mat rho[`iter_ind',1] = rhoterm/(rhoterm-1)
	predict log_uhat`j' if nic08_4d == `j', residuals 
	local ++iter_ind
}

* Recover ae/am from optimality condition
preserve
	collapse (mean) Egmean Lgmean Mgmean, by(nic08_4d)
	mkmat Egmean
	mkmat Lgmean
	mkmat Mgmean
restore
local iter_ind = 1
levelsof nic08_4d, local(ind)
foreach j of local ind {
	mat aeam[`iter_ind',1] = Egmean[`iter_ind',1]/Mgmean[`iter_ind',1]
	local ++iter_ind
}
* Recover structural parameters (rho,sigma,alpha_l,alpha_k,alpha_m,alpha_e)
su ind_group
mat param_struc = J(r(max),8,.)
local iter_ind = 1
levelsof nic08_4d, local(ind)
foreach j of local ind {
	mat param_struc[`iter_ind',1] = `j'
	mat param_struc[`iter_ind',2] = rho[`iter_ind',1] 
	mat param_struc[`iter_ind',3] = sig[`iter_ind',1]
	mat param_struc[`iter_ind',4] = 1./(1+aeam[`iter_ind',1]+akam[`iter_ind',1]+alam[`iter_ind',1])
	mat param_struc[`iter_ind',5] = param_struc[`iter_ind',4]*alam[`iter_ind',1]
	mat param_struc[`iter_ind',6] = param_struc[`iter_ind',4]*akam[`iter_ind',1]
	mat param_struc[`iter_ind',7] = param_struc[`iter_ind',4]*aeam[`iter_ind',1]
	mat param_struc[`iter_ind',8] = nu[`iter_ind',1]
	local ++iter_ind
}
* Save parameters in data
preserve
	svmat param_struc
	keep param_struc1-param_struc8
	rename param_struc1 nic08_4d
	rename param_struc2 rho
	rename param_struc3 sig
	rename param_struc4 am
	rename param_struc5 al
	rename param_struc6 ak
	rename param_struc7 ae
	rename param_struc8 nu
	drop if nic08_4d == .
	tempfile param_est
	save `param_est'
restore
merge m:1 nic08_4d using `param_est'
drop _merge*
* Recover E_struc from ratio of FOC
gen E_struc = (((Espend/Mspend)*(am/ae))^(sig/(sig-1)))*M

* Get average elasticities
egen E_mmbtu = rsum(TotCoal_mmbtu TotOil_mmbtu TotGas_mmbtu elecb_mmbtu) 
egen Emmbtu_gmean = gmean(E_mmbtu)
gen Eqty = E_mmbtu/Emmbtu_gmean
gen lterm = (al*(L)^((sig-1)/sig))
gen mterm = (am*(M)^((sig-1)/sig))
gen kterm = (ak*(K)^((sig-1)/sig))
gen eterm = (ae*(E_struc)^((sig-1)/sig))
gen eterm_mmbtu = (ae*(Eqty)^((sig-1)/sig))
gen Q = lterm+mterm+kterm+eterm
gen Q_mmbtu = lterm+mterm+kterm+eterm_mmbtu
gen ces_func = (lterm+mterm+kterm+eterm)^((nu*sig)/(sig-1))
gen ces_func_Emmbtu = (lterm+mterm+kterm+eterm_mmbtu)^((nu*sig)/(sig-1))
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
keep if nic08_4d == 2394 | nic08_4d ==  2410 | nic08_4d ==  2431
replace nic08_4d = 1 if nic08_4d == 2431
file close _all
file open PFE_elasticities using Output/Tables/Post_PFE/PFE_avgElast-SelectedInd.tex, write replace
file write PFE_elasticities "& Casting of Steel \& Iron & Cement & Basic Steel \\"_n
file write PFE_elasticities "\hline"_n
file write PFE_elasticities "$\bar\epsilon_{y,l}$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su eps_l if nic08_4d == `j'
	local param: di %3.2f r(mean)
	file write PFE_elasticities "&`param'"
}
file write PFE_elasticities " \\"_n
file write PFE_elasticities "$\bar\epsilon_{y,k}$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su eps_k if nic08_4d == `j'
	local param: di %3.2f r(mean)
	file write PFE_elasticities "&`param'"
}
file write PFE_elasticities " \\"_n
file write PFE_elasticities "$\bar\epsilon_{y,m}$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su eps_m if nic08_4d == `j'
	local param: di %3.2f r(mean)
	file write PFE_elasticities "&`param'"
}
file write PFE_elasticities " \\"_n
file write PFE_elasticities "$\bar\epsilon_{y,e}$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su eps_e if nic08_4d == `j'
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
levelsof nic08_4d, local(ind)
foreach j of local ind {
	mat param_struc_boot_`j' = J(`nrep',8,.)
}
forvalues i=1/`nrep'{
	preserve
	keep if nic08_4d == 2394 | nic08_4d ==  2410 | nic08_4d ==  2431
	keep IDnum year KM LM Lspend Espend Mspend LogY nic08_4d ind_group Egmean Lgmean Mgmean
	bsample, strata(nic08_4d)/* Sample with replacement within each industry*/
	display _newline(2) `i' /* Display iteration number */
	* Perform estimation with bootstrap sample
	levelsof nic08_4d, local(ind)
	su ind_group
	foreach vars in rho akam alam aeam sig nu {
		mat `vars'_boot = J(r(max),1,.)
	}
	local iter_ind = 1
	foreach j of local ind {
		capture nl pfe1 @ LogY Espend Mspend KM LM if nic08_4d == `j', parameters(rho akam alam sig nu) initial(rho 0.5 akam 0.5 alam 0.5 sig 0.5 nu 1.1)
		mat akam_boot[`iter_ind',1] = _b[/akam]
		mat alam_boot[`iter_ind',1] = _b[/alam]
		mat sig_boot[`iter_ind',1] = 1/(-1*(_b[/sig]-1))
		scalar rhoterm = exp(_b[/rho])
		mat rho_boot[`iter_ind',1] = rhoterm/(rhoterm-1)
		mat nu_boot[`iter_ind',1] = _b[/nu]
		local ++iter_ind
	}
	* Recover ae/al from optimality condition
	su ind_group
	mat Espend_gmean = J(r(max),1,.)
	mat Mspend_gmean = J(r(max),1,.)
	local iter_ind = 1
	levelsof nic08_4d, local(ind)
	foreach j of local ind {
		su Egmean if nic08_4d == `j'
		mat Egmean[`iter_ind',1] = r(mean)
		su Mgmean if nic08_4d == `j'
		mat Mgmean[`iter_ind',1] = r(mean)
		local ++iter_ind
	}
	local iter_ind = 1
	levelsof nic08_4d, local(ind)
	foreach j of local ind {
		mat aeam_boot[`iter_ind',1] = Egmean[`iter_ind',1]/Mgmean[`iter_ind',1]
		local ++iter_ind
	}
	* Recover structural parameters (rho,sigma,alpha_l,alpha_k,alpha_m,alpha_e,nu)
	local iter_ind = 1
	levelsof nic08_4d, local(ind)
	foreach j of local ind {
		mat param_struc_boot_`j'[`i',1] = `j'
		mat param_struc_boot_`j'[`i',2] = rho_boot[`iter_ind',1] 
		mat param_struc_boot_`j'[`i',3] = sig_boot[`iter_ind',1]
		mat param_struc_boot_`j'[`i',4] = 1./(1+akam_boot[`iter_ind',1]+alam_boot[`iter_ind',1]+aeam_boot[`iter_ind',1])
		mat param_struc_boot_`j'[`i',5] = param_struc_boot_`j'[`i',4]*alam_boot[`iter_ind',1]
		mat param_struc_boot_`j'[`i',6] = param_struc_boot_`j'[`i',4]*akam_boot[`iter_ind',1]
		mat param_struc_boot_`j'[`i',7] = param_struc_boot_`j'[`i',4]*aeam_boot[`iter_ind',1]
		mat param_struc_boot_`j'[`i',8] = nu_boot[`iter_ind',1]
		local ++iter_ind
	}
	restore
}
* Bootstrap confidence intervals
mata:
nrep 499
param_boot2394 = st_matrix("param_struc_boot_2394")
param_boot2410 = st_matrix("param_struc_boot_2410")
param_boot2431 = st_matrix("param_struc_boot_2431")
param_boot_lb2394 = J(1,7,.)
param_boot_ub2394 = J(1,7,.)
param_boot_lb2410 = J(1,7,.)
param_boot_ub2410 = J(1,7,.)
param_boot_lb2431 = J(1,7,.)
param_boot_ub2431 = J(1,7,.)
for (i=1;i<=7;i++) {
	param_boot_lb2394[.,i] = mm_quantile(param_boot2394[.,i+1],1,0.05)
	param_boot_ub2394[.,i] = mm_quantile(param_boot2394[.,i+1],1,0.95)
	param_boot_lb2410[.,i] = mm_quantile(param_boot2410[.,i+1],1,0.05)
	param_boot_ub2410[.,i] = mm_quantile(param_boot2410[.,i+1],1,0.95)
	param_boot_lb2431[.,i] = mm_quantile(param_boot2431[.,i+1],1,0.05)
	param_boot_ub2431[.,i] = mm_quantile(param_boot2431[.,i+1],1,0.95)
}
st_matrix("param_boot_lb",(param_boot_lb2431 \ param_boot_lb2394 \ param_boot_lb2410))
st_matrix("param_boot_ub",(param_boot_ub2431 \ param_boot_ub2394 \ param_boot_ub2410))
end
* TABLE: PFE results
preserve
keep if nic08_4d == 2394 | nic08_4d ==  2410 | nic08_4d ==  2431
replace nic08_4d = 1 if nic08_4d == 2431
file close _all
file open PFE_results using Output/Tables/Post_PFE/PFE_results-SelectedInd.tex, write replace
file write PFE_results "& Casting of Steel \& Iron & Cement & Basic Steel \\"_n
file write PFE_results "\hline"_n

file write PFE_results "$\hat\rho$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su rho if nic08_4d == `j'
	local rho: di %3.2f r(mean)
	file write PFE_results "&`rho'"
}
file write PFE_results " \\"_n
forvalues i = 1/3 {
	local rho_lb: di %3.2f param_boot_lb[`i',1]
	file write PFE_results "&[`rho_lb',"
	local rho_ub: di %3.2f param_boot_ub[`i',1]
	file write PFE_results "`rho_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\sigma$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su sig if nic08_4d == `j'
	local sig: di %3.2f r(mean)
	file write PFE_results "&`sig'"
}
file write PFE_results "\\"_n
forvalues i = 1/3 {
	local sig_lb: di %3.2f param_boot_lb[`i',2]
	file write PFE_results " &[`sig_lb',"
	local sig_ub: di %3.2f param_boot_ub[`i',2]
	file write PFE_results "`sig_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_l$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su al if nic08_4d == `j'
	local al: di %3.2f r(mean)
	file write PFE_results "&`al'"
}
file write PFE_results "\\"_n
forvalues i = 1/3 {
	local al_lb: di %3.2f param_boot_lb[`i',4]
	file write PFE_results " &[`al_lb',"
	local al_ub: di %3.2f param_boot_ub[`i',4]
	file write PFE_results "`al_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_k$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su ak if nic08_4d == `j'
	local ak: di %3.2f r(mean)
	file write PFE_results "&`ak'"
}
file write PFE_results "\\"_n
forvalues i = 1/3 {
	local ak_lb: di %3.2f param_boot_lb[`i',5]
	file write PFE_results "&[`ak_lb',"
	local ak_ub: di %3.2f param_boot_ub[`i',5]
	file write PFE_results "`ak_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_m$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su am if nic08_4d == `j'
	local am: di %3.2f r(mean)
	file write PFE_results "&`am'"
}
file write PFE_results "\\"_n
forvalues i = 1/3 {
	local am_lb: di %3.2f param_boot_lb[`i',3]
	file write PFE_results "&[`am_lb',"
	local am_ub: di %3.2f param_boot_ub[`i',3]
	file write PFE_results "`am_ub']"
}
file write PFE_results "\\"_n

file write PFE_results "$\hat\alpha_e$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su ae if nic08_4d == `j'
	local ae: di %3.2f r(mean)
	file write PFE_results "&`ae'"
}
file write PFE_results "\\"_n
forvalues i = 1/3 {
	local ae_lb: di %3.2f param_boot_lb[`i',6]
	file write PFE_results " &[`ae_lb',"
	local ae_ub: di %3.2f param_boot_ub[`i',6]
	file write PFE_results "`ae_ub']"
}
file write PFE_results "\\"_n


file write PFE_results "$\hat\nu$"
levelsof nic08_4d, local(ind)
foreach j of local ind {
	su nu if nic08_4d == `j'
	local nu: di %3.2f r(mean)
	file write PFE_results "&`nu'"
}
file write PFE_results "\\"_n
forvalues i = 1/3 {
	local nu_lb: di %3.2f param_boot_lb[`i',7]
	file write PFE_results " &[`nu_lb',"
	local nu_ub: di %3.2f param_boot_ub[`i',7]
	file write PFE_results "`nu_ub']"
}

file write PFE_results "\\"_n
file write PFE_results "\hline"_n
file write PFE_results "\(N\)"
foreach ind in 1 2394 2410 {
	su IDnum if nic08_4d == `ind'
	local obs: di %3.0f r(N)
	file write PFE_results "&`obs'"
}
file write PFE_results "\\"_n
file close _all
restore

********************************************************************
*** 2. Get E, measures of productivity
********************************************************************
/*
egen log_uhat = rsum(log_uhat10 log_uhat11 log_uhat12 log_uhat13 log_uhat14 log_uhat15 log_uhat16 log_uhat17 ///
log_uhat18 log_uhat19 log_uhat20 log_uhat21 log_uhat22 log_uhat23 log_uhat24 log_uhat25 log_uhat26 log_uhat27 ///
log_uhat28 log_uhat29 log_uhat30 log_uhat31 log_uhat32 log_uhat33)
*/
egen log_uhat = rowtotal(log_uhat*)
gen uhat = exp(log_uhat)

* TFPR excluding fuel productivity (Hicks-neutral)
gen TFPR_hicksn = Yspend/ces_func
gen logTFPR_hicksn = log(TFPR_hicksn)
* TFPR including fuel productivity
gen TFPR = Yspend/ces_func_Emmbtu
gen logTFPR = log(TFPR)
reg logTFPR i.nic08_4d
predict logTFPR_norm, residuals

* TFP excluding fuel productivity (hicks-neutral)
reg LogY i.year#i.nic08_4d i.nic08_4d
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
reg log_gam_fuel i.nic08_4d // remove industry specific scale
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
reg log_gam_fuel i.nic08_4d
predict Ebar, xb
gen lnEbar = log(Ebar) 
foreach fuel in gas oil coal elecb {
	gen lngam_`fuel'_noindscale = lngam_`fuel'-lnEbar
}
* Drop outliers for fuel productivity graphs and tables (find better method later)
preserve
foreach vars in sig ak am ae al rho nu {
	drop if `vars' < 0
}
*keep if nic08_2d == 13 | nic08_2d ==  17 | nic08_2d ==  20 | nic08_2d ==  23 | nic08_2d ==  24
graph drop _all
graph twoway (hist lngam_coal_noindscale, frac lcolor(gs12) fcolor(gs12) width(`BinWidth') start(`MinVal')) ///
	(hist lngam_gas_noindscale, frac lcolor(red) fcolor(none) width(`BinWidth') start(`MinVal')), ///
	legend(label(1 "Coal") label(2 "Natural Gas")) 
graph export Output/Graphs/Post_PFE/FuelGamma_GasCoaldist-SelectedInd.pdf, replace

foreach fuel in gas oil coal {
	*drop if lngam_`fuel'_noindscale > 15 | lngam_`fuel'_noindscale < -10
	su lngam_`fuel'_noindscale
	local rmean: di %10.2f r(mean)
	hist lngam_`fuel'_noindscale if s_`fuel' == 1, xtitle(`fuel') xtitle("") name(gam_`fuel', replace) xlabel(-10[5]15, labsize(6)) /// 
	addplot(pci 0 5 .5 5, lpattern(-)) legend(off) ylabel(, angle(horizontal) format(%9.1f)) ytitle("")
	graph export Output/Graphs/Post_PFE/FuelGamma`fuel'_SinglefDist-SelectedInd.pdf, replace
}
*gr combine gam_gas gam_oil gam_coal gam_elecb
*graph export Output/Graphs/Post_PFE/FuelGamma_dist-SelectedInd.pdf, replace
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
drop if sig < 0 
drop if ak < 0
drop if rho < 0
*keep if nic08_2d == 13 | nic08_2d ==  17 | nic08_2d ==  20 | nic08_2d ==  23 | nic08_2d ==  24
eststo clear
quietly probit fuelswitch_to L.logTFP ae
margins, dydx(*) post
eststo mdl1, title("All fuels"): margins
quietly probit fuelswitch_togas L.logTFP 
margins, dydx(*) post
eststo mdl2, title("Natural Gas"): margins
quietly probit fuelswitch_tocoal L.logTFP 
margins, dydx(*) post
eststo mdl3, title("Coal"): margins
quietly probit fuelswitch_tooil L.logTFP 
margins, dydx(*) post
eststo mdl4, title("Oil"): margins
quietly probit fuelswitch_toelecb L.logTFP 
margins, dydx(*) post
eststo mdl5, title("Electricity"): margins
esttab using "Output/Tables/Post_PFE/SwitchingProbit_me-SelectedInd.tex", se noconstant title("Marginal effects, probability of adding fuel (current year)") ///
star(+ 0.1 * 0.05 ** 0.01 *** 0.001) mtitles replace
restore


* Balance the panel
egen nyear = total(inrange(year, 2009, 2016)), by(IDnum)
drop if nyear < 6
drop nyear