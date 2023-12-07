clear; clc; close all;

yyyy_anomaly = [9999, 2013];
var_str = 'u';
%colorbarname = 'Density (\sigma_\theta)';
%colorbarname = 'Temperature (deg C)'; clim = [-5 5]; clim_ = 2; contour_interval = [clim(1):2:clim(2)];
colorbarname = 'Velocity (m/s)'; clim = [-0.5 0.5]; clim_ = 0.01; contour_interval = [clim(1):0.1:clim(2)];
%colorbarname = 'W velocity ( x 10^-4 m/s)'; clim = [-0.7 0.7]; clim_ = 0.02; contour_interval = [clim(1):0.3:clim(2)];

casename = 'NWP';
g = grd(casename);
masku2 = g.mask_u./g.mask_u; maskv2 = g.mask_v./g.mask_v;

exp = '_exp.windavgdir';

for mi = 8:8
    mm = mi; mts = num2char(mm,2);
    
    for yi = 1:length(yyyy_anomaly)
        yyyy = yyyy_anomaly(yi);  yts = num2str(yyyy);
        if yyyy == 9999
            yts = 'avg';
            filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\'];
        else
            filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, exp, '\'];
        end
        
        filename = ['monthly_', yts, mts, '.nc'];
        file = [filepath, filename];
        ncload(file)
        
        depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
        if strcmp(var_str, 'w')
            depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w', 2);
        end
        
        depth(depth > 1000) = NaN;
        
        pdens = zeros(size(depth));
        for si = 1:g.N
            pres = sw_pres(squeeze(depth(si,:,:)), g.lat_rho);
            pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
        end
        
        density = pdens - 1000;
        
        var = eval(var_str);
        var(var > 1000) = NaN;
        
        %         if strcmp(var_str,'u') || strcmp(var_str,'v')
        %             skip = 1; npts = [0 0 0 0];
        %             for di = 1:g.N
        %                 u_2d = squeeze(u(di,:,:));
        %                 v_2d = squeeze(v(di,:,:));
        %                 [u_rho(di,:,:),v_rho(di,:,:),lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        %             end
        %             var = eval([var_str, '_rho']);
        %         end
        
        section = 'lon';
        if strcmp(section, 'lon')
            location = 127.6; range = [33.5 35];
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
    
    % make land
    datasize = size(Yi);
    index = find(Yi(1,:) == min(Yi(1,:)));
    Yi2 = repmat(Yi(:,index), [1, datasize(2)]);
    land = -1000*ones(size(Yi2));
    pcolor(Xi,Yi2,land); shading interp
    
    pcolor(Xi,Yi,diffe); shading interp;
    
    cm = colormap('redblue');
    cm = [[.9 .9 .9]; cm];
    cm2 = colormap(cm);
    clim2 = [clim(1)-clim_ clim(2)+clim_];
    
    caxis(clim2);
    [cs, h] = contour(Xi, Yi, diffe, contour_interval, 'k');
    clabel(cs,h,'LabelSpacing',144, 'FontSize', 15)
    c = colorbar; c.FontSize = 15;
    c.Limits = clim;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    
    set(gca, 'FontSize', 15)
    ylabel('Depth(m)', 'FontSize', 15)
    xlabel('Latitude(^oN)', 'FontSize', 15)
    
    ax = get(gca);
    xlim([ax.XLim(1)-0.005 ax.XLim(2)+0.01])
    ylim([-100 0.5])
    ax.XAxis.TickDirection = 'out';
    ax.YAxis.TickDirection = 'out';
    ax.XAxis.LineWidth = 2;
    ax.YAxis.LineWidth = 2;
    
    titlename = ['Anomaly ', datestr(datenum(mts, 'mm'), 'mmm'), ' ', yts];
    %title(titlename, 'FontSize', 25)
    box on
    saveas(gcf, ['diff_', var_str, '_vertical_', section, '_', num2str(loc), '_', casename, '_', yts, mts, '.png'])
end