%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare vertical TS from ROMS to BSm
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

g = grd('BSf');

yyyy = 2021;
ystr = num2str(yyyy);
mm_all = [1:2:12];

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};
staind = [2 3 4 5];

filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/figures/';

for si = 1:length(stations)
    filename_obs = ['ts_1h_', names{si}, '.mat'];
    file_obs = [filepath_obs, filename_obs];
    load(file_obs)

    timevec_obs = datevec(timenum_1h);

    figure; hold on; grid on;
    t = tiledlayout(2,length(mm_all));
    title(t, {[stations{si}, ' station TS'], ''}, 'FontSize', 15)

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        
        index = find(timevec_obs(:,1) == yyyy & timevec_obs(:,2) == mm);
        temp_obs_monthly = mean(temp_obs_1h(:,index), 2, 'omitnan');
        salt_obs_monthly = mean(salt_obs_1h(:,index), 2, 'omitnan');

        if mm < 7
            filepath = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2020/Dsm4_nKC/';
            filename = 'Winter_2020_Dsm4_nKC_sta.nc';
            file = [filepath, filename];
        else
            filepath = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2021/Dsm4_nKC/';
            filename = 'SumFal_2021_Dsm4_nKC_sta.nc';
            file = [filepath, filename];
        end
        ot = ncread(file, 'ocean_time');
        timenum = ot/60/60/24 + datenum(1968,5,23);
        timevec = datevec(timenum);
        index = find(timevec(:,1) == yyyy & timevec(:,2) == mm);
        lat_model = ncread(file, 'lat_rho', [staind(si)], [1]);
        lon_model = ncread(file, 'lon_rho', [staind(si)], [1]);
        h = ncread(file, 'h', [staind(si)], [1]);
        zeta = ncread(file, 'zeta', [staind(si), index(1)], [1, length(index)]);
        temp = ncread(file, 'temp', [1 staind(si), index(1)], [Inf, 1, length(index)]);
        salt = ncread(file, 'salt', [1 staind(si), index(1)], [Inf, 1, length(index)]);
        
        zeta_mean = mean(zeta);
        depth = squeeze(zlevs(h,zeta_mean,g.theta_s,g.theta_b,g.hc,g.N,'r',2));

        temp_model_monthly = mean(temp, 3);
        salt_model_monthly = mean(salt, 3);
        
        nexttile(mi); hold on; grid on;
        p1 = plot(temp_model_monthly, depth, '-k', 'LineWidth', 2);
        p2 = plot(temp_obs_monthly, -depth_1m, '.r', 'MarkerSize', 15);
        xlabel('Temperature (^oC)')
        ylabel('Depth (m)');
        xlim([-3 14])
        set(gca, 'FontSize', 12)
        title(['Temp (', datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ')'], 'FontSize', 12)
        if mi == 1
            l = legend([p2, p1], 'Obs', 'Model');
            l.FontSize = 10;
            l.Location = 'SouthEast';
        end

        nexttile(mi+length(mm_all)); hold on; grid on;
        plot(salt_model_monthly, depth, '-k', 'LineWidth', 2);
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