clear;
%cd 'C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Simulations\OptimalCarbonTax\DiscreteFuel\new'
cd 'D:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Simulations\OptimalCarbonTax\DiscreteFuel\new'

% Parameters

%p_d = 3.08; % price of coal
%p_c = 19.8; % price of natural gas
p_d = 2;
p_c = 1;
sig = 1.6; % standard deviation of log productivity
mu = 0.92; % mean of log productivity
N_d = 0.2; % fraction of firms initially using natural gas
N_c = 0.8; % fraction of firms initially using coal
kap = 6; % fixed cost of adjustment
rho = 2; % Elasticity of substitution between varieties
gamma_d = 0.850; % kg CO2e of 1 mmbtu of coal
gamma_c = 0.108; % kg CO2e of 1 mmbtu of natural gas 
gam_rho = ((rho-1)/rho)^(rho-1)-((rho-1)/rho)^rho;
gamma_carbon = 2.046%/10; % parameters that mape CO2e to a loss functions (externality)
%alph = 0.4 ;% Degree of returns to scale
%gam_alph = (alph^(alph/(1-alph)))-(alph^(1/(1-alph)));

param = [sig;mu;N_d;N_c;kap;rho;gam_rho;p_d;p_c];
pd = p_d^(1-rho);
pc = p_c^(1-rho);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% AGGREGATE PRICE INDEX %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw firms (productivity)
ndraw = 100000;
rng(420);
A = lognrnd(mu,sig,ndraw,1);

% Solve for price index under switching model
model = 1;
f = @(x) find_pind_min(x,param,A,model);
options = optimset('Display','iter');
A_rho = A.^(rho-1);
A_uncond = mean(A_rho);
x0=(A_uncond*(N_d*pd+N_c*pc))^(1/(1-rho)); % initial guess
[pind_s,squared_diff,output] = fmincon(f,x0,[],[],[],[],0.0,[],[],options);
%[pind_s(i,j),squared_diff,output] = fminsearch(f,x0,options);
% for i = 1:100
%     for j = 1:10
%         p_d = i%100%1+i*10
%         p_c = 1
%         kap = j
%         param = [sig;mu;N_d;N_c;kap;rho;gam_rho;p_d;p_c];
%         [pind_s(i,j),squared_diff,output] = fminsearch(f,x0,options);
%         [Ad_s(i,j),Ac_s(i,j),pind_s(i,j)] = simul_aggpriceindex(param,A,pind_s(i,j),1);
%         [Ad_ns(i,j),Ac_ns(i,j),pind_ns(i,j)] = simul_aggpriceindex(param,A,pind_s(i,j),0);
%     end
% end
% get aggregate productivity 
[Ad_s,Ac_s,pind_s] = simul_aggpriceindex(param,A,pind_s,model);

% Solve for price index under no switching model
model = 0;
% get aggregate productivity and price index
[Ad_ns,Ac_ns,pind_ns] = simul_aggpriceindex(param,A,pind_s,model);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% AGGREGATE GHG EMISSIONS %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Switching %%%
Ed_s = Ad_s*((rho-1)/rho)*((pind_s/p_d)^rho)*(1/pind_s);
Ec_s = Ac_s*((rho-1)/rho)*((pind_s/p_c)^rho)*(1/pind_s);
% emissions
ghg_s = gamma_d*Ed_s + gamma_c*Ec_s;
% output without loss from externality
Y_s = 1/pind_s;
% output with loss from externality
Y_s_real = (1/pind_s)*(exp(-gamma_carbon*ghg_s));
%%% No switching %%%
Ed_ns = Ad_ns*((rho-1)/rho)*((pind_ns/p_d)^rho)*(1/pind_ns);
Ec_ns = Ac_ns*((rho-1)/rho)*((pind_ns/p_c)^rho)*(1/pind_ns);
% emissions
ghg_ns = gamma_d*Ed_ns + gamma_c*Ec_ns;
% output without loss from externality
Y_ns = 1/pind_ns;
% output with loss from externality
Y_ns_real = (1/pind_ns)*(exp(-gamma_carbon*ghg_ns));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SIMULATION OF OPTIMAL TAX %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param_noprice = [sig;mu;N_d;N_c;kap;rho;gam_rho];
gammas = [gamma_d;gamma_c;gamma_carbon];
% Guess of optimal prices 
pfuel = [p_d;p_c];

