clear;
cd 'C:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Simulations\OptimalCarbonTax\DiscreteFuel'

% Parameters
p_n = reshape(1:0.5:5,1,[])';
np = size(p_n,1);
p_c = reshape(sort(1:0.5:5,'descend'),1,[])';
%p_c = zeros(np,1)+2;
%pn = 0.5;
%p_c = reshape(0.5:0.1:2,1,[])';
%p_c = reshape(0.1:0.01:1,1,[])';
np = size(p_n,1);
sig = 2; % variance of normal distr
mu = 0; % mean of normal distr
N_n = 0.4; % fraction of firms currently using natural gas
N_c = 0.6; % fraction of firms currently using coal
kap = 1; % fixed cost of adjustment
alph = 0.4 ;% Degree of returns to scale
gam_alph = (alph^(alph/(1-alph)))-(alph^(1/(1-alph)));

param = [np;sig;mu;N_n;N_c;kap;alph;gam_alph];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SIMULATION UNDER NO TAX %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simulating productivity threshold under no tax
for i = 1:np
    if p_n(i,1) > p_c(i,1)
        p_rel(i,1) = p_c(i,1)^(alph/(alph-1))-p_n(i,1)^(alph/(alph-1));
        gamma(i,1) = ((kap/gam_alph)*(1/p_rel(i,1)))^(1-alph);
        %K_n(i,1) = (logncdf(gamma(i,1),mu,sigma)*N_n)
    elseif p_n(i,1) == p_c(i,1)
        p_rel(i,1) = p_n(i,1)^(alph/(alph-1))-p_c(i,1)^(alph/(alph-1));
        gamma(i,1) = 1;
    else
        p_rel(i,1) = p_n(i,1)^(alph/(alph-1))-p_c(i,1)^(alph/(alph-1));
        gamma(i,1) = ((kap/gam_alph)*(1/p_rel(i,1)))^(1-alph);
    end
end
% Draws from productivity distribution (conditional and unconditional)
ndraw = 10000;
rng(420);
A = lognrnd(mu,sig,ndraw,1);
A_alph = A.^(1/(1-alph));
EA_uncond = mean(A_alph);
for i = 1:np
    mask_above(:,i) = (A > gamma(i,1));
    mask_below(:,i) = (A <= gamma(i,1));
    EA_above(i,1) = mean(A_alph(mask_above(:,i),:),1);
    EA_below(i,1) = mean(A_alph(mask_below(:,i),:),1);
end
% Aggregate input quantities under no tax
for i = 1:np
    if p_n(i,1) > p_c(i,1)
        Kn_ur(i,1) = N_n*logncdf(gamma(i,1),mu,sig)*EA_below(i,1)*((alph/p_n(i,1))^(1/(1-alph)));
        Kc_ur(i,1) = N_c*EA_uncond*((alph/p_c(i,1))^(1/(1-alph)))+ N_n*(1-logncdf(gamma(i,1),mu,sig))*EA_above(i,1)*((alph/p_c(i,1))^(1/(1-alph)));
    elseif p_n(i,1) == p_c(i,1)
        Kn_ur(i,1) = N_n*EA_uncond*((alph/p_n(i,1))^(1/(1-alph)));
        Kc_ur(i,1) = N_c*EA_uncond*((alph/p_c(i,1))^(1/(1-alph)));
    else
        Kn_ur(i,1) = N_n*EA_uncond*((alph/p_n(i,1))^(1/(1-alph))) + N_c*(1-logncdf(gamma(i,1),mu,sig))*EA_above(i,1)*((alph/p_n(i,1))^(1/(1-alph)));
        Kc_ur(i,1) = N_c*logncdf(gamma(i,1),mu,sig)*EA_below(i,1)*((alph/p_c(i,1))^(1/(1-alph)));
    end
end
% GHG emissions under no tax
for i = 1:np
    ghg_ur(i,1) = Kn_ur(i,1)+2*Kc_ur(i,1);
