%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate baroclinic energy flux
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2023;
ystr = num2str(yyyy);

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};

cons = 'M2'; % tide

si = 3;
station = stations{si};
name = names{si};

uv = load(['tz_uv_', station, '_', ystr, '.mat']);
lat = uv.lat;
interval = 1; % 1h;
depth_uv = uv.depth;
u_bc = uv.u_baroclinic/100; % cm/s to m/s
v_bc = uv.v_baroclinic/100; % cm/s to m/s

ts = load(['tz_ts_', station, '_', ystr, '.mat']);
timenum = ts.timenum;
depth_pden = ts.depth_salt;
temp = ts.temp;
salt = ts.salt;
sigma = ts.sigma;
pden = sigma + 1000;

gconst = 9.8;
dz = 1; % 1m
depth_pres = depth_pden(1):dz:depth_uv(end);

for ti = 1:length(timenum)
    pden_interp = interp1(depth_pden, pden(:,ti), depth_pres);
    pres_interp = cumsum(pden_interp.*gconst.*dz);
    pres_bc_interp(:,ti) = pres_interp - mean(pres_interp, 'omitnan');
    u_bc_interp(:,ti) = interp1(depth_uv, u_bc(:,ti), depth_pres);
    v_bc_interp(:,ti) = interp1(depth_uv, v_bc(:,ti), depth_pres);
end

timenum_target = datenum(yyyy,1,1):4:datenum(yyyy,8,31);
for ti = 1:length(timenum_target)
    timenum_tmp = timenum_target(ti);
    tindex = find(timenum > timenum_tmp-7 -1e-4 & timenum < timenum_tmp+7 +1e-4);

    if length(tindex) > 336

        for di = 1:length(depth_pres)
            pres_bc_tmp = pres_bc_interp(di,tindex);
            u_bc_tmp = u_bc_interp(di,tindex);
            v_bc_tmp = v_bc_interp(di,tindex);

            try
                [tidestruc, pout] = t_tide(pres_bc_tmp, ...
                    'interval', interval, ...
                    'latitude', lat, ...
                    'start', timenum_tmp(1), ...
                    'secular', 'mean', ...
                    'rayleigh', 1, ...
                    'shallow', 'M10', ...
                    'error', 'wboot', ...
                    'synthesis', 1);
                index = find(ismember(tidestruc.name, {cons})==1);
                pres_bc_freq = tidestruc.freq(index);
                pres_bc_amp = tidestruc.tidecon(index,1);
                pres_bc_pha = tidestruc.tidecon(index,3);
                pres_bc_pha = pres_bc_pha*pi/180;
                pres_bc_camp(di,1) = pres_bc_amp*exp(-sqrt(-1)*pres_bc_pha);
            catch
                pres_bc_camp(di,1) = NaN;
            end

            try
                [tidestruc, pout] = t_tide(u_bc_tmp, ...
                    'interval', interval, ...
                    'latitude', lat, ...
                    'start', timenum_tmp(1), ...
                    'secular', 'mean', ...
                    'rayleigh', 1, ...
                    'shallow', 'M10', ...
                    'error', 'wboot', ...
                    'synthesis', 1);
                index = find(ismember(tidestruc.name, {cons})==1);
                u_bc_freq = tidestruc.freq(index);
                u_bc_amp = tidestruc.tidecon(index,1);
                u_bc_pha = tidestruc.tidecon(index,3);
                u_bc_pha = pden_pha*pi/180;
                u_bc_camp(di,1) = u_bc_amp*exp(-sqrt(-1)*u_bc_pha);
            catch
                u_bc_camp(di,1) = NaN;
            end

            try
                [tidestruc, pout] = t_tide(v_bc_tmp, ...
                    'interval', interval, ...
                    'latitude', lat, ...
                    'start', timenum_tmp(1), ...
                    'secular', 'mean', ...
                    'rayleigh', 1, ...
                    'shallow', 'M10', ...
                    'error', 'wboot', ...
                    'synthesis', 1);
                index = find(ismember(tidestruc.name, {cons})==1);
                v_bc_freq = tidestruc.freq(index);
                v_bc_amp = tidestruc.tidecon(index,1);
                v_bc_pha = tidestruc.tidecon(index,3);
                v_bc_pha = pden_pha*pi/180;
                v_bc_camp(di,1) = v_bc_amp*exp(-sqrt(-1)*v_bc_pha);
            catch
                v_bc_camp(di,1) = NaN;
            end
        end
                    
        up = real(u_bc_camp.*conj(pres_bc_camp));
        EF_u(ti) = sum(up.*dz, 'omitnan'); % W/m

        vp = real(v_bc_camp.*conj(pres_bc_camp));
        EF_v(ti) = sum(vp.*dz, 'omitnan'); % W/m
    end
