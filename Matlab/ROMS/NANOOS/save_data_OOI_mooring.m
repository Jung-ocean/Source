%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save OOI mooring data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

region = 'WA_offshore';
varis = {'temp', 'salt', 'dens', 'do', 'uvel', 'vvel'};

load_OOI_mooring_info
rindex = find(strcmp(regions, region));
lat = lats(rindex);
lon = lons(rindex);
timenum_ref = datenum(1970,1,1);

datenum_start = datenum(2023,1,1);
datenum_end = datenum(2024,12,31);
timenum = datenum_start:datenum_end;

for vi = 1:length(varis)
    vari_str = varis{vi};

    switch vari_str
        case 'temp'
            varname = 'sea_water_temperature_profiler_depth_enabled';
        case 'salt'
            varname = 'sea_water_practical_salinity_profiler_depth_enabled';
        case 'dens'
            varname = 'sea_water_density_profiler_depth_enabled';
        case 'do'
            varname = 'moles_of_oxygen_per_unit_mass_in_sea_water_profiler_depth_enabled';
        case 'uvel'
            varname = 'eastward_sea_water_velocity_profiler_depth_enabled';
        case 'vvel'
            varname = 'northward_sea_water_velocity_profiler_depth_enabled';
    end

    filepath = '/data/jungjih/Observations/OOI_mooring/';
    filename = [region, '_', vari_str, '.nc'];
    file = [filepath, filename];
    if ~exist(file)
        continue
    end

    timenum_tmp = datenum(ncread(file, 'time')/60/60/24 + timenum_ref);
    depth_tmp = ncread(file, 'z');
    vari_tmp = ncread(file, varname);

    depth = unique(depth_tmp);
    vari = NaN(length(depth), length(timenum));
    for ti = 1:length(timenum)
        timenum_target = timenum(ti);

        for di = 1:length(depth)
            index = find(depth_tmp == depth(di) & ...
                timenum_tmp >= timenum_target & timenum_tmp < timenum_target+1);

            if isempty(index)
                vari(di,ti) = NaN;
            else
                vari(di,ti) = mean(vari_tmp(index));
            end
        end
        disp([datestr(timenum_target, 'yyyymmdd'), '...'])
    end

    save([vari_str, '_', region, '_daily.mat'], ...
        'timenum', 'depth', 'vari')
end