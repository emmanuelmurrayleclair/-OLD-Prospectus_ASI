* Value of collateral needed for a loan (1/theta in model*100) - Higher value means larger collateral constraint 
gen colreq=.
lab var colreq "Collateral requirement for a loan (percentage of loan amount)"
replace colreq = 244.9 if a7 == 27
replace colreq = 254.2 if a7 == 29
replace colreq = 129.7 if a7 == 28
replace colreq = 205.4 if a7 == 19
replace colreq = 318 if a7 == 33
replace colreq = 253.5 if a7 == 7
replace colreq = 188.1 if a7 ==  9
replace colreq = 246.6 if a7 == 23
replace colreq = 327.7 if a7 == 8
replace colreq = 314.9 if a7 == 32
replace colreq = 129.7 if a7 == 3
replace colreq = 420.4 if a7 == 6
replace colreq = 287.6 if a7 == 18
replace colreq = 281.9 if a7 == 10
replace colreq = 55.1 if a7 == 22
replace colreq = 266.5 if a7 == 20
replace colreq = 326.7 if a7 == 2
replace colreq = 265.6 if (a7 == 12) | (a7 == 13) | (a7 == 14) | (a7 == 16) | (a7 == 17)
replace colreq = 199.2 if a7 == 30
