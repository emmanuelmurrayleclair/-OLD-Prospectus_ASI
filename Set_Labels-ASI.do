*--------------------
*Clean variable names
*--------------------

drop blk
drop block
replace b_8 = b__8 if b_8 == .
drop b__8
replace b_2 = b02 if b_2 == .
drop b02
replace f_10 = f__10 if f_10 == .
replace f_11 = f__11 if f_11 == .
drop f__10 f__11

foreach v of varlist a* b* f* g* {
     local V: subinstr local v "_" "", all
     rename `v' `V'
}

*---------------
*Order variables
*--------------

order a10, after(a9)
order a17-a22, after(a16)
order b7f, after(b6)
order b7t, after(b7f)
order b4, after(b3)
order b5, after(b4)
order b8, after(b7t)
order b9, after(b8)
order b10, after(b9)
order b13-b15, after(b9)
order b2, before(b3)
*order c10-c11, after(c9)
*order e7, after(e6)
order f2c, after(f2b)
order f10-f11, after(f9)
order f12, after(f11)
order g13, after(g11)
*order h7, after(h6)
*order i7, after(i6)
*order j11, after(j10)
*order j13, after(j11)

order b11-b12, before(b13)
order g12, before(g13)

*--------------------
* Set variable labels
*--------------------

drop a2 a21 a22 a4 a10

lab var a2 "PSL No"
lab var a3 "Scheme code"
lab var a5 "Industry code, 5 digits"
lab var a7 "State code"
lab var a8 "Disctrict code"
lab var a9 "Rural/Urban"
lab var a11 "No. of units"
lab var a12 "Status code"
lab var a13 "Number of manufacturing working days"
lab var a14 "Number of non-manufactruing working days"
lab var a15 "Total number of working days"
lab var a16 "Total cost of production"
lab var a17 "Bonus"
lab var a18 "Provident fund"
lab var a19 "Welfare expenses"
lab var a20 "Share (%) of product"
lab var awgt "Multiplier factor"

lab var b2 "Type of organization"
lab var b3 "Type of ownership"
lab var b4 "Number of plants"
lab var b5 "Number of plants in same state"
lab var b6 "Year of initial production"
lab var b7f "Accounting year (from)"
lab var b7t "Accounting year (to)"
lab var b8 "Months of operation"
lab var b9 "A/C systems"
lab var b10 "ASI data on computers"
lab var b11 "Original value of investments"
lab var b12 "ISO certification"
lab var b13 "Company identification number (CIN)"
lab var b14 "Whether a foreign entity has shares in the company"
lab var b15 "Whether the plant did R&D"

*lab var c1 "Type of fixed capital"
foreach v of varlist c3* {
	lab var `v' "Gross value - Opening"
}
foreach v of varlist c4* {
	lab var `v' "Gross value - Adjustment due to reevaluation"
}
foreach v of varlist c5* {
	lab var `v' "Gross value - Actual addition"
}
foreach v of varlist c6* {
	lab var `v' "Gross value - deduction & adjustment"
}
foreach v of varlist c7* {
	lab var `v' "Gross value - Closing (sum c3 to c6)"
}
foreach v of varlist c8* {
	lab var `v' "Depreciation - up to begining of year"
}
foreach v of varlist c9* {
	lab var `v' "Depreciation - during the current year"
}
foreach v of varlist c10* {
	lab var `v' "Depreciation - due to sold/discarded"
}
foreach v of varlist c11* {
	lab var `v' "Depreciation - up to year end (c8+c9-c10)"
}
foreach v of varlist c12* {
	lab var `v' "Net value - Opening"
}
foreach v of varlist c13* {
	lab var `v' "Net value - Closing"
}
*lab var d1 "Type of working capital"
foreach v of varlist d3* {
	lab var `v' "Working capital - Opening"
}
foreach v of varlist d4* {
	lab var `v' "Working capital - Closing"
}

*lab var e1 "Type of worker"
foreach v of varlist e3* {
	lab var `v' "Days worked - manufacturing"
}
foreach v of varlist e4* {
	lab var `v' "Days worked - non manufacturing"
}
foreach v of varlist e5* {
	lab var `v' "Days worked - Total"
}
foreach v of varlist e6* {
	lab var `v' "Average number of people worked"
}
foreach v of varlist e7* {
	lab var `v' "Number of days paid for"
}
foreach v of varlist e8* {
	lab var `v' "Wages/salaries"
}
foreach v of varlist e9* {
	lab var `v' "Bonus"
}
foreach v of varlist e10* {
	lab var `v' "Contribution to provident fund and other funds"
}
foreach v of varlist e11* {
	lab var `v' "Welfare expenses"
}

lab var f1 "Work done by others"
lab var f2a "Repair & Maintenance - Building"
lab var f2b "Repair & Maintenance - Machinery"
lab var f2c "Repair & Maintenance - Pollution control equipment"
lab var f2d "Repair & Maintenance - Other fixed assets"
lab var f3 "Operating expenses"
lab var f4 "Non-operating expenses"
lab var f5 "Insurance charges"
lab var f6 "Rent paid - plant & machinery"
lab var f7 "Total expenses"
lab var f8 "Rent paid - Building"
lab var f9 "Rent/royalties"
lab var f10 "Interest paid"
lab var f11 "Value of purchase goods"
lab var f12 "R&D expenses"

lab var g1 "Receipts from manufacturing services"
lab var g2 "Receipts from non-manufactruing services"
lab var g3 "Value in electricity generated and sold"
lab var g4 "Value of own construction"
lab var g5 "Net balance of goods sold"
lab var g6 "Rent received - Plant & machinery"
lab var g7 "Total receipts"
lab var g8 "Rent received - Building"
lab var g9 "Recent received - Land"
lab var g10 "Interest received"
lab var g11 "Sale value of goods sold"
lab var g12 "Subsidies"
lab var g13 "Variation in stock of finished goods"

