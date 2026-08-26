function data = load_OOI_mooring_uv_daily(region, vari_str, timenum_target, depth_target);

filepath_all = '/data/jungjih/Observations/OOI_mooring/';

if strcmp(vari_str, 'uvel') == 1
    variname = 'eastward_sea_water_velocity_mean';
else
    variname = 'northward_sea_water_velocity_mean';
end

switch region
    case 'WA_shelf'
        filepath1 = 'WA_shelf_near_surface/';
        filepath = [filepath_all, filepath1];
        filename = [region, '_', vari_str, '.nc'];
        file = [filepath, filename];

        timenum = double(ncread(file, 'time'))/60/60/24 + datenum(1970,1,1);
        z = double(ncread(file, 'z'));
        vari_all = ncread(file, variname);
        vari = [];
        for ti = 1:length(timenum_target)
            timenum_tmp = timenum_target(ti);
            index = find(floor(timenum) == timenum_tmp);
            vari_tmp = mean(vari_all(:,index),2);
            vari(:,ti) = interp1(z, vari_tmp, abs(depth_target));
        end
        vari1 = vari;

        data(1).name = 'near surface';
        data(1).vari = vari1;

        filepath2 = 'WA_shelf_MFN/';
        filepath = [filepath_all, filepath2];
        filename = [region, '_', vari_str, '.nc'];
        file = [filepath, filename];

        timenum = double(ncread(file, 'time'))/60/60/24 + datenum(1970,1,1);
        z = double(ncread(file, 'z'));
        vari_all = ncread(file, variname);
        vari = [];
        for ti = 1:length(timenum_target)
            timenum_tmp = timenum_target(ti);
            index = find(floor(timenum) == timenum_tmp);
            vari_tmp = mean(vari_all(:,index),2);
            vari(:,ti) = interp1(z, vari_tmp, abs(depth_target));
        end
        vari2 = vari;
        
        data(2).name = 'MFN';
        data(2).vari = vari2;

    case 'OR_shelf'
        filepath1 = 'OR_shelf_near_surface/';
        filepath = [filepath_all, filepath1];
        filename = [region, '_', vari_str, '.nc'];
        file = [filepath, filename];

        timenum = double(ncread(file, 'time'))/60/60/24 + datenum(1970,1,1);
        z = double(ncread(file, 'z'));
        vari_all = ncread(file, variname);
        vari = [];
        for ti = 1:length(timenum_target)
            timenum_tmp = timenum_target(ti);
            index = find(floor(timenum) == timenum_tmp);
            vari_tmp = mean(vari_all(:,index),2);
            vari(:,ti) = interp1(z, vari_tmp, abs(depth_target));
        end
        vari1 = vari;

        data(1).name = 'near surface';
        data(1).vari = vari1;

        filepath2 = 'OR_shelf_cabled/';
        filepath = [filepath_all, filepath2];
        filename = [region, '_', vari_str, '.nc'];
        file = [filepath, filename];

        timenum = double(ncread(file, 'time'))/60/60/24 + datenum(1970,1,1);
        z = double(ncread(file, 'z'));
        vari_all = ncread(file, variname);
        vari = [];
        for ti = 1:length(timenum_target)
            timenum_tmp = timenum_target(ti);
            index = find(floor(timenum) == timenum_tmp);
            vari_tmp = mean(vari_all(:,index),2);
            vari(:,ti) = interp1(z, vari_tmp, abs(depth_target));
        end
        vari2 = vari;
        
        data(2).name = 'cabled';
        data(2).vari = vari2;
end



end