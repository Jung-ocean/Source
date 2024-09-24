%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SST to OSTIA temperature monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2021:2021;
mm_all = 6:8;
climit = [0 15];
climit_diff = [-3 3];

ind_png = 1;
ind_gif = 0;

% Model
model_filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/';
g = grd('BSf');
startdate = datenum(2018,7,1);

% Observation
obs_filepath = ['/data/jungjih/Observations/Satellite_SST/OSTIA/monthly/'];

% Plot
f1 = figure;
set(gcf, 'Position', [1 200 1900 450])
t = tiledlayout(1,3);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    yyyymm = datenum(yyyy,mm,15);
    title(t, [datestr(yyyymm, 'mmm, yyyy')], 'FontSize', 20)

    % Observation
    obs_filename = ['OSTIA_', ystr, mstr, '.nc'];
    obs_file = [obs_filepath, obs_filename];

    lon_obs = double(ncread(obs_file, 'lon'));
    lat_obs = double(ncread(obs_file, 'lat'));
    vari_obs = ncread(obs_file, 'analysed_sst')' - 273.15; % K to dec C

    index1 = find(lon_obs < 0);
    index2 = find(lon_obs > 0);

    lon_obs = [lon_obs(index2)-360; lon_obs(index1)];
    vari_obs = [vari_obs(:,index2) vari_obs(:,index1)];
    vari_obs_interp = interp2(lon_obs, lat_obs, vari_obs, g.lon_rho, g.lat_rho);

    % Model
    model_filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
    model_file = [model_filepath, model_filename];

    vari_model = ncread(model_file, 'temp', [1 1 g.N 1], [Inf Inf 1 Inf])';

    nexttile(1)
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

    pobs = pcolorm(g.lat_rho, g.lon_rho, vari_obs_interp);
    colormap jet;
    uistack(pobs,'bottom')
    caxis(climit)

    textm(65, -205, 'OSTIA', 'FontSize', 25)

    nexttile(2)
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

    pmodel = pcolorm(g.lat_rho, g.lon_rho, vari_model);
    colormap jet;
    c = colorbar;
    c.Title.String = '^oC';
    uistack(pmodel,'bottom')
    caxis(climit)
    
    textm(65, -205, 'ROMS', 'FontSize', 25)

    ax3 = nexttile(3);
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

    pdiff = pcolorm(g.lat_rho, g.lon_rho, vari_model - vari_obs_interp);
    colormap(ax3, 'redblue');
    c = colorbar;
    c.Title.String = '^oC';
    uistack(pdiff,'bottom')
    caxis(climit_diff)
%     textm(65, -205, 'Difference (ROMS - OSTIA)', 'FontSize', 25)
    textm(65, -205, 'Difference', 'FontSize', 25)

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    if ind_png == 1
        print(['cmp_SST_w_OSTIA_', ystr, mstr], '-dpng')
    end

    if ind_gif == 1
        % Make gif
        gifname = ['cmp_SST_w_OSTIA_', ystr, '.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if mi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end

    delete(pobs); delete(pmodel); delete(pdiff);
end
end