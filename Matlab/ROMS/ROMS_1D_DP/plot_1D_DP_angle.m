clear; clc; close all

wstr = '2022'; % r c p s
astrs = {'025', '050', '075', '100'};
Hstrs = {'050', '100', '150', '200'};

N = 45;
savename = ['angle_', wstr];

filepath_all = '/data/jungjih/ROMS_1D_DP/output_all/';

xlimit = [-15 15];
ylimit = xlimit;
interval = diff(xlimit)/2;

ei = 0;
for ai = 1:length(astrs)
    for hi = 1:length(Hstrs)
        ei = ei+1;
        expnames{ei} = ['a', astrs{ai}, '_H', Hstrs{hi}, '_w', wstr];
    end
end
expnames{ei+1} = ['a000_H000_w', wstr];

h1 = figure;
set(gcf, 'Position', [1 1 1300, 900])
t = tiledlayout(3,1);
for ei = 1:length(expnames)
    expname = expnames{ei};
    title_str_aice = num2str(str2num(expname(2:4))/100);
    title_str_hice = num2str(str2num(expname(7:9))/100);

    switch title_str_hice
        case '0.5'
            color = 'r';
        case '1'
            color = 'g';
        case '1.5'
            color = 'b';
        case '2'
            color = [0.4941 0.1843 0.5569];
    end

    filepath = [filepath_all, 'output_', expname, '/'];
    filename = 'sta.nc';
    file = [filepath, filename];
    ot = ncread(file, 'ocean_time');
    timenum = ot/60/60/24;
    if strcmp(wstr, '2021') | strcmp(wstr, '2022')
        timenum = timenum + datenum(str2num(wstr), 5, 1);
    end

    Uwind = ncread(file, 'Uwind');
    Vwind = ncread(file, 'Vwind');
    u = 100*squeeze(ncread(file, 'u')); % cm
    usurf = squeeze(u(N,:));
    v = 100*squeeze(ncread(file, 'v')); % cm
    vsurf = squeeze(v(N,:));
    uice = 100*squeeze(ncread(file, 'uice')); % cm
    vice = 100*squeeze(ncread(file, 'vice')); % cm

    if strcmp(wstr(1), 'p')
        zeroind = find(Vwind == 0);
        Vwind(zeroind) = 0.0001;
    end

    speed_wind = sqrt(Uwind.*Uwind + Vwind.*Vwind);
    speed_ice = sqrt(uice.*uice + vice.*vice);
    speed_current = sqrt(usurf.*usurf + vsurf.*vsurf);

    %     angle_wind_ice = acosd( (Uwind.*uice + Vwind.*vice) ./ (speed_wind.*speed_ice) );
    %     angle_wind_current = acosd( (Uwind.*usurf + Vwind.*vsurf) ./ (speed_wind.*speed_current) );
    %     angle_ice_current = acosd( (uice.*usurf + vice.*vsurf) ./ (speed_ice.*speed_current) );

    % Wind-ice angle
    dotProd = dot([Uwind; Vwind], [uice; vice]);
    crossProd = cross([Uwind; Vwind; zeros(size(Uwind))], [uice; vice; zeros(size(uice))]);
    theta_counterclockwise = atan2d(crossProd(3,:), dotProd); % -180 ~ 180
    theta_counterclockwise(theta_counterclockwise < 0) = theta_counterclockwise(theta_counterclockwise < 0) + 360;
    theta_clockwise = 360 - theta_counterclockwise;
    angle_wind_ice = theta_clockwise;
    ind360 = find(angle_wind_ice == 360);
    angle_wind_ice(ind360) = 0;
    
    % Wind-current angle
    dotProd = dot([Uwind; Vwind], [usurf; vsurf]);
    crossProd = cross([Uwind; Vwind; zeros(size(Uwind))], [usurf; vsurf; zeros(size(usurf))]);
    theta_counterclockwise = atan2d(crossProd(3,:), dotProd); % -180 ~ 180
    theta_counterclockwise(theta_counterclockwise < 0) = theta_counterclockwise(theta_counterclockwise < 0) + 360;
    theta_clockwise = 360 - theta_counterclockwise;
    angle_wind_current = theta_clockwise;
    ind360 = find(angle_wind_current == 360);
    angle_wind_current(ind360) = 0;

    %     nexttile(ei); cla; hold on; grid on;
    %     qwind = quiver(0,0,Uwind(tind),Vwind(tind),0, 'k');
    %     qwind.LineWidth = 2;
    %     qwind.MaxHeadSize = 1;
    %
    %     qwater = quiver(0,0,usurf(tind),vsurf(tind),0, 'b');
    %     qwater.LineWidth = 2;
    %     qwater.MaxHeadSize = 1;
    %
    %     qice = quiver(0,0,uice(tind),vice(tind),0, 'r');
    %     qice.LineWidth = 2;
    %     qice.MaxHeadSize = 1;

    if ei ~= 17
        nexttile(2); hold on; grid on
        pi(ei) = plot(timenum, angle_wind_ice, 'Color', color);
    end
    %     text(-14.5, 13, ['Wind = ', num2str(speed_wind(tind)), ' m/s'], 'FontSize', 10)
    %     text(-14.5, -10, ['Wind-Current = ', num2str(angle_wind_current(tind), '%.1f'), '^o'], 'FontSize', 10, 'Color', 'b')
    %     text(-14.5, -13, ['Wind-Ice = ', num2str(angle_wind_ice(tind), '%.1f'), '^o'], 'FontSize', 10, 'Color', 'r')

    %     title(['ai = ', title_str_aice, ', ' 'Hi = ', title_str_hice, ' m'])

    nexttile(3); hold on; grid on
    if ei == 17
        pc(ei) = plot(timenum, angle_wind_current, 'Color', 'k', 'LineWidth', 2);
    else
        pc(ei) = plot(timenum, angle_wind_current, 'Color', color);
    end

