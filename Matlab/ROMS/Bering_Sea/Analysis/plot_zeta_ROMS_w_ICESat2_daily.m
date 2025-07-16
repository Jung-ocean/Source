%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta with ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
yyyy = 2022;
ystr = num2str(yyyy);
mm = 1;
mstr = num2str(mm, '%02i');
startdate = datenum(2018,7,1);

offset = 20;

ispng = 0;
isgif = 1;

filepath_con = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];
% filepath_con = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng_awdrag/ncks/';

filepath_sat = ['/data/jungjih/Observations/Sea_ice/ICESat2/ATL21/data/'];
filename_sat = dir([filepath_sat, 'ATL21-01_', ystr, mstr, '*']);
filename_sat = filename_sat.name;
file_sat = [filepath_sat, filename_sat];
lat_sat = h5read(file_sat, '/grid_lat')';
lon_sat = h5read(file_sat, '/grid_lon')';

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;

% Figure properties
interval = 10;
climit = [-100 100];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = ['cm'];

text_FS = 12;
color_str = [1.0000 0.0745 0.6510];
interval_str = 60;
scale_str = 3;
scale_str_value = 0.5;
scale_str_lat = 62.5;
scale_str_lon = -164;
scale_str_text = '0.5 N/m^2';
scale_str_text_lat = scale_str_lat-.5;
scale_str_text_lon = scale_str_lon;
% Adjust vector
[scale_str_value, scale_str_v, lon_scl] = adjust_vector(scale_str_lon, scale_str_lat, scale_str_value, 0);

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 1600 500])
t = tiledlayout(1,2);
nexttile(1); hold on
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k')
nexttile(2); hold on
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k')

for di = 1:eomday(yyyy,mm)
    dd = di; dstr = num2str(dd, '%02i');

    timenum = datenum(yyyy,mm,dd);
    title(t, datestr(timenum, 'mmm dd, yyyy'), 'FontSize', 15);

    filenum = datenum(yyyy,mm,dd) - startdate + 1;
    fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];
    %         filename = ['zeta_', fstr, '.nc'];
    file_con = [filepath_con, filename];
    vari = 100*ncread(file_con, 'zeta')' + offset;
    aice = ncread(file_con, 'aice')';
    sustr = ncread(file_con, 'sustr')';
    svstr = ncread(file_con, 'svstr')';

    skip = 1;
    npts = [0 0 0 0];

    [sustr_rho,svstr_rho,lonred,latred,maskred] = uv_vec2rho(sustr,svstr,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
    sustr_rho = sustr_rho.*maskred;
    svstr_rho = svstr_rho.*maskred;

    % Adjust vector
    [sustr_rho, svstr_rho, lon_scl] = adjust_vector(g.lon_rho, g.lat_rho, sustr_rho, svstr_rho);

    nexttile(1); hold on;
    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(end)) = climit(end);
    [cs, p] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(p,'bottom')
%     plot_map('Eastern_Bering', 'mercator', 'l');

    if di == 1
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = contour_interval;
    end

    try
        ssha = h5read(file_sat, ['/daily/day', dstr, '/mean_ssha'])';
        fv = h5readatt(file_sat, ['/daily/day', dstr, '/mean_ssha/'], '_FillValue');
        ssha(ssha == fv) = NaN;
        mss = h5read(file_sat, ['/daily/day', dstr, '/mean_weighted_mss'])';
        fv = h5readatt(file_sat, ['/daily/day', dstr, '/mean_weighted_mss/'], '_FillValue');
        mss(mss == fv) = NaN;
        geoid = h5read(file_sat, ['/daily/day', dstr, '/mean_weighted_geoid'])';
        fv = h5readatt(file_sat, ['/daily/day', dstr, '/mean_weighted_geoid/'], '_FillValue');
        geoid(geoid == fv) = NaN;

        ADT = mss + ssha - geoid;
    catch
        ADT = NaN;
    end

    index = find(isnan(ADT) ~= 1);
    s = scatterm(lat_sat(index), lon_sat(index), 40, 100*ADT(index), 'filled', 'MarkerEdgeColor', 'k');

    set(gca, 'FontSize', 15)

    title(['ROMS zeta (color, offset = ', num2str(offset), ' cm) and ICESat2 sea level (dot)'], 'FontSize', 12)

    ax2 = nexttile(2); hold on;
    ai = pcolorm(g.lat_rho, g.lon_rho, aice.*g.mask_rho./g.mask_rho);
    colormap(ax2,gray); 
    caxis([0 1]);
    uistack(ai, 'bottom')

    qstr = quiverm_J(g.lat_rho(1:interval_str:end, 1:interval_str:end), ...
        g.lon_rho(1:interval_str:end, 1:interval_str:end), ...
        svstr_rho(1:interval_str:end, 1:interval_str:end).*scale_str, ...
        sustr_rho(1:interval_str:end, 1:interval_str:end).*scale_str, ...
        0);
    
    qstr(1).Color = color_str;
    qstr(2).Color = color_str;
    qstr(1).LineWidth = 2;
    qstr(2).LineWidth = 2;
    
    qscale = quiverm_J(scale_str_lat, scale_str_lon, 0.*scale_str, scale_str_value.*scale_str, 0);
    qscale(1).Color = color_str;
    qscale(2).Color = color_str;
    qscale(1).LineWidth = 2;
    qscale(2).LineWidth = 2;
    tscale = textm(scale_str_text_lat, scale_str_text_lon, scale_str_text, 'Color', color_str, 'FontSize', text_FS);

    title('Sea ice concentration (color) and surface stress (arrow)', 'FontSize', 12)

    if ispng == 1
        print(['plot_zeta_ROMS_w_ICESat2_daily_', ystr, mstr, dstr], '-dpng')
    end

    if isgif == 1
        % Make gif
        gifname = ['plot_zeta_ROMS_w_ICESat2_daily_', ystr, mstr, '.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if di == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end

    delete(p)
    delete(s)
    delete(ai)
    delete(qstr)
    delete(qscale)
    delete(tscale)
end % di