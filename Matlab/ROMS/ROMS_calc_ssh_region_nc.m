clear; clc

% N.East Sea color = [0.4660 0.6740 0.1880]
% S.East Sea color = [0.6350 0.0780 0.1840]

region_list = {'Eastsea', 'Soya', 'Okhotsk', 'ECS', 'Eastsea_north', 'Eastsea_south', 'Pacific', 'Pacific_south', 'Pacific_north'};

g = grd('NWP');
mask_whole = g.mask_rho./g.mask_rho;

for ri = 1:length(region_list)
    region_name = region_list{ri};
    nc = netcdf(['roms_grid_NWP_', region_name, '.nc']);
    mask = nc{'mask_rho'}(:);
    eval(['mask_', region_name, ' = mask;'])
    close(nc);
    eval(['mask_', region_name, ' = mask_', region_name, './mask_', region_name, ';'])
    
    % empty matrix
    eval(['zeta_', region_name, '_all = [];'])
end
zeta_whole_all = [];

path_2001 = 'G:\Model\ROMS\Case\NWP\output\exp_HYCOM\2001\13th\';
for mi = 1:12
    filename = ['monthly_2001', num2char(mi,2), '.nc'];
    file = [path_2001, filename];
    nc = netcdf(file);
    zeta = nc{'zeta'}(:);
    close(nc)
    
    for ri = 1:length(region_list)
        region_name = region_list{ri};
        eval(['zeta_', region_name, ' = zeta.*mask_', region_name, ';'])
        eval(['zeta_', region_name, '_spatial_mean = mean(zeta_', region_name, '(isnan(zeta_', region_name, ') == 0));'])
        eval(['zeta_', region_name, '_all = [zeta_', region_name, '_all; zeta_', region_name, '_spatial_mean];'])
    end
    
    zeta_whole = zeta.*mask_whole;
    zeta_whole_spatial_mean = mean(zeta_whole(isnan(zeta_whole) == 0));
    zeta_whole_all = [zeta_whole_all; zeta_whole_spatial_mean];
end

for yi = 2002:2011
    yyyy = yi; tys = num2str(yyyy);
    path_other = ['G:\Model\ROMS\Case\NWP\output\exp_HYCOM\', tys, '\'];
    if (yi == 2009) || (yi == 2010) || (yi == 2011)
        path_other = ['G:\Model\ROMS\Case\NWP\output\exp_HYCOM\', tys, '_SODA\'];
    end
    
    for mi = 1:12
        filename = ['monthly_', tys, num2char(mi,2), '.nc'];
        file = [path_other, filename];
        nc = netcdf(file);
        zeta = nc{'zeta'}(:);
        close(nc)
        
        for ri = 1:length(region_list)
            region_name = region_list{ri};
            eval(['zeta_', region_name, ' = zeta.*mask_', region_name, ';'])
            eval(['zeta_', region_name, '_spatial_mean = mean(zeta_', region_name, '(isnan(zeta_', region_name, ') == 0));'])
            eval(['zeta_', region_name, '_all = [zeta_', region_name, '_all; zeta_', region_name, '_spatial_mean];'])
        end
        
        zeta_whole = zeta.*mask_whole;
        zeta_whole_spatial_mean = mean(zeta_whole(isnan(zeta_whole) == 0));
        zeta_whole_all = [zeta_whole_all; zeta_whole_spatial_mean];
    end
end

xdate = [];
for yi = 2001:2011
    for mi = 1:12
        xdate = [xdate; yi mi];
    end
end
xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

figure; hold on; grid on
plot(xdatenum, zeta_Eastsea_all, 'LineWidth', 2)
plot(xdatenum, zeta_Soya_all, 'LineWidth', 2)
plot(xdatenum, zeta_Eastsea_all - zeta_Soya_all, '--k', 'LineWidth', 2)
datetick('x', 'yyyy')

ylim([-0.4 0.5])
xlim([datenum(2000, 12, 31), datenum(2017, 1, 1)])
xlabel('Year', 'fontsize', 25)
ylabel('zeta(m)', 'fontsize', 25)
set(gca, 'FontSize', 25)
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
set(gca, 'XtickLabel', [2001:2016])

h = legend('East Sea', 'Southern Okhotsk Sea', 'difference', 'Location', 'NorthEast');
h.FontSize = 25;
title('monthly sea surface height', 'FontSize', 25)

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