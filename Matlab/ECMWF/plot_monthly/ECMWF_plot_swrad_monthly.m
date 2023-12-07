%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ECMWF monthly air pressure field on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

%% File
filepath = 'D:\Data\Atmosphere\ECMWF_interim\';
filename = '2013-2.nc';
file = [filepath, filename];
%% Setting

average = 0; % 1 = calculate N year average
casename = 'EYECS';

% Target period (figure)
Year_figure = [2013:2013]; Month_figure = [1:12];

if average
    %     % Average period
    %     Year_mean = [2001:2001]; Month_mean = [7, 8];
end

%% Read netcdf file
nc = netcdf(file);
ssrd = nc{'ssrd'}(:);
ssrd_scale_factor = nc{'ssrd'}.scale_factor(:); ssrd_add_offset = nc{'ssrd'}.add_offset(:);
lat = nc{'latitude'}(:); lon = nc{'longitude'}(:); [xx,yy] = meshgrid(lon,lat);
time = nc{'time'}(:);
close(nc)

ssrd_J = ssrd.*ssrd_scale_factor + ssrd_add_offset;
ssrd_W = ssrd_J/43200;

date = datestr(time/24 + datenum(1900,01,01), 'yyyymmHH');
%% Array surface pressure component monthly
for ti = 1:length(time)/2
    swrad_daily(ti,:,:) = squeeze(ssrd_W(2*ti-1, :, :)) + squeeze(ssrd_W(2*ti, :, :));
end

%% Plot surface pressure field
for yii = 1:length(Year_figure)
    for mii = 1:length(Month_figure)
        
        year = Year_figure(yii); ystr = num2str(year);
        month = Month_figure(mii); mstr = num2char(month,2);
        
        index_all = [0 cumsum(eomday(year,1:12))];
        index_start = index_all(mii)+1;
        index_end = index_all(mii+1);
                
        swrad = squeeze(mean(swrad_daily(index_start:index_end,:,:)));
        
        clim = [600 1500];
        contour_interval = clim(1):100:clim(end);
        
        figure;
        map_J(casename)
                
        m_pcolor(xx, yy, swrad); colormap('parula'); shading flat;
        [cs, h] = m_contour(xx, yy, swrad, contour_interval, 'k', 'LineWidth', 1);
        clabel(cs, h, 'FontWeight', 'bold');
        c = colorbar; c.FontSize = 15;
        c.Label.String = 'Solar radiation (W/m^2)'; c.Label.FontSize = 15;
        %caxis(clim);
        
        if average
            % Mean figure
            %w_mean = eval(['uwind_mean_', month_fig '+sqrt(-1).*vwind_mean_', month_fig]);
            %h_mean = m_psliceuv(xx, yy, w_mean, interval, scale, 'k');
            %m_text(text1_Loc(1), text1_Loc(2), 'Mean (2006-2015)', 'fontsize', 15, 'fontweight', 'bold', 'color', 'k')
        end
        
        title(['ECMWF monthly mean of solar radiation ', ystr, mstr], 'fontsize', 15)
        
        saveas(gcf, ['ECMWF_monthly_swrad_', casename, '_', ystr, mstr, '.png'])
        disp([' End plotting ', ystr, mstr])
    end
end