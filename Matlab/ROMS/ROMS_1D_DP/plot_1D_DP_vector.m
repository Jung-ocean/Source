clear; clc; close all

astr = '050';
Hstr = '100';
speed = '09';
wstrs = {['r', speed], ['c', speed], ['p', speed]};

N = 45;
tinterval = 1*3600; % 1 hour
tend = 864000;
savename = ['vector_a', astr, '_H', Hstr, '_w', speed];

filepath_all = '/data/jungjih/ROMS_1D_DP/output_all/';

scale_wind = 3;
xlimit = [-40 40];
ylimit = xlimit;
interval = diff(xlimit)/4;

ei = 0;
for i = 1:length(wstrs)
    ei = ei+1;
    expnames{ei} = ['a', astr, '_H', Hstr, '_w', wstrs{i}];
end
for i = 1:length(wstrs)
    ei = ei+1;
    expnames{ei} = ['a000_H000_w', wstrs{i}];
end

h1 = figure; hold on; grid on
set(gcf, 'Position', [1 1 1300 800])
t = tiledlayout(2,3);
for ti = 1:(tend/tinterval)

    for ei = 1:length(expnames)
        expname = expnames{ei};
        title_str_aice = num2str(str2num(expname(2:4))/100);
        title_str_hice = num2str(str2num(expname(7:9))/100);

        filepath = [filepath_all, 'output_', expname, '/'];
        filename = 'sta.nc';
        file = [filepath, filename];
        ot = ncread(file, 'ocean_time');
        tind = find(ot == tinterval*ti);
        tstr = datestr(ot(tind)/60/60/24, 'dd HH:MM');
        title(t, {['Day ', tstr]}, 'FontSize', 20);

        Uwind = ncread(file, 'Uwind');
        Vwind = ncread(file, 'Vwind');
        u = 100*squeeze(ncread(file, 'u')); % cm
        usurf = squeeze(u(N,:));
        v = 100*squeeze(ncread(file, 'v')); % cm
        vsurf = squeeze(v(N,:));
        uice = 100*squeeze(ncread(file, 'uice')); % cm
        vice = 100*squeeze(ncread(file, 'vice')); % cm

        if strcmp(expname(12), 'p')
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

        % Wind-current angle
        dotProd = dot([Uwind; Vwind], [usurf; vsurf]);
        crossProd = cross([Uwind; Vwind; zeros(size(Uwind))], [usurf; vsurf; zeros(size(usurf))]);
        theta_counterclockwise = atan2d(crossProd(3,:), dotProd); % -180 ~ 180
        theta_counterclockwise(theta_counterclockwise < 0) = theta_counterclockwise(theta_counterclockwise < 0) + 360;
        theta_clockwise = 360 - theta_counterclockwise;
        angle_wind_current = theta_clockwise;

        nexttile(ei); cla; hold on; grid on;
        qwind = quiver(0,0,scale_wind*Uwind(tind),scale_wind*Vwind(tind),0, 'k');
        qwind.LineWidth = 2;
        qwind.MaxHeadSize = 1;

        qwater = quiver(0,0,usurf(tind),vsurf(tind),0, 'b');
        qwater.LineWidth = 2;
        qwater.MaxHeadSize = 1;

        if strcmp(expname(2:4), '000') & strcmp(expname(7:9), '000')

        else
            qice = quiver(0,0,uice(tind),vice(tind),0, 'r');
            qice.LineWidth = 2;
            qice.MaxHeadSize = 1;
        end

        p = plot(xlimit, ylimit, '-', 'Color', [.7 .7 .7]);
        uistack(p, 'bottom')
        axis equal

        xticks([xlimit(1):interval:xlimit(end)]);
        yticks([ylimit(1):interval:ylimit(end)]);

        xlim(xlimit);
        ylim(ylimit);

        %     xlabel('cm/s')
        ylabel('cm/s')

        set(gca, 'FontSize', 15)

        text(-39, 36, ['Wind = ', num2str(speed_wind(tind), '%.1f'), ' m/s'], 'FontSize', 15)
        text(-39, -36, ['Wind-Current = ', num2str(angle_wind_current(tind), '%.1f'), '^o'], 'FontSize', 15, 'Color', 'b')

        if strcmp(expname(2:4), '000') & strcmp(expname(7:9), '000')
            title('No ice', 'FontSize', 15);
        else
            text(-39, -29, ['Wind-Ice = ', num2str(angle_wind_ice(tind), '%.1f'), '^o'], 'FontSize', 15, 'Color', 'r')
            title(['ai = ', title_str_aice, ', ' 'Hi = ', title_str_hice, ' m, wind = ', expname(12:end)], 'FontSize', 15);
        end
    end
    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    % Make gif
    gifname = [savename, '.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

end % ti