%%% Solve for optimal fuel prices (tax) %%%
% No switching
model = 0;
f = @(x) simul_optimtax_func(param_noprice,gammas,x,A,model);
options = optimset('Display','iter');
x0=pfuel; % initial guess (current fuel prices)
lb = [0.0;0.0];
[pfuel_optim_ns,gov_obj_func,output] = fmincon(f,x0,[],[],[],[],lb,[],[],options);
pd_optim_ns = pfuel_optim_ns(1);
pc_optim_ns = pfuel_optim_ns(2);
param_ns = [sig;mu;N_d;N_c;kap;rho;gam_rho;pd_optim_ns;pc_optim_ns];
[Ad_ns_optim,Ac_ns_optim,pind_ns_optim] = simul_aggpriceindex(param_ns,A,pind_s,model);
Ed_ns_optim = Ad_ns_optim*((rho-1)/rho)*((pind_ns_optim/pd_optim_ns)^rho)*(1/pind_ns_optim);
Ec_ns_optim = Ac_ns_optim*((rho-1)/rho)*((pind_ns_optim/pc_optim_ns)^rho)*(1/pind_ns_optim);
ghg_ns_optim = gamma_d*Ed_ns_optim + gamma_c*Ec_ns_optim; % emissions
Y_ns_optim = 1/pind_ns_optim; % Output (no externality)
Y_ns_optim_real = (1/pind_ns_optim)*(exp(-gamma_carbon*ghg_ns_optim)); % Output (externality)

% Switching
model = 1;
for i = 2:50
    kap = i;
    param_noprice = [sig;mu;N_d;N_c;kap;rho;gam_rho];
    f = @(x) simul_optimtax_func(param_noprice,gammas,x,A,model);
    options = optimset('Display','iter');
    x0=pfuel; % initial guess (current fuel prices)
    lb = [0.0;0.0];
    %ub = [10.0,10.0];
    [pfuel_optim_s,gov_obj_func,output] = fmincon(f,x0,[],[],[],[],lb,[],[],options);
    pd_optim_s(i,1) = pfuel_optim_s(1);
    pc_optim_s(i,1) = pfuel_optim_s(2);
    param_s = [sig;mu;N_d;N_c;kap;rho;gam_rho;pd_optim_s(i,1);pc_optim_s(i,1)];
    [Ad_s_optim,Ac_s_optim,pind_s_optim] = simul_aggpriceindex(param_s,A,pind_s,model);
    Ed_s_optim = Ad_s_optim*((rho-1)/rho)*((pind_s_optim/pd_optim_s(i,1))^rho)*(1/pind_s_optim);
    Ec_s_optim = Ac_s_optim*((rho-1)/rho)*((pind_s_optim/pc_optim_s(i,1))^rho)*(1/pind_s_optim);
    ghg_s_optim = gamma_d*Ed_s_optim + gamma_c*Ec_s_optim; % emissions
    Y_s_optim(i,1) = 1/pind_s_optim; % Output (no externality)
    Y_s_optim_real(i,1) = (1/pind_s_optim)*(exp(-gamma_carbon*ghg_s_optim)); % Output (externality)
end

% Graphs
for i = 1:49
    kap(i,1) = i+1;
end
rel_p = pd_optim_s./pc_optim_s;
rel_p = smooth(rel_p);
for i = 1:49
    y(i) = pd_optim_ns/pc_optim_ns;
