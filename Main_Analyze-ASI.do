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
cd "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI"
local DATAPATH = "C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Data"

*--------------
* Use raw data
*--------------
use "`DATAPATH'/ASI_Raw.dta",clear

*--------------
* Use clean data
*--------------
use "`DATAPATH'/ASI_Raw.dta",clear

*--------------
* Graphs
*--------------
do Graph_Initialyear_Productivity.do

