clear; clc; close all

fpath = 'D:\Data\Ocean\KODC\avg_ts(1980_2015)\';
flist = dir(fullfile(fpath, '*.txt')); % filename with path

casename = 'ECS';

[lon_lim, lat_lim] = domain_J(casename);

for ts = 2:2
    if ts == 1
        clim = [10 30];
        contour_interval = [clim(1):2:clim(2)];
        vari = 'TEMP';
        colorbarname = 'Temperature (deg C)';
        colormapname = 'parula';
    elseif ts == 2
        clim = [30 35];
        contour_interval = [clim(1):.5:clim(2)];
        vari = 'SALT';
        colorbarname = 'Salinity';
        colormapname = 'jet';
    end
    
    % Bathymetry file
    zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
    Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;
    
    for fi = 8:8%1:length(flist)
        fname = flist(fi).name;
        
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
        
        figure; hold on;
        map_J(casename)
        m_pcolor(Xi, Yi, Zi); colormap(colormapname); shading flat;
        [cs, h] = m_contour(Xi, Yi, Zi, contour_interval, 'w');
        clabel(cs, h);
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
               
        titlename = [vari, ' Avg ', fname(5:6), ' ', fname(1:3),];
        %title(titlename, 'fontsize', 25)
        
        % plot point
        for i = 1:length(LAT)
            m_plot(LONG(i), LAT(i), '.k', 'markersize', 5)
        end
        
        saveas(gcf,[fpath, fname(1:end-4), '_', vari],'png');
        
    end
end