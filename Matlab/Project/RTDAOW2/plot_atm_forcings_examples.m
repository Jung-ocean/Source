clear; clc

g = grd('NANOOS');
datenum_target = datenum(2025,09,15);
yyyymmdd = datestr(datenum_target, 'yyyymmdd');
filepath = ['/data/jungjih/RTDAOW2/Prm/FRC/', datestr(datenum_target, 'mm-dd-yyyy'), '/'];

time_ref = datenum(2005,1,1);
data = load(['rd_eta_ctz_', yyyymmdd, '.mat']);
ea = data.ea;
nt = data.nt;

varis_org = {'T_2m_K', 'Pa', 'RH', 'Qsw', 'WindE', 'WindN', 'C0loc'};
varis_lp = {'Ta0', 'Pa0', 'RH0', 'Qsw0', 'WindE0', 'WindN0', 'C0'};
filenames_ROMS = {'Tair', 'Pair', 'Qair', 'Swrad', 'wind', 'wind', 'Cloud'};
varis_ROMS = {'Tair', 'Pair', 'Qair', 'swrad', 'Uwind', 'Vwind', 'cloud'};
times_ROMS = {'tair_time', 'pair_time', 'qair_time', 'srf_time', 'wind_time', 'wind_time', 'cloud_time'};
times_lp = {'tTalp', 'tPalp', 'tRHlp', 'tswlp', 'tWindlp', 'tWindlp', 'tlp'};
units = {'^oC', 'mbar', '%', 'W/m^2', 'm/s', 'm/s', ''};
titles = {'Air temperature', 'Air pressure', 'Relative humidity', 'Shortwave radiation', 'Zonal wind', 'Meridional wind', 'Cloud fraction'};

ind_point = 3500;
lon = data.mlon;
lat = data.mlat;

lon_target = lon(ind_point);
lat_target = lat(ind_point);

dist = sqrt((g.lon_rho - lon_target).^2 + (g.lat_rho - lat_target).^2);
[lonind,latind] = find(dist == min(dist(:)));

figure; hold on;
set(gcf, 'Position', [1 200 500 800])
plot_map('US_west', 'mercator', 'l')
plotm(lat_target, lon_target, 'xk', 'MarkerSize', 25, 'LineWidth', 3);
print(['location_point'], '-dpng');

for vi = 1:length(varis_org)
       
    time = data.time;
    vari = eval(['data.', varis_org{vi}]);
    
    time_lp = eval(['data.', times_lp{vi}]);
    vari_lp = eval(['data.', varis_lp{vi}]);
    
    filename = ['frc_ow2km_', filenames_ROMS{vi}, '.nc'];
    file = [filepath, filename];
    time_forcing = ncread(file, times_ROMS{vi});
    vari_forcing = squeeze(ncread(file, varis_ROMS{vi}, [lonind, latind, 1], [1 1 Inf]))';

    figure; hold on; grid on;
    set(gcf, 'Position', [1 200 800 500])
    po = plot(time+time_ref, vari(ind_point,:), '-k', 'LineWidth', 2);
    if vi == 5 || vi == 6
        pf = plot(time_forcing+time_ref, vari_forcing, '--g', 'LineWidth', 2);
        
        l = legend([po, pf], 'Original', 'ROMS forcing');
        l.Location = 'SouthOutside';
        l.NumColumns = 2;
        l.FontSize = 15;
    else
        pl = plot(time_lp+time_ref, vari_lp(ind_point,:), '-r', 'LineWidth', 2);
        pf = plot(time_forcing+time_ref, vari_forcing, '--g', 'LineWidth', 2);

        l = legend([po, pl, pf], 'Original', 'Low-pass filtered', 'ROMS forcing');
        l.Location = 'SouthOutside';
        l.NumColumns = 3;
        l.FontSize = 15;
    end
    datetick('x', 'mm/dd')
    ylabel(units{vi});
    set(gca, 'FontSize', 12)

    title(titles{vi}, 'FontSize', 15)

    savename = replace(titles{vi}, ' ', '_');
    print(savename, '-dpng')
end