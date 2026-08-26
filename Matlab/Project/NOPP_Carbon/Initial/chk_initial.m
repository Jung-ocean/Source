clear; clc; close all

domain = 'Oregon_1km';
[lon_lim, lat_lim] = load_domain(domain);

source = '/data/jungjih/Models/LiveOcean/daily/ocean_avg_0001.nc';
gs = grd('LiveOcean');
% source = '/data/jungjih/Models/WCOFS/daily_3D/nos.wcofs.avg.nowcast.20240102.t03z.nc';
% gs = grd('WCOFS');

initial = ['./initial_', domain, '_LiveOcean.nc'];
g = grd(domain);

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
            str = 'rho';
            vari_u = ncread(source, 'ubar');
            vari_v = ncread(source, 'vbar');
            [vari_u_rho,vari_v_rho,lonred,latred,maskred]=...
            uv_vec2rho_J(vari_u,vari_v,gs.lon_rho,gs.lat_rho,gs.angle,gs.mask_rho,1,[0 0 0 0]);
            vari_source = vari_u_rho;
            
            vari_u = ncread(initial, 'ubar');
            vari_v = ncread(initial, 'vbar');
            [vari_u_rho,vari_v_rho,lonred,latred,maskred]=...
            uv_vec2rho_J(vari_u,vari_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,1,[0 0 0 0]);
            vari_ini = vari_u_rho;
            climit = [-.3 .3];
            unit = 'm/s';
        case 'vbar'
            str = 'rho';
            vari_u = ncread(source, 'ubar');
            vari_v = ncread(source, 'vbar');
            [vari_u_rho,vari_v_rho,lonred,latred,maskred]=...
            uv_vec2rho_J(vari_u,vari_v,gs.lon_rho,gs.lat_rho,gs.angle,gs.mask_rho,1,[0 0 0 0]);
            vari_source = vari_v_rho;

            vari_u = ncread(initial, 'ubar');
            vari_v = ncread(initial, 'vbar');
            [vari_u_rho,vari_v_rho,lonred,latred,maskred]=...
            uv_vec2rho_J(vari_u,vari_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,1,[0 0 0 0]);
            vari_ini = vari_v_rho;
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
    plot_map(domain, 'mercator', 'l');
    p1 = pcolorm(lat_source, lon_source, vari_source.*mask_source./mask_source);
    colormap jet(12);
    caxis(climit)
    title(['Source ', vari], 'FontSize', 15);
    
    % Initial
    nexttile(2);
    plot_map(domain, 'mercator', 'l');
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