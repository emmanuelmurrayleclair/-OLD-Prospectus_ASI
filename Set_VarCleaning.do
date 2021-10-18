*--------------------------------------
* Get Electricity sold by power plants
*--------------------------------------

* Extract Electricity sold from Output data
gen elecsold_qty_kwh = 0
gen elecsold_qty_mgwh = 0
gen elecgen_qty_kwh = 0
gen elecgen_qty_mgwh = 0
gen elecsold = 0
replace elecsold = j7_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 28) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 28)
gen elecsold_unit_kwh = j4_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 28) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 28)
gen elecsold_unit_mgwh = j4_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 13) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 13)
replace elecsold_qty_kwh = j6_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 28) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 28)
replace elecsold_qty_mgwh = j6_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 13) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 13)
replace elecgen_qty_kwh = j5_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 28) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 28)
replace elecgen_qty_mgwh = j5_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 13) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 13)
gen elecsold_p_kwh = j7_1/j6_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 28) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 28)
gen elecsold_p_mgwh = j7_1/j6_1 if (j3_1  >= 25101 & j3_1 <= 25119 & j4_1 == 13) | (j3_1 >= 1710001 & j3_1 <= 1710099 & j4_1 == 13)

forvalues i = 2/10 {
	replace elecsold_unit_kwh = j4_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 28) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 28)
	replace elecsold_unit_mgwh = j4_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 13) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 13)
	replace elecsold_qty_kwh = elecsold_qty_kwh + j6_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 28) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 28)
	replace elecsold_qty_mgwh = elecsold_qty_mgwh + j6_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 13) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 13)
	replace elecgen_qty_kwh = elecgen_qty_kwh + j5_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 28) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 28)
	replace elecgen_qty_mgwh = elecgen_qty_mgwh + j5_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 13) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 13)
	if elecsold_p_kwh > 0 & elecsold_p_kwh != . {
		replace elecsold_p_kwh = (elecsold_p_kwh + j7_`i'/j6_`i')/2 if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 28) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 28)
	}
	else if elecsold_p_kwh == . {
		replace elecsold_p_kwh = j7_`i'/j6_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 28) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 28)
	}
	if elecsold_p_mgwh > 0 & elecsold_p_mgwh != . {
		replace elecsold_p_mgwh = (elecsold_p_mgwh + j7_`i'/j6_`i')/2 if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 13) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 13)
	}
	else if elecsold_p_mgwh == . {
		replace elecsold_p_mgwh = j7_`i'/j6_`i' if (j3_`i'  >= 25101 & j3_`i' <= 25119 & j4_`i' == 13) | (j3_`i' >= 1710001 & j3_`i' <= 1710099 & j4_`i' == 13)
	}
}

replace elecsold_p_kwh = . if elecsold_p_kwh == 0
replace elecsold_p_mgwh = . if elecsold_p_mgwh == 0
* Convert units to mmBtu
gen elecsold_qty_mmbtu = 0.0034095106405145*elecsold_qty_kwh + 3.4095106405145*elecsold_qty_mgwh
gen elecgen_qty_mmbtu = 0.0034095106405145*elecgen_qty_kwh + 3.4095106405145*elecgen_qty_mgwh
gen p_elecsold_mmbtu = ((elecsold_p_kwh/0.0034095106405145)+(elecsold_p_mgwh/3.4095106405145))/2 if elecsold_p_kwh > 0 & elecsold_p_mgwh > 0
replace p_elecsold_mmbtu = elecsold_p_kwh/0.0034095106405145 if elecsold_p_kwh > 0 & elecsold_p_mgwh == .
replace p_elecsold_mmbtu = elecsold_p_mgwh/3.4095106405145 if elecsold_p_mgwh > 0 & elecsold_p_kwh == .


*-----------------------------------------
* Rename and keep relevant variables only
*-----------------------------------------

rename a9 urb
rename a7 state
replace state = 28 if state == 36 // Make Telangana as part of Andhra Pradesh because it was only created in 2014 
rename a5 ind5d
rename a8 district
gen ind4d = int(ind5d/10) if ind5d > 9999
rename a11 no_plant
rename a12 status
rename a16 tot_cost // Labor only? 

rename b3 ownership
label define OwnerCodevals 1 "Central Gov" 2 "State or Local Gov" 3 "Central and Local Gov" 4 "Joint Public" 5 "Joint Private" 6 "Private"
replace ownership=. if ownership==0 | ownership==7 | ownership==8
label values ownership OwnerCodevals
rename b2 orgtype
rename b4 no_plant_tot
rename b5 no_plant_samestate
rename b6 first_yr
gen age = yr-first_yr
rename b8 oper_months
rename b9 AC
rename b12 ISO
rename b14 foreign_share
rename b15 RD_dummy
rename b10 ASI_data

rename c3_1 Land_Gross_Open
rename c7_1 Land_Gross_Close
rename c12_1 Land_Net_Open
rename c13_1 Land_Net_Close
rename c3_2 Bldg_Gross_Open
rename c7_2 Bldg_Gross_Close
rename c12_2 Bldg_Net_Open
rename c13_2 Bldg_Net_Close
rename c3_10 TotFixedAsset_Gross_Open
rename c7_10 TotFixedAsset_Gross_Close
rename c12_10 TotFixedAsset_Net_Open
rename c13_10 TotFixedAsset_Net_Close
rename c9_10 TotFixedAsset_deprecciation
rename c3_7 PollutionControl_Gross_Open
rename c7_7 PollutionControl_Gross_Close
rename c12_7 PollutionControl_Net_Open
rename c13_7 PollutionControl_Net_Close
rename c9_7 PollutionControl_deprecciation