end
% Aggregate output under no tax
for j = 1:np
    for i = 1:ndraw
        % Individual profits, input choices and output quantity
        pi_c1(i,j) = ((A(i,1)/p_c(j,1))^(1/(1-alph)))*p_c(j,1)*gam_alph;
        pi_c2(i,j) = ((A(i,1)/p_c(j,1))^(1/(1-alph)))*p_c(j,1)*gam_alph-kap;
        pi_n1(i,j) = ((A(i,1)/p_n(j,1))^(1/(1-alph)))*p_n(j,1)*gam_alph-kap;
        pi_n2(i,j) = ((A(i,1)/p_n(j,1))^(1/(1-alph)))*p_n(j,1)*gam_alph;
        if pi_c1(i,j) > pi_n1(i,j)
            pi_1(i,j) = pi_c1(i,j);
            kc_ind1(i,j) = (alph*A(i,1)/p_c(j,1))^(1/(1-alph));
            kn_ind1(i,j) = 0;
            y1(i,j) = A(i,1)*(kc_ind1(i,j)^alph);
        else
            pi_1(i,j) = pi_n1(i,j);
            kc_ind1(i,j) = 0;
            kn_ind1(i,j) = (alph*A(i,1)/p_n(j,1))^(1/(1-alph));
            y1(i,j) = A(i,1)*(kn_ind1(i,j)^alph);
        end
        if pi_c2(i,j) > pi_n2(i,j)
            pi_2(i,j) = pi_c2(i,j);
            kc_ind2(i,j) = (alph*A(i,1)/p_c(j,1))^(1/(1-alph));
            kn_ind2(i,j) = 0;
            y2(i,j) = A(i,1)*(kc_ind2(i,j)^alph);
        else
            pi_2(i,j) = pi_n2(i,j);
            kc_ind2(i,j) = 0;
            kn_ind2(i,j) = (alph*A(i,1)/p_n(j,1))^(1/(1-alph));
            y2(i,j) = A(i,1)*(kn_ind2(i,j)^alph);
        end
    end
    Kc_bottomup(j,1) = N_c*mean(kc_ind1(:,j),1)+N_n*mean(kc_ind2(:,j),1);
    Kn_bottomup(j,1) = N_c*mean(kn_ind1(:,j),1)+N_n*mean(kn_ind2(:,j),1);
    PI_bottomup(j,1) = N_c*mean(pi_1(:,j),1)+N_n*mean(pi_2(:,j),1);
    Y_bottomup(j,1) = N_c*mean(y1(:,j),1)+N_n*mean(y2(:,j),1);
end

% Aggregate output (directly)
for i = 1:np
    if p_c(i,1) > p_n(i,1)
        Y(i,1) = N_c*logncdf(gamma(i,1),mu,sig)*EA_below(i,1)*((alph/p_c(i,1))^(alph/(1-alph)))+(N_n*EA_uncond+N_c*(1-logncdf(gamma(i,1),mu,sig))*EA_above(i,1))*((alph/p_n(i,1))^(alph/(1-alph)));
    elseif p_c(i,1) < p_n(i,1)
        Y(i,1) = N_n*logncdf(gamma(i,1),mu,sig)*EA_below(i,1)*((alph/p_n(i,1))^(alph/(1-alph)))+(N_c*EA_uncond+N_n*(1-logncdf(gamma(i,1),mu,sig))*EA_above(i,1))*((alph/p_c(i,1))^(alph/(1-alph)));
    else
        Y(i,1) = N_n*EA_uncond*((alph/p_n(i,1))^(alph/(1-alph)))+N_c*EA_uncond*((alph/p_c(i,1))^(alph/(1-alph)));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SIMULATION WITH TAX %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set target GHG emissions
