clear; clc

g = grd('NWP');
mask_whole = g.mask_rho./g.mask_rho;

nc = netcdf('roms_grid_NWP_Eastsea.nc');
mask_Eastsea = nc{'mask_rho'}(:);
close(nc);
mask_Eastsea = mask_Eastsea./mask_Eastsea;

nc = netcdf('roms_grid_NWP_Soya.nc');
mask_Soya = nc{'mask_rho'}(:);
close(nc);
mask_Soya = mask_Soya./mask_Soya;

nc = netcdf('roms_grid_NWP_Okhotsk.nc');
mask_Okhotsk = nc{'mask_rho'}(:);
close(nc);
mask_Okhotsk = mask_Okhotsk./mask_Okhotsk;

nc = netcdf('roms_grid_NWP_ECS.nc');
mask_ECS = nc{'mask_rho'}(:);
close(nc);
mask_ECS = mask_ECS./mask_ECS;

path_all = 'G:\Model\ROMS\Case\NWP\input\';

Pair_Eastsea_all = [];
Pair_Soya_all = [];
Pair_Okhotsk_all = [];
Pair_ECS_all = [];
Pair_whole_all = [];

for yi = 2001:2016
    yyyy = yi; tys = num2str(yyyy);
    datenum_ref = datenum(yyyy,1,1);
    for mi = 1:12
        filename = ['Pair_NWP_ECMWF_', tys, '.nc'];
        file = [path_all, filename];
        
        nc = netcdf(file);
        Pair_time = nc{'Pair_time'}(:);
        Pair_date = datestr(datenum_ref + Pair_time, 'yyyymm');
        mindex = find(str2num(Pair_date(:, 5:6)) == mi);
        Pair = squeeze(mean(nc{'Pair'}(mindex,:,:)));
        close(nc)
        
        Pair_Eastsea = Pair.*mask_Eastsea;
        Pair_Eastsea_spatial_mean = mean(Pair_Eastsea(isnan(Pair_Eastsea) == 0));
        Pair_Eastsea_all = [Pair_Eastsea_all; Pair_Eastsea_spatial_mean];
        
        Pair_Soya = Pair.*mask_Soya;
        Pair_Soya_spatial_mean = mean(Pair_Soya(isnan(Pair_Soya) == 0));
        Pair_Soya_all = [Pair_Soya_all; Pair_Soya_spatial_mean];
        
        Pair_Okhotsk = Pair.*mask_Okhotsk;
        Pair_Okhotsk_spatial_mean = mean(Pair_Okhotsk(isnan(Pair_Okhotsk) == 0));
        Pair_Okhotsk_all = [Pair_Okhotsk_all; Pair_Okhotsk_spatial_mean];
        
        Pair_ECS = Pair.*mask_ECS;
        Pair_ECS_spatial_mean = mean(Pair_ECS(isnan(Pair_ECS) == 0));
        Pair_ECS_all = [Pair_ECS_all; Pair_ECS_spatial_mean];
        
        Pair_whole = Pair.*mask_whole;
        Pair_whole_spatial_mean = mean(Pair_whole(isnan(Pair_whole) == 0));
        Pair_whole_all = [Pair_whole_all; Pair_whole_spatial_mean];
    end
end

xdate = [];
for yi = 2001:2016
    for mi = 1:12
        xdate = [xdate; yi mi];
    end
end
xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

figure; hold on; grid on
plot(xdatenum, Pair_Eastsea_all, 'LineWidth', 2)
plot(xdatenum, Pair_Soya_all, 'LineWidth', 2)
plot(xdatenum, Pair_Eastsea_all - Pair_Soya_all, '--k', 'LineWidth', 2)
datetick('x', 'yyyy')

ylim([990 1030])
xlim([datenum(2000, 12, 31), datenum(2017, 1, 1)])
xlabel('Year', 'fontsize', 25)
ylabel('Pair(mbar)', 'fontsize', 25)
set(gca, 'FontSize', 25)
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
set(gca, 'XtickLabel', [2001:2016])

h = legend('East Sea', 'Southern Okhotsk', 'Location', 'SouthEast');
h.FontSize = 25;
title('monthly mean air pressure', 'FontSize', 25)

% domain check
figure; hold on
pcolor(g.lon_rho, g.lat_rho, g.mask_rho./g.mask_rho); shading flat
mask_Eastsea_area = mask_Eastsea+1;
pcolor(g.lon_rho, g.lat_rho, mask_Eastsea_area); shading flat
mask_Soya_area = mask_Soya+2;
pcolor(g.lon_rho, g.lat_rho, mask_Soya_area); shading flat
xlabel('Longitude'); ylabel('Latitude');
set(gca, 'FontSize', 15)
axis tight;