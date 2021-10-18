* Change some industry codes to match with NAICS
rename IndCodeReturn ind5d
replace ind5d = 1040 if ind5d >= 10401 & ind5d <= 10409
replace ind5d = 1072 if ind5d >= 10721 & ind5d <= 10729
replace ind5d = 1073 if ind5d >= 10733 & ind5d <= 10736
replace ind5d = 1010 if ind5d >= 10101 & ind5d <= 10103
replace ind5d = 1071 if ind5d == 10711 | ind5d == 10719
replace ind5d = 10791 if ind5d == 10791 | ind5d == 10792
replace ind5d = 10793 if ind5d >= 10793 & ind5d <= 10799
replace ind5d = 1101 if ind5d == 11011 | ind5d == 11012 | ind5d == 11019
replace ind5d = 1393 if (ind5d >= 13931 & ind5d <= 13935) | ind5d == 13939
replace ind5d = 1430 if ind5d == 14301 | ind5d == 14309
replace ind5d = 1629 if (ind5d >= 16291 & ind5d <= 16297) | ind5d == 16299
replace ind5d = 17013 if ind5d >= 17013 & ind5d <= 17015
replace ind5d = 1701 if ind5d == 17016 | ind5d == 17017 | ind5d == 17019 
replace ind5d = 1702 if ind5d == 17021 | ind5d == 17022
replace ind5d = 1920 if ind5d >= 19201 & ind5d <= 19204 
replace ind5d = 1910 if ind5d >= 19101 & ind5d <= 19109 
replace ind5d = 2030 if ind5d >= 20301 & ind5d <= 20304
replace ind5d = 2012 if (ind5d >= 20121 & ind5d <= 20123) | ind5d == 20129
replace ind5d = 2100 if ind5d >= 21001 & ind5d <= 21006 
replace ind5d = 2022 if ind5d == 20221 | ind5d == 20222 | ind5d == 20224 | ind5d == 20229
replace ind5d = 2023 if ind5d >= 20231 & ind5d <= 20234
replace ind5d = 2219 if ind5d == 22191 | ind5d == 22192
replace ind5d = 2392 if (ind5d >= 23921 & ind5d <= 23923) | ind5d == 23929
replace ind5d = 2310 if (ind5d >= 23103 & ind5d <= 23107) | ind5d == 23101 | ind5d == 23109
replace ind5d = 2394 if ind5d >= 23941 & ind5d <= 23943
replace ind5d = 23952 if ind5d == 23952 | ind5d == 23954
replace ind5d = 23951 if ind5d == 23951 | ind5d == 23953 | ind5d == 23955 | ind5d == 23956 | ind5d == 23959
replace ind5d = 23945 if ind5d == 23945 | ind5d == 23992 
replace ind5d = 2410 if ind5d >= 24101 & ind5d <= 24109
replace ind5d = 2750 if ind5d == 27501 | ind5d == 27502 | ind5d == 27504 | ind5d == 27509
replace ind5d = 3030 if ind5d >= 30301 & ind5d <= 30305

/*
* Remove outliers
su p_natgas_mmbtu, detail
replace p_natgas_mmbtu = . if p_natgas_mmbtu > r(p99)
su natgas_mmbtu, detail
replace natgas_mmbtu = . if natgas_mmbtu > r(p99)
su Natgas, detail
replace Natgas = . if Natgas > r(p99)
su Coal, detail
replace Coal = . if Coal > r(p99)
su Oil, detail
replace Oil = . if Oil > r(p99)
*/
/*
* Generate price index and quantities for Coal, Natural gas and oil by year (for firms where we only observe spending)
gen oil_mmbtu = Oil/p_oil_mmbtu
bysort yr: egen p_coal_mmbtu_index = median(p_coal_mmbtu)
bysort yr: egen p_natgas_mmbtu_index = median(p_natgas_mmbtu)
replace coal_mmbtu = Coal/p_coal_mmbtu_index if coal_mmbtu == . // For firms where I only observe spending, use price index
replace natgas_mmbtu = Natgas/p_natgas_mmbtu_index if natgas_mmbtu == . // For firms where I only observe spending, use price index
gen anyfuel_mmbtu = 1 if (oil_mmbtu != .) | (natgas_mmbtu != .) | (coal_mmbtu != .)
replace oil_mmbtu = 0 if (oil_mmbtu == .) & (anyfuel_mmbtu == 1)
replace natgas_mmbtu = 0 if (natgas_mmbtu == .) & (anyfuel_mmbtu == 1)
replace coal_mmbtu = 0 if (coal_mmbtu == .) & (anyfuel_mmbtu == 1)
*/

