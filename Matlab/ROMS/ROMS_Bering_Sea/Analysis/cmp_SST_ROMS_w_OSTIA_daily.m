%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SST to OSTIA temperature
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyymmdd_all = [datenum(2019,1,1):datenum(2019,7,1)];
climit = [0 15];
climit_diff = [-3 3];

ind_png = 0;
ind_gif = 1;

% Model
model_filepath = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';
g = grd('BSf');
startdate = datenum(2018,7,1);

% Plot
f1 = figure;
set(gcf, 'Position', [1 200 1900 450])
t = tiledlayout(1,3);

for di = 1:length(yyyymmdd_all)

    yyyymmdd = yyyymmdd_all(di);
    yyyymmdd_str = datestr(yyyymmdd, 'yyyymmdd');
    ystr = datestr(yyyymmdd, 'yyyy');
    mstr = datestr(yyyymmdd, 'mm');

    % Observation
    obs_filepath = ['/data/jungjih/Observations/Satellite_SST/OSTIA/daily/', ystr, '/', mstr, '/'];
    obs_filename = [yyyymmdd_str, '120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB_REP-v02.0-fv02.0.nc'];
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
    filenumber = yyyymmdd - startdate + 1;
    fstr = num2str(filenumber, '%04i');
    model_filename = ['Dsm2_spng_avg_', fstr, '.nc'];
    model_file = [model_filepath, model_filename];

    vari_model = ncread(model_file, 'temp', [1 1 g.N 1], [Inf Inf 1 Inf])';

    nexttile(1)
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

    pobs = pcolorm(g.lat_rho, g.lon_rho, vari_obs_interp);
    colormap jet;
    uistack(pobs,'bottom')
    caxis(climit)

    title('OSTIA SST', 'FontSize', 15)

    nexttile(2)
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

    pmodel = pcolorm(g.lat_rho, g.lon_rho, vari_model);
    colormap jet;
    c = colorbar;
    c.Title.String = '^oC';
    uistack(pmodel,'bottom')
    caxis(climit)
    title('ROMS SST', 'FontSize', 15)

    ax3 = nexttile(3);
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

    pdiff = pcolorm(g.lat_rho, g.lon_rho, vari_model - vari_obs_interp);
    colormap(ax3, 'redblue');
    c = colorbar;
    c.Title.String = '^oC';
    uistack(pdiff,'bottom')
    caxis(climit_diff)
    title('Difference (ROMS - OSTIA)', 'FontSize', 15)

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    title(t, [datestr(yyyymmdd, 'mmm dd, yyyy')], 'FontSize', 25)

    if ind_png == 1
        print(['cmp_SST_w_OSTIA_', yyyymmdd_str], '-dpng')
    end

    if ind_gif == 1
        % Make gif
        gifname = ['cmp_SST_w_OSTIA_', ystr, '.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if di == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end

    delete(pobs); delete(pmodel); delete(pdiff);
end