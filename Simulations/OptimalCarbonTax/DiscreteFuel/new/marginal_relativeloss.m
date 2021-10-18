% Function that returns the relative marginal effects of fuel prices on the
% price index (delP/delp_d)/(delP/delp_c)
function marg_rel_loss = marginal_relativeloss(param,omega,Ad,Ac,model)
sig = param(1);
mu = param(2);
N_d = param(3);
N_c = param(4);
kap = param(5);
rho = param(6);
gam_rho = param(7);
p_d = param(8);
p_c = param(9);

if model == 0
    marg_rel_loss = (p_d/p_c)^rho;
elseif model == 1
    marg_rel_loss = ((p_d/p_c)^rho)*(((1-rho)*Ad-N_d*(omega^rho))/((1-rho)*Ac-N_d*(omega^rho)));
end
marg_rel_loss = marg_rel_loss;
end

