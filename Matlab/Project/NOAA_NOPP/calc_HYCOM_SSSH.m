clear; clc; close all

isplot = 1;

filepath = '/data/jungjih/Models/HYCOM/';
[lon_limit, lat_limit] = load_domain('US_west');

dd_all = 1:4;
HH_all = 0:23;

timenum = [];
SSSH = NaN(98,233,length(dd_all)*length(HH_all));
dataind = 0;
for di = 1:length(dd_all)
    dd = dd_all(di);
    dstr = num2str(dd, '%02i');
    for Hi = 1:length(HH_all)
        dataind = dataind+1;
        HH = HH_all(Hi);
        Hstr = num2str(HH, '%02i');

        filename = ['US058GCOM-OPSnce.espc-d-031-hycom_fcst_glby008_202507', dstr, '12_t00', Hstr, '_Sssh.nc'];
        file = [filepath, filename];
        timenum_tmp = ncread(file, 'time')/24 + datenum(2000,1,1);
        timenum = [timenum; timenum_tmp];

        if di == 1 & Hi == 1
            lon = ncread(file, 'lon')-360;
            lat = ncread(file, 'lat');

            lonind = find(lon > lon_limit(1) & lon < lon_limit(2));
            latind = find(lat > lat_limit(1) & lat < lat_limit(2));

            lon = lon(lonind);
            lat = lat(latind);
        end

        SSSH_tmp = ncread(file, 'steric_ssh', [lonind(1) latind(1) 1], [length(lonind) length(latind) 1]);
        SSSH(:,:,dataind) = SSSH_tmp;
    end
end

% Bandpass filter
fs = 1; % 1 hour
freq_M2 = load_tidal_frequency('M2');
freq_M2 = freq_M2/24; % cpd to cph
lf = 0.8*freq_M2;
hf = 1.2*freq_M2;

SSSH_filtered = SSSH;
for i = 1:length(lon)
    for j = 1:length(lat)
        SSSH_tmp = squeeze(SSSH(i,j,:));
        if sum(isnan(SSSH_tmp)) == 0
            SSSH_filtered(i,j,:) = bandpass_butter4(SSSH_tmp, fs, lf, hf, 0);
        end
    end
    disp(['Bandpass filter ', num2str(i), ' / ', num2str(length(lon)), ' ...'])
end
[lat2, lon2] = meshgrid(lat, lon);
save('HYCOM_SSSH.mat', 'timenum', 'lon2', 'lat2', 'SSSH_filtered');

% Plot
if isplot == 1
    g = grd('NANOOS');

    unit = 'cm';
    climit = [-2 2];
    interval = [.5];
    [color, contour_interval] = get_color('redblue', climit, interval);

    f1 = figure; hold on;
    set(gcf, 'Position', [1 200 500 800])
    for ti = 1:size(SSSH_filtered,3)
        SSSH_tmp = 100*squeeze(SSSH_filtered(:,:,ti)); % m to cm
        p = plot_contourf([], lat2, lon2, SSSH_tmp, color, climit, contour_interval);
        if ti == 1
            plot_map('US_west', 'mercator', 'l')
            contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');

            c = colorbar;
            c.Title.String = unit;
            c.Ticks = contour_interval;
        end
        title(['HYCOM M2 SSSH (', datestr(timenum(ti), 'mm/dd/yy HH:MM'), ')'])

        % Make gif
        gifname = ['HYCOM_SSSH.gif'];
        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if ti == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end

        delete(p)
    end
end