* Define fuel quantity shares
gen totfuel_mmbtu = TotOil_mmbtu+TotGas_mmbtu+TotCoal_mmbtu+elecb_mmbtu
gen oil_s = TotOil_mmbtu/totfuel_mmbtu
gen natgas_s = TotGas_mmbtu/totfuel_mmbtu
gen coal_s = TotCoal_mmbtu/totfuel_mmbtu
gen elec_s = elecb_mmbtu/totfuel_mmbtu

 * Merge with NPRI dataset
gen dataset_id = 0
append using "Data/NPRI_Clean.dta"

* Emission intensity per unit of energy
* Coal
su gamma_coal
replace gamma_coal = r(mean)
lab var gamma_coal "Emission Factor - Coal"
* Oil
su gamma_oil 
replace gamma_oil = r(mean)
lab var gamma_oil "Emission Factor - Oil"
* Natural Gas
su gamma_natgas
replace gamma_natgas = r(mean) 
lab var gamma_natgas "Emission Factor - Natural Gas"
* Electricity
su gamma_elec
replace gamma_elec = r(mean)
lab var gamma_elec "Emission Factor - Electricity"
replace elecb_mmbtu = 0 if elecb_mmbtu == .
replace elec_s = 0 if elec_s == .

gen pol_intensity = (gamma_coal*coal_s)+(gamma_oil*oil_s)+(gamma_natgas*natgas_s)+(gamma_elec*elec_s)

*** Histogram of pollution intensity for steel & Iron, Cement, Glass, Aluminium and pulp & paper manufacturing (Canadian plants and indian plants)***
preserve
	keep if ind5d == 2394 | ind5d == 2410 | ind5d == 1701 | ind5d == 24202 | ind5d == 2310 
	keep if yr >= 2009
	* Cement manufacturing
	twoway (hist pol_intensity if ind5d == 2394 & dataset_id == 0, frac lcolor(gs12) fcolor(gs12)) ///
		(hist pol_intensity if ind5d == 2394 & dataset_id == 1, frac lcolor(red) fcolor(none)), ///
		legend(label(1 "Indian plants (ASI)") label(2 "Canadian plants (NPRI)")) ///
		xtitle("CO2e per mmbtu") graphregion(color(white)) xlabel(53[7]99) ylabel(, angle(horizontal) format(%9.1f))
		graph export Output/Graphs/Canada_India/pol_intensity_cement.pdf, replace
	* Steel and Iron manufacturing
	twoway (hist pol_intensity if ind5d == 2410 & dataset_id == 0, frac lcolor(gs12) fcolor(gs12)) ///
		(hist pol_intensity if ind5d == 2410 & dataset_id == 1, frac lcolor(red) fcolor(none)), ///
		legend(label(1 "Indian plants (ASI)") label(2 "Canadian plants (NPRI)")) ///
		xtitle("CO2e per mmbtu") graphregion(color(white)) xlabel(53[7]99)  ylabel(, angle(horizontal) format(%9.1f))
		graph export Output/Graphs/Canada_India/pol_intensity_steel.pdf, replace
	* Pulp and Paper manufacturing
	twoway (hist pol_intensity if ind5d == 1701 & dataset_id == 0, frac lcolor(gs12) fcolor(gs12)) ///
		(hist pol_intensity if ind5d == 1701 & dataset_id == 1, frac lcolor(red) fcolor(none)), ///
		legend(label(1 "Indian plants (ASI)") label(2 "Canadian plants (NPRI)")) ///
		xtitle("CO2e per mmbtu") graphregion(color(white)) xlabel(53[7]99)  ylabel(, angle(horizontal) format(%9.1f))
		graph export Output/Graphs/Canada_India/pol_intensity_paper.pdf, replace
	* Aluminium
	twoway (hist pol_intensity if ind5d == 24202 & dataset_id == 0, frac lcolor(gs12) fcolor(gs12)) ///
		(hist pol_intensity if ind5d == 24202 & dataset_id == 1, frac lcolor(red) fcolor(none)), ///
		legend(label(1 "Indian plants (ASI)") label(2 "Canadian plants (NPRI)")) ///
		xtitle("CO2e per mmbtu") graphregion(color(white)) xlabel(53[7]99)  ylabel(, angle(horizontal) format(%9.1f))
		graph export Output/Graphs/Canada_India/pol_intensity_aluminium.pdf, replace
	* Glass
	twoway (hist pol_intensity if ind5d == 2310 & dataset_id == 0, frac lcolor(gs12) fcolor(gs12)) ///
		(hist pol_intensity if ind5d == 2310 & dataset_id == 1, frac lcolor(red) fcolor(none)), ///
		legend(label(1 "Indian plants (ASI)") label(2 "Canadian plants (NPRI)")) ///
		xtitle("CO2e per mmbtu") graphregion(color(white)) xlabel(53[7]99)  ylabel(, angle(horizontal) format(%9.1f))
		graph export Output/Graphs/Canada_India/pol_intensity_glass.pdf, replace
