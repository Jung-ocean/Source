%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare tide to BSm data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

si = 4;

yyyy = 2021;
ystr = num2str(yyyy);

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};

filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/figures/';
filename_obs = ['harmonic_constants_BSm_', ystr, '.mat'];
file_obs = [filepath_obs, filename_obs];
load(file_obs);

tindex = find(isnan(ubar(si,:)) ~= 1);
timenum_target = timenum(tindex);

figure;
set(gcf, 'Position', [1 200, 1300 600])
t = tiledlayout(2,4);
title(t, {[stations{si}, ' station barotropic tidal ellipse (', datestr(timenum_target(1), 'mmm dd'), '-', datestr(timenum_target(end), 'mmm dd, yyyy'), ')'], ''})

nexttile(1,[1,4]); hold on; grid on;
p1 = plot(timenum_target, ubar(si,tindex), 'r');

for ci = 1:length(constituents)

    for mi = 1:2
        if mi == 1
            load(file_obs);
            color = 'r';
        else
            load(['harmonic_constants_BSm_ROMS_', ystr, '.mat']);
            color = 'k';

            if ci == 1
                nexttile(1,[1,4]); hold on; grid on;
                p2 = plot(timenum_target, ubar(si,tindex), 'k');
                xticks(datenum(yyyy,1:12,1))
                xlim([datenum(yyyy,1,1)-1 datenum(yyyy+1,1,1)])
                datetick('x', 'keepticks', 'keeplimits')
                ylim([-100 100])
                ylabel('cm/s')
                l = legend([p1, p2], 'Mooring', 'ROMS');
                l.FontSize = 12;
                l.Location = 'NorthWest';
                title('Zonal barotropic current')
            end
        end

        freq_u = 2*pi*ubar_freq(si,ci); % (cycles/hr) to angular frequency
        Au = ubar_amp(si,ci);
        Phi_u = ubar_pha(si,ci);
        freq_v = 2*pi*vbar_freq(si,ci); % (cycles/hr) to angular frequency
        Av = vbar_amp(si,ci);
        Phi_v = vbar_pha(si,ci);

        [SEMA ECC INC PHA w]=ap2ep(Au, Phi_u, Av, Phi_v);

        t = 0:.1:(2*pi./freq_u);
        u = Au*cos(freq_u.*t-Phi_u*pi/180);
        v = Av*cos(freq_v.*t-Phi_v*pi/180);
        w = u+i.*v;

        angle1 = angle(w(1)).*180/pi;
        if angle1 < 0
            angle1 = angle1 + 360;
        end
        angle2 = angle(w(2)).*180/pi;
        if angle2 < 0
            angle2 = angle2 + 360;
        end

        if angle2-angle1 < 0
            direction = 'cw';
        else
            direction = 'ccw';
        end

        %     % Check direction
        %     figure; hold on; grid on;
        %     for ti = 1:length(t)
        %         plot([0, real(w(ti))], [0, imag(w(ti))], '-r')
        %         pause
        %     end

        Sma=SEMA;
        Smi=SEMA*ECC;
        D=INC;

        nexttile(ci+4); hold on; grid on
        ellipse(Sma,Smi,D*pi/180,0,0, color);
        plot([0, real(w(1))], [0, imag(w(1))], '-', 'Color', color)
        if strcmp(direction, 'cw')
            marker = '>';
        elseif strcmp(direction, 'ccw')
            marker = '<';
        end
        index = find(imag(w) == max(imag(w)));
        p = plot(real(w(index)), imag(w(index)), marker, 'MarkerSize', 6, 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
        xlim_current = get(gca, 'xlim');
        xlim([xlim_current(1)-2 xlim_current(2)+2]);
        ylim_current = get(gca, 'ylim');
        ylim([ylim_current(1)-2 ylim_current(2)+2]);
        axis equal
        xt = get(gca, 'XTick');
        set(gca, 'YTick', xt);
        xlabel('u (cm/s)');
        ylabel('v (cm/s)');

        title(constituents{ci});
    end
end

print(['cmp_tide_to_BSm_', stations{si}], '-dpng')