target = 5;
% Find tax rate that achieves this target under different tax structures
for i = 1:np
    ghg_target = ghg_ur(i,1)/target;
    for k = 1:4
        struc = k;
        %test(i,k) = SimulOptimalTax_func(p_n,p_c(i,1),param,0.1,ghg_target(i,1),EA_uncond,A,struc);
        f = @(x) SimulOptimalTax_func(p_n(i,1),p_c(i,1),param,x,ghg_target,EA_uncond,A,struc);
        options = optimset('Display','iter');
        x0=0.0;
        %[tau(i,k),fval(i,k)] = simulannealbnd(f,x0,0.0,[],options)
        [tau(i,k),fval(i,k),output] = fminsearch(f,x0,options);
        %if k == 2
        %    [tau(i,k),fval(i,k)] = fmincon(f,x0,[],[],[],[],1.0,[],[],options);
        %else
        %    [tau(i,k),fval(i,k)] = fmincon(f,x0,[],[],[],[],0.0,[],[],options);
        %end
    end
end

% Find aggregate output loss under the different tax structures
% net input prices under carbon tax
p_nt(:,1) = (1+tau(:,1)).*p_n;
p_ct(:,1) = (1+2*tau(:,1)).*p_c;
% net input prices under coal tax
%p_nt(:,2) = p_n;
%p_ct(:,2) = (1+tau(:,2)).*p_c;
p_nt(:,2) = (1+tau(:,2)).*p_n;
p_ct(:,2) = (1+3*tau(:,2)).*p_c;
% net input prices under natural gas tax
p_nt(:,3) = (1+5*tau(:,3)).*p_n;
p_ct(:,3) = (1+tau(:,3)).*p_c;
% net input prices under fuel tax
p_nt(:,4) = (1+tau(:,4)).*p_n;
p_ct(:,4) = (1+tau(:,4)).*p_c;
for k = 1:4
    for j = 1:np
        for i = 1:ndraw
            % Individual profits, input choices and output quantity
            pi_c1(i,j,k) = ((A(i,1)/p_ct(j,k))^(1/(1-alph)))*p_ct(j,k)*gam_alph;
            pi_c2(i,j,k) = ((A(i,1)/p_ct(j,k))^(1/(1-alph)))*p_ct(j,k)*gam_alph-kap;
            pi_n1(i,j,k) = ((A(i,1)/p_nt(j,k))^(1/(1-alph)))*p_nt(j,k)*gam_alph-kap;
            pi_n2(i,j,k) = ((A(i,1)/p_nt(j,k))^(1/(1-alph)))*p_nt(j,k)*gam_alph;
            if pi_c1(i,j,k) > pi_n1(i,j,k)
                pi_1(i,j,k) = pi_c1(i,j,k);
                kc_ind1(i,j,k) = (alph*A(i,1)/p_ct(j,k))^(1/(1-alph));
                kn_ind1(i,j,k) = 0;
                y1(i,j,k) = A(i,1)*(kc_ind1(i,j,k)^alph);
            else
                pi_1(i,j,k) = pi_n1(i,j,k);
                kc_ind1(i,j,k) = 0;
                kn_ind1(i,j,k) = (alph*A(i,1)/p_nt(j,k))^(1/(1-alph));
                y1(i,j,k) = A(i,1)*(kn_ind1(i,j,k)^alph);
            end
            if pi_c2(i,j,k) > pi_n2(i,j,k)
                pi_2(i,j,k) = pi_c2(i,j,k);
                kc_ind2(i,j,k) = (alph*A(i,1)/p_ct(j,k))^(1/(1-alph));
                kn_ind2(i,j,k) = 0;
                y2(i,j,k) = A(i,1)*(kc_ind2(i,j,k)^alph);
            else
                pi_2(i,j,k) = pi_n2(i,j,k);
                kc_ind2(i,j,k) = 0;
                kn_ind2(i,j,k) = (alph*A(i,1)/p_nt(j,k))^(1/(1-alph));
                y2(i,j,k) = A(i,1)*(kn_ind2(i,j,k)^alph);
            end
        end
        Kc_bottomup(j,k) = N_c*mean(kc_ind1(:,j,k),1)+N_n*mean(kc_ind2(:,j,k),1);
        Kn_bottomup(j,k) = N_c*mean(kn_ind1(:,j,k),1)+N_n*mean(kn_ind2(:,j,k),1);
        PI_bottomup(j,k) = N_c*mean(pi_1(:,j,k),1)+N_n*mean(pi_2(:,j,k),1);
        Y_bottomup(j,k) = N_c*mean(y1(:,j,k),1)+N_n*mean(y2(:,j,k),1);
    end
