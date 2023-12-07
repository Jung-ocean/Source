%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot OSTIA daily temperature on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc
%% Setting
% Target date from start to end
start_year = 2018;
start_month = 10;
start_day = 19;
start_datenum = datenum(start_year, start_month, start_day,0,0,0) - datenum(start_year, 01, 01,0,0,0) + 1;

end_month = 10;
end_day = 24;
end_datenum = datenum(start_year, end_month, end_day,0,0,0) - datenum(start_year, 01, 01,0,0,0) + 1;

clim = [10 30];
contour_interval = [clim(1):2:clim(2)];
colormap_style = 'jet';
colorbarname = 'Temperature (deg C)';

% Map limit
casename = 'RV';
[lon_lim, lat_lim] = domain_J(casename);
lim = [lon_lim lat_lim];

% Filepath (related with start_year)
path = ['D:\Data\Satellite\OSTIA\', num2char(start_year,4), '\'];

%% Loop start
for i = start_datenum:end_datenum
    
    filedate = datestr(datenum(start_year,01,01,0,0,0) + i - 1, 'yyyymmdd');
    filepath = [path, num2char(i,3), '\'];
    filename = [filedate, '-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc.bz2'];
    [status, result] = unzip7([filepath, filename], filepath);
    file = [filepath, filename(1:end-4)];
    
    % Read data from netcdf file
    nc = netcdf(file);
    temp = nc{'analysed_sst'}(:);
    scale_factor = nc{'analysed_sst'}.scale_factor(:);
    add_offset = nc{'analysed_sst'}.add_offset(:);
    Lat = nc{'lat'}(:);
    Lon = nc{'lon'}(:);
    mask = nc{'mask'}(:);
    close(nc)
    
    % Convert raw temperature -> Kelvin -> Celsius (with mask)
    temp_Kelvin = temp*scale_factor + add_offset;
    temp_Celsius = temp_Kelvin - add_offset;
    mask(mask ~= 1) = nan;
    temp_mask = temp_Celsius.*mask;
    
    % Set the map and data limit
    lon_ind = find(Lon > lon_lim(1) & Lon < lon_lim(2));
    lat_ind = find(Lat > lat_lim(1) & Lat < lat_lim(2));
    
    Lon_selected = Lon(lon_ind);
    Lat_selected = Lat(lat_ind);
    temp_selected = temp_mask(lat_ind, lon_ind);
    
    % Plot
    figure; hold on;
    map_J(casename)
    m_pcolor(Lon_selected, Lat_selected, temp_selected); colormap(colormap_style); shading flat;
    [cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'w');
    clabel(cs, h);
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
        
    title(['OSTIA ', filedate], 'fontsize', 15)
    saveas(gcf, ['OSTIA_', casename, '_', filedate, '.png'])
    
    disp(['End calculation ', file])
    delete(file)
    %close all
end