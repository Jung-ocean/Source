clear; clc; close all

region = 'Oregon';
[lon_lim, lat_lim] = load_domain(region);

time_rec = 196;
filenum = time_rec;
fstr = num2str(filenum, '%04i');

source = ['/data/jungjih/Models/LiveOcean/daily/ocean_avg_', fstr, '.nc'];
gs = grd('LiveOcean');

bndy = './boundary_Oregon_1km.nc';
g = grd('Oregon_1km');

direction = 'south';
varis = {'temp', 'salt', 'u', 'v'};

figure;
set(gcf, 'Position', [1 200 800 500])
t = tiledlayout(1,2);
t.Padding = 'compact';
t.TileSpacing = 'compact';

for vi = 1:length(varis)
    vari = varis{vi};
    switch vari
        case 'temp'
            str = 'rho';
            zstr = 'z_r';
            climit = [0 12];
            unit = '^oC';
        case 'salt'
            str = 'rho';
            zstr = 'z_r';
            climit = [29 35];
            unit = 'psu';
        case 'u'
            str = 'u';
            zstr = 'z_u';
            climit = [-.3 .3];
            unit = 'm/s';
        case 'v'
            str = 'v';
            zstr = 'z_v';
            climit = [-.3 .3];
            unit = 'm/s';
    end
    lon_source = eval(['gs.lon_', str]);
    lat_source = eval(['gs.lat_', str]);
    z_source = eval(['gs.', zstr]);
    lon_bndy = eval(['g.lon_', str]);
    lat_bndy = eval(['g.lat_', str]);
    z_bndy = eval(['g.', zstr]);

    switch direction
        case 'south'
            lat = min(lat_bndy(:));
            lon1 = min(lon_bndy(:));
            lon2 = max(lon_bndy(:));

            latdist = abs(gs.lat_rho(1,:) - lat);
            latind = find(latdist == min(latdist));
            lonind = find(gs.lon_rho(:,1) > lon1 & gs.lon_rho(:,1) < lon2);
            vari_source = ncread(source, vari, [lonind(1) latind, 1, 1], [length(lonind), 1, Inf, 1]);
            vari_source = squeeze(vari_source);
            z_source = squeeze(z_source(lonind, latind, :));
            xdata_1d = lon_source(lonind, latind);
            xdata_source = repmat(xdata_1d, [1, gs.N]);

            vari_bndy = ncread(bndy, [vari, '_', direction], [1, 1, time_rec], [Inf, Inf, 1]);
            z_bndy = squeeze(z_bndy(:, 1, :));
            xdata_1d = lon_bndy(:, 1);
            xdata_bndy = repmat(xdata_1d, [1, g.N]);

            xlabel_str = 'Longitude';
        case 'north'
            lat = max(lat_bndy(:));
            lon1 = min(lon_bndy(:));
            lon2 = max(lon_bndy(:));

            latdist = abs(gs.lat_rho(1,:) - lat);
            latind = find(latdist == min(latdist));
            lonind = find(gs.lon_rho(:,end) > lon1 & gs.lon_rho(:,end) < lon2);
            vari_source = ncread(source, vari, [lonind(1) latind, 1, 1], [length(lonind), 1, Inf, 1]);
            vari_source = squeeze(vari_source);
            z_source = squeeze(z_source(lonind, latind, :));
            xdata_1d = lon_source(lonind, latind);
            xdata_source = repmat(xdata_1d, [1, gs.N]);

            vari_bndy = ncread(bndy, [vari, '_', direction], [1, 1, time_rec], [Inf, Inf, 1]);
            z_bndy = squeeze(z_bndy(:, end, :));
            xdata_1d = lon_bndy(:, end);
            xdata_bndy = repmat(xdata_1d, [1, g.N]);

            xlabel_str = 'Longitude';
    end

    % Source
    nexttile(1);
    p1 = pcolor(xdata_source, z_source, vari_source); shading flat
    colormap jet(12);
    caxis(climit)
    xlabel(xlabel_str)
    ylabel('Depth (m)')
    title(['Source ', vari], 'FontSize', 15);
    
    % Initial
    nexttile(2);
    p2 = pcolor(xdata_bndy, z_bndy, vari_bndy); shading flat
    colormap jet(12);
    caxis(climit)
    xlabel(xlabel_str)
    yticklabels('')
    c = colorbar;
    c.Title.String = unit;
    title(['Boundary ', vari], 'FontSize', 15);

    print(['chk_bndy_', vari, '_', direction, '_', fstr], '-dpng')
    delete(p1); delete(p2)
end