end

% Aggregate proportion of coal-using firms switching towards natural gas (kn_ind1)
for i = 1:np
    for k = 1:4
        switch_n(i,k) = (ndraw-nnz(~kn_ind1(:,i,k)))/ndraw;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% MODEL VALIDATION %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simulating productivity thresholds
for k = 1:4
    for i = 1:np
        if p_nt(i,k) > p_ct(i,k)
            p_rel_r(i,k) = p_ct(i,k)^(alph/(alph-1))-p_nt(i,k)^(alph/(alph-1));
            gamma_r(i,k) = ((kap/gam_alph)*(1/p_rel_r(i,k)))^(1-alph);
            %K_n(i,1) = (logncdf(gamma(i,1),mu,sigma)*N_n)
        elseif p_nt(i,k) == p_ct(i,k)
            p_rel_r(i,k) = p_nt(i,k)^(alph/(alph-1))-p_ct(i,k)^(alph/(alph-1));
            gamma_r(i,k) = 1;
        else
            p_rel_r(i,k) = p_nt(i,k)^(alph/(alph-1))-p_ct(i,k)^(alph/(alph-1));
            gamma_r(i,k) = ((kap/gam_alph)*(1/p_rel_r(i,k)))^(1-alph);
        end
    end
end
for k = 1:4
    for i = 1:np
        mask_above_r(:,i,k) = (A > gamma_r(i,k));
        mask_below_r(:,i,k) = (A <= gamma_r(i,k));
        EA_above_r(i,k) = mean(A_alph(mask_above_r(:,i,k),:),1);
        EA_below_r(i,k) = mean(A_alph(mask_below_r(:,i,k),:),1);
    end
end
% Aggregate input quantities
for k = 1:4
    for i = 1:np
        if p_nt(i,k) > p_ct(i,k)
            Kn_r(i,k) = N_n*logncdf(gamma_r(i,k),mu,sig)*EA_below_r(i,k)*((alph/p_nt(i,k))^(1/(1-alph)));
            Kc_r(i,k) = N_c*EA_uncond*((alph/p_ct(i,k))^(1/(1-alph)))+ N_n*(1-logncdf(gamma_r(i,k),mu,sig))*EA_above_r(i,k)*((alph/p_ct(i,k))^(1/(1-alph)));
        elseif p_nt(i,k) == p_ct(i,k)
            Kn_r(i,k) = N_n*EA_uncond*((alph/p_nt(i,k))^(1/(1-alph)));
            Kc_r(i,k) = N_c*EA_uncond*((alph/p_ct(i,k))^(1/(1-alph)));
        else
            Kn_r(i,1) = N_n*EA_uncond*((alph/p_nt(i,k))^(1/(1-alph))) + N_c*(1-logncdf(gamma_r(i,k),mu,sig))*EA_above_r(i,k)*((alph/p_nt(i,k))^(1/(1-alph)));
            Kc_r(i,1) = N_c*logncdf(gamma_r(i,k),mu,sig)*EA_below_r(i,k)*((alph/p_ct(i,k))^(1/(1-alph)));
        end
    end
end
% GHG emissions under no tax
for k = 1:4
    for i = 1:np
        ghg_r(i,k) = Kn_r(i,k)+2*Kc_r(i,k);
    end
end

