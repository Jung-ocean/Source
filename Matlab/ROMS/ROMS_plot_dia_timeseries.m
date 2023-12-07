clear; clc; close all

yyyy = 2013;

refdatenum = datenum(yyyy,1,1);
filenumber = 182:243;
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

tracers = 'v';
varis = {'accel', 'cor', 'prsgrd', 'vvisc'};
titles = {'Acceleration', 'Coriolis', 'Pressure gradient', 'Vertical viscosity'};

casename = 'EYECS_20190904';

g = grd(casename);

%lon = 128; lat = 34.5; ylimit = [-36 0]; ytick = [-30 -20 -10 0];
lon = 128.3; lat = 34.2; ylimit = [-83 0]; ytick = [-80 -40 0];

dist=sqrt((g.lon_rho-lon).^2+(g.lat_rho-lat).^2);
min_dist=min(min(dist));

[x,y]=find(dist==min_dist);
lat_ind = x; lon_ind = y;
%lat_target=lat(x(1),y(1));lon_target=lon(x(1),y(1));
depth = g.z_r(:,lat_ind, lon_ind);

all = zeros(g.N,length(filenumber),length(varis));
for fi = 1:length(filenumber)
    
    fns = num2char(filenumber(fi), 4)
    savename = filedate(fi,:);
    
    filename = ['.\daily\dia_', fns, '.nc'];
    nc = netcdf(filename);
    
    for vi = 1:length(varis)
        var_str = [tracers, '_', varis{vi}];
        if strcmp(var_str, [tracers, '_adv'])
            var = nc{[tracers, '_hadv']}(:,:,lat_ind, lon_ind) + nc{[tracers, '_vadv']}(:,:,lat_ind, lon_ind);
        else
            var = nc{var_str}(:,:,lat_ind, lon_ind);
        end
        
        all(:,fi,vi) = var;
        
    end % vi
end % fi

all_scale = all/1e-6;
clim = [-60 60];
contour_intervals = [-60 -50 -40 -30 -20 -10 10 20 30 40 50 60];

for vi = 1:length(varis)
    var_str = [tracers, '_', varis{vi}];
    vari = all_scale(:,:,vi);
    for ni = 1:g.N
        vari_movmean(ni,:) = (movmean(vari(ni,:),14));
    end
    
    figure; hold on;
    pcolor(filenumber+1, depth, vari_movmean); shading interp
    [cs,h] = contour(filenumber+1, depth, vari_movmean, contour_intervals, 'k'); shading interp
    h.LineWidth = 1;
    clabel(cs,h,'LabelSpacing',1000, 'FontSize', 25, 'FontWeight', 'bold')
    
    colormap('redblue2')
    
    xtickindex = [1 32 62];
    
    set(gca, 'Xtick', filenumber(xtickindex))
    set(gca, 'XtickLabel', {'1 JUL', '1 AUG', '31 AUG'})
    axis tight
    xlim([182 244.5])
    ylim(ylimit)
    caxis(clim)
        
    ylabel('Depth (m)')
    
    if sum(strcmp(var_str, {'u_vvisc', 'v_vvisc'}))
        c = colorbar; c.FontSize = 30;
        c.Title.String = 'x10^-^6 m/s^2';
        c.Title.FontSize = 20;
        setposition('vertical')
        set(gca, 'Position', [ 0.1258    0.2055    0.5960    0.7195])
    else
        setposition('vertical')
        set(gca, 'Position', [ 0.3258    0.2055    0.5960    0.7195])
    end
    
    ylabel('Depth (m)')
    yticks(ytick)
    
    if ~sum(strcmp(var_str, {'u_prsgrd', 'v_prsgrd'}))
        set(gca,'YTickLabel',[]);
        ylabel('');
    end
    
    box on
    ax = get(gca);
    ax.XAxis.LineWidth = 2;
    ax.YAxis.LineWidth = 2;
    
    set(gca, 'FontSize', 32)
    title([titles{vi}], 'FontSize', 35)
    
    %saveas(gcf, ['.\timeseries\', tracers, '_', varis{vi}, '.png'])
    print(['.\timeseries\', tracers, '_', varis{vi}, '.tiff'],'-dtiff','-r300');
end