restore

*** TABLE: number of fuels used within narrowly defined industries ***
* Cement
preserve
	keep if ind5d == 2394
	keep if yr >= 2009
	keep if dataset_id == 0
	egen nfuels_notused = anycount(TotCoal TotOil TotGas elecb_mmbtu), values(0)
	gen nfuels = 4-nfuels_notused
	lab var nfuels "Number of Fuels used (Including Electricity)"
	tabout nfuels using "Output/Tables/Mixing/nfuels_cement.tex", replace  c(freq col) style(tex)
restore
*** TABLE: different fuel mixes within narrowly defined industries ***
egen fueltot_new = rsum(TotCoal_mmbtu TotOil_mmbtu TotGas_mmbtu elecb_mmbtu)
gen s_coal = TotCoal_mmbtu/fueltot_new
gen s_oil = TotOil_mmbtu/fueltot_new
gen s_gas = TotGas_mmbtu/fueltot_new
gen s_elec = elecb_mmbtu/fueltot_new
* Cement
preserve
	keep if ind5d == 2394
	keep if yr >= 2009
	keep if dataset_id == 0
	gen c = 1 if TotCoal > 0 & TotOil == 0 & TotGas == 0 & elecb_mmbtu == 0
	gen g = 1 if TotGas > 0 & TotOil == 0 * TotCoal == 0 & elecb_mmbtu == 0
	gen o = 1 if TotOil > 0 & TotGas == 0 * TotCoal == 0 & elecb_mmbtu == 0
	gen e = 1 if elecb_mmbtu > 0 & TotGas == 0 * TotCoal == 0 & TotOil == 0
	gen cg = 1 if TotCoal > 0 & TotGas > 0 & TotOil == 0 & elecb_mmbtu == 0
	gen co = 1 if TotCoal > 0 & TotOil > 0 & TotGas == 0 & elecb_mmbtu == 0
	gen ce = 1 if TotCoal > 0 & elecb_mmbtu > 0 & TotGas == 0 & TotOil == 0
	gen go = 1 if TotGas > 0 & TotOil > 0 & TotCoal == 0 & elecb_mmbtu == 0
	gen ge = 1 if TotGas > 0 & elecb_mmbtu > 0 & TotCoal == 0 & TotOil == 0
	gen oe = 1 if TotOil > 0 & elecb_mmbtu > 0 & TotGas == 0 & TotCoal == 0
	gen coe = 1 if TotOil > 0 & TotCoal > 0 & elecb_mmbtu > 0 & TotGas == 0
	gen cog = 1 if TotOil > 0 & TotCoal > 0 & elecb_mmbtu == 0 & TotGas > 0
	gen cge = 1 if TotOil == 0 & TotCoal > 0 & elecb_mmbtu > 0 & TotGas > 0
	gen oge = 1 if TotOil > 0 & TotCoal == 0 & elecb_mmbtu > 0 & TotGas > 0
	gen coge = 1 if TotOil > 0 & TotCoal > 0 & elecb_mmbtu > 0 & TotGas > 0
	collapse (sum) c g o e cg co ce go ge oe coe cog cge oge coge
	egen ntot = rsum(c g o e cg co ce go ge oe coe cog cge oge coge)
	foreach vars in c g o e cg co ce go ge oe coe cog cge oge coge {
		replace `vars' = `vars'/ntot*100
	}
	gen other = g + c + o + cg + co + go + ge + cog + ce + oge + coge
	file close _all
	file open fuelmix using "Output/Tables/Mixing/fuelmix-cement.tex", write replace
	file write fuelmix "& Percentage \\"_n
	local perc: di %3.2f oe
	file write fuelmix "Oil, Electricity & `perc' \% \\"_n
	local perc: di %3.2f coe
	file write fuelmix "Coal, Oil, Electricity & `perc' \% \\"_n
	local perc: di %3.2f other
	file write fuelmix "Other & `perc' \% \\"_n
	file close _all
