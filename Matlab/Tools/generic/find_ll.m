function [lon_ind, lat_ind] = find_ll(lon, lat, lon_range, lat_range)
% ex)
% [lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, [120 130], [30 40])

if isvector(lon)
    lon_ind = find(lon >= lon_range(1) & lon <= lon_range(2));
    lat_ind = find(lat >= lat_range(1) & lat <= lat_range(2));
    
else
    lon_ind1 = find(lon > lon_range(1) & lon < lon_range(2));
    lat_ind1 = find(lat > lat_range(1) & lat < lat_range(2));
    
    chk_lon = ismember(lon_ind1, lat_ind1);
    chk_lat = ismember(lat_ind1, lon_ind1);
    
    lon_ind_chk = lon_ind1(chk_lon);
    lat_ind_chk = lat_ind1(chk_lat);
    
    if isequal(lat_ind_chk, lon_ind_chk)
        lat(lat_ind_chk) = 0;
        [lat_ind, lon_ind] = find(lat == 0);
    else
        error('Please try other method')
    end
    
end

end