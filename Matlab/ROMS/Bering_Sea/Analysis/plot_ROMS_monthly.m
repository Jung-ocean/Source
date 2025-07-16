%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2022;
mm_all = 5:7;

exp = 'Dsm4';
vari_str = 'pden';
layer = 1;
casename = 'Bering';

ind_png = 1;
ind_gif = 0;

% Model
filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
startdate = datenum(2018,7,1);
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;

switch vari_str
    case 'temp'
        dim = '3d';
        color = 'parula';
        climit = [-2 6];
%         climit = [6 12];
        contour_interval = climit(1):1:climit(end);
        unit = '^oC';

    case 'salt'
        dim = '3d';
        color = 'jet';
        climit = [31.5 33.5];
        contour_interval = climit(1):.5:climit(end);
        %         contour_interval = [31.5 32.5];
        unit = 'psu';

    case 'pden'
        dim = '3d';
        interval = 0.2;
        climit = [25.5 26.5];
        num_color = diff(climit)/interval;
        contour_interval = climit(1):interval:climit(end);
        color = jet(num_color);
        unit = '\sigma_t';

    case 'aice'
        dim = '2d';
        color = 'parula';
        climit = [0 1];
        unit = '';

    case 'zeta'
        dim = '2d';
        color = 'jet';
        climit = [-40 40];
        contour_interval = climit(1):5:climit(end);
        unit = 'cm';
end

f1 = figure; hold on;
set(gcf, 'Position', [1 200 800 500])
plot_map(casename, 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'Color', 'k');

ystr = num2str(yyyy);

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    timenum = datenum(yyyy,mm,15);

    filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
    file = [filepath, filename];

    if strcmp(dim, '3d')
        if layer > 0
            vari = ncread(file, vari_str, [1 1 layer 1], [Inf Inf 1 Inf])';
        else
            zeta = ncread(file, 'zeta')';
            z = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
            if strcmp(vari_str, 'pden')
                temp_sigma = squeeze(ncread(file, 'temp'));
                temp_sigma = permute(temp_sigma, [3 2 1]);
                temp = vinterp(temp_sigma,z,layer);

                salt_sigma = squeeze(ncread(file, 'salt'));
                salt_sigma = permute(salt_sigma, [3 2 1]);
                salt = vinterp(salt_sigma,z,layer);

                pres = sw_pres(layer*ones(size(g.lat_rho)), g.lat_rho);
                pden = sw_pden_ROMS(salt, temp, pres, 0);

                vari = pden - 1000;
            else
            
            var_sigma = squeeze(ncread(file, vari_str));
            var_sigma = permute(var_sigma, [3 2 1]);
            vari = vinterp(var_sigma,z,layer);
            end
        end
    else
        vari = ncread(file, vari_str)';
        if strcmp(vari_str, 'zeta')
            vari = vari.*100;
        end
    end

    h = plot_contourf(g.lat_rho, g.lon_rho, vari, contour_interval, climit, color);
    plot_map(map, 'mercator', 'l')

%     p = pcolorm(g.lat_rho, g.lon_rho, vari.*mask);
%     colormap(color);
%     caxis(climit);
%     uistack(p,'bottom')
    c = colorbar;
    c.Title.String = unit;

    if ind_contour == 1
        vari_contour = vari;
        vari_contour(isnan(vari_contour) == 1) = -10;
        [cs,h] = contourm(g.lat_rho, g.lon_rho, vari_contour, contour_interval, '-k', 'LineWidth', 2);
%         cl = clabelm(cs, h, 'LabelSpacing', 500);
%         set(cl, 'Color', 'k', 'FontSize', 20, 'LineStyle', 'none', 'BackgroundColor', 'none')
    end

    if strcmp(dim, '3d')
        if layer > 0
            title(['ROMS ', vari_str, ' layer ', num2str(layer), ' (', datestr(timenum, 'mmm, yyyy'), ')'], 'FontSize', 15)
        else
            title(['ROMS ', vari_str, ' ', num2str(layer), ' m (', datestr(timenum, 'mmm, yyyy'), ')'], 'FontSize', 15)
        end
    else
        title(['ROMS ', vari_str, ' (', datestr(timenum, 'mmm, yyyy'), ')'], 'FontSize', 15)
    end

    %     % Argo location
    %     load Argo_num_046.mat
    %     index = find(floor(time) == timenum);
    %     lon_point = lon(index);
    %     lat_point = lat(index);
    %     pt = plotm(lat_point, lon_point, '.k', 'MarkerSize', 15);

    if ind_png == 1
        print([vari_str, '_layer_', num2str(layer), '_', casename, '_', datestr(timenum, 'yyyymm')], '-dpng')
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
%         delete(cl); 
        delete(h);
    end
end
