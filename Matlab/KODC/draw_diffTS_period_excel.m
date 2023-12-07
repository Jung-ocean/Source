clear; clc; close all

casename = 'KODC_small';
month_all = [8];
depth_all = [0];

figpath = 'D:\Data\Ocean\KODC\avg_ts_period(n2)\';
titletype = [''];

filepath = 'D:\Data\Ocean\KODC\avg_ts_period(n2)\';
%file1 = 'KODC_avg(1990_1995).mat';
file1 = 'D:\Data\Ocean\KODC\avg_ts(1979_2020)\KODC_avg(1979_2020).mat';
file2 = 'KODC_avg(sstrati).mat';
load([filepath, file2]);
data_file2_all = data_avg;

% Bathymetry file
zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;

[lon_lim, lat_lim] = domain_J(casename);

for ts = 1:1
    if ts == 1
        variindex = 12;
        clim = [-2 2];
        contour_interval = [clim(1):1:clim(2)];
        vari = 'temp';
        colorbarname = '^oC';
        colormap_style = 'redblue2';
    elseif ts == 2
        variindex = 13;
        clim = [-1 1];
        contour_interval = [clim(1):.2:clim(2)];
        vari = 'salt';
        colorbarname = 'g/kg';
        colormap_style = 'redblue2';
    end
    
    %load([filepath, file1])
    load([file1])
    data_file1_all = data_avg;
        
        for mi = 1:length(month_all)
            month = month_all(mi); mstr = num2char(month,2);
            
            for di = 1:length(depth_all)
                depth = depth_all(di);
                if depth > 99; charnum = 3; else; charnum = 2; end
                dstr = num2char(depth, charnum);
                
                index1 = find(data_file1_all(:,2) == month & data_file1_all(:,11) == depth);
                index2 = find(data_file1_all(:,2) == month+1 & data_file1_all(:,11) == depth);
                
                index = sort([index1; index2]);
                
                data_file1 = data_file1_all(index,:);
                
                nanind = find(isnan(mean(data_file1,2)) == 1);
                data_file1(nanind,:) = [];
                
                obsline = data_file1(:,7);
                obspoint = data_file1(:,8);
                
                obsline_u = unique(obsline);
                obspoint_u = unique(obspoint);
                
                aindex = find(data_file2_all(:,2) == month & data_file2_all(:,11) == depth);
                data_file2 = data_file2_all(aindex,:);
                
                obsline_a = data_file2(:,7);
                obspoint_a = data_file2(:,8);

            data_diff = [];
            for oli = 1:length(obsline_u)
                for opi = 1:length(obspoint_u)
                    tindex = find(obsline == obsline_u(oli) & obspoint == obspoint_u(opi));
                    aindex = find(obsline_a == obsline_u(oli) & obspoint_a == obspoint_u(opi));
                    if length(tindex) > 1
                        tindex = tindex(1);
                    end
                    if ~isempty(tindex) && ~isempty(aindex)
                        data_diff = [data_diff; data_file1(tindex,:)];
                        data_diff(end, variindex) = data_file2(aindex, variindex) - data_file1(tindex, variindex);
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
                
                figure
                map_J(casename)
                m_pcolor(Xi, Yi, Zi.*mask./mask); colormap(colormap_style); shading flat;
                [cs, h] = m_contour(Xi, Yi, Zi.*mask./mask, contour_interval, 'k');
                h.LineWidth = 1;
                clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold', 'LabelSpacing', 200);
                c = colorbar; c.FontSize = 15;
                %c.Label.String = colorbarname; c.Label.FontSize = 15;
                c.Title.String = colorbarname; c.Title.FontSize = 15;
                caxis(clim);
                
                %titlename = [titletype, datestr((data_file1(1,1:6)), 'mmm'), ' ', num2str(year)];
                %title(titlename, 'fontsize', 25)
                
                % plot point
                m_plot(lon_target, lat_target, '.k', 'markersize', 10)
                
                %setposition([casename, '_obs'])
                %setposition([casename])
                m_gshhs_i('patch', [.7 .7 .7])
                saveas(gcf,[figpath, 'diff_', vari, '_', dstr, 'm_', casename, '_', mstr],'png');
            end
        end
        %close all
end