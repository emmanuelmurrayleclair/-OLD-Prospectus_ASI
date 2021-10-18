function rss_ces = nlls(data,param)
%Returns the residual sum of squares of the CES estimating equation given
%current paramter guesses
%   Parameters 
rho = param(1);
akam = param(2);
alam = param(3)
sig = param(4);
%   Data
%   Data
Espend = data(:,2);
Mspend = data(:,6);
logY = data(:,5);
KM = data(:,8);
LM = data(:,9);

% Individual error term
kterm = akam*(KM.^sig);
lterm = alam*(LM.^sig);
cons = rho;
res = logY-cons-log(Mspend.*(1+kterm+lterm) + Espend);

% Residual sum of squares
rss_ces = sum(res.^2,1);

end