rename d3_11 TotCurAsset_Open
rename d4_11 TotCurAsset_Close
rename d3_2 TotFuels_Open
rename d4_2 TotFuels_Close
rename d3_7 TotInventory_Open
rename d4_7 TotInventory_Close
rename d3_12 LongTermDebt_Open
rename d4_12 LongTermDebt_Close
rename d3_13 ShortTermDebt_Open
rename d4_13 ShortTermDebt_Close
rename d3_15 TotalLiabilities_Open
rename d4_15 TotalLiabilities_Close
rename d3_17 OutstandingLoans_Open
rename d4_17 OutstandingLoans_Close
rename d3_8 cash_Open
rename d4_8 cash_Close

rename e6_10 nEmployees_tot
rename e6_6 nEmployees_NonManagers
rename e6_7 nEmployees_Managers
rename e8_10 Wages_tot
rename e8_6 Wages_NonManagers
rename e8_7 Wages_Managers
gen avgWages_tot = Wages_tot/nEmployees_tot
gen avgWages_NonManagers = Wages_NonManagers/nEmployees_NonManagers
gen avgWages_Managers = Wages_Managers/nEmployees_Managers

rename f3 OperExpenses
rename f5 Insurance
rename f12 RD_spending
rename f10 interest
rename f7 TotExpenses
rename f6 rent

rename h5_23 TotInput_qty
rename h6_23 TotInput
rename h7_23 Totinput_price
rename h4_17 Oil_unit
rename h5_17 Oil_qty
rename h6_17 Oil
rename h7_17 Oil_price
rename h4_18 Coal_unit
rename h5_18 Coal_qty
rename h6_18 Coal
rename h7_18 Coal_price
rename h4_19 Natgas_unit
rename h5_19 Natgas_qty
rename h6_19 Natgas
rename h7_19 Natgas_price
rename h4_20 OtherFuel_unit
rename h5_20 OtherFuel_qty
rename h6_20 OtherFuel
rename h7_20 OtherFuel_price
rename h4_15 ElecOwn_unit
rename h5_15 ElecOwn_qty
rename h6_15 ElecOwn
rename h7_15 ElecOwn_price
rename h4_16 ElecBought_unit
rename h5_16 ElecBought_qty
rename h6_16 ElecBought
rename h7_16 ElecBought_price

rename i7_4 Import_unit
rename i7_5 Import_qty
rename i7_6 Import
rename i7_7 Import_price

rename j4_1 QtyUnit_o1
rename j5_1 QtyManuf_o1
rename j6_1 QtySold_o1
rename j7_1 SalesGross_o1
rename j12_1 Price_o1
rename j4_2 QtyUnit_o2
rename j5_2 QtyManuf_o2
rename j6_2 QtySold_o2
rename j7_2 SalesGross_o2
rename j12_2 Price_o2
rename j4_3 QtyUnit_o3
rename j5_3 QtyManuf_o3
rename j6_3 QtySold_o3
rename j7_3 SalesGross_o3
rename j12_3 Price_o3
rename j4_4 QtyUnit_o4
rename j5_4 QtyManuf_o4
rename j6_4 QtySold_o4
rename j7_4 SalesGross_o4
rename j12_4 Price_o4
rename j4_5 QtyUnit_o5
rename j5_5 QtyManuf_o5
rename j6_5 QtySold_o5
rename j7_5 SalesGross_o5
rename j12_5 Price_o5
rename j7_12 SalesGross_tot
rename j8_12 SalesTax
rename j9_12 Duty
rename j11_12 Subsidy
rename j12_12 PriceOutput
rename j13_12 ValueManuf_tot

order *, sequential
drop a3-a20
drop b7f-c13_11
drop d3_1-d4_18
drop e3_1-e11_10
drop f1-f11
drop g1-i7_99
drop j3_1-j14_99

