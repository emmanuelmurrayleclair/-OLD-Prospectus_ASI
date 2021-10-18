function rss_ces = nlls(data,param)
%Returns the residual sum of squares of the CES estimating equation given
%current paramter guesses
%   Parameters 
rho = param(1);
al = param(2);
ak = param(3);
am = param(4);
ae  = param(5);
sig = param(6);
%   Data
Espend = data(:,2);
Lspend = data(:,4);
logY = data(:,6);
Mspend = data(:,7);
KL = data(:,9);
Espend_gmean = data(:,3);
Mspend_gmean = data(:,8);
Lspend_gmean = data(:,5);

% Individual error term
kterm = (ak/al)*(KL.^((sig-1)/sig));
%mterm = amal*(ML.^((sig-1)/sig));
cons = log(rho/(rho-1));
f = cons+log(Lspend.*(1+kterm)+Espend + Mspend);
% Moments
m1 = f.*(logY-f);
m2 = (Espend_gmean.*al)-(Lspend_gmean.*ae);
m3 = al+ak+ae+am-1
M1 = mean(m1);
M2 = mean(m2);
M3 = mean(m3);

% Residual sum of squares
rss_ces = (M1^2+M2^2+M3^2);

end

