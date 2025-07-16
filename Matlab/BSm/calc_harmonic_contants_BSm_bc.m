%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate harmonic constants of BSm data using t-tide
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2023;
ystr = num2str(yyyy);
mm_start = 1;
mm_end = 8;

si = 3;
interval = 1; % 1 hour

timenum_target = datenum(yyyy,1,1):4:datenum(yyyy,8,31);

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};
% constituents = {'M2', 'S2', 'K1', 'O1'};
constituents = {'M2'};

station = stations{si};
name = names{si};
file = ['tz_baroclinic_', station, '_', ystr, '.mat'];
load(file);

for ti = 1:length(timenum_target)
    timenum_tmp = timenum_target(ti);
    tindex = find(timenum > timenum_tmp-7 -1e-4 & timenum < timenum_tmp+7 +1e-4);

    if length(tindex) > 336
        timenum_tmp = timenum(tindex);
        ubar_tmp = ubar(tindex);
        vbar_tmp = vbar(tindex);

        [tidestruc, pout] = t_tide(ubar_tmp, ...
            'interval', interval, ...
            'latitude', lat, ...
            'start', timenum_tmp(1), ...
            'secular', 'mean', ...
            'rayleigh', 1, ...
            'shallow', 'M10', ...
            'error', 'wboot', ...
            'synthesis', 1);
        for ci = 1:length(constituents)
            cons = constituents{ci};
            index = find(ismember(tidestruc.name, {cons})==1);
            ubar_freq(ti,ci) = tidestruc.freq(index);
            ubar_amp(ti,ci) = tidestruc.tidecon(index,1);
            ubar_pha(ti,ci) = tidestruc.tidecon(index,3);
        end

        [tidestruc, pout] = t_tide(vbar_tmp, ...
            'interval', interval, ...
            'latitude', lat, ...
            'start', timenum_tmp(1), ...
            'secular', 'mean', ...
            'rayleigh', 1, ...
            'shallow', 'M10', ...
            'error', 'wboot', ...
            'synthesis', 1);
        for ci = 1:length(constituents)
            cons = constituents{ci};
            index = find(ismember(tidestruc.name, {cons})==1);
            vbar_freq(ti,ci) = tidestruc.freq(index);
            vbar_amp(ti,ci) = tidestruc.tidecon(index,1);
            vbar_pha(ti,ci) = tidestruc.tidecon(index,3);
        end

        for di = 1:length(depth)
            u_tmp = u_baroclinic(di,tindex);
            v_tmp = v_baroclinic(di,tindex);

            [tidestruc, pout] = t_tide(u_tmp, ...
                'interval', interval, ...
                'latitude', lat, ...
                'start', timenum_tmp(1), ...
                'secular', 'mean', ...
                'rayleigh', 1, ...
                'shallow', 'M10', ...
                'error', 'wboot', ...
                'synthesis', 1);
            for ci = 1:length(constituents)
                cons = constituents{ci};
                index = find(ismember(tidestruc.name, {cons})==1);
                u_freq(ti,di,ci) = tidestruc.freq(index);
                u_amp(ti,di,ci) = tidestruc.tidecon(index,1);
                u_pha(ti,di,ci) = tidestruc.tidecon(index,3);
            end

            [tidestruc, pout] = t_tide(v_tmp, ...
                'interval', interval, ...
                'latitude', lat, ...
                'start', timenum_tmp(1), ...
                'secular', 'mean', ...
                'rayleigh', 1, ...
                'shallow', 'M10', ...
                'error', 'wboot', ...
                'synthesis', 1);
            for ci = 1:length(constituents)
                cons = constituents{ci};
                index = find(ismember(tidestruc.name, {cons})==1);
                v_freq(ti,di,ci) = tidestruc.freq(index);
                v_amp(ti,di,ci) = tidestruc.tidecon(index,1);
                v_pha(ti,di,ci) = tidestruc.tidecon(index,3);
            end
        end % di
    else
        ubar_freq(ti,:) = NaN;
        ubar_amp(ti,:) = NaN;
        ubar_pha(ti,:) = NaN;
        vbar_freq(ti,:) = NaN;
        vbar_amp(ti,:) = NaN;
        vbar_pha(ti,:) = NaN;

        u_freq(ti,:,:) = NaN;
        u_amp(ti,:,:) = NaN;
        u_pha(ti,:,:) = NaN;
        v_freq(ti,:,:) = NaN;
        v_amp(ti,:,:) = NaN;
        v_pha(ti,:,:) = NaN;
    end
end % ti

save(['harmonic_constants_BSm_bc_', ystr, '.mat'], ...
    'station', 'name', 'constituents', 'timenum_target', 'depth', ...
    'ubar_freq', 'ubar_amp', 'ubar_pha', ...
    'vbar_freq', 'vbar_amp', 'vbar_pha', ...
    'u_freq', 'u_amp', 'u_pha', ...
    'v_freq', 'v_amp', 'v_pha')