% Aggregate output
for i = 1:np
    if p_ct(i,1) > p_nt(i,1)
        Y(i,1) = N_c*logncdf(gamma(i,1),mu,sig)*EA_below_r(i,1)*((alph/p_ct(i,1))^(alph/(1-alph)))+(N_n*EA_uncond+N_c*(1-logncdf(gamma(i,1)))*EA_above_r(i,1))*((alph/p_nt(i,1))^(alph/(1-alph)));
    elseif p_ct(i,1) < p_nt(i,1)
        Y(i,1) = N_n*logncdf(gamma(i,1),mu,sig)*EA_below_r(i,1)*((alph/p_nt(i,1))^(alph/(1-alph)))+(N_c*EA_uncond+N_n*(1-logncdf(gamma(i,1)))*EA_above_r(i,1))*((alph/p_ct(i,1))^(alph/(1-alph)));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% MANUAL TESTS %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CASE 1
% No tax
p_c = 1;
p_n = 3;
[ghg(1,1),Y_bottomup(1,1),Y_topbottom(1,1),profit(1,1),prop_switch(1,1)] = SimulTax_func(p_n,p_c,param,EA_uncond,A);

% Carbon tax
tau = 1.7038;
p_c1(1,1) = (1+2*tau)*1;
p_n1(1,1) = (1+tau)*3;
[ghg(2,1),Y_bottomup(2,1),Y_topbottom(2,1),profit(2,1),prop_switch(2,1)] = SimulTax_func(p_n1(1,1),p_c1(1,1),param,EA_uncond,A);

% Coal tax
tau = 2.5;
p_c1(1,2) =(1+tau)*1;
p_n1(1,2) = 3;
[ghg(3,1),Y_bottomup(3,1),Y_topbottom(3,1),profit(3,1),prop_switch(3,1)] = SimulTax_func(p_n1(1,2),p_c1(1,2),param,EA_uncond,A);

%CASE 2
% No tax
p_c = 1;
p_n = 2;
[ghg(1,2),Y_bottomup(1,2),Y_topbottom(1,2),profit(1,2),prop_switch(1,2)] = SimulTax_func(p_n,p_c,param,EA_uncond,A);

% Carbon tax
tau = 1.01;
p_c1(2,1) = (1+2*tau)*1; 
p_n1(2,1) = (1+tau)*2;
[ghg(2,2),Y_bottomup(2,2),Y_topbottom(2,2),profit(2,2),prop_switch(2,2)] = SimulTax_func(p_n1(2,1),p_c1(2,1),param,EA_uncond,A);

% Coal tax
tau = 2.5;
p_c1(2,2)=(1+tau)*1;
p_n1(2,2) = 2;
[ghg(3,2),Y_bottomup(3,2),Y_topbottom(3,2),profit(3,2),prop_switch(3,2)] = SimulTax_func(p_n1(2,2),p_c1(2,2),param,EA_uncond,A);

%CASE 3
% No tax
p_c = 1;
p_n = 1.5;
[ghg(1,3),Y_bottomup(1,3),Y_topbottom(1,3),profit(1,3),prop_switch(1,3)] = SimulTax_func(p_n,p_c,param,EA_uncond,A);

% Carbon tax
tau = 0.644;
p_c1(3,1) = (1+2*tau)*1; 
p_n1(3,1) = (1+tau)*1.5;
[ghg(2,3),Y_bottomup(2,3),Y_topbottom(2,3),profit(2,3),prop_switch(2,3)] = SimulTax_func(p_n1(3,1),p_c1(3,1),param,EA_uncond,A);

% Coal tax
tau = 2.5;
p_c1(3,2)=(1+tau)*1;
p_n1(3,2) = 1.5;
[ghg(3,3),Y_bottomup(3,3),Y_topbottom(3,3),profit(3,3),prop_switch(3,3)] = SimulTax_func(p_n1(3,2),p_c1(3,2),param,EA_uncond,A);

p_rel_input = p_n1./p_c1;

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
