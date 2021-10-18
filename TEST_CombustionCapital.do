forvalues i = 1/10 {
	gen npcms_3d`i' = int(int(int(int(npcmsInput`i'/10)/10)/10)/10)
}
forvalues i = 1/5 {
	gen npcms_3d_import`i' = int(int(int(int(npcmsImport`i'/10)/10)/10)/10)
}

gen combust_k = 0
forvalues i = 1/10 {
	replace combust_k = 1 if npcms_3d`i' == 434
}
forvalues i = 1/5 {
	replace combust_k = 1 if npcms_3d_import`i' == 434
}
