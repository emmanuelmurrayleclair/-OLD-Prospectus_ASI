% This function returns the government's objective function given current 
% guess of fuel prices
function gov_obj = simul_optimtax_func(param_noprice,gammas,pfuel,A,model)
p_d = pfuel(1);
p_c = pfuel(2);
param = [param_noprice;p_d;p_c];
gamma_d = gammas(1);
gamma_c = gammas(2);
gamma_carbon = gammas(3);
sig = param(1);
mu = param(2);
N_d = param(3);
N_c = param(4);
kap = param(5);
rho = param(6);
gam_rho = param(7);

%%% Aggregate ouput (1/P) %%%
if model == 1
    f = @(x) find_pind_min(x,param,A,model);
    options = optimset('Display','iter');
    x0=2.0;
    [pind,squared_diff,output] = fmincon(f,x0,[],[],[],[],0.1,[],[],options);
    %[pind,squared_diff,output] = fminsearch(f,x0,options);
    %[pind,squared_diff,output] = simulannealbnd(f,x0,0.0,[],options);
    % get aggregate productivity 
    [Ad,Ac,pind] = simul_aggpriceindex(param,A,pind,model);
elseif model == 0
    [Ad,Ac,pind] = simul_aggpriceindex(param,A,1.0,model);
end

%%% GHG emissions %%%
Ed = Ad*((rho-1)/rho)*((pind/p_d)^rho)*(1/pind);
Ec = Ac*((rho-1)/rho)*((pind/p_c)^rho)*(1/pind);
ghg = gamma_d*Ed + gamma_c*Ec;

%%% Return objective function %%%
gov_obj = -(1/pind)*(exp(-gamma_carbon*ghg));
end

