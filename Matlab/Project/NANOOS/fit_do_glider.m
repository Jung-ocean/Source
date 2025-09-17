clear; clc; close all

filepath = '/data/jungjih/Observations/Glider/';
filename = 'Glider_381_202408.csv';
file = [filepath, filename];
data = readtable(file);
lat = table2array(data(:,8));
lon = table2array(data(:,9));
timenum = datenum(table2array(data(:,2)));
timevec = datevec(timenum);
profile = table2array(data(:,3));
depth = table2array(data(:,4));
u = table2array(data(:,11));
v = table2array(data(:,12));
do = table2array(data(:,19));
temp = table2array(data(:,53));
salt = table2array(data(:,52));

p = gsw_p_from_z(-depth,lat);
[SA, in_ocean] = gsw_SA_from_SP(salt,p,lon,lat);
% Potential temperature
pt0 = gsw_pt0_from_t(SA,temp,p);
% Potential density
% CT = gsw_CT_from_t(SA,temp,p);
CT = gsw_CT_from_pt(SA,pt0);
pden = gsw_rho(SA,CT,0);

% Spiciness
spiciness0 = gsw_spiciness0(SA,CT);

% Fitting
x = [depth, pden, spiciness0];
x_nan = isnan(x);
x_nan_sum = sum(x_nan,2);
index = find(x_nan_sum == 0 & isnan(do) == 0 & depth > 100);

xdata = x(index,:);
xmean = mean(xdata);
xstd = std(xdata);
xnorm = (xdata - xmean)./xstd;

deg = 4;
d = size(xnorm, 2);

yfcn = @(p,x) ...
    polyND(p, x, deg);
%p(1)*x(:,1) + p(2)*x(:,2) + p(3)*x(:,3) + ...
%    p(4)*x(:,1).^2 + p(5)*x(:,2).^2 + p(6)*x(:,3).^2 + ...
%    p(7);

nParams = nchoosek(d+deg, deg);
p0 = ones(nParams,1);
pfit = lsqcurvefit(yfcn,p0,xnorm,do(index,:));

do_re = yfcn(pfit,xnorm);

figure; hold on; grid on
set(gcf, 'Position', [1 200 800 500])
plot(do(index), do_re, '.k');
plot([-1000 1000], [-1000 1000], '-k')
xlim([-50 400])
ylim([-50 400])
xlabel('Dissolved oxygen')
ylabel('Reconstructed')

% Test
