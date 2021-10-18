*--------------------------------------------------------
* Clean ASI Data and Create some Descriptive Statistics 
*--------------------------------------------------------

*----------------
* Initial Set Up
*----------------
cls
clear all
version 13
set maxvar 10000
set type double
set more off

* File path
* Laptop
*cd "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI"
*local DATAPATH = "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data"
* Desktop
cd "D:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI"
local DATAPATH = "D:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data"

*--------------
* Use raw data
*--------------
*use "`DATAPATH'/ASI_Raw.dta",clear
*use "`DATAPATH'/Enterprise_WorldBank_Raw.dta" 
*use "`DATAPATH'/ASI_Clean.dta",clear
*use "`DATAPATH'/NPRI_Canada.dta",clear

*--------------
* Clean data
*-------------- 
*do Program_Clean-Data.do

*--------------
* Use clean data
*--------------
*use "`DATAPATH'/ASI_Clean.dta",clear
*use "`DATAPATH'/ASI_Clean_subset.dta",clear
*use "`DATAPATH'/ASI_CleanBalanced.dta",clear
use "`DATAPATH'/ASI_CleanPartiallyBalanced.dta",clear
*use "`DATAPATH'/NPRI_Clean.dta",clear


*--------------
* Graphs/Tables
*--------------
*do Graph_Initialyear_Productivity.do
*do Graph_SlowCourts.do
*do GraphTables_Colreq-Enterprise.do
*do GraphsTables_Colreq-ASI.do
*do Graphs_FossilFuels-ASI.do // (Uses clean_substet data)
do Graphs_FossilFuels-Switching.do // (Use balanced panel)
*do Graphs_Emissions-NPRI_ASI.do
*do GeoGraph_FuelDist-ASI.do


