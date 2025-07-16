%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot tidal ellipse using BSm data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2023;
ystr = num2str(yyyy);

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};

si = 3;
ci = 1;

scale = 3/10;
y_barotropic = 5;
y_scale = -4;
scale_value = 10;

ylimit = [-60 15];


load(['harmonic_constants_BSm_bc_', ystr, '.mat']);

% % Check current direction
% figure; hold on; grid on;
% for ti = 1:length(u)
%     quiver(0, 0, u(ti), v(ti), 0, '-k')
%     pause
% end

figure; hold on; grid on
set(gcf, 'Position', [1 200, 1800 500])
title({[stations{si}, ' station tidal ellipse (', datestr(timenum_target(1), 'mmm dd'), '-', datestr(timenum_target(end), 'mmm dd, yyyy'), ')'], ''})

for ti = 1:length(timenum_target)
    timenum_tmp = timenum_target(ti);

    freq_u = 2*pi*ubar_freq(ti,ci); % (cycles/hr) to angular frequency
    Au = scale.*ubar_amp(ti,ci);
    Phi_u = ubar_pha(ti,ci);
    freq_v = 2*pi*vbar_freq(ti,ci); % (cycles/hr) to angular frequency
    Av = scale.*vbar_amp(ti,ci);
    Phi_v = vbar_pha(ti,ci);

    [SEMA ECC INC PHA w]=ap2ep(Au, Phi_u, Av, Phi_v);

    t = 0:.1:(20*pi./freq_u);
    u = Au*cos(freq_u.*t-Phi_u*pi/180);
    v = Av*cos(freq_v.*t-Phi_v*pi/180);
    w = u+i.*v;

    if length(w) == 1
        continue
    end

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

    %     % Check ellipse direction
    %     figure; hold on; grid on;
    %     for ti = 1:length(t)
    %         plot([0, real(w(ti))], [0, imag(w(ti))], '-r')
    %         pause
    %     end

    Sma=SEMA;
    Smi=SEMA*ECC;
    D=INC;

    e = ellipse(Sma,Smi,D*pi/180,timenum_tmp,y_barotropic,'k');
    p = plot([timenum_tmp, timenum_tmp+real(w(1))], [y_barotropic, y_barotropic+imag(w(1))], '-k');
    if strcmp(direction, 'cw')
%         marker = '>';
        e.Color = 'k';
        p.Color = 'k';
    elseif strcmp(direction, 'ccw')
%         marker = '<';
        e.Color = 'r';
        p.Color = 'r';
    end
%     index = find(imag(w) == max(imag(w)));
%     p = plot(timenum_tmp+real(w(index)), y_barotropic+imag(w(index)), marker, 'MarkerSize', 6, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');

    % Baroclinic plot
    for di = 1:length(depth)
        depth_tmp = -depth(di);
        freq_u = 2*pi*u_freq(ti,di,ci); % (cycles/hr) to angular frequency
        Au = scale.*u_amp(ti,di,ci);
        Phi_u = u_pha(ti,di,ci);
        freq_v = 2*pi*v_freq(ti,di,ci); % (cycles/hr) to angular frequency
        Av = scale.*v_amp(ti,di,ci);
        Phi_v = v_pha(ti,di,ci);

        [SEMA ECC INC PHA w]=ap2ep(Au, Phi_u, Av, Phi_v);

        t = 0:.1:(20*pi./freq_u);
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

        Sma=SEMA;
        Smi=SEMA*ECC;
        D=INC;

        Sma_baroclinic(ti, di, ci) = Sma./scale;

        e = ellipse(Sma,Smi,D*pi/180,timenum_tmp,depth_tmp,'k');
        p = plot([timenum_tmp, timenum_tmp+real(w(1))], [depth_tmp, depth_tmp+imag(w(1))], '-k');
        if strcmp(direction, 'cw')
%             marker = '>';
            e.Color = 'k';
            p.Color = 'k';
        elseif strcmp(direction, 'ccw')
%             marker = '<';
            e.Color = 'r';
            p.Color = 'r';
        end
%         index = find(imag(w) == max(imag(w)));
%         p = plot(timenum_tmp+real(w(index)), depth_tmp+imag(w(index)), marker, 'MarkerSize', 6, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');

    end
end

% Scale
Au = scale.*scale_value;
Phi_u = 0;
Av = scale.*scale_value;
Phi_v = 90;

freq_u = 0.0805;
freq_v = 0.0805;

[SEMA ECC INC PHA w]=ap2ep(Au, Phi_u, Av, Phi_v);

Sma=SEMA;
Smi=SEMA*ECC;
D=INC;

e = ellipse(Sma,Smi,D*pi/180,timenum_target(end)-20,y_scale,'k');
plot([timenum_target(end)-20, timenum_target(end)-20+real(w(1))], [y_scale, y_scale+imag(w(1))], '-k')
text(timenum_target(end)-16, y_scale, [num2str(scale_value), ' cm/s'], 'FontSize', 15)
axis equal
xlim([timenum_target(1)-10 timenum_target(end)+10])
ylim(ylimit);

xticks(datenum(yyyy,1:12,1));
datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
ylabel('Depth (m)');

set(gca, 'FontSize', 15)

title(['Horizontal M2 tidal current ellipses at ', station, ' stations (black = CW & red = CCW)']);
box on

print(['M2_tidal_ellipse_', station, '_', ystr], '-dpng')