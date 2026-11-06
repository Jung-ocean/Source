function data = load_OOI_data_daily(region, vari_str, timenum_target)

switch region
    case 'OR_shelf'
        switch vari_str
            case 'Chla'
                variname = 'mass_concentration_of_chlorophyll_a_in_sea_water';
                filepath = '/data/jungjih/Observations/OOI_mooring/OR_shelf_near_surface/';
            case 'NO3'
                variname = 'mole_concentration_of_nitrate_in_sea_water_suna';
                filepath = '/data/jungjih/Observations/OOI_mooring/OR_shelf_near_surface/';
            case 'swrad_net'
                variname = 'netsirr';
                filepath = '/data/jungjih/Observations/OOI_buoy/Oregon_shelf/';
        end
end

filename = [region, '_', vari_str, '.nc'];
file = [filepath, filename];

timenum = double(ncread(file, 'time'))/60/60/24 + datenum(1970,1,1);
vari_all = ncread(file, variname);
data = [];
for ti = 1:length(timenum_target)
    timenum_tmp = timenum_target(ti);
    index = find(floor(timenum) == timenum_tmp);
    data(ti) = mean(vari_all(index));
end

end