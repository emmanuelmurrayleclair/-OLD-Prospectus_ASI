clear;
clc;

datatable = readtable("D:\Users\Emmanuel\Dropbox\Prospectus_Emmanuel\ASI\Output\PFEdata11.txt");
data = table2array(datatable);

%   Data
Espend = data(:,2);
Mspend = data(:,6);
logY = data(:,5);
KM = data(:,8);
LM = data(:,9);
Espend_gmean = data(:,3);
Mspend_gmean = data(:,7);
Lspend_gmean = data(:,4);

% Estimation
f = @(x) nlls_ces_objfun(data,x);
%options = optimset('Display','iter');
options = optimoptions(@fmincon,'Display','iter');
x0 = [0.5;0.5;0.5;0.5];
%lb = [1;0;0;0];
%ub = [1.5;0.5;0.5;2];
%ub = [20.0;100.0;20.0]
[param_est,rss_est] = fmincon(f,x0,[],[],[],[],[],[],[],options);
%options = optimoptions(@simulannealbnd,'MaxIterations',30000,'Display','iter');
%[param_est,rss_est] = simulannealbnd(f,x0,lb,[],options);

%options = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter');
%x0 = param_est;
%[param_est,rss_est] = fmincon(f,x0,[],[],[],[],lb,[],[],options);