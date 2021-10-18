% Returns implied aggregate price index and aggregate productivity given
% guess of price index
function [Ad,Ac,pind,omega] = simul_aggpriceindex(param,A,p_guess,model)
    sig = param(1);
    mu = param(2);
    N_d = param(3);
    N_c = param(4);
    kap = param(5);
    rho = param(6);
    gam_rho = param(7);
    p_d = param(8);
    p_c = param(9);
   
    % Productivity threshold (given guess of price index)
    Y = 1/p_guess;
    pc = p_c^(1-rho);
    pd = p_d^(1-rho);
    omega = ((kap/((p_guess^rho)*Y*gam_rho))*(1/(pc-pd)))^(1/(rho-1));
    
    % Aggregate productivity
    A_rho = A.^(rho-1);
    A_uncond = mean(A_rho);
    
    if model == 1    
        if p_d == p_c
            Ad = N_d*A_uncond;
            Ac = N_c*A_uncond;
        elseif p_d > p_c
            mask_below = (A <= omega);
            mask_above = (A > omega);
            EA_below = mean(A_rho(mask_below,:),1);
            EA_above = mean(A_rho(mask_above,:),1);
            pr_below = logncdf(omega,mu,sig);
            pr_above = 1-logncdf(omega,mu,sig);
            Ad = N_d*pr_below*EA_below;
            if isnan(EA_above) == 1
                Ac = N_c*A_uncond;
            else
                Ac = (N_d*pr_above*EA_above)+(N_c*A_uncond);
            end
        elseif p_d < p_c 
            mask_below = (A <= -omega);
            mask_above = (A > -omega);
            EA_below = mean(A_rho(mask_below,:),1);
            EA_above = mean(A_rho(mask_above,:),1);
            pr_below = logncdf(-omega,mu,sig);
            pr_above = 1-logncdf(-omega,mu,sig);
            if isnan(EA_above) == 1
                Ad = N_d*A_uncond;
            else
                Ad = N_d*A_uncond+N_c*pr_above*EA_above;
            end
            Ac = N_c*pr_below*EA_below;
        end
    elseif model == 0
        Ad = N_d*A_uncond;
        Ac = N_c*A_uncond;
    end
    
    % Aggregate price index and productivity 
    Ad = Ad;
    Ac = Ac;
    pind = (rho/(rho-1))*((pd*Ad+pc*Ac)^(1/(1-rho)));
end
