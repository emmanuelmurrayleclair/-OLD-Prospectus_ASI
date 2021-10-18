* Concordance between NAICS and NIC-08
gen ind5d = .
replace ind5d = 10803 if naics == 311111
replace ind5d = 10803 if naics == 311119
replace ind5d = 10611 if naics == 311211
replace ind5d = 10612 if naics == 311214
replace ind5d = 10626 if naics == 311224
replace ind5d = 1040 if naics == 311225 // actually 1040
replace ind5d = 10616 if naics == 311230
replace ind5d = 1072 if naics == 311310 // actually 1072
replace ind5d = 1073 if naics == 311340 // actually 10733 to 10736
replace ind5d = 10750 if naics == 311410
replace ind5d = 10307 if naics == 311420
replace ind5d = 10501 if naics == 311511
replace ind5d = 10504 if naics == 311515
replace ind5d = 10505 if naics == 311520
replace ind5d = 1010 if naics == 311611 // actually 10101 to 10103
replace ind5d = 10107 if naics == 311614
replace ind5d = 10104 if naics == 311615
replace ind5d = 82920 if naics == 311710
replace ind5d = 1071 if naics == 311814 // actually 10711 and 10719
replace ind5d = 10712 if naics == 311821
replace ind5d = 10791 if naics == 311920 // actually 10791 and 10792
replace ind5d = 10793 if naics == 311990 // actually 10793-10799
replace ind5d = 11031 if naics == 312120
replace ind5d = 1101 if naics == 312140 // actually 11011,11012,11019
replace ind5d = 1393 if naics == 314110 // actually 13931-13935,13939
replace ind5d = 1430 if naics == 315190 // actually 14301 and 14309
replace ind5d = 16101 if naics == 321111
replace ind5d = 16221 if naics == 321112
replace ind5d = 16109 if naics == 321114
replace ind5d = 16211 if naics == 321211
replace ind5d = 16211 if naics == 321212
replace ind5d = 16221 if naics == 321215
replace ind5d = 16212 if naics == 321216
replace ind5d = 16213 if naics == 321911
replace ind5d = 16219 if naics == 321919
replace ind5d = 1629 if naics == 321999 // actually 16291-16297,16299
replace ind5d = 17011 if naics == 322111 // mechanical pulp mill
replace ind5d = 17011 if naics == 322112 // chemical pulp mill
replace ind5d = 17013 if naics == 322121 // actually 17013-17015
replace ind5d = 17012 if naics == 322122
replace ind5d = 1701 if naics == 322130 // actually 17016,17017,17019
replace ind5d = 1702 if naics == 322211 // actuall 17021,17022
replace ind5d = 17024 if naics == 322220
replace ind5d = 18119 if naics == 323119
replace ind5d = 1920 if naics == 324110 // actually 19201-19204
replace ind5d = 19209 if naics == 324121
replace ind5d = 19209 if naics == 324122
replace ind5d = 1910 if naics == 324190 // actually 19101,19109
replace ind5d = 20111 if naics == 325120
replace ind5d = 20132 if naics == 325210
replace ind5d = 2030 if naics == 325220 // actually 20301-20304
replace ind5d = 2012 if naics == 325313 // actually 20121-20123,20129
replace ind5d = 2012 if naics == 325314 // actually 20121-20123,20129
replace ind5d = 2100 if naics == 325410 // actually 21001-21006,21009
replace ind5d = 2022 if naics == 325510 // actually 20221,20222,20224,20229
replace ind5d = 20295 if naics == 325520
replace ind5d = 2023 if naics == 325610 // actually 20231-20234
replace ind5d = 20292 if naics == 325920
replace ind5d = 22203 if naics == 326111
replace ind5d = 22201 if naics == 326114
replace ind5d = 22207 if naics == 326191
replace ind5d = 22207 if naics == 326193
replace ind5d = 22199 if naics == 326210
replace ind5d = 2219 if naics == 326220 // actually 22191,22192
replace ind5d = 22199 if naics == 326290
replace ind5d = 2392 if naics == 327120 // actually 23921-23923,23929
replace ind5d = 2310 if naics == 327214 // actually 23101,23103-23107,23109
replace ind5d = 2310 if naics == 327215 // actually 23101,23103-23107,23109
replace ind5d = 2394 if naics == 327310 // actually 23941-23943
replace ind5d = 23911 if naics == 327320 
replace ind5d = 23952 if naics == 327330 // actually 23952 and 23954
replace ind5d = 23951 if naics == 327390 // actually 23951,23953,23955,23956,23959
replace ind5d = 23944 if naics == 327410
replace ind5d = 23945 if naics == 327420 // actuallly 23945 and 23992
replace ind5d = 23993 if naics == 327910
replace ind5d = 2410 if naics == 331110 // actually 24101-24109
replace ind5d = 24311 if naics == 331210
replace ind5d = 24319 if naics == 331221
replace ind5d = 24319 if naics == 331222 
replace ind5d = 24202 if naics == 331313 
replace ind5d = 24202 if naics == 331317 
replace ind5d = 24320 if naics == 331523
replace ind5d = 24320 if naics == 331529
replace ind5d = 25910 if naics == 332113
replace ind5d = 25920 if naics == 332810
replace ind5d = 28110 if naics == 333611
replace ind5d = 27400 if naics == 335110
replace ind5d = 2750 if naics == 335223 // actually 27501,27502,27504,27509
replace ind5d = 29101 if naics == 336110
replace ind5d = 29104 if naics == 336310
replace ind5d = 3030 if naics == 336410 // actually 30301-30305
replace ind5d = 31001 if naics == 337110
replace ind5d = 31001 if naics == 337123
replace ind5d = 31001 if naics == 337213

* Get dataset ready to merge with ASI
rename s_coal coal_s
rename s_natgas natgas_s
rename s_oil oil_s

gen dataset_id = 1

rename year yr
rename idnum plant_id 
rename oil oil_mmbtu 
rename coal coal_mmbtu
rename natgas natgas_mmbtu

keep naics ind5d oil_s coal_s natgas_s oil_mmbtu coal_mmbtu natgas_mmbtu plant_id yr dataset_id








