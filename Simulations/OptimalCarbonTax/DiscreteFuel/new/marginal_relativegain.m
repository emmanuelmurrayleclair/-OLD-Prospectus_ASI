% Function that returns the relative marginal effects of fuel prices on
% aggregate ghg emissions (delGHG/delp_d)/(delGHG/delp_c)
function marg_rel_gain = marginal_relativegain(param,omega,Ad,Ac,pind,gammas,model)
sig = param(1);
mu = param(2);
N_d = param(3);
N_c = param(4);
kap = param(5);
rho = param(6);
gam_rho = param(7);
p_d = param(8);
p_c = param(9);
gamma_d = gammas(1);
gamma_c = gammas(2);

if model == 0
    ghg_p = gamma_d^(p_d^(-rho))+gamma_c^(p_c^(-rho));
    p_rel = (p_d^(1-rho)+p_c^(1-rho));
    marg_rel_gain = ((p_d/p_c)^rho)*((ghg_p-(gamma_d/(p_d*p_rel)))/(ghg_p-(gamma_c/(p_c*p_rel))));
elseif model == 1
    ghg_p = gamma_d^(p_d^(-rho))+gamma_c^(p_c^(-rho));
    p_rel = ((p_d^(1-rho))*Ad+(p_c^(1-rho))*Ac);
    delP_delpd = (pind*(p_rel^rho)*((p_d^(-rho))*((1-rho)*Ad + N_d*(omega^rho))))/((1-rho)-(p_rel^rho)*(p_c^(1-rho)-p_c^(1-rho))*N_d*(omega^rho));
    delP_delpc = (pind*(p_rel^rho)*((p_c^(-rho))*((1-rho)*Ac - N_d*(omega^rho))))/((1-rho)-(p_rel^rho)*(p_c^(1-rho)-p_c^(1-rho))*N_d*(omega^rho));
    gbar = gamma_d*(p_d^(-rho))*Ad+gamma_c*(p_c^(-rho))*Ac
    marg_rel_gain_numerator = delP_delpd*(1/pind)*((rho-1)*gbar + N_d*(omega^rho)*ghg_p) + ((N_d*(omega^rho)*ghg_p)/((p_d^rho)*(p_c^(1-rho)-p_d^(1-rho))))-(gamma_d*(p_d^(-rho-1))*Ad);
    marg_rel_gain_denom = delP_delpc*(1/pind)*((rho-1)*gbar + N_d*(omega^rho)*ghg_p) + ((N_d*(omega^rho)*ghg_p)/((p_c^rho)*(p_c^(1-rho)-p_d^(1-rho))))-(gamma_c*(p_c^(-rho-1))*Ac);
    marg_rel_gain = marg_rel_gain_numerator/marg_rel_gain_denom;
end
marg_rel_gain = marg_rel_gain;
end

