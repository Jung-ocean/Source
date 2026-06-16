clear; clc; close all

region = 'Oregon';
[lon_lim, lat_lim] = load_domain(region);

source = '/data/jungjih/Models/LiveOcean/daily/ocean_avg_0001.nc';
gs = grd('LiveOcean');

initial = './initial_Oregon_1km.nc';
g = grd('Oregon_1km');

varis = {'zeta', 'SST', 'botT', 'SSS', 'botS', 'ubar', 'vbar'};

figure;
set(gcf, 'Position', [1 200 700 800])
t = tiledlayout(1,2);
t.Padding = 'compact';
t.TileSpacing = 'tight';

for vi = 1:length(varis)
    vari = varis{vi};
    switch vari
        case 'zeta'
            str = 'rho';
            vari_source = ncread(source, 'zeta');
            vari_ini = ncread(initial, 'zeta');
            climit = [-.5 .5];
            unit = 'm';
        case 'SST'
            str = 'rho';
            vari_source = ncread(source, 'temp', [1 1 gs.N 1], [Inf Inf 1 1]);
            vari_ini = ncread(initial, 'temp', [1 1 g.N 1], [Inf Inf 1 1]);
            climit = [0 12];
            unit = '^oC';
        case 'botT'
            str = 'rho';
            vari_source = ncread(source, 'temp', [1 1 1 1], [Inf Inf 1 1]);
            vari_ini = ncread(initial, 'temp', [1 1 1 1], [Inf Inf 1 1]);
            climit = [0 12];
            unit = '^oC';
        case 'SSS'
            str = 'rho';
            vari_source = ncread(source, 'salt', [1 1 gs.N 1], [Inf Inf 1 1]);
            vari_ini = ncread(initial, 'salt', [1 1 g.N 1], [Inf Inf 1 1]);
            climit = [29 35];
            unit = 'psu';
        case 'botS'
            str = 'rho';
            vari_source = ncread(source, 'salt', [1 1 1 1], [Inf Inf 1 1]);
            vari_ini = ncread(initial, 'salt', [1 1 1 1], [Inf Inf 1 1]);
            climit = [29 35];
            unit = 'psu';
        case 'ubar'
            str = 'u';
            vari_source = ncread(source, 'ubar');
            vari_ini = ncread(initial, 'ubar');
            climit = [-.3 .3];
            unit = 'm/s';
        case 'vbar'
            str = 'v';
            vari_source = ncread(source, 'vbar');
            vari_ini = ncread(initial, 'vbar');
            climit = [-.3 .3];
            unit = 'm/s';
    end
    lon_source = eval(['gs.lon_', str]);
    lat_source = eval(['gs.lat_', str]);
    mask_source = eval(['gs.mask_', str]);
    lon_ini = eval(['g.lon_', str]);
    lat_ini = eval(['g.lat_', str]);
    mask_ini = eval(['g.mask_', str]);

    % Source
    nexttile(1);
    plot_map(region, 'mercator', 'l');
    p1 = pcolorm(lat_source, lon_source, vari_source.*mask_source./mask_source);
    colormap jet(12);
    caxis(climit)
    title(['Source ', vari], 'FontSize', 15);
    
    % Initial
    nexttile(2);
    plot_map(region, 'mercator', 'l');
    p2 = pcolorm(lat_ini, lon_ini, vari_ini.*mask_ini./mask_ini);
    colormap jet(12);
    caxis(climit)
    c = colorbar;
    c.Title.String = unit;
    plabel off
    title(['Initial ', vari], 'FontSize', 15);

    print(['chk_ini_', vari], '-dpng')
    delete(p1); delete(p2)
end