*----------------------
* Industry concordance
*----------------------
* NIC-04 to NIC-08
if yr < 2009 {
	replace ind4d = 1010 if ind4d == 1511
	replace ind4d = 1020 if ind4d == 1512
	replace ind4d = 1030 if ind4d == 1513
	replace ind4d = 1040 if ind4d == 1514
	replace ind4d = 1050 if ind4d == 1520
	replace ind4d = 1061 if ind4d == 1531
	replace ind4d = 1062 if ind4d == 1532
	replace ind4d = 1071 if ind4d == 1541
	replace ind4d = 1072 if ind4d == 1542
	replace ind4d = 1073 if ind4d == 1543
	replace ind4d = 1074 if ind4d == 1544
	replace ind4d = 1075 if (ind4d == 1512) | (ind4d == 1513) | (ind4d == 1544) | (ind4d == 1549) 
	replace ind4d = 1079 if (ind4d == 1549) | (ind4d == 2429)
	replace ind4d = 1080 if ind4d == 1533
	replace ind4d = 1101 if ind4d == 1551
	replace ind4d = 1102 if (ind4d == 0113) | (ind4d == 1552)
	replace ind4d = 1103 if ind4d == 1553
	replace ind4d = 1105 if ind4d == 1554
	replace ind4d = 1200 if ind4d == 1600
	replace ind4d = 1311 if (ind4d == 1711) | (ind4d == 1713)
	replace ind4d = 1313 if (ind4d == 1712) | (ind4d == 1714)
	replace ind4d = 1391 if ind4d == 1730
	replace ind4d = 1392 if (ind4d == 1721) | (ind4d == 1722) | (ind4d == 1725)
	replace ind4d = 1394 if ind4d == 1723
	replace ind4d = 1399 if (ind4d == 1724) | (ind4d == 1729)
	replace ind4d = 1410 if ind4d == 1810
	replace ind4d = 1420 if ind4d == 1820
	replace ind4d = 1430 if ind4d == 1730
	replace ind4d = 1511 if (ind4d == 1820) | (ind4d == 1911)
	replace ind4d = 1512 if (ind4d == 1912) | (ind4d == 3966)
	replace ind4d = 1520 if ind4d == 1920
	replace ind4d = 1610 if ind4d == 2010
	replace ind4d = 1621 if ind4d == 2021
	replace ind4d = 1622 if ind4d == 2022
	replace ind4d = 1623 if ind4d == 2023
	replace ind4d = 1629 if (ind4d == 2029) | (ind4d == 3699)
	replace ind4d = 1701 if ind4d == 2101
	replace ind4d = 1702 if ind4d == 2102
	replace ind4d = 1709 if (ind4d == 2109) | (ind4d == 3699)
	replace ind4d = 1811 if ind4d == 2221
	replace ind4d = 1812 if ind4d == 2222
	replace ind4d = 1910 if ind4d == 2310
	replace ind4d = 1920 if (ind4d == 1010)| (ind4d == 1020) | (ind4d == 2320)
	replace ind4d = 2011 if (ind4d == 2330)| (ind4d == 2411) | (ind4d == 2429)
	replace ind4d = 2012 if ind4d == 2412
	replace ind4d = 2013 if ind4d == 2413
	replace ind4d = 2021 if ind4d == 2421
	replace ind4d = 2022 if ind4d == 2422
	replace ind4d = 2023 if ind4d == 2424
	replace ind4d = 2029 if ind4d == 2429
	replace ind4d = 2030 if ind4d == 2430
	replace ind4d = 2100 if ind4d == 2423
	replace ind4d = 2211 if ind4d == 2511
	replace ind4d = 2219 if ind4d == 2519
	replace ind4d = 2220 if ind4d == 2520
	replace ind4d = 2310 if ind4d == 2610
	replace ind4d = 2391 if ind4d == 2692
	replace ind4d = 2392 if ind4d == 2693
	replace ind4d = 2393 if ind4d == 2691
	replace ind4d = 2394 if ind4d == 2694
	replace ind4d = 2395 if ind4d == 2695
	replace ind4d = 2396 if ind4d == 2696
	replace ind4d = 2399 if ind4d == 2699
	replace ind4d = 2410 if (ind4d == 2711) | (ind4d == 2712) | (ind4d == 2713) | (ind4d == 2714)| (ind4d == 2715) | (ind4d == 2716) | (ind4d == 2717)| (ind4d == 2718) | (ind4d == 2719)
	replace ind4d = 2424 if ind4d == 2720
	replace ind4d = 2431 if ind4d == 2731
	replace ind4d = 2432 if ind4d == 2732
	replace ind4d = 2511 if ind4d == 2811
	replace ind4d = 2512 if ind4d == 2812
	replace ind4d = 2513 if ind4d == 2813 
	replace ind4d = 2520 if ind4d == 2927
	replace ind4d = 2591 if ind4d == 2891
	replace ind4d = 2592 if ind4d == 2892
	replace ind4d = 2593 if (ind4d == 2893) | (ind4d == 2929)
	replace ind4d = 2599 if ind4d == 2899
	replace ind4d = 2610 if ind4d == 3210
	replace ind4d = 2620 if ind4d == 3000
	replace ind4d = 2630 if ind4d == 3220
	replace ind4d = 2640 if ind4d == 3230
	replace ind4d = 2651 if ind4d == 3312 | ind4d == 3313
	replace ind4d = 2652 if ind4d == 3330
	replace ind4d = 2660 if ind4d == 3311
	replace ind4d = 2670 if ind4d == 3312 | ind4d == 3313
	replace ind4d = 2652 if ind4d == 3330
	replace ind4d = 2660 if ind4d == 3311
	replace ind4d = 2670 if ind4d == 3312 | ind4d == 3320
	replace ind4d = 2680 if ind4d == 2429
	replace ind4d = 2710 if ind4d == 3110 | ind4d == 3120
	replace ind4d = 2720 if ind4d == 3140
	replace ind4d = 2731 if ind4d == 3130
	replace ind4d = 2733 if ind4d == 3120
	replace ind4d = 2740 if ind4d == 3250
	replace ind4d = 2750 if ind4d == 2930
	replace ind4d = 2790 if ind4d == 3120 | ind4d == 3130 | ind4d == 3150 | ind4d == 3190
	replace ind4d = 2811 if ind4d == 2911
	replace ind4d = 2812 if ind4d == 2912
	replace ind4d = 2814 if ind4d == 2913
	replace ind4d = 2815 if ind4d == 2914
	replace ind4d = 2816 if ind4d == 2915
	replace ind4d = 2817 if ind4d == 3000
	replace ind4d = 2818 if ind4d == 2922
	replace ind4d = 2819 if ind4d == 2919
	replace ind4d = 2821 if ind4d == 2921
	replace ind4d = 2822 if ind4d == 2922
	replace ind4d = 2823 if ind4d == 2923
	replace ind4d = 2824 if ind4d == 2924
	replace ind4d = 2825 if ind4d == 2925
	replace ind4d = 2826 if ind4d == 2926
	replace ind4d = 2829 if ind4d == 2929
	replace ind4d = 2910 if ind4d == 3410
	replace ind4d = 2920 if ind4d == 3420
	replace ind4d = 2930 if ind4d == 3430
	replace ind4d = 3011 if ind4d == 3511
	replace ind4d = 3012 if ind4d == 3512
	replace ind4d = 3020 if ind4d == 3520
	replace ind4d = 3030 if ind4d == 3530
	replace ind4d = 3040 if ind4d == 2927
	replace ind4d = 3091 if ind4d == 3591
	replace ind4d = 3092 if ind4d == 3592
	replace ind4d = 3099 if ind4d == 3599
	replace ind4d = 3100 if ind4d == 3610
	replace ind4d = 3211 if ind4d == 3691
	replace ind4d = 3212 if ind4d == 3699
	replace ind4d = 3220 if ind4d == 3692
	replace ind4d = 3230 if ind4d == 3693
	replace ind4d = 3240 if ind4d == 3694
	replace ind4d = 3250 if ind4d == 3311 | ind4d == 3320
	replace ind4d = 3290 if ind4d == 3699
	replace ind4d = 3311 if (ind4d == 2811) | (ind4d == 2812) | (ind4d == 2813) | (ind4d == 2892)| (ind4d == 2893) | (ind4d == 2899) | (ind4d == 2927)| (ind4d == 2929) | (ind4d == 3420)
	replace ind4d = 3312 if (ind4d == 2911) | (ind4d == 2912) | (ind4d == 2913) | (ind4d == 2914)| (ind4d == 2915) | (ind4d == 2919) | (ind4d == 2921)| (ind4d == 2922) | (ind4d == 2923) ///
		| (ind4d == 2924) | (ind4d == 2925) | (ind4d == 2926) | (ind4d == 2929) | (ind4d == 3110) | (ind4d == 3699) | (ind4d == 7250)
	replace ind4d = 3313 if (ind4d == 3220) | (ind4d == 3311) | (ind4d == 3312) | (ind4d == 3313)| (ind4d == 3320)
	replace ind4d = 3314 if (ind4d == 2520) | (ind4d == 3110) | (ind4d == 3120) | (ind4d == 3130)| (ind4d == 3140) | (ind4d == 3150) | (ind4d == 3190)| (ind4d == 3210)
	replace ind4d = 3315 if (ind4d == 3511) | (ind4d == 3512) | (ind4d == 3520) | (ind4d == 3530)| (ind4d == 3599) | (ind4d == 6303)
	replace ind4d = 3319 if (ind4d == 1721) | (ind4d == 1723) | (ind4d == 2023) | (ind4d == 2029)| (ind4d == 2519) | (ind4d == 2520) | (ind4d == 2610)| (ind4d == 2699) | (ind4d == 3311) ///
		| (ind4d == 3312) | (ind4d == 3330) | (ind4d == 3692) | (ind4d == 3694)
	replace ind4d = 3320 if (ind4d == 2813) | (ind4d == 2911) | (ind4d == 2912) | (ind4d == 2914)| (ind4d == 2915) | (ind4d == 2919) | (ind4d == 2921)| (ind4d == 2922) | (ind4d == 2923) ///
		| (ind4d == 2924) | (ind4d == 2925) | (ind4d == 2926) | (ind4d == 2929) | (ind4d == 3000) | (ind4d == 3110) | (ind4d == 3220) | (ind4d == 3311) | (ind4d == 3313)
	replace ind4d = 3510 if ind4d == 4010
	replace ind4d = 3520 if ind4d == 4020
	replace ind4d = 3530 if ind4d == 4030
	replace ind4d = 3600 if ind4d == 4100
	replace ind4d = 3700 if ind4d == 9000
	replace ind4d = 3830 if ind4d == 3710 | ind4d == 3720
	replace ind4d = 3520 if ind4d == 4020
	replace ind4d = 3900 if ind4d == 9000
	replace ind4d = 4100 if ind4d == 4520
	replace ind4d = 4311 if ind4d == 4510
	replace ind4d = 4321 if ind4d == 4530
	replace ind4d = 4322 if ind4d == 4530
	replace ind4d = 4330 if ind4d == 4540
	replace ind4d = 4390 if ind4d == 4520
	replace ind4d = 4510 if ind4d == 5010
	replace ind4d = 4520 if ind4d == 5020
	replace ind4d = 4530 if ind4d == 5030
	replace ind4d = 4540 if ind4d == 5040
	replace ind4d = 4610 if ind4d == 5110
	replace ind4d = 4620 if ind4d == 5121
	replace ind4d = 4630 if ind4d == 5122
	replace ind4d = 4641 if ind4d == 5131
	replace ind4d = 4649 if ind4d == 5139
	replace ind4d = 4651 if ind4d == 5151
	replace ind4d = 4652 if ind4d == 5152 | ind4d == 5139
	replace ind4d = 4653 if ind4d == 5159
	replace ind4d = 4661 if ind4d == 5141
	replace ind4d = 4662 if ind4d == 5142
	replace ind4d = 4663 if ind4d == 5143
	replace ind4d = 4669 if ind4d == 5149 | ind4d == 5139
	replace ind4d = 4690 if ind4d == 5190
	replace ind4d = 4711 if ind4d == 5211
	replace ind4d = 4719 if ind4d == 5219
	replace ind4d = 4721 if ind4d == 5220
	replace ind4d = 4730 if ind4d == 5050
	replace ind4d = 4741 if ind4d == 5239
	replace ind4d = 4742 if ind4d == 5233
	replace ind4d = 4751 if ind4d == 5232
	replace ind4d = 4752 if ind4d == 5234
	replace ind4d = 4753 if ind4d == 5233 | ind4d == 5239
	replace ind4d = 4772 if ind4d == 5231
	replace ind4d = 4774 if ind4d == 5240
	replace ind4d = 4781 if ind4d == 5252
	replace ind4d = 4791 if ind4d == 5251
	replace ind4d = 4799 if ind4d == 5259
	replace ind4d = 4911 if ind4d == 6010
	replace ind4d = 4921 if ind4d == 6021
	replace ind4d = 4922 if ind4d == 6022
	replace ind4d = 4923 if ind4d == 6023
	replace ind4d = 4930 if ind4d == 6030
	replace ind4d = 5011 if ind4d == 6110
	replace ind4d = 5021 if ind4d == 6120
	replace ind4d = 5110 if ind4d == 6210
	replace ind4d = 5120 if ind4d == 6210
	replace ind4d = 5210 if ind4d == 6302
	replace ind4d = 5221 if ind4d == 6303
	replace ind4d = 5224 if ind4d == 6301
	replace ind4d = 5229 if ind4d == 6309
	replace ind4d = 5310 if ind4d == 6411
	replace ind4d = 5320 if ind4d == 6412
	replace ind4d = 5610 if ind4d == 5520
	replace ind4d = 5811 if ind4d == 2211 | ind4d == 7240
	replace ind4d = 5813 if ind4d == 2212
	replace ind4d = 5819 if ind4d == 2219
	replace ind4d = 5820 if ind4d == 7221
	replace ind4d = 5911 if ind4d == 9211 | ind4d == 9213
	replace ind4d = 5914 if ind4d == 9212
	replace ind4d = 5920 if ind4d == 2213
	replace ind4d = 6010 if ind4d == 9213
	replace ind4d = 6110 if ind4d == 6420
	replace ind4d = 6201 if ind4d == 7229
	replace ind4d = 6202 if ind4d == 7210
	replace ind4d = 6209 if ind4d == 7290
	replace ind4d = 6311 if ind4d == 7230
	replace ind4d = 6312 if ind4d == 7240
	replace ind4d = 6391 if ind4d == 9220
	replace ind4d = 6399 if ind4d == 7499
	replace ind4d = 6411 if ind4d == 6511
	replace ind4d = 6419 if ind4d == 6519
	replace ind4d = 6491 if ind4d == 6591
	replace ind4d = 6492 if ind4d == 6592
	replace ind4d = 6499 if ind4d == 6599
	replace ind4d = 6511 if ind4d == 6601
	replace ind4d = 6512 if ind4d == 6603
	replace ind4d = 6530 if ind4d == 6602
	replace ind4d = 6611 if ind4d == 6711
	replace ind4d = 6612 if ind4d == 6712
	replace ind4d = 6619 if ind4d == 6719
	replace ind4d = 6621 if ind4d == 6720
	replace ind4d = 6630 if ind4d == 6712
	replace ind4d = 6810 if ind4d == 7010
	replace ind4d = 6820 if ind4d == 7020
	replace ind4d = 6910 if ind4d == 7411
	replace ind4d = 6920 if ind4d == 7412
	replace ind4d = 7010 if ind4d == 7414
	replace ind4d = 7110 if ind4d == 7421
	replace ind4d = 7120 if ind4d == 7422
	replace ind4d = 7210 if ind4d == 7310
	replace ind4d = 7220 if ind4d == 7320
	replace ind4d = 7310 if ind4d == 7430
	replace ind4d = 7320 if ind4d == 7413
	replace ind4d = 7410 if ind4d == 7499
	replace ind4d = 7420 if ind4d == 7494
	replace ind4d = 7490 if ind4d == 7414 | ind4d == 7421 | ind4d == 7492
	replace ind4d = 7500 if ind4d == 8520
	replace ind4d = 7710 if ind4d == 7111
	replace ind4d = 7721 if ind4d == 7130
	replace ind4d = 7730 if ind4d == 7111 | ind4d == 7112 | ind4d == 7113 | ind4d == 7121 | ind4d == 7122 | ind4d == 7123 | ind4d == 7129
	replace ind4d = 7740 if ind4d == 6599
	replace ind4d = 7810 if ind4d == 7491
	replace ind4d = 7911 if ind4d == 6304
	replace ind4d = 8010 if ind4d == 7492
	replace ind4d = 8110 if ind4d == 7493
	replace ind4d = 8130 if ind4d == 9000
	replace ind4d = 8211 if ind4d == 7499
	replace ind4d = 8292 if ind4d == 7495
	replace ind4d = 8411 if ind4d == 7511
	replace ind4d = 8412 if ind4d == 7512
	replace ind4d = 8413 if ind4d == 7513
	replace ind4d = 8421 if ind4d == 7521
	replace ind4d = 8422 if ind4d == 7522
	replace ind4d = 8423 if ind4d == 7523
	replace ind4d = 8430 if ind4d == 7530
	replace ind4d = 8510 if ind4d == 8010
	replace ind4d = 8521 if ind4d == 8021
	replace ind4d = 8522 if ind4d == 8022
	replace ind4d = 8530 if ind4d == 8030
	replace ind4d = 8541 if ind4d == 9241
	replace ind4d = 8542 if ind4d == 8090
	replace ind4d = 8610 if ind4d == 8511
	replace ind4d = 8620 if ind4d == 8512
	replace ind4d = 8690 if ind4d == 8519
	replace ind4d = 8720 if ind4d == 8531
	replace ind4d = 8810 if ind4d == 8532
	replace ind4d = 9000 if ind4d == 9214
	replace ind4d = 9101 if ind4d == 9231
	replace ind4d = 9102 if ind4d == 9232
	replace ind4d = 9103 if ind4d == 9233
	replace ind4d = 9200 if ind4d == 5190 | ind4d == 5259 | ind4d == 9249
	replace ind4d = 9311 if ind4d == 9241
	replace ind4d = 9312 if ind4d == 9241
	replace ind4d = 9321 if ind4d == 9249
	replace ind4d = 9329 if ind4d == 9219
	replace ind4d = 9411 if ind4d == 9111
	replace ind4d = 9412 if ind4d == 9112
	replace ind4d = 9420 if ind4d == 9120
	replace ind4d = 9491 if ind4d == 9191
	replace ind4d = 9492 if ind4d == 9192
	replace ind4d = 9499 if ind4d == 9199
	replace ind4d = 9511 if ind4d == 7250
	replace ind4d = 9512 if ind4d == 3220
	replace ind4d = 9521 if ind4d == 3230 | ind4d == 5260
	replace ind4d = 9522 if ind4d == 5260
	replace ind4d = 9523 if ind4d == 5260
	replace ind4d = 9524 if ind4d == 3610
	replace ind4d = 9529 if ind4d == 5260
	replace ind4d = 9601 if ind4d == 9301
	replace ind4d = 9602 if ind4d == 9302
	replace ind4d = 9603 if ind4d == 9303
	replace ind4d = 9609 if ind4d == 9309
	replace ind4d = 9700 if ind4d == 9500
	replace ind4d = 9810 if ind4d == 9600
	replace ind4d = 9820 if ind4d == 9700
	replace ind4d = 9900 if ind4d == 9900
}
gen ind3d = int(ind4d/10)
gen ind2d = int(ind3d/10)
gen ind1d = int(ind2d/10)

