%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot rotary spectrum using calc_rotary_spectrum.m function
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2023;
ystr = num2str(yyyy);

mm_start = 6;
msstr = datestr(datenum(yyyy,mm_start,15), 'mmm');
mm_end = 8;
mestr = datestr(datenum(yyyy,mm_end,15), 'mmm');

xlimit = [-0.1 0.1];
ylimit = [-60 0]; % -80

si = 3;
stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};

climit = [-1 4];
interval = .5;
[color, contour_interval] = get_color('jet', climit, interval);
unit = 'log_1_0(Power)';

figure; hold on; grid on;
set(gcf, 'Position', [1 1 800 800])
t = tiledlayout(2,1);
title(t, {[stations{si}, ' station PSD (',msstr, '-', mestr, ' ', ystr, ', 48 h high-pass filtered)'], ''})

station = stations{si};
file = ['tz_baroclinic_', station, '_', ystr, '.mat'];
load(file);

tindex = find(timenum > datenum(yyyy,mm_start,1) & timenum < datenum(yyyy,mm_end+1,1));
ubar_tmp = ubar(tindex);
vbar_tmp = vbar(tindex);
ubc_tmp = u_baroclinic(:,tindex);
vbc_tmp = v_baroclinic(:,tindex);

nanind = find(isnan(ubar_tmp) == 0);
ubar_target = ubar_tmp(nanind);
vbar_target = vbar_tmp(nanind);
ubc_target = ubc_tmp(:,nanind);
vbc_target = vbc_tmp(:,nanind);

% Barotropic
fs = 1;
% [px,py,pcw,pccw,freq,rdn] = s_rotation_spectra(ubar_target,vbar_target,Fs);
[psd, freq] = calc_rotary_spectrum(ubar_target, vbar_target, fs);

nexttile(1); hold on; grid on;
plot(freq, psd, '-k', 'LineWidth', 1)
set(gca, 'YScale', 'log')
xlim(xlimit)
ylim([1e-2 1e7])

ylabel('Power (cm^2 s^-^2 cph-1)')

% inertial frequency
f = 2*(7.2921e-5)*sind(lat);
T = 2*pi/f;
fc = 1./(T/60/60);

fnames = {'M2', 'S2', 'K1', 'O1', 'fc'};
xdiff_negative = [0 0.003 0.003 0 0];
xdiff_positive = [-0.003 0 0 -0.003 0];
freqs = [0.0805114 0.0833333 0.0417807 0.0387307 fc];
for fi = 1:length(freqs)
    freq = freqs(fi);
    plot([freq freq], [8e5 2e6], '-k', 'LineWidth', 2);
    text(freq + xdiff_positive(fi), 5e6, fnames{fi});
    plot(-[freq freq], [8e5 2e6], '-k', 'LineWidth', 2);
    text(-freq - xdiff_negative(fi), 5e6, fnames{fi});
end
text(-0.095, 3e-2, 'Clockwise', 'FontSize', 15)
text(0.04, 3e-2, 'Counter-clockwise', 'FontSize', 15)

% set(gca,'xticklabel',[])
title('Barotropic (depth-averaged)');

% Baroclinic
bc_psd = [];
for di = 1:size(ubc_target,1)
    u_tmp = ubc_target(di,:);
    v_tmp = vbc_target(di,:);

%     [px,py,pcw,pccw,freq,rdn] = s_rotation_spectra(u_tmp,v_tmp,Fs);
    [psd, freq] = calc_rotary_spectrum(u_tmp, v_tmp, fs);

    bc_psd = [bc_psd; psd];
end

bc_psd = log10(bc_psd);
bc_psd(bc_psd < climit(1)) = climit(1);
bc_psd(bc_psd > climit(2)) = climit(2);

nexttile(2); hold on
contourf(freq, -depth, bc_psd, contour_interval, 'LineColor', 'none');
caxis(climit)
colormap(color)
xlim(xlimit);
ylim(ylimit);

xlabel('Frequency (cph)')
ylabel('Depth (m)');

c = colorbar;
c.Location = 'SouthOutside';
c.Label.String = unit;

title('Baroclinic');

t.Padding = 'compact';
t.TileSpacing = 'compact';

print(['psd_', stations{si}, '_', ystr, '_', msstr, '_', mestr], '-dpng')