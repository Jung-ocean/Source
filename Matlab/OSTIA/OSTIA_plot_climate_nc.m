%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot OSTIA climate mean temperature using .nc file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

domain_case = 'NWP';

% Target year and month
yyyy_all = 2011:2020;
mm_all = 1:12;

% Contour and Colorbar properties
FS = 15;
clim = [0 30];
cinterval = 4;
contour_interval = [clim(1):cinterval:clim(2)];
colormap_style = 'parula';
colorbarname = '^oC';

% Map limit
[lon_lim, lat_lim] = domain_J(domain_case);
lim = [lon_lim lat_lim];

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');
    filename = ['OSTIA_monthly_global_2011_2020.nc'];
    
    nc = netcdf(filename);
    time = nc{'time'}(:);
    
    timevec = datevec(time/60/60/24 + datenum(1981,1,1));
    index = find(ismember(timevec(:,1), yyyy_all) == 1 & timevec(:,2) == mm);
    
    Lon = nc{'lon'}(:);
    Lat = nc{'lat'}(:);
    temp_Kelvin = nc{'analysed_sst'}(index,:,:);
    temp_add_offset = nc{'analysed_sst'}.add_offset(:);
    temp_scale_factor = nc{'analysed_sst'}.scale_factor(:);
    FillValue_ = nc{'analysed_sst'}.FillValue_(:);
    close(nc)
    
    temp_Kelvin(temp_Kelvin == FillValue_) = NaN;
    temp_Kelvin = temp_Kelvin.*temp_scale_factor + temp_add_offset;
    temp_Celsius = temp_Kelvin - 273.15;
    temp = temp_Celsius;
    
    temp_mean = squeeze(mean(temp));
    
    % Set the map and data limit
    lon_ind = find(Lon > lon_lim(1) & Lon < lon_lim(2));
    lat_ind = find(Lat > lat_lim(1) & Lat < lat_lim(2));
    
    if lon_lim(2) > 180
        lon_ind2 = find(Lon > -180 & Lon < lon_lim(2) - 360);
        lon_ind = [lon_ind; lon_ind2];
    end
    
    Lon_selected = Lon(lon_ind);
    Lon_selected(Lon_selected < 0) = Lon_selected(Lon_selected < 0) + 360;
    
    Lat_selected = Lat(lat_ind);
    temp_selected = temp_mean(lat_ind, lon_ind);
    
    % Plot
    figure; hold on;
    map_J(domain_case)
    m_pcolor(Lon_selected, Lat_selected, temp_selected); colormap(colormap_style); shading flat;
    [cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'k');
    h.LineWidth = 1;
    clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
    c = colorbar; c.FontSize = FS;
    c.Title.String = colorbarname; c.Title.FontSize = FS;
    caxis(clim);
    
    setposition(domain_case)
    m_gshhs_i('patch', [.7 .7 .7])
    
    %title(['OSTIA ', tys, tms], 'fontsize', 25);
    saveas(gcf, ['OSTIA_', domain_case, '_climate', mstr, '.png'])
    
end