*----------------------
* Clean variables
*----------------------
recode first_yr (0=.)
replace first_yr = . if first_yr < 1500
replace first_yr = . if first_yr > yr

* Drop observations where everything is missing (usually firms not operating)
drop if (TotCurAsset_Open==.) & (TotFixedAsset_Gross_Open==.) & (TotalLiabilities_Open==.) & (TotInventory_Open==.) & (ShortTermDebt_Open==.) & (PollutionControl_Net_Open==.) ///
 & (OutstandingLoans_Open==.) & (LongTermDebt_Open==.) & (ShortTermDebt_Open==.) & (TotFuels_Open==.) & (TotInventory_Open==.)
 
drop if (TotCurAsset_Close==.) & (TotFixedAsset_Gross_Close==.) & (TotalLiabilities_Close==.) & (TotInventory_Close==.) & (ShortTermDebt_Close==.) & (PollutionControl_Net_Close==.) ///
 & (OutstandingLoans_Close==.) & (LongTermDebt_Close==.) & (ShortTermDebt_Close==.) & (TotFuels_Close==.) & (TotInventory_Close==.)

/*
/// 1. Find and delete duplicate obesrvations ///
duplicates report yr state urb ind1d TotWorkingCapital_Open TotFixedAsset_Gross_Open TotalLiabilities_Open
duplicates report yr state urb ind1d TotWorkingCapital_Close TotFixedAsset_Gross_Close TotalLiabilities_Close

duplicates drop yr state urb ind1d TotWorkingCapital_Open TotFixedAsset_Gross_Open TotalLiabilities_Open, force
duplicates drop yr state urb ind1d TotWorkingCapital_Close TotFixedAsset_Gross_Close TotalLiabilities_Close, force

sort yr state urb ind1d TotWorkingCapital_Open TotFixedAsset_Gross_Open TotalLiabilities_Open 
*/