restore
* Casting Steel and Iron
preserve
	keep if ind5d == 24319
	keep if yr >= 2009
	keep if dataset_id == 0
	gen c = 1 if TotCoal > 0 & TotOil == 0 & TotGas == 0 & elecb_mmbtu == 0
	gen g = 1 if TotGas > 0 & TotOil == 0 * TotCoal == 0 & elecb_mmbtu == 0
	gen o = 1 if TotOil > 0 & TotGas == 0 * TotCoal == 0 & elecb_mmbtu == 0
	gen e = 1 if elecb_mmbtu > 0 & TotGas == 0 * TotCoal == 0 & TotOil == 0
	gen cg = 1 if TotCoal > 0 & TotGas > 0 & TotOil == 0 & elecb_mmbtu == 0
	gen co = 1 if TotCoal > 0 & TotOil > 0 & TotGas == 0 & elecb_mmbtu == 0
	gen ce = 1 if TotCoal > 0 & elecb_mmbtu > 0 & TotGas == 0 & TotOil == 0
	gen go = 1 if TotGas > 0 & TotOil > 0 & TotCoal == 0 & elecb_mmbtu == 0
	gen ge = 1 if TotGas > 0 & elecb_mmbtu > 0 & TotCoal == 0 & TotOil == 0
	gen oe = 1 if TotOil > 0 & elecb_mmbtu > 0 & TotGas == 0 & TotCoal == 0
	gen coe = 1 if TotOil > 0 & TotCoal > 0 & elecb_mmbtu > 0 & TotGas == 0
	gen cog = 1 if TotOil > 0 & TotCoal > 0 & elecb_mmbtu == 0 & TotGas > 0
	gen cge = 1 if TotOil == 0 & TotCoal > 0 & elecb_mmbtu > 0 & TotGas > 0
	gen oge = 1 if TotOil > 0 & TotCoal == 0 & elecb_mmbtu > 0 & TotGas > 0
	gen coge = 1 if TotOil > 0 & TotCoal > 0 & elecb_mmbtu > 0 & TotGas > 0
	collapse (sum) c g o e cg co ce go ge oe coe cog cge oge coge
	egen ntot = rsum(c g o e cg co ce go ge oe coe cog cge oge coge)
	foreach vars in c g o e cg co ce go ge oe coe cog cge oge coge {
		replace `vars' = `vars'/ntot*100
	}
	gen other = g + c + o + cg + co + go + ge + cog + ce + coge
	file close _all
	file open fuelmix using "Output/Tables/Mixing/fuelmix-steel.tex", write replace
	file write fuelmix "& Percentage \\"_n
	local perc: di %3.2f oe
	file write fuelmix "Oil, Electricity & `perc' \% \\"_n
	local perc: di %3.2f coe
	file write fuelmix "Coal, Oil, Electricity & `perc' \% \\"_n
	local perc: di %3.2f oge
	file write fuelmix "Oil, Gas, Electricity & `perc' \% \\"_n
	local perc: di %3.2f other
	file write fuelmix "Other & `perc' \% \\"_n
	file close _all
restore


twoway (hist pol_intensity if coe == 1, frac lcolor(gs12) fcolor(gs12)) ///
	(hist pol_intensity if oe == 1, frac lcolor(blue) fcolor(none)) 
	(hist pol_intensity if oge == 1, frac lcolor(red) fcolor(none))


* Compare Canada and India
preserve
	collapse (mean) pol_intensity, by(ind5d yr dataset_id)
	keep if yr >= 2009 & yr <= 2015
	egen same_ind = anymatch(ind5d), values(1010 1040 1071 1072 1073 1101 1393 1430 ///
	1629 1701 1702 1910 1920 2012 2022 2023 2030 2100 2219 2310 2392 2394 2410 2750 ///
	3030 10104 10107 10307 10504 10505 10611 10612 10616 10626 10712 10750 10793 10803 ///
	11031 16101 16109 16211 16212 16213 16219 16221 17011 17012 17013 17024 18119 19209 ///
	20111 20132 20292 20295 22199 22203 22207 23911 23944 23945 23951 23952 23993 24202 ///
	24311 24319 24320 25910 25920 27400 28110 29101 29104 31001 82920)
	keep if same_ind
	reshape wide pol_intensity, i(ind5d yr) j(dataset_id)
	drop if pol_intensity1 == .
	drop if pol_intensity0 == .
	*gen pol_intensity_diff = pol_intensity0-pol_intensity1
	collapse (mean) pol_intensity1 pol_intensity0, by(yr)
	twoway (connected pol_intensity0 yr) (connected pol_intensity1 yr), ///
		graphregion(color(white)) ytitle("Emission intensity of 1 mmbtu") xlabel(2009[1]2015) ///
		legend(label(1 "Indian plants (ASI)") label(2 "Canadian plants (NPRI)"))
		graph export Output/Graphs/Canada_India/pol_intensity_average.pdf, replace
restore








