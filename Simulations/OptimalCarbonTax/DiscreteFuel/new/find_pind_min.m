% function that returns squared different between implied aggregate price
% index and current guess of price index
function pind_func_min = find_pind_min(pind_guess,param,A,model)

% Find implied price index
[~,~,pind_implied] = simul_aggpriceindex(param,A,pind_guess,model);
pind_func_min = (pind_implied-pind_guess)^2;
end

