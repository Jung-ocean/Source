clear; clc; close all

Year_all = [2003:2015];
fig_type = 'normal'; % normal or Anomaly
casename = 'YECS_flt';
month_all = [10 12];
depth_all = [0 50];

[lon_lim, lat_lim] = domain_J(casename);

for ts = 1:2
    if ts == 1
        clim = [10 30];
        contour_interval = [clim(1):2:clim(2)];
        vari = 'TEMP';
        colorbarname = 'Temperature (deg C)';
        colormap_style = 'parula';
    elseif ts == 2
        clim = [30 35];
        contour_interval = [clim(1):.5:clim(2)];
        vari = 'SALT';
        colorbarname = 'Salinity';
        colormap_style = 'jet';
    end
    
    if strcmp(fig_type,'normal')
        fpath1 = 'D:\Data\Ocean\KODC\KODC_';
        titletype = [''];
    elseif strcmp(fig_type, 'anomaly')
        fpath1 = 'D:\Data\Ocean\KODC\TS_diff_';
        colormap_style = 'redblue';
        clim = [-4 4];
        contour_interval = [clim(1):2:clim(2)];
        titletype = ['Anomaly '];
    end
    
    % Bathymetry file
    zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
    Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;
    
    for yi = 1:length(Year_all)
        year = Year_all(yi); ystr = num2str(year);
        fpath = [fpath1, num2char(year,4), '\'];
        
        if year == 9999
            fpath = 'D:\Data\Ocean\KODC\avg_ts(1980_2015)\';
            ystr = 'mean';
        end
        
        %flist = dir(fullfile(fpath, '*.txt')); % filename with path
        %for fi = 1:length(flist)
        %    fname = flist(fi).name;
        for mi = 1:length(month_all)
            month = month_all(mi); mstr = num2char(month,2);
            for di = 1:length(depth_all)
                depth = depth_all(di);
                if depth > 99; charnum = 3; else; charnum = 2; end
                dstr = num2char(depth, charnum);
                
                fname = [dstr, 'm_', mstr, '_', ystr, '.txt'];
                
                % load temperature data
                [ST, LONG, LAT, TEMP, SALT] = textread([fpath, fname],'%d %f %f %f %f');
                
                X1 = min(LONG); X2 = max(LONG);
                Y1 = min(LAT); Y2 = max(LAT);
                Xp = [X1:0.1:X2]; Yp = [Y1:0.1:Y2];
                [Xi, Yi] = meshgrid(Xp, Yp);
                
                zind = find(lon_lim(1) < Zlon & Zlon < lon_lim(2) & lat_lim(1) < Zlat & Zlat < lat_lim(2));
                Zlon2 = Zlon(zind); Zlat2 = Zlat(zind); Zz2 = Zz(zind);
                z_grid = griddata(Zlon2,Zlat2,Zz2, Xi, Yi);
                
                Zi = griddata(LONG, LAT, eval(vari), Xi, Yi);
                Zi(z_grid < str2num(fname(1:end-13))) = NaN; % Bathymetry
                
                for li = 1:length(Yp)
                    lind = isnan(Zi(li,:));
                    try
                        lind2 = find(diff(lind) == 1);
                        Zi(li,lind2(end):-1:lind2(end)-2) = nan;
                    catch
                    end
                    
                end
                
                figure;
                map_J(casename)
                m_pcolor(Xi, Yi, Zi); colormap(colormap_style); shading flat;
                [cs, h] = m_contour(Xi, Yi, Zi, contour_interval, 'k');
                clabel(cs, h);
                c = colorbar; c.FontSize = 15;
                c.Label.String = colorbarname; c.Label.FontSize = 15;
                caxis(clim);
                
                titlename = [titletype, datestr(datenum(1, str2num(fname(5:6)),1), 'mmm'), ' ', num2str(year)];
                %title(titlename, 'fontsize', 25)
                
                % plot point
                for i = 1:length(LAT)
                    m_plot(LONG(i), LAT(i), '.k', 'markersize', 5)
                end
                
                %saveas(gcf,[fname(1:end-4), '_', vari],'png');
                saveas(gcf,[fpath, vari, '_', dstr, 'm_', casename, '_', ystr, mstr],'png');
            end
        end
        close all
    end
end