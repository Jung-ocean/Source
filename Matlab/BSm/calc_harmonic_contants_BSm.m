%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate harmonic constants of BSm data using t-tide
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2021;
ystr = num2str(yyyy);
mm_start = 1;
mm_end = 1;
depth_start = 5;

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};
constituents = {'M2', 'S2', 'K1', 'O1'};

for si = 3%1:length(stations)
    station = stations{si};
    file = ['uv_1h_', names{si}, '.mat'];
    load(file);

    tindex = find(timenum_1h > datenum(yyyy,mm_start,1) & timenum_1h < datenum(yyyy,mm_end+1,1));
    timenum = timenum_1h(tindex);
    u_tmp1 = u_obs_1h(:,tindex);
    v_tmp1 = v_obs_1h(:,tindex);

    nanindex = find(sum(isnan(u_tmp1),2) ~= size(u_tmp1,2));
    depth_tmp = depth_1m(nanindex);
    u_tmp2 = u_tmp1(nanindex,:);
    v_tmp2 = v_tmp1(nanindex,:);

    dindex = find(depth_tmp >= depth_start);
    depth = depth_tmp(dindex);
    u = u_tmp2(dindex,:);
    v = v_tmp2(dindex,:);
    
    for di = 1:length(depth)
        if sum(isnan(u(di,:)),2) > 0
            u_raw = u(di,:);
            u(di,:) = fillmissing(u(di,:), 'linear', 'EndValues', 'none');
%             figure; hold on; grid on;
%             plot(u(di,:));
%             plot(u_raw);
        end
        if sum(isnan(v(di,:)),2) > 0
            v_raw = v(di,:);
            v(di,:) = fillmissing(v(di,:), 'linear', 'EndValues', 'none');
%             figure; hold on; grid on;
%             plot(v(di,:));
%             plot(v_raw);
        end
    end

    ubar(si,:) = mean(u,1);
    vbar(si,:) = mean(v,1);

    figure; hold on; grid on;
    plot(timenum, ubar(si,:));
    ylim([-100 100])
    figure; hold on; grid on;
    plot(timenum, vbar(si,:));
    ylim([-100 100])

    interval = 1;
    lat = mean(lat_obs(:), 'omitnan');

    output = ['harmonic_ubar_', stations{si}, '.txt'];
    [tidestruc, pout] = t_tide(ubar(si,:), ...
        'interval', interval, ...
        'latitude', lat, ...
        'start', timenum(1), ...
        'secular', 'mean', ...
        'rayleigh', 1, ...
        'output', output, ...
        'shallow', 'M10', ...
        'error', 'wboot', ...
        'synthesis', 1);
    for ci = 1:length(constituents)
        cons = constituents{ci};
        index = find(ismember(tidestruc.name, {cons})==1);
        ubar_freq(si,ci) = tidestruc.freq(index);
        ubar_amp(si,ci) = tidestruc.tidecon(index,1);
        ubar_pha(si,ci) = tidestruc.tidecon(index,3);
    end
    ubar_predict(si,:) = pout;

    output = ['harmonic_vbar_', stations{si}, '.txt'];
    [tidestruc, pout] = t_tide(vbar(si,:), ...
        'interval', interval, ...
        'latitude', lat, ...
        'start', timenum(1), ...
        'secular', 'mean', ...
        'rayleigh', 1, ...
        'output', output, ...
        'shallow', 'M10', ...
        'error', 'wboot', ...
        'synthesis', 1);
    for ci = 1:length(constituents)
        cons = constituents{ci};
        index = find(ismember(tidestruc.name, {cons})==1);
        vbar_freq(si,ci) = tidestruc.freq(index);
        vbar_amp(si,ci) = tidestruc.tidecon(index,1);
        vbar_pha(si,ci) = tidestruc.tidecon(index,3);
    end
    vbar_predict(si,:) = pout;
end % si

save(['harmonic_constants_BSm_', ystr, '.mat'], 'stations', 'names', 'constituents', 'timenum', 'depth', 'u', 'ubar', 'ubar_freq', 'ubar_amp', 'ubar_pha', 'ubar_predict', 'v', 'vbar', 'vbar_freq', 'vbar_amp', 'vbar_pha', 'vbar_predict')