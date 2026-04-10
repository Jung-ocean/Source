clear; clc; close all

yyyy_all = 2022:2025;

type = 'GDP'; % GDP or IOS

g = grd('NANOOS');
figure;
set(gcf, 'Position', [1 200 500 800])
plot_map('US_west', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 200], '-k')
plotm([43 43 46 46 43], [-126 -124 -124 -126 -126], '--b')

[lon_lim, lat_lim] = load_domain('US_west');
xv = [lon_lim(1) lon_lim(2) lon_lim(2) lon_lim(1) lon_lim(1)];
yv = [lat_lim(1) lat_lim(1) lat_lim(2) lat_lim(2) lat_lim(1)];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    s = []; xs = []; xe = [];
    switch type
        case 'GDP'
            datenum_ref = datenum(1970,1,1);

            filepath = ['/data/jungjih/Observations/Drifter/GDP/6h/', ystr, '/'];
            files = dir([filepath, '*.nc']);
            for fi = 1:length(files)
                filename = files(fi).name;
                file = [filepath, filename];
                ID = ncread(file, 'ID')';
                start_date = ncread(file, 'start_date')/60/60/24 + datenum_ref;
                start_lon = ncread(file, 'start_lon');
                start_lat = ncread(file, 'start_lat');
                end_date = ncread(file, 'end_date')/60/60/24 + datenum_ref;
                end_lon = ncread(file, 'end_lon');
                end_lat = ncread(file, 'end_lat');

                time = ncread(file, 'time')/60/60/24 + datenum_ref;
                lon = ncread(file, 'lon360')-360;
                lat = ncread(file, 'latitude');

                in = inpolygon(lon, lat, xv, yv);
                index = find(in == 1);
                if ~isempty(index)
                    s(fi) = scatterm(lat, lon, 10, time, 'filled');
                    xs(fi) = plotm(start_lat, start_lon, 'xg', 'MarkerSize', 15, 'LineWidth', 5);
                    xe(fi) = plotm(end_lat, end_lon, 'xr', 'MarkerSize', 15, 'LineWidth', 5);
                end
                if fi == 1
                    colormap jet(12)
                    caxis([datenum(yyyy,1,1), datenum(yyyy,12,31)]);
                    c = colorbar;
                    c.Ticks = datenum(yyyy,1:12,1);
                    datetick(c, 'y', 'mmm dd', 'keeplimits', 'keepticks')
                    title([type, ' (', ystr, ')'], 'FontSize', 15)
                end
            end

        case 'IOS'
            filepath = '/data/jungjih/Observations/Drifter/IOS/data/';
            files = dir([filepath, '*_', ystr, '*drf']);
            for fi = 1:length(files)
                filename = files(fi).name;
                file = [filepath, filename];
                fid = fopen(file);
                % Find the end of header
                while true
                    line = fgetl(fid);
                    if contains(line,'*END OF HEADER')
                        break
                    end
                end
                % Read data
                data = textscan(fid,'%f %s %s %f %f %f %f','MultipleDelimsAsOne',1);
                fclose(fid);

                num1 = data{1};
                date = data{2};
                time = data{3};
                lat  = data{4};
                lon  = data{5};
                flag = data{6};
                SST = data{7};

                t = datetime(strcat(date,{' '},time),'InputFormat','yyyy/MM/dd HH:mm:ss');
                time = datenum(t);

                start_lon = lon(1);
                start_lat = lat(1);
                end_lon = lon(end);
                end_lat = lat(end);

                in = inpolygon(lon, lat, xv, yv);
                index = find(in == 1);
                if ~isempty(index)
                    s(fi) = scatterm(lat, lon, 10, time, 'filled');
                    xs(fi) = plotm(start_lat, start_lon, 'xg', 'MarkerSize', 15, 'LineWidth', 5);
                    xe(fi) = plotm(end_lat, end_lon, 'xr', 'MarkerSize', 15, 'LineWidth', 5);
                end
                if fi == 1
                    colormap jet(12)
                    caxis([datenum(yyyy,1,1), datenum(yyyy,12,31)]);
                    c = colorbar;
                    c.Ticks = datenum(yyyy,1:12,1);
                    datetick(c, 'y', 'mmm dd', 'keeplimits', 'keepticks')
                    title([type, ' (', ystr, ')'], 'FontSize', 15)
                end
            end
    end % type
    
    print([type, '_', ystr], '-dpng')
    delete(s); delete(xs); delete(xe);
end