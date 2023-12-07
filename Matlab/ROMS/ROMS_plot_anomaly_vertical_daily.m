clear; clc; close all;

yyyy_anomaly = [9999, 2013];
var_str = 'temp';
%colorbarname = 'Density (\sigma_\theta)';
colorbarname = 'Temperature (deg C)';
%colorbarname = 'Velocity (m/s)';
clim = [-4 4];
contour_interval = [clim(1):2:clim(2)];

casename = 'NWP';
g = grd(casename);
masku2 = g.mask_u./g.mask_u; maskv2 = g.mask_v./g.mask_v;

datenum_ref = datenum(2013,1,1);
filenumber = 182:243;
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');

for fi = 1:length(filenumber)
    %mm = mi; mts = num2char(mm,2);
    
    for yi = 1:length(yyyy_anomaly)
        yyyy = yyyy_anomaly(yi);  yts = num2str(yyyy);
        if yyyy == 9999
            yts = 'avg';
            filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\daily\'];
        else
            filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\daily\'];
        end
        
        %filename = ['monthly_', yts, mts, '.nc'];
        %file = [filepath, filename];
        %ncload(file)
        
        filename = ['avg_', fns(fi,:), '.nc'];
        file = [filepath, filename];
        ncload(file)
        
        depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
        depth(depth > 1000) = NaN;
        
        pdens = zeros(size(depth));
        for si = 1:g.N
            pres = sw_pres(squeeze(depth(si,:,:)), g.lat_rho);
            pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
        end
        
        density = pdens - 1000;
        var = eval(var_str);
        
        if strcmp(var_str,'u') || strcmp(var_str,'v')
            skip = 1; npts = [0 0 0 0];
            for di = 1:g.N
                u_2d = squeeze(u(di,:,:));
                v_2d = squeeze(v(di,:,:));
                [u_rho(di,:,:),v_rho(di,:,:),lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
            end
            var = eval([var_str, '_rho']);
        end
        
        section = 'lon';
        if strcmp(section, 'lon')
            location = 126.2; range = [33.5 35];
        elseif strcmp(section, 'lat')
            %location = 35.855; range = [124.38 126.245]; % 309 line
            location = 34.5; range = [123 126];
        end
        
        [loc, dir_str, Xi, Yi, data] = ROMS_plot_vertical_function(g, depth, var_str, var, section, location, range);
        loc = round(loc*10)/10;
        
        close all
        
        data_all(yi,:,:) = data;
    end
    
    diffe = squeeze(data_all(2,:,:) - data_all(1,:,:));
    
    figure; hold on
    pcolor(Xi,Yi,diffe); shading interp; colormap('redblue')
    caxis(clim);
    [cs, h] = contour(Xi, Yi, diffe, contour_interval, 'k');
    clabel(cs,h,'LabelSpacing',144, 'FontSize', 15)
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    
    set(gca, 'FontSize', 15)
    ylabel('Depth(m)', 'FontSize', 15)
    xlabel('Latitude(^oN)', 'FontSize', 15)
    
    title([filedate(fi,:)], 'fontsize', 25)
    saveas(gcf, [var_str, '_vertical_', section, '_', num2str(loc), '_', casename, '_', filedate(fi,:), '.png'])
end