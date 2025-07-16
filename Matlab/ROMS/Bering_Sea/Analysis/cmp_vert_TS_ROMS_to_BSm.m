%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare vertical TS from ROMS to BSm
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

gc = grd('BSf');
ge = grd('BSf_s7b3');

yyyy = 2022;
ystr = num2str(yyyy);
mm_all = [1:6];

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};

filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/figures/';

for si = 1:length(stations)
    filename_obs = ['ts_1h_', names{si}, '.mat'];
    file_obs = [filepath_obs, filename_obs];
    load(file_obs)
    lat_target = mean(lat_obs(:), 'omitnan');
    lon_target = mean(lon_obs(:), 'omitnan');

    timevec_obs = datevec(timenum_1h);

    figure; hold on; grid on;
    t = tiledlayout(2,length(mm_all));
    title(t, {[stations{si}, ' station TS'], ''}, 'FontSize', 15)

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        
        index = find(timevec_obs(:,1) == yyyy & timevec_obs(:,2) == mm);
        temp_obs_monthly = mean(temp_obs_1h(:,index), 2, 'omitnan');
        salt_obs_monthly = mean(salt_obs_1h(:,index), 2, 'omitnan');

        temp_con_monthly = load_models_profile_monthly('BSf', gc, 'temp', yyyy, mm, lat_target, lon_target, -depth_1m);
        salt_con_monthly = load_models_profile_monthly('BSf', gc, 'salt', yyyy, mm, lat_target, lon_target, -depth_1m);
        
        temp_exp_monthly = load_models_profile_monthly('BSf_s7b3', ge, 'temp', yyyy, mm, lat_target, lon_target, -depth_1m);
        salt_exp_monthly = load_models_profile_monthly('BSf_s7b3', ge, 'salt', yyyy, mm, lat_target, lon_target, -depth_1m);

        nexttile(mi); hold on; grid on;
        p1 = plot(temp_con_monthly, -depth_1m, '-k', 'LineWidth', 2);
        p2 = plot(temp_exp_monthly, -depth_1m, '.g', 'LineWidth', 2);
        p3 = plot(temp_obs_monthly, -depth_1m, '.r', 'MarkerSize', 15);
        xlabel('Temperature (^oC)')
        ylabel('Depth (m)');
        xlim([-3 14])
        set(gca, 'FontSize', 12)
        title(['Temp (', datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ')'], 'FontSize', 12)
        if mi == 1
            l = legend([p3, p1, p2], 'Obs', 'Model', 'Model (s7b3)');
            l.FontSize = 10;
            l.Location = 'SouthEast';
        end

        nexttile(mi+length(mm_all)); hold on; grid on;
        plot(salt_con_monthly, -depth_1m, '-k', 'LineWidth', 2);
        plot(salt_exp_monthly, -depth_1m, '.g', 'LineWidth', 2);
        plot(salt_obs_monthly, -depth_1m, '.r', 'MarkerSize', 15);
        xlabel('Salinity (psu)')
        ylabel('Depth (m)');
        xlim([29 34])
        set(gca, 'FontSize', 12)
        title(['Salt (', datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ')'], 'FontSize', 12)
    end
    figure(si)
    set(gcf, 'Position', [1 1 1800 900])
    print(['cmp_TS_to_BSm_', stations{si}], '-dpng')
end