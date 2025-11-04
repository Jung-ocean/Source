clear; clc; close all

filepath = '/data/jungjih/Observations/Glider_ERDDAP/';
filename = 'ce_381-20210912T1740-delayed_9cf8_ad91_20a8.csv';
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

varis = {'sigma', 'spiciness0', 'pt0', 'salt'};
xlabels = {'\sigma_\theta', 'Spiciness', 'Potential temperature', 'Salinity'};
units = {'kg/m^3', 'kg/m^3', '^oC', 'psu'};
xlimits = [22 27; -2 2; 5 20; 31 34.5];

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 800])
t = tiledlayout(2,3);
t.Padding = 'compact';
t.TileSpacing = 'compact';

nexttile(1, [2 1]);
g = grd('NANOOS');
plot_map('US_west', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000], '-k')
plotm(lat, lon, '.r');
title([datestr(min(timenum), 'mmm dd'), ' - ',  datestr(max(timenum), 'mmm dd, yyyy')], 'FontSize', 15)

tiles = [2 3 5 6];
for vi = 1:length(varis)
    vari = eval(varis{vi});

    nexttile(tiles(vi)); hold on; grid on;
    x = vari;
    y = do;
    nbins = 1000;
    hist = histogram2(x,y, nbins);
    hist.FaceColor = 'flat';
    colormap jet

    if vi == length(varis)
        c = colorbar;
        c.Layout.Tile = 'East';
        c.Title.String = 'Count';
    end
    caxis([0 35])
    xlim([xlimits(vi,:)])
    ylim([0 350])
    xlabel([xlabels{vi}, ' (', units{vi}, ')']);
    ylabel('Dissolved oxygen (\mumol/kg)');
end

print([filename(1:end-4)], '-dpng')