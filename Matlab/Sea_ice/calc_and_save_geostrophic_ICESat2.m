%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate geostrophic currents using the ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2022;
mm_all = 1:6;
ispng = 1;
isgif = 1;

g = grd('BSf');

filepath = '/data/jungjih/Observations/Sea_ice/ICESat2/data/';

ystr = num2str(yyyy);
ADT_ICESat2 = [];

polygon = [
    -205.8165   63.9824
    -188.8137   63.9824
    -198.7042   58.9821
    -203.5939   51.2265
    -205.7053   49.8488
    ];

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
dataind = 1;
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filename = dir([filepath, 'ATL21-01_', ystr, mstr, '*']);
    filename = filename.name;
    file = [filepath, filename];

    lat = h5read(file, '/grid_lat')';
    lon = h5read(file, '/grid_lon')';
    grid_x = h5read(file, '/grid_x')';
    grid_y = h5read(file, '/grid_y')';

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        try
            ssha = h5read(file, ['/daily/day', dstr, '/mean_ssha'])';
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_ssha/'], '_FillValue');
            ssha(ssha == fv) = NaN;
            mss = h5read(file, ['/daily/day', dstr, '/mean_weighted_mss'])';
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_mss/'], '_FillValue');
            mss(mss == fv) = NaN;
            geoid = h5read(file, ['/daily/day', dstr, '/mean_weighted_geoid'])';
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_geoid/'], '_FillValue');
            geoid(geoid == fv) = NaN;
        catch
            ssha = NaN;
            mss = NaN;
            geoid = NaN;
        end

        ADT = mss + ssha - geoid;

        index = find(isnan(ADT) ~= 1);
        lon_data = lon(index);
        lat_data = lat(index);
        ADT_data = ADT(index);

        index1 = find(lat_data > min(g.lat_rho(:)) & lat_data < max(g.lat_rho(:)) ...
            & lon_data > min(g.lon_rho(:))+360);
        index2 = find(lat_data > min(g.lat_rho(:)) & lat_data < max(g.lat_rho(:)) ...
            & lon_data < max(g.lon_rho(:)));
        index = [index1; index2];

        lat_Bering = lat_data(index);
        lon_Bering = lon_data(index);
        lon_Bering(lon_Bering > 0) = lon_Bering(lon_Bering > 0) - 360;
        ADT_Bering = ADT_data(index);

        % Cut out data outside the ROMS domain
        [in, on] = inpolygon(lon_Bering, lat_Bering, polygon(:,1), polygon(:,2));
        lat_target = lat_Bering(~in);
        lon_target = lon_Bering(~in);
        ADT_target = ADT_Bering(~in);

        % Find cluster
        cnum = 1;
        cluster_all = [];
        for li = 1:length(lat_target)
            dist = sqrt( (lat_target(li)-lat_target).^2 + (lon_target(li)-lon_target).^2 );
            dindex = find(dist < 1);
            if li == 1
                cluster_all{cnum} = dindex;
            else
                chk_cluster = 0;
                ind_cluster = 0;
                for ci = 1:length(cluster_all)
                    if sum(ismember(cluster_all{ci}, dindex)) ~= 0
                        chk_cluster = 1;
                        ind_cluster = ci;
                    end
                end
                if chk_cluster == 1
                    cluster_all{ind_cluster} = unique([cluster_all{ind_cluster}; dindex]);
                    chk_cluster = 0;
                    ind_cluster = 0;
                else
                    cnum = cnum + 1;
                    cluster_all{cnum} = dindex;
                end
            end
        end

        if isempty(cluster_all)
            lat_interp_all = NaN;
            lon_interp_all = NaN;
            ADT_interp_all = NaN;
            num_ADT_all = NaN;
            lat_mid_all = NaN;
            lon_mid_all = NaN;
            ugeo_all = NaN;
            vgeo_all = NaN;
            num_geo_all = NaN;
        else
            lat_interp_all = [];
            lon_interp_all = [];
            ADT_interp_all = [];
            num_ADT_all = [];
            lat_mid_all = [];
            lon_mid_all = [];
            ugeo_all = [];
            vgeo_all = [];
            num_geo_all = [];
            for ci = 1:length(cluster_all)
                cluster_ind = cluster_all{ci};
                lon_cluster = lon_target(cluster_ind);
                lat_cluster = lat_target(cluster_ind);
                ADT_cluster = ADT_target(cluster_ind);

                minind = find(lat_cluster == min(lat_cluster));
                maxind = find(lat_cluster == max(lat_cluster));

                if length(cluster_ind) == 1
                    lon_start = NaN;
                    lat_start = NaN;

                    lon_end = NaN;
                    lat_end = NaN;
                else
                    %                     lon_start = (lon_cluster(minind) + lon_cluster(minind+1))/2;
                    lon_start = lon_cluster(minind);
                    lat_start = lat_cluster(minind);

                    %                     lon_end = (lon_cluster(maxind) + lon_cluster(maxind-1))/2;
                    lon_end = lon_cluster(maxind);
                    lat_end = lat_cluster(maxind);
                end

                az = azimuth(lat_start, lon_start, lat_end, lon_end);

                lon_interp = linspace(lon_start, lon_end, length(cluster_ind))';
                lat_interp = linspace(lat_start, lat_end, length(cluster_ind))';
                ADT_interp = griddata(lon_cluster, lat_cluster, double(ADT_cluster), lon_interp', lat_interp');
                num_ADT = max(1, length(ADT_interp));

                lon_mid = (lon_interp(2:end) + lon_interp(1:end-1))/2;
                lat_mid = (lat_interp(2:end) + lat_interp(1:end-1))/2;

                gconst = 9.8; % m/s^2
                f = 2*(7.2921e-5)*sind(lat_mid); % /s
                wgs84 = wgs84Ellipsoid("m");

                if size(ADT_interp,1) == 1
                    ADT_interp = ADT_interp';
                end
                dADT = ADT_interp(2:end) - ADT_interp(1:end-1);
                dy = distance(lat_interp(2:end),lon_interp(2:end),lat_interp(1:end-1),lon_interp(1:end-1),wgs84);
                dADT_dy = dADT./dy;

                vel_x = -(gconst./f).*dADT_dy;
                vel_y = 0.*vel_x;

                ugeo = [cosd(az)*vel_x + sind(az)*vel_y];
                vgeo = [-sind(az)*vel_x + cosd(az)*vel_y];
                num_geo = max(1, length(ugeo));

                if isempty(ugeo)
                    lat_interp = NaN;
                    lon_interp = NaN;
                    ADT_interp = NaN;
                    lat_mid = NaN;
                    lon_mid = NaN;
                    ugeo = NaN;
                    vgeo = NaN;
                end

                lat_interp_all = [lat_interp_all; lat_interp];
                lon_interp_all = [lon_interp_all; lon_interp];
                ADT_interp_all = [ADT_interp_all; ADT_interp];
                num_ADT_all = [num_ADT_all; num_ADT];
                lat_mid_all = [lat_mid_all; lat_mid];
                lon_mid_all = [lon_mid_all; lon_mid];
                ugeo_all = [ugeo_all; ugeo];
                vgeo_all = [vgeo_all; vgeo];
                num_geo_all = [num_geo_all; num_geo];
            end
        end

        p = pcolorm(lat, lon, ADT);
        colormap redblue
        caxis([-1 1])
        c = colorbar;
        c.Title.String = 'm';

        scale = 20;
        q = quiverm(lat_mid_all, lon_mid_all, vgeo_all*scale, ugeo_all*scale, 0);
        q(1).Color = 'k';
        q(2).Color = 'k';

        qref = quiverm(65, -195, 0, 0.1*scale, 0);
        qref(1).Color = 'k';
        qref(2).Color = 'k';
        qt = textm(64, -195, '10 cm/s');

        title(datestr(datenum(yyyy,mm,dd), 'mmm dd, yyyy'))

        if ispng == 1
            print(['uv_ICESat2_daily_', ystr, mstr, dstr], '-dpng')
        end

        if isgif == 1
            % Make gif
            gifname = ['uv_ICESat2_daily_', ystr, '.gif'];

            frame = getframe(h1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if mi == 1 && di == 1
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end
        end
        delete(p)
        delete(q)
        delete(qref)
        delete(qt)

        data_ICESat2(dataind).timenum = datenum(yyyy,mm,dd);
        data_ICESat2(dataind).lat_ADT = lat_interp_all;
        data_ICESat2(dataind).lon_ADT = lon_interp_all;
        data_ICESat2(dataind).ADT = ADT_interp_all;
        data_ICESat2(dataind).num_ADT = num_ADT_all;
        data_ICESat2(dataind).lat_geo = lat_mid_all;
        data_ICESat2(dataind).lon_geo = lon_mid_all;
        data_ICESat2(dataind).ugeo = ugeo_all;
        data_ICESat2(dataind).vgeo = vgeo_all;
        data_ICESat2(dataind).num_geo = num_geo_all;
        
        dataind = dataind + 1;
    end
end

save(['uv_ICESat2_', ystr, '.mat'], 'data_ICESat2')