clear; clc; close all

year_all = [2013:2013];
casename = 'southern';
month_all = [8];
depth_all = [0];

fpath = 'D:\Data\Ocean\KODC\excel\';
%figpath = 'D:\Data\Ocean\KODC\KODC_';
figpath = fpath;
titletype = [''];

% Bathymetry file
zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;

[lon_lim, lat_lim] = domain_J(casename);

for ts = 1:1
    if ts == 1
        variindex = 12;
        clim = [10 30];
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
    elseif ts == 3
        clim = [18 28];
        contour_interval = [clim(1):1:clim(2)];
        vari = 'density';
        colorbarname = '\sigma_t';
        colormap_style = 'parula';
    end
    
    for yi = 1:length(year_all)
        year = year_all(yi); ystr = num2str(year);
        fname = [fpath, 'KODC_', ystr, '.xls'];
                
        [num, raw, txt] = xlsread(fname);
        
        obsline = txt(3:end,2); obspoint = txt(3:end,3);
        lat = txt(3:end, 5); lon = txt(3:end, 6);
        date = datenum(txt(3:end, 7));
        dep = txt(3:end, 8);
        temp = txt(3:end, 9);
        salt = txt(3:end, 11);
        
        data_cell = [obsline obspoint lat lon dep temp salt];
        datasize = size(data_cell);
        
        clearvars data
        for i = 1:datasize(1)
            for j = 1:datasize(2)
                if isempty(cell2mat(data_cell(i,j))) == 1
                    data(i,j) = NaN;
                else
                    data(i,j) = str2num(cell2mat(data_cell(i,j)));
                end
            end
        end
        
        data_all = [datevec(date) data];
        
        for mi = 1:length(month_all)
            month = month_all(mi); mstr = num2char(month,2);
            
            for di = 1:length(depth_all)
                depth = depth_all(di);
                if depth > 99; charnum = 3; else; charnum = 2; end
                dstr = num2char(depth, charnum);
                
                index1 = find(data_all(:,2) == month & data_all(:,11) == depth);
                index2 = find(data_all(:,2) == month+1 & data_all(:,11) == depth);
                
                index = sort([index1; index2]);
                
                data_target = data_all(index,:);
                
                nanind = find(isnan(mean(data_target,2)) == 1);
                data_target(nanind,:) = [];
                
                lon_target = data_target(:,10);
                lat_target = data_target(:,9);
                if ts == 3
                    SALT = data_target(:,13);
                    TEMP = data_target(:,12);
                    dep1 = depth;
                    dep = ones(length(lat_target),1)*dep1;
                    pres = sw_pres(dep, lat_target);
                    pdens = sw_pden(SALT, TEMP, pres, 0);
                    density = pdens - 1000;
                    vari_target = density;
                else
                    vari_target = data_target(:,variindex);
                end
                
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
                
                if depth == 75
                    s = 0.7;
                else
                    s = 0.9;
                end
                k = boundary(lon_target, lat_target, s);
                mask = inpolygon(Xi,Yi, lon_target(k), lat_target(k));
                
                figure('visible', 'off');
                map_J(casename)
                m_pcolor(Xi, Yi, Zi.*mask./mask); colormap(colormap_style); shading flat;
                [cs, h] = m_contour(Xi, Yi, Zi.*mask./mask, contour_interval, 'k');
                h.LineWidth = 1;
                clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold', 'LabelSpacing', 200);
                c = colorbar; c.FontSize = 25;
                %c.Label.String = colorbarname; c.Label.FontSize = 25;
                c.Title.String = colorbarname; c.Title.FontSize = 25;
                caxis(clim);
                
                titlename = [titletype, datestr(datenum(year,month,15), 'mmm'), ' ', num2str(year)];
                title(titlename, 'fontsize', 25)
                
                % plot point
                m_plot(lon_target, lat_target, '.k', 'markersize', 10)
                
                setposition(casename)
                m_gshhs_i('patch', [.7 .7 .7])
                %saveas(gcf,[figpath, vari, '_', dstr, 'm_', casename, '_', ystr, mstr],'png');
                print([figpath, vari, '_', dstr, 'm_', casename, '_', ystr, mstr], '-dtiff','-r300')
            end
        end
        %close all
    end
end