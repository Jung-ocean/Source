clear; clc; close all

yyyy = 2020;

refdatenum = datenum(yyyy,1,1);
filenumber = 153:160;
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

tracers = 'ubar';
varis = {'accel', 'bstr', 'cor', 'hadv', 'hvisc',  'prsgrd', 'sstr'};

% varis = {'accel', 'cor', 'hadv', 'hvisc',  'prsgrd', 'vadv', 'vvisc'};

casename = 'EYECS_20220110';

g = grd(casename);

station = '20LTC06_S';

switch station
    case 'SE'
        location = [128.419027 34.222472];
    case '20LTC06_S'
        location = [127.7103, 34.2936];
end

for fi = 1:length(filenumber)
    
    fns = num2char(filenumber(fi), 4)
    
    filename = ['.\dia_', fns, '.nc'];
    filename_avg = ['.\avg_', fns, '.nc'];
    
    nc = netcdf(filename);
    ncavg = netcdf(filename_avg);
      
    ubar = ncavg{'ubar'}(:);
    vbar = ncavg{'vbar'}(:);
    
    skip = 1; npts = [0 0 0 0];
    [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(ubar.*g.mask_u,vbar.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        
    uvel = ubar;
    vvel = v_rho;
    
    lon = g.lon_u;
    lat = g.lat_u;
    mask = g.mask_u;
    
    nanind = 0;
    while nanind == 0
        [k,dist] = dsearchn([lon(:) lat(:)], location);
        nanind = mask(k);
        if nanind == 0
            lon(k) = []; lat(k) = []; mask(k) = [];
            uvel(k) = [];
            vvel(k) = [];
        end
    end
    
    u_surf(fi) = uvel(k);
    v_surf(fi) = vvel(k);
        
    for vi = 1:length(varis)
        vari = varis{vi};
        
        uvar = nc{['ubar_', varis{vi}]}(:);
        vvar = nc{['vbar_', varis{vi}]}(:);
        
        skip = 1; npts = [0 0 0 0];
        [uvar_rho,vvar_rho,lon,lat,mask] = uv_vec2rho(uvar.*g.mask_u,vvar.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        
        udia = uvar;
        vdia = vvar_rho;
        
        lon = g.lon_u;
        lat = g.lat_u;
        mask = g.mask_u;
        
        nanind = 0;
        while nanind == 0
            [k,dist] = dsearchn([lon(:) lat(:)], location);
            nanind = mask(k);
            if nanind == 0
                lon(k) = []; lat(k) = []; mask(k) = [];
                udia(k) = [];
                vdia(k) = [];
                tempvar(k) = [];
            end
        end
        
        udia_all(vi,fi) = udia(k);
        vdia_all(vi,fi) = vdia(k);
        
    end % vi
    close(nc)
    close(ncavg)
end % fi

figure; hold on; grid on
for vi = 1:length(varis)
    if vi == 1
        plot(udia_all(vi,:), 'k', 'LineWidth', 2)
    else
        plot(udia_all(vi,:), 'LineWidth', 2)
    end
end
plot(sum(udia_all(2:end,:),1),'--r')
l = legend(varis)

figure; hold on; grid on
plot(1:length(filenumber), u_surf, '-or')
plot(2:length(filenumber), u_surf(1:end-1) + udia_all(1,1:end-1)*60*60*24, '-ok')