*-------------------
* Add external data
*-------------------

**** Price of Oil *****
* Import crude oil prices - Indian basket (USD)
preserve
	clear
	import excel "Data\External\Price_IndianOil_USDperBarrel.xlsx", sheet("Sheet1") firstrow
	save "Data\External\Price_IndianOil_USDperBarrel.dta", replace
restore
merge m:1 yr using "Data/External/Price_IndianOil_USDperBarrel.dta"
drop _merge
* Import exchange rate
merge m:1 yr using "Data/External/Exchange_rate.dta"
drop _merge
gen p_oil_bar = p_oil*exinus
* Convert price of oil from barell to gallon
gen p_oil_gal = p_oil_bar/42
* Convert price of oil from gallon to mmbtu (EPA)
gen p_oil_mmbtu = p_oil/0.138

*-----------------------------
* Panel Identifiers (Existing)
*-----------------------------

* This takes panel identifiers estimated from another paper and merge it with this dataset
replace dsl = int(dsl/10000) if yr == 2008
merge 1:1 dsl using "Data/ASI_PanelID.dta"
rename ID_PANEL plant_id


*---------------------------
* Panel Identifiers (Manual)
*---------------------------
* Create two datasets for each year (one with closing values and one with opening values) including time-invariant variables that may identify plants and time-varying variables that should not move too much (i.e. labor)
local T = 2018
forvalues t = 2001/`T' {
	preserve
		keep if yr == `t'
		keep dsl yr ind2d ind1d state urb TotFixedAsset_Gross_Open TotalLiabilities_Open TotCurAsset_Open TotInventory_Open ///
		TotFixedAsset_Net_Open Land_Gross_Open Land_Net_Open Bldg_Gross_Open Bldg_Net_Open nEmployees_Managers nEmployees_NonManagers
		rename nEmployees_Managers nEmployees_Managers_`t'
		rename nEmployees_NonManagers nEmployees_NonManagers_`t'
		rename dsl dsl_`t'
		save "Data/Panel_Identifier/`t'_close.dta",replace // Dataset with closing values 
	restore
}
local T = 2018
forvalues t = 2001/`T' {
	preserve
		keep if yr == `t'
		keep dsl yr ind2d ind1d state urb TotFixedAsset_Gross_Close TotFixedAsset_Net_Close TotInventory_Close TotalLiabilities_Close ///
		TotCurAsset_Close Land_Gross_Close Land_Net_Close Bldg_Gross_Close Bldg_Net_Close nEmployees_Managers nEmployees_NonManagers
		rename nEmployees_Managers nEmployees_Managers_`t'
		rename nEmployees_NonManagers nEmployees_NonManagers_`t'
		rename dsl dsl_`t'
		save "Data/Panel_Identifier/`t'_open.dta",replace // Dataset with opening values
	restore
}

