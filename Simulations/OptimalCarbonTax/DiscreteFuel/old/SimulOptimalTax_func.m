function ghg_func = Agg_fuel(p_n,p_c,param,tau,ghg_target,EA_uncond,A,struc)
    sig = param(2,1);
    mu = param(3,1);
    N_n = param(4,1);
    N_c = param(5,1);
    kap = param(6,1);
    alph = param(7,1);
    gam_alph = param(8,1);
    % Tax structure
    if struc == 1 % pigouvian tax
        p_nt = (1+tau(1))*p_n;
        p_ct = (1+2*tau(1))*p_c;
    elseif struc == 2 % coal tax
        %p_nt = p_n;
        %p_ct = (1+tau(1))*p_c;
        p_nt = (1+tau(1))*p_n;
        p_ct = (1+3*tau(1))*p_c;
    elseif struc == 3 % natural gas tax 
        p_nt = (1+5*tau(1))*p_n;
        p_ct = (1+tau(1))*p_c;
    elseif struc == 4 % fuel tax
        p_nt = (1+tau(1))*p_n;
        p_ct = (1+tau(1))*p_c;
    end
    % Productivity threshold
    if p_nt > p_ct
        p_rel = p_ct^(alph/(alph-1))-p_nt^(alph/(alph-1));
        gamma = ((kap/gam_alph)*(1/p_rel))^(1-alph);
        %K_n(i,1) = (logncdf(gamma(i,1),mu,sigma)*N_n)
    elseif p_nt == p_ct
        p_rel = p_nt^(alph/(alph-1))-p_ct^(alph/(alph-1));
        gamma = 1;
    else
        p_rel = p_nt^(alph/(alph-1))-p_ct^(alph/(alph-1));
        gamma = ((kap/gam_alph)*(1/p_rel))^(1-alph);
    end
    A_alph = A.^(1/(1-alph));
    mask_above = (A > gamma);
    mask_below = (A <= gamma);
    EA_above = mean(A_alph(mask_above,:),1);
    EA_below = mean(A_alph(mask_below,:),1);
    % Aggregate fuel quantities
    if p_nt > p_ct
        Kn = N_n*logncdf(gamma,mu,sig)*EA_below*((alph/p_nt)^(1/(1-alph)));
        Kc = N_c*EA_uncond*((alph/p_ct)^(1/(1-alph)))+ N_n*(1-logncdf(gamma,mu,sig))*EA_above*((alph/p_ct)^(1/(1-alph)));
    elseif p_nt == p_ct
        Kn = N_n*EA_uncond*((alph/p_nt)^(1/(1-alph)));
        Kc = N_c*EA_uncond*((alph/p_ct)^(1/(1-alph)));
    else
        Kn = N_n*EA_uncond*((alph/p_nt)^(1/(1-alph))) + N_c*(1-logncdf(gamma,mu,sig))*EA_above*((alph/p_nt)^(1/(1-alph)));
        Kc = N_c*logncdf(gamma,mu,sig)*EA_below*((alph/p_ct)^(1/(1-alph)));
    end
    
    ghg_func = (ghg_target - Kn-2*Kc)^2;
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%Kn = inputArg1;
%Kc = inputArg2;
end