*lab var h1 "Product purchased (domestic)"
foreach v of varlist h3* {
	lab var `v' "Item code"
}
foreach v of varlist h4* {
	lab var `v' "Unit of quantity"
}
foreach v of varlist h5* {
	lab var `v' "Quantity consumed"
}
foreach v of varlist h6* {
	lab var `v' "Purchase value"
}
foreach v of varlist h7* {
	lab var `v' "Rate per unit (price)"
}

*lab var i1 "Product purchased (imported)"
foreach v of varlist i3* {
	lab var `v' "Item code"
}
foreach v of varlist i4* {
	lab var `v' "Unit of quantity"
}
foreach v of varlist i5* {
	lab var `v' "Quantity consumed"
}
foreach v of varlist i6* {
	lab var `v' "Purchase value"
}
foreach v of varlist i7* {
	lab var `v' "Rate per unit (price)"
}

*lab var j1 "Product sold"
foreach v of varlist j3* {
	lab var `v' "Item code"
}
foreach v of varlist j4* {
	lab var `v'  "Unit of quantity"
}
foreach v of varlist j5* {
	lab var `v'  "Quantity manufactured"
}
foreach v of varlist j6* {
	lab var `v'  "Quantity sold"
}
foreach v of varlist j7* {
	lab var `v'  "Gross sale value"
}
foreach v of varlist j8* {
	lab var `v'  "Goods and service tax"
}
foreach v of varlist j9* {
	lab var `v'   "excise duty"
}
foreach v of varlist j10* {
	lab var `v'   "Others"
}
foreach v of varlist j11* {
	lab var `v'   "Subsidy"
}
foreach v of varlist j12* {
	lab var `v'   "Per unit sale value (price)"
}
foreach v of varlist j13* {
	lab var `v'   "ex-factory value of quantity (unit cost?)"
}
foreach v of varlist j14* {
	lab var `v'   "Total"
}

lab var yr "Year"

*------------------
* Set value labels
*------------------
lab def a7 1 "Jammu & Kashmir" 2 "Himachal Pradesh" 3 "Punjab" 4 "Chandigarh" 5 "Uttaranchal" /*
*/ 6 "Haryana" 7 "Delhi" 8 "Rajasthan" 9 "Uttar Pradesh" 10 "Bihar" 11 "Sikkim" 12 "Arunachal Pradesh" /*
*/ 13 "Nagaland" 14 "Manipur" 15 "Mizoram" 16 "Tripura" 17 "Meghalaya" 18 "Assam" 19 "West Bengal" /*
*/ 20 "Jharkhand" 21 "Orissa" 22 "Chattisgarh" 23 "Madhya Pradesh" 24 "Gujarat" 25 "Daman & Diu" /*
*/ 26 "D & N Haveli" 27 "Maharastra" 28 "Andhra Pradesh" 29 "Karnataka" 30 "Goa" 31 "Lakshadweep" 32 "Kerala" /*
*/  33 "Tamil Nadu" 34 "Pondicherry" 35 "A & N Islands" 36 "Telangana", modify
lab values a7 a7

lab def a9 1 "Rural" 2 "Urban"
lab values a9 a9

lab def b2 1 "Individual owner" 2 "Family owned" 3 "Partneship" 4 "Public limited" 5 "Private limited" /*
*/ 6 "Government" 7 "Public corp" 8 "Industry commissions" 9 "Handlooms" 10 "Co-operative" 19 "Other"
lab values b2 b2

lab def b3 1 "Central gov" 2 "State/Local gov" 3 "Joint gov" 4 "Joint Public" 5 "Joint Private" 6 "Private" 9 "N\A"
lab values b3

/*
lab def c1 1 "Land" 2 "Building" 3 "Plant & machinery" 4 "Transport equipment" 5 "Computer equipment" 6 "Pollution control equipment" /*
*/ 7 "Others" 8 "sub-total" 9 "Capital work in progress" 10 "Total"
lab values c1 c1

lab def d1 1 "Raw materials" 2 "Fuels & lubricants" 3 "Spares, stores & others" 4 "sub-total" 5 "semi-finished goods" 6 "finished goods" /*
*/ 7 "Total inventory" 8 "Cash in hand & at bank" 9 "sundry debtors" 10 "other cur assets" 11 "total cur assets" 12 "sundry creditors" /*
*/ 13 "over draft, cash credit, short term loans" 14 "Other cur liabilities" 15 "total cur liabilities" 16 "Working capital" 17 "Outstanding loans"
lab values d1 d1

lab def e1 1 "Male" 2 "Female" 3 "Child" 4 "sub-total" 5 "Contract workers" 6 "total workers" 7 "Management" 8 "Other employees" 9 "unpaid" /*
*/ 10 "total employees" 11 "number of working days" 12 "total cost of production"
lab values e1 e1

lab def h1 11 "Other basic items" 12 "total basic items" 13 "non basic chemicals" 14 "packing items" 15 "electricity own generated" /*
*/ 16 "electricity purchased & consumed" 17 "oil products" 18 "coal" 19 "gas" 20 "Other fuels" 21 "consumable store" /*
*/ 22 "total non-basic items" 23 "total inputs" 24 "additional requirement of electricity"
lab values h1 h1 

lab def i1 6 "other items imported" 7 "total imports"
lab values i1 i1

lab def j1 11 "other products" 12 "Total" 99 "Misc"
lab values j1 j1
*/

