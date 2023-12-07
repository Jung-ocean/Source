%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ECMWF ERA5 monthly wind field on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

filepath = 'D:\Data\Atmosphere\ECMWF_interim\';
casename = 'YECS_large';
[lon_target, lat_target] = domain_J(casename);

year_mean = 2013:2013;
month_mean = 7:8;

year_figure = 2013;
month_figure = 7:8;

load wind_climate(2006_2015).mat

uwind_sum = zeros(2,15,23); vwind_sum = zeros(2,15,23);
for yi = 1:length(year_mean)
    year_target = year_mean(yi); ystr = num2str(year_target)
    
    for mi = 1:length(month_mean)
        
        month_target = month_mean(mi); mstr = num2char(month_target,2);
        
        ufilepath = ['D:\Data\Atmosphere\ECMWF_ERA5\10m_u_component_of_wind\', ystr, '\', ystr, mstr, '\'];
        vfilepath = ['D:\Data\Atmosphere\ECMWF_ERA5\10m_v_component_of_wind\', ystr, '\', ystr, mstr, '\'];
        
        ufilename = ['ECMWF_ERA5_10m_u_component_of_wind_', ystr, mstr, '.nc'];
        vfilename = ['ECMWF_ERA5_10m_v_component_of_wind_', ystr, mstr, '.nc'];
        
        ufile = [ufilepath, ufilename];
        vfile = [vfilepath, vfilename];
        
        unc = netcdf(ufile);
        
        longitude = unc{'longitude'}(:);
        latitude = unc{'latitude'}(:);
        
        lonind = find(lon_target(1) < longitude & longitude < lon_target(2));
        latind = find(lat_target(1) < latitude & latitude< lat_target(2));
        
        uwind = unc{'u10'}(:,latind,lonind);
        usf = unc{'u10'}.scale_factor(:);
        uao = unc{'u10'}.add_offset(:);
        uwind_monthly = squeeze(mean(uwind)).*usf + uao;
        
        lon = longitude(lonind);
        lat = latitude(latind);
        
        vnc = netcdf(vfile);
        
        vwind = vnc{'v10'}(:,latind,lonind);
        vsf = vnc{'v10'}.scale_factor(:);
        vao = vnc{'v10'}.add_offset(:);
        vwind_monthly = squeeze(mean(vwind)).*vsf + vao;
        
        close(unc); close(vnc);
        
        [xx, yy] = meshgrid(lon, lat);
        
        uwind_sum(mi,:,:) = squeeze(uwind_sum(mi,:,:)) + uwind_monthly;
        vwind_sum(mi,:,:) = squeeze(vwind_sum(mi,:,:)) + vwind_monthly;
        
        if year_target == year_figure
            figure;
            map_J(casename)
            puv = puv_J(['ECMWF_raw_', casename]);
            
            % Target figure
            w_target = (uwind_monthly+sqrt(-1).*vwind_monthly);
            h_target = m_psliceuv(xx, yy, w_target, puv.interval, puv.scale_factor, puv.color);
            w_climate = (squeeze(uwind_climate(mi,:,:))+sqrt(-1).*squeeze(vwind_climate(mi,:,:)));
            h_climate = m_psliceuv(xx, yy, w_climate, puv.interval, puv.scale_factor, 'k');
            
            % Scale
            h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
            
            % Text
            m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text, 'FontWeight', 'bold', 'Color', puv.scale_text_color)
            
            h = legend([h_target, h_climate], '2013', 'climate');
            h.Location = 'NorthWest';
            h.FontSize = 15;
            
            saveas(gcf, ['wind_ERA5_', casename, '_', ystr, mstr, '.png'])
        end
    end
end
% uwind_climate = uwind_sum./length(year_mean);
% vwind_climate = vwind_sum./length(year_mean);

% save wind_climate(2006_2015).mat xx yy uwind_climate vwind_climate
% for mi = 1:length(month_mean)
%     month_target = month_mean(mi); mstr = num2char(month_target,2);
%     figure;
%     map_J(casename)
%     puv = puv_J(['ECMWF_raw_', casename]);
%     
%     % Target figure
%     w_target = (squeeze(uwind_climate(mi,:,:))+sqrt(-1).*squeeze(vwind_climate(mi,:,:)));
%     h_target = m_psliceuv(xx, yy, w_target, puv.interval, puv.scale_factor, puv.color);
%     
%     % Scale
%     h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
%     
%     % Text
%     m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text, 'FontWeight', 'bold', 'Color', puv.scale_text_color)
%     
%     saveas(gcf, ['wind_ERA5_', casename, '_climate', mstr, '.png'])
% end