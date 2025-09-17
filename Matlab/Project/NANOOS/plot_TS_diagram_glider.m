clear; clc; close all

slimit = [29 35];
tlimit = [0 22];

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

SA_4_TS = [slimit(1):.01:slimit(2)];
CT_4_TS = [tlimit(1):.1:tlimit(2)];
[x,y] = meshgrid(SA_4_TS,CT_4_TS);
pden_4_TS = gsw_rho(x,y,0);
spiciness_4_TS = gsw_spiciness0(x,y);

figure; hold on;
[c, h] = contour(x, y, pden_4_TS-1000, [0:1:30], 'r');
clabel(c,h, 'Color', 'r');
[c, h] = contour(x, y, spiciness_4_TS, [-5:1:5], 'k');
clabel(c,h, 'Color', 'k');
scatter(SA, CT, 10, do, '.')
caxis([61 300])
colormap jet
c = colorbar;
c.Label.String = 'Dissolved oxygen';
c.Title.String = '\mumol/kg';

xlim(slimit)
ylim(tlimit)

xlabel('Absolute Salinity')
ylabel('Conservative Temperature')