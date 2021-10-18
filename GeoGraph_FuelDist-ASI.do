gen id = .
replace id = 2 if state == 28
replace id = 4 if state == 18
replace id = 5 if state == 10
replace id = 6 if state == 4
replace id = 7 if state == 22
replace id = 8 if state == 26
replace id = 9 if state == 25
replace id = 10 if state == 7
replace id = 11 if state == 30
replace id = 12 if state == 24
replace id = 13 if state == 6
replace id = 14 if state == 2
replace id = 15 if state == 1
replace id = 16 if state == 20
replace id = 17 if state == 29
replace id = 18 if state == 32
replace id = 20 if state == 23
replace id = 21 if state == 27
replace id = 22 if state == 14
replace id = 23 if state == 17
replace id = 26 if state == 21
replace id = 27 if state == 34
replace id = 28 if state == 3
replace id = 29 if state == 8
replace id = 31 if state == 33
replace id = 32 if state == 16
replace id = 33 if state == 9
replace id = 34 if state == 5
replace id = 35 if state == 19

drop _merge
drop ISO
cd "Data/Spatial Data"
merge m:1 id using inddb

su natgas_mmbtu, detail
drop if natgas_mmbtu > r(p95)

* Spatial distribution of fossil fuels across states
preserve
	collapse (mean) p_natgas_mmbtu p_coal_mmbtu (sum) natgas_mmbtu oil_mmbtu coal_mmbtu, by(id)
	replace Natgas = Natgas/1000000
	replace natgas_mmbtu = natgas_mmbtu/1000
	format natgas_mmbtu %10.1fc
	spmap natgas_mmbtu using indcoord, id(id) legtitle(Natural Gas (billion Btu)) legstyle(2)  ocolor(black ..) osize(vvthin ..) fcolor(Heat) ///
	legend(pos(4) size(*0.8)) clmethod(custom) clbreaks(1 500(500)6000) //clnumber(10)
	graph export "..\..\Output\Graphs\Natgas_Dist_byState.pdf", replace 
restore