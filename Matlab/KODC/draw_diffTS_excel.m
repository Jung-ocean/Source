clear; clc; close all

year_all = [2013:2013];
casename = 'southern';
month_all = [8];
depth_all = [0];

fpath = 'D:\Data\Ocean\KODC\excel\';
figpath = 'D:\Data\Ocean\KODC\diff(1970_2019)\';
titletype = [''];

apath = 'D:\Data\Ocean\KODC\avg_ts(1970_2019)\';
afile = 'KODC_avg(1970_2019).mat';
load([apath, afile]);
data_avg_all = data_avg;

% Bathymetry file
zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;

[lon_lim, lat_lim] = domain_J(casename);

for ts = 1:1
    if ts == 1
        variindex = 12;
        clim = [-3 3];
        contour_interval = [clim(1):1:clim(2)];
        vari = 'temp';
        colorbarname = '^oC';
        colormap_style = 'redblue2';
    elseif ts == 2
        variindex = 13;
        clim = [30 35];
        contour_interval = [clim(1):.5:clim(2)];
        vari = 'salt';
        colorbarname = 'g/kg';
        colormap_style = 'jet';
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
                
                obsline = data_target(:,7);
                obspoint = data_target(:,8);
                
                obsline_u = unique(obsline);
                obspoint_u = unique(obspoint);
                
                aindex = find(data_avg_all(:,2) == month & data_avg_all(:,11) == depth);
                data_avg = data_avg_all(aindex,:);
                
                obsline_a = data_avg(:,7);
                obspoint_a = data_avg(:,8);

            data_diff = [];
            for oli = 1:length(obsline_u)
                for opi = 1:length(obspoint_u)
                    tindex = find(obsline == obsline_u(oli) & obspoint == obspoint_u(opi));
                    aindex = find(obsline_a == obsline_u(oli) & obspoint_a == obspoint_u(opi));
                    if length(tindex) > 1
                        tindex = tindex(1);
                    end
                    if ~isempty(tindex)
                        data_diff = [data_diff; data_target(tindex,:)];
                        data_diff(end, variindex) = data_target(tindex, variindex) - data_avg(aindex, variindex);
                    else
                    end
                    
                end
            end
                                
                lon_target = data_diff(:,10);
                lat_target = data_diff(:,9);
                vari_target = data_diff(:,variindex);
                
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
                
                k = boundary(lon_target, lat_target, 0.9);
                mask = inpolygon(Xi,Yi, lon_target(k), lat_target(k));
                
                figure('visible', 'off');
                map_J(casename)
                m_pcolor(Xi, Yi, Zi.*mask./mask); colormap(colormap_style); shading flat;
                [cs, h] = m_contour(Xi, Yi, Zi.*mask./mask, contour_interval, 'k');
                h.LineWidth = 1;
                clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold', 'LabelSpacing', 200);
                c = colorbar; c.FontSize = 25;
                %c.Label.String = colorbarname; c.Label.FontSize = 15;
                c.Title.String = colorbarname; c.Title.FontSize = 25;
                caxis(clim);
                
                titlename = [titletype, datestr((data_target(1,1:6)), 'mmm'), ' ', num2str(year)];
                %title(titlename, 'fontsize', 25)
                
                % plot point
                m_plot(lon_target, lat_target, '.k', 'markersize', 15)
                
                %setposition([casename, '_obs'])
                setposition([casename])
                m_gshhs_i('patch', [.7 .7 .7])
                saveas(gcf,[figpath, 'diff_', vari, '_', dstr, 'm_', casename, '_', ystr, mstr],'png');
                %print([figpath, 'diff_', vari, '_', dstr, 'm_', casename, '_', ystr, mstr], '-dtiff','-r300')
            end
        end
        %close all
    end
end