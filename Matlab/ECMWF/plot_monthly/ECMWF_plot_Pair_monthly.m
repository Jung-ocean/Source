%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ECMWF monthly air pressure field on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

%% File
filepath = '.\';
filename = 'ECMWF_interim_monthly_2000-2016.nc';
file = [filepath, filename];
%% Setting

average = 0; % 1 = calculate N year average
casename = 'ECMWF_pressure';

% Target period (figure)
Year_figure = [2001:2016]; Month_figure = [7 8];

if average
    %     % Average period
    %     Year_mean = [2001:2001]; Month_mean = [7, 8];
end

%% Read netcdf file
nc = netcdf(file);
msl = nc{'msl'}(:);
msl_scale_factor = nc{'msl'}.scale_factor(:); msl_add_offset = nc{'msl'}.add_offset(:);
lat = nc{'latitude'}(:); lon = nc{'longitude'}(:); [xx,yy] = meshgrid(lon,lat);
time = nc{'time'}(:);
close(nc)

msl_Pa = msl.*msl_scale_factor + msl_add_offset;
msl_hPa = msl_Pa/100;

date = datestr(time/24 + datenum(1900,01,01), 'yyyymm');
%% Array surface pressure component monthly
for ti = 1:length(time)
    eval(['sp_', date(ti,:), ' = squeeze(msl_hPa(ti, :, :));'])
end

if average
    %     %% Calculate monthly mean
    %     for mi = 1:length(Month_mean);
    %         uwind_sum = zeros(length(lat), length(lon));
    %         vwind_sum = zeros(length(lat), length(lon));
    %         for yi = 1:length(Year_mean);
    %             eval(['uwind_sum = uwind_sum + uwind_', num2char(Year_mean(yi),4), num2char(Month_mean(mi),2), ';']);
    %             eval(['vwind_sum = vwind_sum + vwind_', num2char(Year_mean(yi),4), num2char(Month_mean(mi),2), ';']);
    %         end
    %         eval(['uwind_mean_', num2char(Month_mean(mi),2) '= uwind_sum/length(Year_mean);'])
    %         eval(['vwind_mean_', num2char(Month_mean(mi),2) '= vwind_sum/length(Year_mean);'])
    %     end
end

%% Plot surface pressure field
for yii = 1:length(Year_figure)
    for mii = 1:length(Month_figure)
        
        tys = num2char(Year_figure(yii), 4);
        tms = num2char(Month_figure(mii), 2);
        
        pressure = eval(['sp_', tys, tms]);
        
        clim = [1000 1015];
        contour_interval = clim(1):3:clim(end);
        
        map_J(casename)
        
        
        m_pcolor(xx, yy, pressure); colormap('msl'); shading flat;
        [cs, h] = m_contour(xx, yy, pressure, contour_interval, 'k', 'LineWidth', 1);
        clabel(cs, h, 'FontWeight', 'bold');
        c = colorbar; c.FontSize = 15;
        c.Label.String = 'Pressure (hPa)'; c.Label.FontSize = 15;
        caxis(clim);
        
        if average
            % Mean figure
            %w_mean = eval(['uwind_mean_', month_fig '+sqrt(-1).*vwind_mean_', month_fig]);
            %h_mean = m_psliceuv(xx, yy, w_mean, interval, scale, 'k');
            %m_text(text1_Loc(1), text1_Loc(2), 'Mean (2006-2015)', 'fontsize', 15, 'fontweight', 'bold', 'color', 'k')
        end
        
        title(['ECMWF monthly mean sea level pressure ', tys, tms], 'fontsize', 15)
        
        saveas(gcf, ['ECMWF_monthly_pressure_', tys, tms, '.png'])
        disp([' End plotting ', tys, tms])
    end
end