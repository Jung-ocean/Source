%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ECMWF monthly wind field on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

average = 1;

filepath = 'D:\Data\Atmosphere\ECMWF_interim\monthly\mat\';
casename = 'NWP_small';

year_mean = 1997:2007;
month_mean = 7:8;

year_figure = 2013;
month_figure = 7:8;

u10_avg07 = zeros; u10_avg08 = zeros;
v10_avg07 = zeros; v10_avg08 = zeros;

for yi = 1:length(year_mean)
    year_target = year_mean(yi); yts = num2str(year_target);
    
    ufilename = ['u10_', yts, '_monthly.mat'];
    vfilename = ['v10_', yts, '_monthly.mat'];
    
    ufile = [filepath, ufilename];
    vfile = [filepath, vfilename];
    
    u = load(ufile);
    v = load(vfile);
    
    for mi = 1:length(month_mean)
        month_target = month_mean(mi); mts = num2char(month_target,2);
        
        eval(['u10_avg', mts, ' = u10_avg', mts, ' + u.u10_', yts, mts, ';'])
        eval(['v10_avg', mts, ' = v10_avg', mts, ' + v.v10_', yts, mts, ';'])
        
    end
end
u10_avg07 = u10_avg07/length(year_mean); u10_avg08 = u10_avg08/length(year_mean);
v10_avg07 = v10_avg07/length(year_mean); v10_avg08 = v10_avg08/length(year_mean);

lon = u.longitude; lat = u.latitude;

% Plot wind field
for yii = 1:length(year_figure)
    for mii = 1:length(month_figure)
        
        yts = num2str(year_figure(yii));
        mts = num2char(month_figure(mii), 2);
        
        ufilename = ['u10_', yts, '_monthly.mat'];
        vfilename = ['v10_', yts, '_monthly.mat'];
        
        ufile = [filepath, ufilename];
        vfile = [filepath, vfilename];
        
        u = load(ufile);
        v = load(vfile);
        
        eval(['u10_target = u.u10_', yts, mts, ';'])
        eval(['v10_target = v.v10_', yts, mts, ';'])
        
        % Calculate wind speed in the plot area
        [lon_lim, lat_lim] = domain_J('NWP_small');%domain_J('windstress_YSBCW');
        lat_ind = find(lat_lim(1)+1 < lat & lat < lat_lim(2)-1);
        lon_ind = find(lon_lim(1)+1 < lon & lon < lon_lim(2)-1);
        
        u_wind_area = u10_target(lat_ind, lon_ind);
        v_wind_area = v10_target(lat_ind, lon_ind);
        
        lon_area = lon(lon_ind);
        lat_area = lat(lat_ind);
        
        [xx, yy] = meshgrid(lon_area, lat_area);
        
        figure
        map_J(casename)
        puv = puv_J(['ECMWF_raw_', casename]);
        
        % Target figure
        %w_target = (u_wind_area+sqrt(-1).*v_wind_area);
        %h_target = m_psliceuv(xx, yy, w_target, puv.interval, puv.scale_factor, puv.color);
        
        if average
            eval(['u_avg = u10_avg', mts, '(lat_ind, lon_ind);'])
            eval(['v_avg = v10_avg', mts, '(lat_ind, lon_ind);'])
            
            w_mean = u_avg+sqrt(-1).*v_avg;
            %h_mean = m_psliceuv(xx, yy, w_mean, puv.interval, puv.scale_factor, [.5 .5 .5]);
            h_mean = m_psliceuv(xx, yy, w_mean, puv.interval, puv.scale_factor, puv.color);
        end
        
        % Scale
        h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
        
        % Text
        m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text, 'FontWeight', 'bold', 'Color', puv.scale_text_color)

        
        % Box
        %[line_lon, line_lat] = domain_J('windstress_YSBCW');
        %plot_line_map(line_lon, line_lat, [0 0.4510 0.7412], '-')
                
%        l = legend([h_mean, h_target], 'Mean (1980-2015)', [yts], 'Location', 'SouthEast');
        
        %title(['ECMWF monthly wind ', yts, mts], 'fontsize', 15)
    end
end