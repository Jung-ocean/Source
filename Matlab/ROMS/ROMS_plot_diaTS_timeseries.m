clear; clc; close all

yyyy = 2013;

refdatenum = datenum(yyyy,1,1);
filenumber = 182:243;
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

tracers = 'temp';
%varis = {'rate', 'vdiff', 'adv', 'hadv', 'xadv', 'yadv', 'vadv'};
varis = {'rate', 'hdiff', 'vdiff', 'hadv', 'vadv', 'xadv', 'yadv'};

casename = 'EYECS_20190904';

g = grd(casename);

%lon = 127.7; lat = 34.2;
lon = 128; lat = 34.5;

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

all_scale = all/1e-5;
for vi = 1:length(varis)
    vari = all_scale(:,:,vi);
    for ni = 1:g.N
        vari_movmean(ni,:) = (movmean(vari(ni,:),14));
    end
        
    figure; hold on;
    pcolor(filenumber+1, depth, vari_movmean); shading interp
    colormap('redblue2')
    
    xtickindex = [1 32 62];
    
    set(gca, 'Xtick', filenumber(xtickindex))
    set(gca, 'XtickLabel', filedate(xtickindex,:))
    axis tight
    xlim([182 244.5])
    ylim([-36 0])
    caxis([-10 10])
    c = colorbar;
    c.Title.String = 'x10^-^5 ^oC/s';
    ylabel('Depth (m)')
    
    set(gca, 'FontSize', 15)
    
    title([tracers, '\_', varis{vi}])
    saveas(gcf, ['.\timeseries\', tracers, '_', varis{vi}, '.png'])
end