*---------------
*Order variables
*---------------

use "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data_Raw\ASI_Raw.dta", clear

foreach v of varlist _all {
     local V: subinstr local v "_" "", all
     rename `v' `V'
}

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
order c10-c11, after(c9)
order e7, after(e6)
order f2c, after(f2b)
order f10-f11, after(f9)
order f12, after(f11)
order g13, after(g11)
order h7, after(h6)
order i7, after(i6)
order j11, after(j10)
order j13, after(j11)

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

lab var c1 "Type of fixed capital"
lab var c3 "Gross value - Opening"
lab var c4 "Gross value - Adjustment due to reevaluation"
lab var c5 "Gross value - Actual addition"
lab var c6 "Gross value - deduction & adjustment"
lab var c7 "Gross value - Closing (sum c3 to c6)"
lab var c8 "Depreciation - up to begining of year"
lab var c9 "Depreciation - during the current year"
lab var c10 "Depreciation - due to sold/discarded"
lab var c11 "Depreciation - up to year end (c8+c9-c10)"
lab var c12 "Net value - Opening"
lab var c13 "Net value - closing"

lab var d1 "Type of working capital"
lab var d3 "Working capital - Opening"
lab var d4 "Working capital - Closing"

lab var e1 "Type of worker"
lab var e3 "Days worked - manufacturing"
lab var e4 "Days worked - non manufacturing"
lab var e5 "Days worked - Total"
lab var e6 "Average number of people worked"
lab var e7 "Number of days paid for"
lab var e8 "Wages/salaries"
lab var e9 "Bonus"
lab var e10 "Contribution to provident fund and other funds"
lab var e11 "Welfare expenses"

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

lab var h1 "Product purchased (domestic)"
lab var h3 "Item code"
lab var h4 "Unit of quantity"
lab var h5 "Quantity consumed"
lab var h6 "Purchase value"
lab var h7 "Rate per unit (price)"

lab var i1 "Product purchased (imported)"
lab var i3 "Item code"
lab var i4 "Unit of quantity"
lab var i5 "Quantity consumed"
lab var i6 "Purchase value"
lab var i7 "Rate per unit (price)"

lab var j1 "Product sold"
lab var j3 "Item code"
lab var j4 "Unit of quantity"
lab var j5 "Quantity manufactured"
lab var j6 "Quantity sold"
lab var j7 "Gross sale value"
lab var j8 "Goods and service tax"
lab var j9 "excise duty"
lab var j10 "Others"
lab var j11 "Subsidy"
lab var j12 "Per unit sale value (price)"
lab var j13 "ex-factory value of quantity (unit cost?)"
lab var j14 "Total"

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
lab values b3 b3

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

save "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data_Raw\ASI_Raw.dta", replace

