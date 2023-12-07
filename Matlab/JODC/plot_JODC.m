clear; clc; close all

casename = 'LTRANS';
[lon_lim, lat_lim] = domain_J(casename);

depth_target = 100;

for ts = 2:2
    if ts == 1
        clim = [10 30];
        contour_interval = [clim(1):2:clim(2)];
        vari = 'Temp';
        colorbarname = 'Temperature (deg C)';
    elseif ts == 2
        clim = [30 35];
        contour_interval = [clim(1):1:clim(2)];
        vari = 'Salt';
        colorbarname = 'Salinity';
    end
    
    % Bathymetry file
    zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
    Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;
    
    fname = 'jodc-odv-20181130160107.txt';
    data_all = read_JODC(fname);
    
    Cruise = table2array(data_all(:,1));
    Station = table2array(data_all(:,2));
    mondayyr = table2array(data_all(:,4));
    hhmm = table2array(data_all(:,5));
    Lon = table2array(data_all(:,6));
    Lat = table2array(data_all(:,7));
    Depthm = table2array(data_all(:,9));
    Temperature = table2array(data_all(:,13));
    Salinity = table2array(data_all(:,15));
    
    index = find(Depthm == depth_target);
    LONG = Lon(index);
    LAT = Lat(index);
    Temp = Temperature(index);
    Salt = Salinity(index);
    
    X1 = min(LONG); X2 = max(LONG);
    Y1 = min(LAT); Y2 = max(LAT);
    Xp = [X1:0.1:X2]; Yp = [Y1:0.1:Y2];
    [Xi, Yi] = meshgrid(Xp, Yp);
    
    %             zind = find(lon_lim(1) < Zlon & Zlon < lon_lim(2) & lat_lim(1) < Zlat & Zlat < lat_lim(2));
    %             Zlon2 = Zlon(zind); Zlat2 = Zlat(zind); Zz2 = Zz(zind);
    %             z_grid = griddata(Zlon2,Zlat2,Zz2, Xi, Yi);
    %
                Zi = griddata(LONG, LAT, eval(vari), Xi, Yi);
    %             Zi(z_grid < str2num(fname(1:2))) = NaN; % Bathymetry
    
    %             for li = 1:length(Yp)
    %                 lind = isnan(Zi(li,:));
    %                 try
    %                     lind2 = find(diff(lind) == 1);
    %                     Zi(li,lind2(end):-1:lind2(end)-2) = nan;
    %                 catch
    %                 end
    %
    %             end
    
    figure;
    map_J(casename)
    m_pcolor(Xi, Yi, Zi); shading flat;
    [cs, h] = m_contour(Xi, Yi, Zi, contour_interval, 'k');
    clabel(cs, h);
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
    
    %             titlename = [titletype, datestr(datenum(1, str2num(fname(5:6)),1), 'mmm'), ' ', num2str(year)];
    %title(titlename, 'fontsize', 25)
    
    % plot point
    for i = 1:length(LAT)
        m_plot(LONG(i), LAT(i), '.k', 'markersize', 5)
    end
    
    saveas(gcf,[vari,'_JODC_', num2str(depth_target),'.png']);
    
end

