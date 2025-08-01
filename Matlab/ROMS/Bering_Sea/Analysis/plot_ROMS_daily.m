%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS daily 
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2022;
mm_all = 1:5;

vari_str = 'aice';
layer = 45;
casename = 'Bering';

ind_contour = 0;
ind_png = 1;
ind_gif = 1;

% Model
filepath = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';
startdate = datenum(2018,7,1);
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;

switch vari_str
    case 'temp'
        dim = '3d';
        color = 'parula';
        climit = [-2 6];
        contour_interval = [0 2];
        unit = '^oC';

    case 'salt'
        dim = '3d';
        color = 'jet';
        climit = [31.5 33.5];
        %contour_interval = climit(1):.5:climit(end);
%         contour_interval = [31.5 32.5];
        unit = 'g/kg';

    case 'aice'
        dim = '2d';
        color = 'gray';
        climit = [0 1];
        unit = '';

    case 'zeta'
        dim = '2d';
        color = 'redblue';
        climit = [-1 1];
        unit = 'm';
end

f1 = figure; hold on;
set(gcf, 'Position', [1 200 1300 800])
plot_map(casename, 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

ystr = num2str(yyyy);

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mi, '%02i');

for di = 1:eomday(yyyy,mm)
    dd = di;
    timenum = datenum(yyyy,mm,dd);
    filenumber = timenum - startdate + 1;
    fstr = num2str(filenumber, '%04i');
    filename = ['Dsm2_spng_avg_', fstr, '.nc'];
    file = [filepath, filename];

    if strcmp(dim, '3d')
        vari = ncread(file, vari_str, [1 1 layer 1], [Inf Inf 1 Inf])';
    else
        vari = ncread(file, vari_str)';
    end

    p = pcolorm(g.lat_rho, g.lon_rho, vari.*mask);
    colormap(color);
    caxis(climit);
    uistack(p,'bottom')
    c = colorbar;
    c.Title.String = unit;

    if ind_contour == 1
        vari_contour = vari;
        vari_contour(isnan(vari_contour) == 1) = -10;
        [cs,h] = contourm(g.lat_rho, g.lon_rho, vari_contour, contour_interval, '-k', 'LineWidth', 4);
        cl = clabelm(cs, h, 'LabelSpacing', 500);
        set(cl, 'Color', 'k', 'FontSize', 20, 'LineStyle', 'none', 'BackgroundColor', 'none')
    end

    if strcmp(dim, '3d')
        title(['ROMS ', vari_str, ' layer ', num2str(layer), ' (', datestr(timenum, 'mmm dd, yyyy'), ')'], 'FontSize', 15)
    else
        title(['ROMS ', vari_str, ' (', datestr(timenum, 'mmm dd, yyyy'), ')'], 'FontSize', 15)
    end

%     % Argo location
%     load Argo_num_046.mat
%     index = find(floor(time) == timenum);
%     lon_point = lon(index);
%     lat_point = lat(index);
%     pt = plotm(lat_point, lon_point, '.k', 'MarkerSize', 15);

    if ind_png == 1
        print([vari_str, '_layer_', num2str(layer), '_', casename, '_', datestr(timenum, 'yyyymmdd')], '-dpng')
    end

    if ind_gif == 1
        % Make gif
        gifname = [vari_str, '_layer_', num2str(layer), '_', casename, '_', datestr(timenum, 'yyyy'), '.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if mi == 1 && di == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end % ind_gifrsync -av --include '*/' --include '*.png' --include '*.gif' --include '*.jpg' --exclude '*' --delete /data/jungjih/* ./data/

    delete(p)
%     delete(pt)
    if ind_contour == 1
        delete(cl); delete(h);
    end
end
end