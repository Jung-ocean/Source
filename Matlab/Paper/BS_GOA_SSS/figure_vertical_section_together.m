clear; clc; close all

figure;
set(gcf, 'Position', [1 200 1800 900])

varis = {'temp', 'salt', 'pden'};

for vi = 1:length(varis)

vari_str = varis{vi};
yyyy_all = 2019:2022;
mm = 7; mstr = num2str(mm, '%02i');

% plusind = yyyy_all(1) - 2015;
plusind = 0;

region = 'Gulf_of_Anadyr_NW_SE';

iscontour = 0;
w_salt = 0;

switch vari_str
    case 'salt'
        climit = [29 34];
        interval = 0.25;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color = jet(num_color);
        unit = 'psu';
        titlestr = 'salinity';
        savename = 'vertical_salt';
    case 'temp'
        climit = [-2 12];
        interval = 2;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color = jet(num_color);
        unit = '^oC';
        titlestr = 'temperature';
        savename = 'vertical_temp';
    case 'pden'
        climit = [22 27];
        interval = 0.5;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color = jet(num_color);
        unit = '\sigma_\theta';
        titlestr = 'potential density';
        savename = 'vertical_pden';
    case 'v_n'
        climit = [-20 20];
        interval = 5;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color_tmp = redblue; close all
        c1 = interp1(color_tmp(:,1), linspace(1,length(color_tmp),num_color));
        c2 = interp1(color_tmp(:,2), linspace(1,length(color_tmp),num_color));
        c3 = interp1(color_tmp(:,3), linspace(1,length(color_tmp),num_color));
        color = [c1; c2; c3]';
        unit = 'cm/s';
        titlestr = 'normal velocity';
        savename = 'vertical_v_n';
    case 'u_t'
        climit = [-20 20];
        interval = 5;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color_tmp = redblue; close all
        c1 = interp1(color_tmp(:,1), linspace(1,length(color_tmp),num_color));
        c2 = interp1(color_tmp(:,2), linspace(1,length(color_tmp),num_color));
        c3 = interp1(color_tmp(:,3), linspace(1,length(color_tmp),num_color));
        color = [c1; c2; c3]';
        unit = 'cm/s';
        titlestr = 'tangential velocity';
        savename = 'vertical_u_t';
    case 'w'
        color = 'redblue';
        climit = [-1e-4 1e-4];
        contour_interval = [-1e-4 1e-4];
        unit = 'm/s';
        titlestr = 'Vertical velocity';
        savename = 'vertical_w';
end

switch region
    case 'Cape_Navarin'
        text1_dep = -150;
        text1_lon = -181;
        text2_dep = -185;
        text2_lon = -181;
        text_FS = 20;
    case 'Mattew_Lawrence'
        text1_dep = -61;
        text1_lon = -172.2;
        text2_dep = -61;
        text2_lon = -171.9;
        text_FS = 20;
    case 'Gulf_of_Anadyr'
        text1_dep = -72;
        text1_lon = -174.4;
        text2_dep = -85;
        text2_lon = -174.7;
        text_FS = 15;
    case 'Gulf_of_Anadyr_NW_SE'
        ylimit = [-100 0];
        text1_dep = -75;
        text1_lon = -180;
        text2_dep = -90;
        text2_lon = -180;
        text_FS = 20;
        lon_limit = -176.9945; lat_limit = 63.3551;
    case 'Anadyr_Strait'
        text1_dep = -40;
        text1_lon = -173;
        text2_dep = -50;
        text2_lon = -173;
        text_FS = 20;
        if strcmp(vari_str, 'v_n')
            climit = [-50 50];
            contour_interval = climit(1):10:climit(2);
        end
    case 'Navarin_Matthew'
        ylimit = [-120 0];
%         text1_dep = -97;
%         text1_lon = -175;
%         text2_dep = -115;
%         text2_lon = -175;
        text1_dep = -90;
        text1_lon = -181;
        text2_dep = -110;
        text2_lon = -181;
        text_FS = 20;
        if strcmp(vari_str, 'v_n')
            climit = [-50 50];
            interval = 10;
            contour_interval = climit(1):interval:climit(2);
            num_color = diff(climit)/interval;
            color_tmp = redblue; close all
            c1 = interp1(color_tmp(:,1), linspace(1,length(color_tmp),num_color));
            c2 = interp1(color_tmp(:,2), linspace(1,length(color_tmp),num_color));
            c3 = interp1(color_tmp(:,3), linspace(1,length(color_tmp),num_color));
            color = [c1; c2; c3]';
        end
        lon_limit = -178;
end
title_str = strrep(region, '_' , ' ');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/transect/Gulf_of_Anadyr_NW_SE/', region, '_transect_ocean_vars_', ystr, '_monthly.mat']);

    timenum = timeR;
    mask = Seg.mask;
    mask2d = Seg.mask2d;
    azimuth = Seg.azimuth;
    depth = Seg.zseca;
    lon = Seg.lonseca;
    lat = Seg.latseca;

    temp = Sec.temp(:,:,mm);
    salt = Sec.salt(:,:,mm);
    v_n = Sec.v_n(:,:,mm);
    u_t = Sec.u_t(:,:,mm);
    w = Sec.w(:,:,mm);
    zeta = Sec.zeta(:,mm);
    aice = Sec.aice(:,mm);
    sustr = Sec.sustr(:,mm);
    svstr = Sec.svstr(:,mm);

    if strcmp(vari_str, 'v_n') || strcmp(vari_str, 'u_t')
        vari = eval(vari_str);
        vari = vari.*100;
    elseif strcmp(vari_str, 'pden')
        pres = sw_pres(abs(depth), lat);
        pden = sw_pden_ROMS(salt, temp, pres, 0);
        vari = pden - 1000;
    else
        vari = eval(vari_str);
    end

    vari(vari < climit(1)) = climit(1);
    % Tile
    ax = subplot('Position', [.1+.16*(yi-1) .7-.27*(vi-1) .15 .25]); hold on;

    %     p = pcolor(lon, depth, vari.*mask); shading flat
    p = contourf(lon, depth, vari.*mask, contour_interval); shading flat
    caxis(climit)
    if iscontour == 1
        [cs,h] = contour(lon, depth, vari.*mask, contour_interval, 'k');
%         [cs,h] = contour(lon, depth, vari.*mask, [contour_interval], 'k');
%         clabel(cs, h, 'Color', 'k', 'FontSize', 15)
    end

    if strcmp(region, 'Gulf_of_Anadyr_NW_SE')
        xlim([min(min(lon)) lon_limit]);
    elseif strcmp(region, 'Navarin_Matthew')
        xlim([min(min(lon)) lon_limit]);
    end
    ylim(ylimit)

    colormap(ax, color)

    xticks([-179.5:1:176.5])
    xlabel('Longitude')
    ylabel('Depth (m)')

    set(gca, 'FontSize', 15)

    %     text(-181, -180, [title_str], 'FontSize', 20)
    text(text1_lon, text1_dep, vari_str, 'FontSize', text_FS)
    text(text2_lon, text2_dep, datestr(datenum(yyyy,mm,1), 'mmm, yyyy'), 'FontSize', text_FS)

    if vi == 1 | vi == 2
        xticklabels('')
        xlabel('')
    end
    if yi ~= 1
        yticklabels('')
        ylabel('')
    end

end % yi

c = colorbar('Position', [.74 .7-.27*(vi-1) .01 .24]);
c.Title.String = unit;
c.FontSize = 12;

end % vi

exportgraphics(gcf,['figure_vertical_together_', mstr, '.png'],'Resolution',150)