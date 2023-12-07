clear; clc; close all

Year_all = [2013];

casename = 'YECS_small';
vari = 'density';

[lon_lim, lat_lim] = domain_J(casename);

contour_interval = [18:1:28];
clim = [contour_interval(1) contour_interval(end)];
colorbarname = 'Density (\sigma_t)';

fpath1 = 'D:\Data\Ocean\KODC\KODC_';
titletype = [' '];
colormap_style = 'jet';


% Bathymetry file
zfile = load('D:\Data\Ocean\Bathymetry\KorBathy30s.mat');
Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;

for yi = 1:length(Year_all);
    year = Year_all(yi);
    fpath = [fpath1, num2char(year,4), '\'];
    flist = dir(fullfile(fpath, '*.txt')); % filename with path
    
    for fi = 1:length(flist)
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
        
        dep1 = str2num(fname(1:2));
        dep = ones(length(LAT),1)*dep1;
        pres = sw_pres(dep, LAT);
        pdens = sw_pden(SALT, TEMP, pres, 0);
        density = pdens - 1000;
        
        Zi = griddata(LONG, LAT, eval(vari), Xi, Yi);
        Zi(z_grid < str2num(fname(1:2))) = NaN; % Bathymetry
        
        for li = 1:length(Yp)
            lind = isnan(Zi(li,:));
            try
                lind2 = find(diff(lind) == 1);
                Zi(li,lind2(end):-1:lind2(end)-2) = nan;
            catch
            end
            
        end
        
        map_J(casename)
        m_pcolor(Xi, Yi, Zi); colormap(colormap_style); shading flat;
        [cs, h] = m_contour(Xi, Yi, Zi, contour_interval, 'w');
        clabel(cs, h);
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
        
        titlename = [vari, titletype, num2str(year), fname(5:6), ' ', fname(1:3)];
        title(titlename, 'fontsize', 25)
        
        % plot point
        for i = 1:length(LAT)
            m_plot(LONG(i), LAT(i), '.k', 'markersize', 5)
        end
        
        saveas(gcf,[fname(1:end-4), '_', vari],'png');
        
        
    end
end