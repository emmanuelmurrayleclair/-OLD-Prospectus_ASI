function [ghg,Y_bottomup,Y_topbottom,profit,prop_switch] = SimulTax_func(p_n,p_c,param,EA_uncond,A)
    sig = param(2,1);
    mu = param(3,1);
    N_n = param(4,1);
    N_c = param(5,1);
    kap = param(6,1);
    alph = param(7,1);
    gam_alph = param(8,1);
    
    if p_n > p_c
        p_rel = p_c^(alph/(alph-1))-p_n^(alph/(alph-1));
    elseif p_n < p_c 
        p_rel = p_n^(alph/(alph-1))-p_c^(alph/(alph-1));
    end
    if p_n == p_c
        gamma = 1;
    else
        gamma = ((kap/gam_alph)*(1/p_rel))^(1-alph);
    end
    A_alph = A.^(1/(1-alph));
    mask_above = (A > gamma);
    mask_below = (A <= gamma);
    EA_above = mean(A_alph(mask_above(:,1),:),1);
    EA_below = mean(A_alph(mask_below(:,1),:),1);
    % Aggregate input quantities
    if p_n > p_c
        Kn = N_n*logncdf(gamma,mu,sig)*EA_below*((alph/p_n)^(1/(1-alph)));
        Kc = N_c*EA_uncond*((alph/p_c)^(1/(1-alph)))+ N_n*(1-logncdf(gamma,mu,sig))*EA_above*((alph/p_c)^(1/(1-alph)));
    elseif p_n < p_c
        Kc = N_c*logncdf(gamma,mu,sig)*EA_below*((alph/p_c)^(1/(1-alph)));
        Kn = N_n*EA_uncond*((alph/p_n)^(1/(1-alph)))+ N_c*(1-logncdf(gamma,mu,sig))*EA_above*((alph/p_n)^(1/(1-alph)));
    end
    % GHG emissions under no tax
    ghg = Kn+2*Kc;

    % Aggregate output and profits
    ndraw = size(A,1);
    for i = 1:ndraw
        % Individual profits, input choices and output quantity
        pi_c1(i,1) = ((A(i,1)/p_c)^(1/(1-alph)))*p_c*gam_alph;
        pi_c2(i,1) = ((A(i,1)/p_c)^(1/(1-alph)))*p_c*gam_alph-kap;
        pi_n1(i,1) = ((A(i,1)/p_n)^(1/(1-alph)))*p_n*gam_alph-kap;
        pi_n2(i,1) = ((A(i,1)/p_n)^(1/(1-alph)))*p_n*gam_alph;
        if pi_c1(i,1) > pi_n1(i,1)
            pi_1(i,1) = pi_c1(i,1);
            kc_ind1(i,1) = (alph*A(i,1)/p_c)^(1/(1-alph));
            kn_ind1(i,1) = 0;
            y1(i,1) = A(i,1)*(kc_ind1(i,1)^alph);
        else
            pi_1(i,1) = pi_n1(i,1);
            kc_ind1(i,1) = 0;
            kn_ind1(i,1) = (alph*A(i,1)/p_n)^(1/(1-alph));
            y1(i,1) = A(i,1)*(kn_ind1(i,1)^alph);
        end
        if pi_c2(i,1) > pi_n2(i,1)
            pi_2(i,1) = pi_c2(i,1);
            kc_ind2(i,1) = (alph*A(i,1)/p_c)^(1/(1-alph));
            kn_ind2(i,1) = 0;
            y2(i,1) = A(i,1)*(kc_ind2(i,1)^alph);
        else
            pi_2(i,1) = pi_n2(i,1);
            kc_ind2(i,1) = 0;
            kn_ind2(i,1) = (alph*A(i,1)/p_n)^(1/(1-alph));
            y2(i,1) = A(i,1)*(kn_ind2(i,1)^alph);
        end
    end
    Kc_bottomup = N_c*mean(kc_ind1(:,1),1)+N_n*mean(kc_ind2(:,1),1);
    Kn_bottomup = N_c*mean(kn_ind1(:,1),1)+N_n*mean(kn_ind2(:,1),1);
    PI_bottomup = N_c*mean(pi_1(:,1),1)+N_n*mean(pi_2(:,1),1);
    Y_bottomup = N_c*mean(y1(:,1),1)+N_n*mean(y2(:,1),1);
    
    % Aggregate output (directly)
    if p_c > p_n
        Y_topbottom = N_c*(logncdf(gamma,mu,sig)*EA_below*((alph/p_c)^(alph/(1-alph)))+((1-logncdf(gamma,mu,sig))*EA_above*(alph/p_n)^(alph/(1-alph))))+(N_n*EA_uncond)*((alph/p_n)^(alph/(1-alph)));
    elseif p_c < p_n
        Y_topbottom = N_n*logncdf(gamma,mu,sig)*EA_below*((alph/p_n)^(alph/(1-alph)))+(N_c*EA_uncond+N_n*(1-logncdf(gamma,mu,sig))*EA_above)*((alph/p_c)^(alph/(1-alph)));
    else
        Y_topbottom = N_n*EA_uncond*((alph/p_n)^(alph/(1-alph)))+N_c*EA_uncond*((alph/p_c)^(alph/(1-alph)));
    end
    profit = N_c*mean(pi_1(:,1),1)+N_n*mean(pi_2(:,1),1);
    Y_bottomup = N_c*mean(y1(:,1),1)+N_n*mean(y2(:,1),1);
    ghg = Kn+2*Kc;
    if p_n < p_c
        prop_switch = (1-logncdf(gamma,mu,sig));
    else
        prop_switch = 0;
    end
end

