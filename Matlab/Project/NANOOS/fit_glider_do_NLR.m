clear; clc; close all

filepath = '/data/jungjih/Observations/Glider_ERDDAP/';
filename = 'ce_382-20240618T1940_702d_e42b_441a.csv';
file = [filepath, filename];
type = 'ERDDAP';
glider = load_glider(file, type);

lat = glider.lat;
lon = glider.lon;
timenum = glider.timenum;
timevec = datevec(timenum);
depth = glider.depth;
depth = -abs(depth);
do = glider.do;
temp = glider.temp;
salt = glider.salt;

lon_unique = unique(lon);
h = NaN(size(lon));
for li = 1:length(lon_unique)
    lon_tmp = lon_unique(li);
    lonind = find(lon == lon_tmp);
    depth_tmp = depth(lonind);
    h(lonind,1) = abs(min(depth_tmp));
end

p = gsw_p_from_z(depth,lat);
[SA, in_ocean] = gsw_SA_from_SP(salt,p,lon,lat);
% Potential temperature
pt0 = gsw_pt0_from_t(SA,temp,p);
% Potential density
% CT = gsw_CT_from_t(SA,temp,p);
CT = gsw_CT_from_pt(SA,pt0);
pden = gsw_rho(SA,CT,0);
sigma = pden-1000;
% Spiciness
spiciness0 = gsw_spiciness0(SA,CT);

lon_target = lon;
h_target = h;
depth_target = depth;
pt0_target = pt0;
salt_target = salt;
sigma_target = sigma;
spiciness0_target = spiciness0;
do_target = do;

% Fitting
x = [sigma];
x_nan = isnan(x);
x_nan_sum = sum(x_nan,2);
y = do_target;
y_nan = isnan(y);
index = find(x_nan_sum == 0 & y_nan == 0);

xdata = x(index,:);
xmean = mean(xdata);
xstd = std(xdata);
xnorm = xdata;%(xdata - xmean)./xstd;
ydata = y(index);

yfcn = @(p,x) ...
    p(1).*x + p(2).*x.^2 + p(3).*x.^3 + p(4).*x.^4 + p(5);

p0 = ones(5,1);
pfit = lsqcurvefit(yfcn,p0,xnorm,ydata);

do_re = yfcn(pfit,xnorm);

figure; hold on; grid on
set(gcf, 'Position', [1 200 800 500])

nbins = 1000;
hist = histogram2(ydata,do_re, nbins);
hist.FaceColor = 'flat';
colormap jet
plot([-1000 1000], [-1000 1000], '-k')
xlim([0 350])
ylim([0 350])
xlabel('Dissolved oxygen')
ylabel('Reconstructed')