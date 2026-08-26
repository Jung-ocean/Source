%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ECMWF monthly wind field on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

filepath = 'D:\Data\Atmosphere\ECMWF_interim\';
casename = 'YECS_large';

year_figure = [2013];
month_figure = 4:6;

% Plot wind field
for yii = 1:length(year_figure)
    for mii = 1:length(month_figure)
        
        yyyy = year_figure(yii); ystr = num2str(yyyy);
        mm = month_figure(mii); mstr = num2char(mm, 2);
        
        %ufilename = ['ECMWF_Interim_u10_', ystr, '.nc'];
        %vfilename = ['ECMWF_Interim_v10_', ystr, '.nc'];
        ufilename = [ystr, '-1.nc'];
        vfilename = [ystr, '-1.nc'];
        
        ufile = [filepath, ufilename];
        vfile = [filepath, vfilename];
        
        unc = netcdf(ufile);
        lon = unc{'longitude'}(:);
        lat = unc{'latitude'}(:);
        time = unc{'time'}(:);
        if isempty(unc{'u10'}.scale_factor(:))
            u10 = unc{'u10'}(:);
        else
            u10 = unc{'u10'}(:).*unc{'u10'}.scale_factor(:) + unc{'u10'}.add_offset(:);
        end
        close(unc)
        timevec = datevec(time/24 + datenum(1900,1,1));
        index = find(timevec(:,1) == yyyy & timevec(:,2) == mm);
        
        vnc = netcdf(vfile);
        if isempty(vnc{'v10'}.scale_factor(:))
            v10 = vnc{'v10'}(:);
        else
            v10 = vnc{'v10'}(:).*vnc{'v10'}.scale_factor(:) + vnc{'v10'}.add_offset(:);
        end
        close(vnc)
        
        u_monthly = squeeze(mean(u10(index,:,:)));
        v_monthly = squeeze(mean(v10(index,:,:)));
        
        u10_target = u_monthly;
        v10_target = v_monthly;
        
        % Calculate wind speed in the plot area
        %[lon_lim, lat_lim] = domain_J(casename);%domain_J('windstress_YSBCW');
        %lat_ind = find(lat_lim(1)+1 < lat & lat < lat_lim(2)-1);
        %lon_ind = find(lon_lim(1)+1 < lon & lon < lon_lim(2)-1);
        
        %u_wind_area = u10_target(lat_ind, lon_ind);
        %v_wind_area = v10_target(lat_ind, lon_ind);
        
        %lon_area = lon(lon_ind);
        %lat_area = lat(lat_ind);
        
        %[xx, yy] = meshgrid(lon_area, lat_area);
        [xx, yy] = meshgrid(lon, lat);
        
        figure
        map_J(casename)
        puv = puv_J(['ECMWF_raw_', casename]);
        
        % Target figure
        w_target = (u10_target+sqrt(-1).*v10_target);
        h_target = m_psliceuv(xx, yy, w_target, puv.interval, puv.scale_factor, puv.color);
        
        % Scale
        h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
        
        % Text
        m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text, 'FontWeight', 'bold', 'Color', puv.scale_text_color)

        % Box
        %[line_lon, line_lat] = domain_J('windstress_YSBCW');
        %plot_line_map(line_lon, line_lat, [0 0.4510 0.7412], '-')
                
%        l = legend([h_mean, h_target], 'Mean (1980-2015)', [yts], 'Location', 'SouthEast');
        
        title(['ECMWF Interim monthly wind ', ystr, mstr], 'fontsize', 15)
        
        %saveas(gcf, ['wind_monthly_ECMWF_Interim_', ystr, mstr, '.png'])
    end
end