end

asdf





% %
% %         timenum_tmp = timenum(tindex);
% %         EF_u_tmp = EF_u(tindex);
% %         EF_v_tmp = EF_v(tindex);
% %
% %         EF_u_bc_avg(ti) = mean(EF_u_tmp);
% %         EF_v_bc_avg(ti) = mean(EF_v_tmp);
% %      else
% %          EF_u_bc_avg(ti) = NaN;
% %          EF_v_bc_avg(ti) = NaN;
% %      end
% % end
%
%
%
%
%
%
%     pres = [];
%     for di = 1:length(depth_pres)
%         if di == 1
%             pres(di,1) = NaN;
%         else
%             pres(di,1) = sum(pden_interp(1:di-1)*gconst*dz); % N/m^2 = Pa
%         end
%     end
%     pres_bc_tmp = pres - mean(pres, 'omitnan');
%
%     u_bc_interp = interp1(depth_uv, u_bc(:,ti), depth_pres)';
%     v_bc_interp = interp1(depth_uv, v_bc(:,ti), depth_pres)';
%
%     up_tmp = pres_bc_tmp.*u_bc_interp; % W/m^2
%     vp_tmp = pres_bc_tmp.*v_bc_interp; % W/m^2
%
%     index = find(isnan(up_tmp) == 0 & isnan(vp_tmp) == 0);
%     if isempty(index)
%         depth_range(ti,:) = NaN;
%     else
%         depth_range(ti,:) = depth_pres(index);
%     end
%
%     EF_u(ti) = sum(up_tmp.*dz, 'omitnan'); % W/m
%     EF_v(ti) = sum(vp_tmp.*dz, 'omitnan'); % W/m
%
%     up(:,ti) = up_tmp;
%     vp(:,ti) = vp_tmp;
%     pres_bc(:,ti) = pres_bc_tmp;
% end


figure;
set(gcf, 'Position', [1 1 1300 800])
t = tiledlayout(3,1);

nexttile(1); hold on; grid on;
dist10 = abs(depth_pden - 10);
index10 = find(dist10 == min(dist10));
dist30 = abs(depth_pden - 30);
index30 = find(dist30 == min(dist30));
dist60 = abs(depth_pden - 50);
index60 = find(dist60 == min(dist60));
plot(timenum, temp(index10,:));
plot(timenum, temp(index30,:));
plot(timenum, temp(index60,:));
xlim([datenum(yyyy,1,1) datenum(yyyy,8,31)])
ylim([-3 12])
xticks(datenum(yyyy,1:12,1));
datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
ylabel('Temperature (^oC)');

nexttile(2); hold on; grid on;
plot(timenum, salt(index10,:));
plot(timenum, salt(index30,:));
plot(timenum, salt(index60,:));
xlim([datenum(yyyy,1,1) datenum(yyyy,8,31)])
ylim([29 33])
xticks(datenum(yyyy,1:12,1));
datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
ylabel('Salinity (psu)');

nexttile(3); hold on; grid on;
plot(timenum_target, sqrt(EF_u_bc_avg.^2 + EF_v_bc_avg.^2), 'k', 'LineWidth', 2)
xlim([datenum(yyyy,1,1) datenum(yyyy,8,31)])
ylim([0 33])
xticks(datenum(yyyy,1:12,1));
datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
ylabel('Energy flux (W/m)');