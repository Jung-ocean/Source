clear; clc; close all

casename = 'southern';
month_all = [8];
depth_all = [0];

fpath = 'D:\Data\Ocean\KODC\avg_ts(2006_2015)\';
fname = 'KODC_avg(2006_2015).mat';
load([fpath,fname])

figpath = fpath;
titletype = [''];

% Bathymetry file
zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;

[lon_lim, lat_lim] = domain_J(casename);

for ts = 1:1
    if ts == 1
        variindex = 12;
        clim = [0 30];
        contour_interval = [clim(1):2:clim(2)];
        vari = 'temp';
        colorbarname = '^oC';
        colormap_style = 'parula';
    elseif ts == 2
        variindex = 13;
        clim = [30 35];
        contour_interval = [clim(1):.5:clim(2)];
        vari = 'salt';
        colorbarname = 'g/kg';
        colormap_style = 'jet';
    end
    
    for mi = 1:length(month_all)
        month = month_all(mi); mstr = num2char(month,2);
        
        for di = 1:length(depth_all)
            depth = depth_all(di);
            if depth > 99; charnum = 3; else; charnum = 2; end
            dstr = num2char(depth, charnum);
            
            index = find(data_avg(:,2) == month & data_avg(:,11) == depth);
            
            data_target = data_avg(index,:);
            
            lon_target = data_target(:,10);
            lat_target = data_target(:,9);
            vari_target = data_target(:,variindex);
            
            X1 = min(lon_target); X2 = max(lon_target);
            Y1 = min(lat_target); Y2 = max(lat_target);
            Xp = [X1:0.1:X2]; Yp = [Y1:0.1:Y2];
            [Xi, Yi] = meshgrid(Xp, Yp);
            Zi = griddata(lon_target, lat_target, vari_target, Xi, Yi);
            
            % Bathymetry
            zind = find(lon_lim(1) < Zlon & Zlon < lon_lim(2) & lat_lim(1) < Zlat & Zlat < lat_lim(2));
            Zlon2 = Zlon(zind); Zlat2 = Zlat(zind); Zz2 = Zz(zind);
            z_grid = griddata(Zlon2,Zlat2,Zz2, Xi, Yi);
            Zi(z_grid < depth) = NaN;
            
            k = boundary(lon_target, lat_target,0.9);
            mask = inpolygon(Xi,Yi, lon_target(k), lat_target(k));
            
            figure;
            map_J(casename)
            m_pcolor(Xi, Yi, Zi.*mask./mask); colormap(colormap_style); shading flat;
            [cs, h] = m_contour(Xi, Yi, Zi.*mask./mask, contour_interval, 'k');
            clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold', 'LabelSpacing', 200);
            c = colorbar; c.FontSize = 25;
            c.Title.String = colorbarname; c.Title.FontSize = 15;
            %c.Label.String = colorbarname; c.Label.FontSize = 15;
            caxis(clim);
            
            %titlename = [titletype, 'avg_' , 'mmm'), ' ', num2str(year)];
            %title(titlename, 'fontsize', 25)
            
            % plot point
            m_plot(lon_target, lat_target, '.k', 'markersize', 15)
            
            setposition(casename)
            m_gshhs_i('patch', [.7 .7 .7])
            %saveas(gcf,[figpath, vari, '_', dstr, 'm_', casename, '_avg', mstr],'png');
            print([figpath, vari, '_', dstr, 'm_', casename, '_avg', mstr], '-dtiff','-r300')
            %save([figpath, vari, '_', dstr, 'm_', casename, '_avg', mstr, '.mat'], 'Xi', 'Yi', 'Zi');
        end
    end
    
end