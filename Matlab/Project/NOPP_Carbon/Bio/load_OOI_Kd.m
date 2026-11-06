function [timenum_Kd, Kd] = load_OOI_Kd(region, timenum_target)

switch region
    case 'OR_inshore'
        filepath = ['/data/jungjih/Observations/OOI_mooring/OR_inshore_profiler/'];
    case 'OR_shelf'
        filepath = ['/data/jungjih/Observations/OOI_mooring/OR_shelf_profiler/'];
    case 'OR_offshore'
        filepath = ['/data/jungjih/Observations/OOI_mooring/OR_offshore_shallow_profiler/'];
end
filename = [region, '_PAR.nc'];
file = [filepath, filename];

time = ncread(file, 'time');
PAR_raw = ncread(file, 'downwelling_photosynthetic_photon_flux_in_sea_water_profiler_depth_enabled');
actual_range = ncreadatt(file, 'downwelling_photosynthetic_photon_flux_in_sea_water_profiler_depth_enabled', 'actual_range');
depth = ncread(file, 'z');

timenum = time/60/60/24 + datenum(1970,1,1);
PAR_raw(PAR_raw < min(actual_range) | PAR_raw > max(actual_range)) = NaN;
PAR_Wm2 = PAR_raw/4.57;

timenum_Kd = [];
Kd = [];
for ti = 1:length(timenum_target)
    timenum_tmp = timenum_target(ti);
    tindex = find(floor(timenum) == timenum_tmp);
    if isempty(tindex)
        continue
    end

    timenum_tmp2 = timenum(tindex);
    timevec_tmp = datevec(timenum_tmp2);
    hour_unique = unique(timevec_tmp(:,4));
    depth_tmp = depth(tindex);
    PAR_tmp = PAR_Wm2(tindex);

    for hi = 1:length(hour_unique)
        hindex = find(timevec_tmp(:,4) == hour_unique(hi));
        depth_tmp2 = abs(depth_tmp(hindex));
        PAR_tmp2 = PAR_tmp(hindex);

        dindex = find(depth_tmp2 == min(depth_tmp2));
        if length(dindex) > 1
            depth_unique = unique(depth_tmp2);
            depth_tmp3 = depth_unique;
            PAR_tmp3 = [];
            for di = 1:length(depth_unique)
                dindex = find(depth_tmp2 == depth_unique(di));
                PAR_tmp3(di) = mean(PAR_tmp2(dindex));
            end
            depth_tmp2 = depth_tmp3;
            PAR_tmp2 = PAR_tmp3;
            dindex = find(depth_tmp2 == min(depth_tmp2));
        end
        dindex_bottom = find(depth_tmp2 == max(depth_tmp2));
        H = depth_tmp2(dindex_bottom);

        I0 = PAR_tmp2(dindex);
        if I0 < 1
            continue
        end
        I_bottom = PAR_tmp2(dindex_bottom);
        if length(I_bottom) > 1
            H = mean(H);
            I_bottom = mean(I_bottom);
        end

        try
            if I_bottom < 0.01*I0
                z_eu = interp1(PAR_tmp2, depth_tmp2, 0.01*I0);
                k_tmp = -log(0.01)/z_eu;
            else
                k_tmp = -log(I_bottom/I0)/H;
            end

            timenum_Kd = [timenum_Kd; mean(timenum_tmp2(hindex))];
            Kd = [Kd; k_tmp];
        catch
            continue
        end
        
    end
end


end