* Set panel identifiers by matching firms
****Initialization with first two years*****
preserve
	use "Data\Panel_Identifier\2002_open.dta", clear
	*1. join observation between two years based on time-invariant variables (create a set of potential matches for each plants)
	joinby state urb ind1d using "Data/Panel_Identifier\2001_close.dta"
	sort dsl_2002
	*2. Create a dummy var that takes 1 if the open variable is within (+/-) 0.5% of the close variable in the previous year
	local vars TotFixedAsset_Gross TotCurAsset TotalLiabilities
	foreach v of local vars {
		drop if (`v'_Close ==. & `v'_Open !=.) | (`v'_Open ==. & `v'_Close !=.)
		gen `v' = 1 if `v'_Close <= (0.005*`v'_Open+`v'_Open) & `v'_Close >= (`v'_Open-0.005*`v'_Open)
		replace `v' = 0 if `v'_Close > (0.005*`v'_Open+`v'_Open) | `v'_Close < (`v'_Open-0.005*`v'_Open) | (`v'_Close ==. & `v'_Open ==.)
	}
	*3. Compute average of match dummy across variables and keep non-zero matches only
	egen avgmatch_dummy = rowmean(TotFixedAsset_Gross TotCurAsset TotalLiabilities)
	keep if avgmatch_dummy > 0 & avgmatch_dummy != .
	*4. Define match quality (percentage difference in number of workers and opening/closing values)
	gen nEmployees_2002 = nEmployees_Managers_2002+nEmployees_NonManagers_2002
	gen nEmployees_2001 = nEmployees_Managers_2001+nEmployees_NonManagers_2001
	local vars nEmployees nEmployees_Managers nEmployees_NonManagers // Skilled and unskilled labor
	foreach v of local vars {
		gen `v'_diff = `v'_2002-`v'_2001
		gen `v'_avgdiff = (`v'_2002+`v'_2001)/2
		gen `v'_percdiff = abs(100*(`v'_diff/`v'_avgdiff))
	}
	local vars TotFixedAsset_Gross TotCurAsset TotalLiabilities // Opening and Closing variables
	foreach v of local vars {
		gen `v'_diff = `v'_Open-`v'_Close
		gen `v'_avgdiff = (`v'_Open+`v'_Close)/2
		gen `v'_percdiff = abs(100*(`v'_diff/`v'_avgdiff))
	}
	*5. Define overall measure of match quality and keep below a threshold 
	egen avgdiff = rowmean(TotFixedAsset_Gross_percdiff TotCurAsset_percdiff TotalLiabilities_percdiff)
	drop if nEmployees_Managers_percdiff == .
	drop if nEmployees_NonManagers_percdiff == .
	egen nEmployees_avgtotdiff = rowmean(nEmployees_Managers_percdiff nEmployees_NonManagers_percdiff)
	egen totdiff = rowmean(avgdiff nEmployees_avgtotdiff)
	keep if totdiff < 50
	*6. Keep the smallest difference for each plant
	bysort dsl_2002: egen mindiff = min(totdiff)
	keep if totdiff == mindiff
	*7. Make sure there are no duplicates matches 
	duplicates report dsl_2002
	duplicates report dsl_2001
	duplicates tag dsl_2001, gen(dupnew)
	bysort dsl_2001: egen mindiff_duplicates = min(totdiff)
	keep if totdiff == mindiff_duplicates
