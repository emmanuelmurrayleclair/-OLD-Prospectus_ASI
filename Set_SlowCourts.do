* Average case pendency in high courts (Daksh database)
gen k1=.
lab var k1 "Average pendency of court cases by high court (days)"
replace k1 = 1370 if a7 == 9 // Allahabad
replace k1 = 1300 if (a7 ==  27) // Bombay
replace k1 = 1207 if a7 == 24 // Gujarat
replace k1 = 1102 if a7 == 10 // Patna
replace k1 = 1025 if a7 == 23 // Madhya Pradesh
replace k1 = 1015 if a7 == 29 // Karnataka
replace k1 = 992 if a7 == 7 // Delhi
replace k1 = 922 if a7 == 8 // Rajasthan
replace k1 = 891 if a7 == 33 // Madras
replace k1 = 866 if (a7 == 35) | (a7 == 19) // Kolkata
replace k1 = 822 if (a7 == 28) | (a7 == 36) // Hyderabad
replace k1 = 750 if (a7 == 6) | (a7 == 4) | (a7 == 3) // Punjab and Haryana
replace k1 = 723 if a7 == 16 // Tripura
replace k1 = 711 if (a7 == 32) | (a7 == 31) // Kerala
replace k1 = 703 if a7 == 20 // Jharkand
replace k1 = 679 if a7 == 2 // Himachal Pradesh
replace k1 = 610 if a7 == 21 // Odissa
replace k1 = 435 if (a7 == 30) | (a7 == 25) | (a7 == 26) // Goa
replace k1 = 390 if a7 == 5 // Uttarakhand
replace k1 = 314 if a7 == 11 // Sikkim

* Year of High court creation (Boehm and Oberfield 2020)
gen k2=.
lab var k2 "Year of high court creation"
replace k2 = 1866 if a7 == 9 // Allahabad
replace k2 = 1956 if (a7 == 28) | (a7 == 36) // Hyderabad
replace k2 = 1862 if (a7 ==  27) // Bombay
replace k2 = 1862 if (a7 == 35) | (a7 == 19) // Kolkata
replace k2 = 1966 if a7 == 7 // Delhi
replace k2 = 1948 if (a7 == 12) | (a7 == 18) | (a7 == 15) | (a7 == 13) // Gauhati
replace k2 = 1960 if a7 == 24 // Gujarat
replace k2 = 1971 if a7 == 2 // Himachal Pradesh
replace k2 = 1928 if a7 == 1 // Jammu & Kashmir
replace k2 = 2000 if a7 == 20 // Jharkand
replace k2 = 1884 if a7 == 29 // Karnataka
replace k2 = 1956 if (a7 == 32) | (a7 == 31) // Kerala
replace k2 = 1936 if a7 == 23 // Madhya Pradesh
replace k2 = 1862 if a7 == 33 // Madras
replace k2 = 1948 if a7 == 21 // Odissa
replace k2 = 1916 if a7 == 10 // Patna
replace k2 = 1947 if (a7 == 6) | (a7 == 4) | (a7 == 3) // Punjab and Haryana
replace k2 = 1949 if a7 == 8 // Rajasthan 
replace k2 = 1955 if a7 == 11 // Sikkim
replace k2 = 2000 if a7 == 5 // Uttarakhand
replace k2 = 1982 if (a7 == 30) |  (a7 == 25) | (a7 == 26) // Goa
replace k2 = 2013 if a7 == 14 // Manipur
replace k2 = 2013 if a7 == 17 // Meghalaya
replace k2 = 2013 if a7 == 16 // Tripura