end
xlabel('Day')

nexttile(2)
if strcmp(wstr, '2021') | strcmp(wstr, '2022')
    xticks(datenum(str2num(wstr), 5, 1:11));
    xlim([datenum(str2num(wstr), 5, 1)-1 datenum(str2num(wstr), 5, 11)+1])
    datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
else
    xticks(0:10)
    xlim([-1 11])
end
yticks(0:50:350)
ylim([0 361])
ylabel('degree')
set(gca, 'FontSize', 15)

l = legend(pi(1:4), 'Hi = 0.5 m (ai = 0.25, 0.5, 0.75, 1)', 'Hi = 1.0 m (ai = 0.25, 0.5, 0.75, 1)', 'Hi = 1.5 m (ai = 0.25, 0.5, 0.75, 1)', 'Hi = 2.0 m (ai = 0.25, 0.5, 0.75, 1)');
l.Location = 'NorthWest';

title('Ice turning angle (Clockwise from the wind)')

nexttile(3)
if strcmp(wstr, '2021') | strcmp(wstr, '2022')
    xticks(datenum(str2num(wstr), 5, 1:11));
    xlim([datenum(str2num(wstr), 5, 1)-1 datenum(str2num(wstr), 5, 11)+1])
    datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
else
    xticks(0:10)
    xlim([-1 11])
end
yticks(0:50:350)
ylim([0 361])
ylabel('degree')
set(gca, 'FontSize', 15)

l = legend([pc(1:4), pc(end)], 'Hi = 0.5 m (ai = 0.25, 0.5, 0.75, 1)', 'Hi = 1.0 m (ai = 0.25, 0.5, 0.75, 1)', 'Hi = 1.5 m (ai = 0.25, 0.5, 0.75, 1)', 'Hi = 2.0 m (ai = 0.25, 0.5, 0.75, 1)', 'No ice');
l.Location = 'NorthWest';

title('Current turning angle (Clockwise from the wind)')

% Wind plot
nexttile(1); hold on; grid on
pw = plot(timenum,speed_wind, 'k');

p_aspect = pbaspect;
d_aspect = daspect;
xscale = p_aspect(1) / d_aspect(1);
yscale = p_aspect(2) / d_aspect(2);
scale = yscale/xscale;

interval = 360;
Uwind_mini = scale*Uwind./10;
Vwind_mini = Vwind./10;
qwind = quiver(timenum(1:interval:end),speed_wind(1:interval:end),Uwind_mini(1:interval:end),Vwind_mini(1:interval:end),0, 'k');
qwind.LineWidth = 2;
qwind.MaxHeadSize = 0.1;

if strcmp(wstr, '2021') | strcmp(wstr, '2022')
    xticks(datenum(str2num(wstr), 5, 1:11));
    xlim([datenum(str2num(wstr), 5, 1)-1 datenum(str2num(wstr), 5, 11)+1])
    datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
else
    xticks(0:10)
    xlim([-1 11])
end
ylim([0 12]);
ylabel('m/s')
set(gca, 'FontSize', 15)

l = legend(pw, expname(11:end));
l.Location = 'NorthWest';

title('Wind speed (line) and vector (scaled by a factor of 0.1)')

t.TileSpacing = 'compact';
t.Padding = 'compact';

print([savename], '-dpng')