restore

local T = 2018
forvalues t = 2001/`T'{



}









/*
* Create datasets by year for panel matching
local T = 2018
forvalues t = 2001/`T' {
	preserve
		keep if yr == `t'
		keep dsl yr first_yr ind3d state TotWorkingCapital_Open TotFixedAsset_GrossOpen TotalLiabilities_Open TotInventory_Open ShortTermDebt_Open /// 
PollutionControl_NetOpen OutstandingLoans_Open LongTermDebt_Open TotFuels_Open
		rename TotWorkingCapital_Open TotWorkingCapital
		rename TotFixedAsset_GrossOpen TotFixedAsset_Gross
		rename TotalLiabilities_Open TotalLiabilities
		rename TotInventory_Open TotInventory
		rename ShortTermDebt_Open ShortTermDebt
		rename PollutionControl_NetOpen PollutionControl
		rename OutstandingLoans_Open OutstandingLoans
		rename LongTermDebt_Open LongTermDebt
		rename TotFuels_Open TotFuels
		save "Data/Panel_Identifier/`t'_close.dta",replace
	restore
}
local T = 2018
forvalues t = 2001/`T' {
	preserve
		keep if yr == `t'
		keep dsl yr first_yr ind3d state TotWorkingCapital_Close TotFixedAsset_GrossClose TotalLiabilities_Close TotInventory_Close ShortTermDebt_Close /// 