end
plot(kap,rel_p(2:end,1),'-',kap,y,'--')
hold on`
xlabel('Fixed switching cost')
ylabel('Relative price (tax) of dirty fuel') 
hold off
set(gcf,'Color','w');

relY = Y_s_optim(2:50)-Y_s_optim_real(2:50);
relY = smooth(relY);
plot(kap,relY,'-')
%plot(kap,Y_s_optim(2:50),'--',kap,Y_s_optim_real(2:50),'-')
hold on
xlabel('Fixed switching cost')
ylabel('Output')
legend('Without externality','With externality')
hold off





f = @(x) simul_optimtax_func(param_noprice,gammas,x,A,model);
options = optimset('Display','iter');
x0=pfuel; % initial guess (current fuel prices)
lb = [0.0;0.0];
[pfuel_optim_s,gov_obj_func,output] = fmincon(f,x0,[],[],[],[],lb,[],[],options);
%[pfuel_optim_s,gov_obj_func,output] = simulannealbnd(f,x0,0.0,[],options);
pd_optim_s = pfuel_optim_s(1);
pc_optim_s = pfuel_optim_s(2);
param_s = [sig;mu;N_d;N_c;kap;rho;gam_rho;pd_optim_s;pc_optim_s];
[Ad_s_optim,Ac_s_optim,pind_s_optim] = simul_aggpriceindex(param_s,A,pind_s,model);
Ed_s_optim = Ad_s_optim*((rho-1)/rho)*((pind_s_optim/pd_optim_s)^rho)*(1/pind_s_optim);
Ec_s_optim = Ac_s_optim*((rho-1)/rho)*((pind_s_optim/pc_optim_s)^rho)*(1/pind_s_optim);
ghg_s_optim = gamma_d*Ed_s_optim + gamma_c*Ec_s_optim; % emissions
Y_s_optim = 1/pind_s_optim; % Output (no externality)
Y_s_optim_real = (1/pind_s_optim)*(exp(-gamma_carbon*ghg_s_optim)); % Output (externality)
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% INVESTIGATION OF FACTORS DRIVING OPTIMAL TAX %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Case of no switching %%%
model = 0;
p_c(1,1) = pc_optim_ns;
p_c(1,2) = p_c(1,1)+0.01;
p_d(1,1) = 2*pc_optim_ns;
p_d(2,1) = p_d(1)*1.5;
for i = 3:50
    for j = 1:2
        p_d(i,1) = p_d(i-1)+p_d(i-1)-p_d(i-2);
        p_rel(i,1) = p_d(i)/p_c(1,j);
    end
end
for i = 1:50
   for j = 1:2
       param = [sig;mu;N_d;N_c;kap;rho;gam_rho;p_d(i,1);p_c(1,j)];
       [Ad_ns(i,j),Ac_ns(i,j),pind_ns(i,j)] = simul_aggpriceindex(param,A,1.0,model);
       marg_rel_loss(i,j) = marginal_relativeloss(param,1.0,Ad_ns(i,j),Ac_ns(i,j),model);
       marg_rel_gain(i,j) = marginal_relativegain(param,1.0,Ad_ns(i,j),Ac_ns(i,j),pind_ns(i,j),gammas,model);
       Ed_ns(i,j) = Ad_ns(i,j)*((rho-1)/rho)*((pind_ns(i,j)/p_d(i,1))^rho)*(1/pind_ns(i,j));
       Ec_ns(i,j) = Ac_ns(i,j)*((rho-1)/rho)*((pind_ns(i,j)/p_c(1,j))^rho)*(1/pind_ns(i,j));
       % emissions
       ghg_ns(i,j) = gamma_d*Ed_ns(i,j) + gamma_c*Ec_ns(i,j);
   end
end
delG_delpd_ns = gradient(ghg_ns(:,1))./gradient(p_d(:));
delP_delpd_ns = gradient(pind_ns(:,1))./gradient(p_d(:));
for i = 1:50
    delG_delpc_ns(i,:) = gradient(ghg_ns(i,:))./gradient(p_c(1,:));
    delP_delpc_ns(i,:) = gradient(pind_ns(i,:))./gradient(p_c(1,:));
end
marg_rel_G = delG_delpd_ns./delG_delpc_ns(:,1);
marg_rel_P = delP_delpd_ns./delP_delpc_ns(:,1);

plot(p_rel,marg_rel_G,'-o',p_rel,marg_rel_P,'b--o')

%%% Case of switching %%%
model = 1;
p_c(1,1) = pc_optim_s;
p_d(1,1) = 2*pc_optim_s;
p_d(2,1) = p_d(1)*1.5;
p_guess = 0.3;
for i = 3:50
    p_d(i,1) = p_d(i-1)+p_d(i-1)-p_d(i-2);
    p_rel(i,1) = p_d(i)/p_c;
end
for i = 1:50
   param = [sig;mu;N_d;N_c;kap;rho;gam_rho;p_d(i,1);p_c];
   [Ad_s(i,1),Ac_s(i,1),pind_s(i,1),omega_s(i,1)] = simul_aggpriceindex(param,A,p_guess,model);
   Ed_s(i,1) = Ad_s(i,1)*((rho-1)/rho)*((pind_s(i,1)/p_d(i,1))^rho)*(1/pind_s(i,1));
   Ec_s(i,1) = Ac_s(i,1)*((rho-1)/rho)*((pind_s(i,1)/p_c)^rho)*(1/pind_s(i,1));
   % emissions
   ghg_s(i,1) = gamma_d*Ed_s(i,1) + gamma_c*Ec_s(i,1);
   %marg_rel_loss(i,1) = marginal_relativeloss(param,omega_s(i,1),Ad_s(i,1),Ac_s(i,1),model);
   %marg_rel_gain(i,1) = marginal_relativegain(param,omega_s(i,1),Ad_s(i,1),Ac_s(i,1),pind_s(i,1),gammas,model)
end
delG_delpd_s = gradient(ghg_s(:))./gradient(p_d(:))
delP_delpd_s = gradient(pind_s(:))./gradient(p_d(:))

plot(p_d,delG_delpd_s,'-',p_d,delG_delpd_ns,'b--')
plot(p_d,delP_delpd_s,'-',p_d,delP_delpd_ns,'b--')




% Optimal taxation for different values of the elasticity of substitution
% across industries 
rhos = [1.2;2;3;4;5;6;7;8;9;10];
for i = 1:10
    rho = rho(i);
    
    param = [sig;mu;N_d;N_c;kap;rho;gam_rho;p_d;p_c];
    pd = p_d^(1-rho);
    pc = p_c^(1-rho);
end





xaxis = [3;2;1.5];
plot(xaxis,Y_bottomup(2,1:3),'-o',xaxis,Y_bottomup(3,1:3),'b--o')
hold on
xlabel('gross relative price (natural gas/coal)')
ylabel('Aggregate output')
legend('Carbon tax','Coal tax')
hold off
set(gcf,'Color','w');
saveas(gcf, 'Relprice_Output.pdf')
axes.SortMethod='ChildOrder'
export_fig Relprice_Output.pdf

plot(xaxis,profit(2,1:3),'-o',xaxis,profit(3,1:3),'b--o')
hold on
xlabel('gross relative price (natural gas/coal)')
ylabel('Profits')
legend('Carbon tax','Coal tax')
hold off
set(gcf,'Color','w');
saveas(gcf,'Relprice_Profits.pdf')
axes.SortMethod='ChildOrder'
export_fig Relprice_Profits.pdf

plot(xaxis,prop_switch(2,1:3),'-o',xaxis,prop_switch(3,1:3),'b--o')
hold on
xlabel('gross relative price (natural gas/coal)')
ylabel('Probability of switching from natural gas to coal')
legend('Carbon tax','Coal tax')
hold off
set(gcf,'Color','w');
saveas(gcf,'Relprice_Switch.pdf')
axes.SortMethod='ChildOrder'
export_fig Relprice_Switch.pdf

plot(xaxis,p_rel_input(1:3,1),'-o',xaxis,p_rel_input(1:3,2),'b--o',xaxis,[1;1;1],':')
hold on
xlabel('gross relative price (natural gas/coal)')
ylabel('Net of tax relative price (natural gas/coal)')
legend('Carbon tax','Coal tax')
hold off
set(gcf,'Color','w');
saveas(gcf,'RelpriceGross_RelpriceNet.pdf')
axes.SortMethod='ChildOrder'
export_fig RelpriceGross_RelpriceNet.pdf


% % Draws from productivity distribution (conditional and unconditional)
% ndraw = 10000;
% A = lognrnd(mu,sig,ndraw,1);
% A_alph = A.^(1/(1-alph));
% EA_uncond = mean(A_alph);
% 
% %tau = 1.012;
% %p_c = (1+2*tau)*1; 
% %p_n = (1+tau)*2;
% p_c = 1;
% p_n = 2;
% 
% %tau = 1.5;
% %p_c=(1+tau)*1;
% %p_n = 2;
% 
% %tau = 0.8
% %p_c = (1+tau)*1;
% %p_n = (1-0.5596)*3;
% % Simulating productivity threshold under no tax
% if p_n > p_c
%     p_rel = p_c^(alph/(alph-1))-p_n^(alph/(alph-1));
% elseif p_n < p_c 
%     p_rel = p_n^(alph/(alph-1))-p_c^(alph/(alph-1));
% end
% if p_n == p_c
%     gamma = 1;
% else
%     gamma = ((kap/gam_alph)*(1/p_rel))^(1-alph);
% end
% mask_above = (A > gamma);
% mask_below = (A <= gamma);
% EA_above = mean(A_alph(mask_above(:,1),:),1);
% EA_below = mean(A_alph(mask_below(:,1),:),1);
% % Aggregate input quantities
% if p_n > p_c
%     Kn = N_n*logncdf(gamma,mu,sig)*EA_below*((alph/p_n)^(1/(1-alph)));
%     Kc = N_c*EA_uncond*((alph/p_c)^(1/(1-alph)))+ N_n*(1-logncdf(gamma,mu,sig))*EA_above*((alph/p_c)^(1/(1-alph)));
% elseif p_n < p_c
%     Kc = N_c*logncdf(gamma,mu,sig)*EA_below*((alph/p_c)^(1/(1-alph)));
%     Kn = N_n*EA_uncond*((alph/p_n)^(1/(1-alph)))+ N_c*(1-logncdf(gamma,mu,sig))*EA_above*((alph/p_n)^(1/(1-alph)));
% end
% % GHG emissions under no tax
% ghg = Kn+2*Kc
% 
% % Aggregate output and profits
% for i = 1:ndraw
%     % Individual profits, input choices and output quantity
%     pi_c1(i,1) = ((A(i,1)/p_c)^(1/(1-alph)))*p_c*gam_alph;
%     pi_c2(i,1) = ((A(i,1)/p_c)^(1/(1-alph)))*p_c*gam_alph-kap;
%     pi_n1(i,1) = ((A(i,1)/p_n)^(1/(1-alph)))*p_n*gam_alph-kap;
%     pi_n2(i,1) = ((A(i,1)/p_n)^(1/(1-alph)))*p_n*gam_alph;
%     if pi_c1(i,1) > pi_n1(i,1)
%         pi_1(i,1) = pi_c1(i,1);
%         kc_ind1(i,1) = (alph*A(i,1)/p_c)^(1/(1-alph));
%         kn_ind1(i,1) = 0;
%         y1(i,1) = A(i,1)*(kc_ind1(i,1)^alph);
%     else
%         pi_1(i,1) = pi_n1(i,1);
%         kc_ind1(i,1) = 0;
%         kn_ind1(i,1) = (alph*A(i,1)/p_n)^(1/(1-alph));
%         y1(i,1) = A(i,1)*(kn_ind1(i,1)^alph);
%     end
%     if pi_c2(i,1) > pi_n2(i,1)
%         pi_2(i,1) = pi_c2(i,1);
%         kc_ind2(i,1) = (alph*A(i,1)/p_c)^(1/(1-alph));
%         kn_ind2(i,1) = 0;
%         y2(i,1) = A(i,1)*(kc_ind2(i,1)^alph);
%     else
%         pi_2(i,1) = pi_n2(i,1);
%         kc_ind2(i,1) = 0;
%         kn_ind2(i,1) = (alph*A(i,1)/p_n)^(1/(1-alph));
%         y2(i,1) = A(i,1)*(kn_ind2(i,1)^alph);
%     end
% end
% Kc_bottomup = N_c*mean(kc_ind1(:,1),1)+N_n*mean(kc_ind2(:,1),1);
% Kn_bottomup = N_c*mean(kn_ind1(:,1),1)+N_n*mean(kn_ind2(:,1),1);
% PI_bottomup = N_c*mean(pi_1(:,1),1)+N_n*mean(pi_2(:,1),1)
% Y_bottomup = N_c*mean(y1(:,1),1)+N_n*mean(y2(:,1),1)
% 
% 
% 
% 
% 
% xaxis = p_c-p_n;
% plot(xaxis,Y_bottomup(:,1),xaxis,Y_bottomup(:,2),'--')
% %plot(xaxis,Y_bottomup(:,1),xaxis,Y_bottomup(:,2),xaxis,Y_bottomup(:,3),xaxis,Y_bottomup(:,4));