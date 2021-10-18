* Data directory
global ASIpaneldir Data/Panel_Data/Clean_data

* Import data and set panel
use Data/Panel_Data/Clean_data/ASI_PanelSwitchin-Allind, clear
xtset IDnum year
set scheme burd

* Fuel quantities (assuming median price for everyone)
foreach fuel in coal oil gas elecb {
	su p`fuel'_mmbtu, detail
	gen pmedian_`fuel' = r(p50)
	replace `fuel'_mmbtu = `fuel'/pmedian_`fuel'
}
* Fuel shares
replace energy_mmbtu = coal_mmbtu + oil_mmbtu + gas_mmbtu + elecb_mmbtu
foreach fuel in coal oil gas {
	replace s_`fuel' = `fuel'_mmbtu/energy_mmbtu
}
gen s_elec = elecb_mmbtu/energy_mmbtu
* Share frequency (discrete gaps of 0.1 --> under the assumption of 10 tasks)
mat ShareFreq = J(11,4,.)
su s_coal if s_coal == 0
mat ShareFreq[1,1] = r(N)/_N
su s_coal if s_coal <= 0.1 & s_coal > 0
mat ShareFreq[2,1] = r(N)/_N
su s_coal if s_coal <= 0.2 & s_coal > 0.1
mat ShareFreq[3,1] = r(N)/_N
su s_coal if s_coal <= 0.3 & s_coal > 0.2
mat ShareFreq[4,1] = r(N)/_N
su s_coal if s_coal <= 0.4 & s_coal > 0.3
mat ShareFreq[5,1] = r(N)/_N
su s_coal if s_coal <= 0.5 & s_coal > 0.4
mat ShareFreq[6,1] = r(N)/_N
su s_coal if s_coal <= 0.6 & s_coal > 0.5
mat ShareFreq[7,1] = r(N)/_N
su s_coal if s_coal <= 0.7 & s_coal > 0.6
mat ShareFreq[8,1] = r(N)/_N
su s_coal if s_coal <= 0.8 & s_coal > 0.7
mat ShareFreq[9,1] = r(N)/_N
su s_coal if s_coal <= 0.9 & s_coal > 0.8
mat ShareFreq[10,1] = r(N)/_N
su s_coal if s_coal <= 1 & s_coal > 0.9
mat ShareFreq[11,1] = r(N)/_N

su s_oil if s_oil == 0
mat ShareFreq[1,2] = r(N)/_N
su s_oil if s_oil <= 0.1 & s_oil > 0
mat ShareFreq[2,2] = r(N)/_N
su s_oil if s_oil <= 0.2 & s_oil > 0.1
mat ShareFreq[3,2] = r(N)/_N
su s_oil if s_oil <= 0.3 & s_oil > 0.2
mat ShareFreq[4,2] = r(N)/_N
su s_oil if s_oil <= 0.4 & s_oil > 0.3
mat ShareFreq[5,2] = r(N)/_N
su s_oil if s_oil <= 0.5 & s_oil > 0.4
mat ShareFreq[6,2] = r(N)/_N
su s_oil if s_oil <= 0.6 & s_oil > 0.5
mat ShareFreq[7,2] = r(N)/_N
su s_oil if s_oil <= 0.7 & s_oil > 0.6
mat ShareFreq[8,2] = r(N)/_N
su s_oil if s_oil <= 0.8 & s_oil > 0.7
mat ShareFreq[9,2] = r(N)/_N
su s_oil if s_oil <= 0.9 & s_oil > 0.8
mat ShareFreq[10,2] = r(N)/_N
su s_oil if s_oil <= 1 & s_oil > 0.9
mat ShareFreq[11,2] = r(N)/_N

su s_gas if s_gas == 0
mat ShareFreq[1,3] = r(N)/_N
su s_gas if s_gas <= 0.1 & s_gas > 0
mat ShareFreq[2,3] = r(N)/_N
su s_gas if s_gas <= 0.2 & s_gas > 0.1
mat ShareFreq[3,3] = r(N)/_N
su s_gas if s_gas <= 0.3 & s_gas > 0.2
mat ShareFreq[4,3] = r(N)/_N
su s_gas if s_gas <= 0.4 & s_gas > 0.3
mat ShareFreq[5,3] = r(N)/_N
su s_gas if s_gas <= 0.5 & s_gas > 0.4
mat ShareFreq[6,3] = r(N)/_N
su s_gas if s_gas <= 0.6 & s_gas > 0.5
mat ShareFreq[7,3] = r(N)/_N
su s_gas if s_gas <= 0.7 & s_gas > 0.6
mat ShareFreq[8,3] = r(N)/_N
su s_gas if s_gas <= 0.8 & s_gas > 0.7
mat ShareFreq[9,3] = r(N)/_N
su s_gas if s_gas <= 0.9 & s_gas > 0.8
mat ShareFreq[10,3] = r(N)/_N
su s_gas if s_gas <= 1 & s_gas > 0.9
mat ShareFreq[11,3] = r(N)/_N

su s_elec if s_elec == 0
mat ShareFreq[1,4] = r(N)/_N
su s_elec if s_elec <= 0.1 & s_elec > 0
mat ShareFreq[2,4] = r(N)/_N
su s_elec if s_elec <= 0.2 & s_elec > 0.1
mat ShareFreq[3,4] = r(N)/_N
su s_elec if s_elec <= 0.3 & s_elec > 0.2
mat ShareFreq[4,4] = r(N)/_N
su s_elec if s_elec <= 0.4 & s_elec > 0.3
mat ShareFreq[5,4] = r(N)/_N
su s_elec if s_elec <= 0.5 & s_elec > 0.4
mat ShareFreq[6,4] = r(N)/_N
su s_elec if s_elec <= 0.6 & s_elec > 0.5
mat ShareFreq[7,4] = r(N)/_N
su s_elec if s_elec <= 0.7 & s_elec > 0.6
mat ShareFreq[8,4] = r(N)/_N
su s_elec if s_elec <= 0.8 & s_elec > 0.7
mat ShareFreq[9,4] = r(N)/_N
su s_elec if s_elec <= 0.9 & s_elec > 0.8
mat ShareFreq[10,4] = r(N)/_N
su s_elec if s_elec <= 1 & s_elec > 0.9
mat ShareFreq[11,4] = r(N)/_N


