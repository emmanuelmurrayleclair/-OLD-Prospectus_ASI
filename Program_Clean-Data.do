**************************
* Construct Summary Info
**************************

*------------------
* Clean the dataset
*------------------

* Set labels
*do Set_Labels-ASI.do

* Clean variable names, industry concordance
*do Set_VarCleaning.do

*--------------------------------------------
* Add various information from other sources
*--------------------------------------------

* Information on court speed and court history
*do Set_SlowCourts.do
*do Set_FinConstraint.do

*Industry concordance b etween NIC-08 and NAICS
do Set_NIC-NAICS_concordance.do



*------------------
* Save dataset
*------------------
*save "Data/ASI_Clean_full.dta", replace
*save "Data/ASI_Clean_subset.dta", replace
save "Data/NPRI_Clean.dta", replace