PollutionControl_NetClose OutstandingLoans_Close LongTermDebt_Close TotFuels_Close
		rename TotWorkingCapital_Close TotWorkingCapital
		rename TotFixedAsset_GrossClose TotFixedAsset_Gross
		rename TotalLiabilities_Close TotalLiabilities
		rename TotInventory_Close TotInventory
		rename ShortTermDebt_Close ShortTermDebt
		rename PollutionControl_NetClose PollutionControl
		rename OutstandingLoans_Close OutstandingLoans
		rename LongTermDebt_Close LongTermDebt
		rename TotFuels_Close TotFuels
		save "Data/Panel_Identifier/`t'_open.dta",replace
	restore
}


*------------------------
* Panel Identifiers (old)
*------------------------

// Goal: create a match if all variables with close/open match between two years

gen match_count = .
gen match_id = .
sort yr
bysort yr: gen nyr = _N

* Number of observations per year
preserve
	collapse (mean) nyr, by(yr)
	mata
		mata clear
		nyr = st_data(.,"nyr")
	end
restore 
* Identifies first (nfirst) and last (nlast) observations for each given year
mata
	T = 18
	nfirst = J(T,1,.)
	nlast = J(T,1,.)
	nfirst[1,1] = 1
	nlast[1,1] = nyr[1]
	for (i=2; i<=T; i++) {
		nfirst[i,1] = nlast[i-1,1]+1
		nlast[i,1] = nlast[i-1,1]+nyr[i,1]
	}
	st_matrix("nfirst",nfirst)
	st_matrix("nlast",nlast)
	st_matrix("nyr",nyr)
end
svmat nfirst
rename nfirst nfirst
svmat nlast
rename nlast1 nlast
svmat nyr
* Matching test
local nfirst = nfirst[2]
local nlast = nlast[2]
local nfirst_before = nfirst[1]
local nlast_before = nlast[1]

forval i = `nfirst'/`nlast' {
	forval j = `nfirst_before'/`nlast_before' {
		if (TotalLiabilities_Open[`i'] == TotalLiabilities_Close[`j']) {
			quietly: replace match_id = `i' in `i'
			quietly: replace match_id = `i' in `j'
			}
	}
}

forval i = `nfirst'/`nlast' {
	forval j = `nfirst_before'/`nlast_before' {
		*if (TotalLiabilities_Open[`i'] == TotalLiabilities_Close[`j'] & TotalLiabilities_Close[`j'] != . & TotalLiabilities_Open[`i'] != .) ///
		*& (TotworkingCapital_Open[`i'] == TotworkingCapital_Close[`j'] &  TotworkingCapital_Open[`i'] != . & TotworkingCapital_Close[`j'] != .) ///
		*& (TotFixedAsset_GrossOpen[`i'] == TotFixedAsset_GrossClose[`j'] & TotFixedAsset_GrossOpen[`i'] != . & TotFixedAsset_GrossClose[`j'] != .) {
			quietly: replace match_id = `i' in `i'
			quietly: replace match_id = `i' in `j'
	}
}


local T = 18
forval t = 2/`T'{
	local nfirst = nfirst[`t']
	local nlast = nlast[`t']
	local nfirst_before = nfirst[`t'-1]
	local nlast_before = nfirst[`t'-1]
	forval i = `nfirst'/`nlast' {
		forval j = `nfirst_before'/`nlast_before' {
			if (TotalLiabilities_Open[`i'] == TotalLiabilities_Close[`j'] & TotalLiabilities_Close[`j'] != . & TotalLiabilities_Open[`i'] != .) ///
			& (TotworkingCapital_Open[`i'] == TotworkingCapital_Close[`j'] &  TotworkingCapital_Open[`i'] != . & TotworkingCapital_Close[`j'] != .) ///
			& (TotFixedAsset_GrossOpen[`i'] == TotFixedAsset_GrossClose[`j'] & TotFixedAsset_GrossOpen[`i'] != . & TotFixedAsset_GrossClose[`j'] != .) {
				replace match_id = `i' in `i'
				replace match_id = `i' in `j'
			}
		}
	}
}




*/



















