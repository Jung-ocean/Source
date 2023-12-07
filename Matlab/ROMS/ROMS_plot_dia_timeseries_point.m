clear; clc; close all

yyyy = 2020;

refdatenum = datenum(yyyy,1,1);
filenumber = 170:180;
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

% tracers = 'ubar';
% varis = {'accel', 'bstr', 'cor', 'hadv', 'hvisc',  'prsgrd', 'sstr'};

varis = {'accel', 'cor', 'hadv', 'hvisc',  'prsgrd', 'vadv', 'vvisc'};

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
      
    u = ncavg{'u'}(1,40,:,:);
    Huon = ncavg{'Huon'}(1,40,:,:);
    v = ncavg{'v'}(1,40,:,:);
    temp = ncavg{'temp'}(1,40,:,:);
    
    skip = 1; npts = [0 0 0 0];
    [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u.*g.mask_u,v.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        
    uvel = u_rho;
    Huvel = Huon;
    vvel = v_rho;
    
    lon = g.lon_rho;
    lat = g.lat_rho;
    mask = g.mask_rho;
    pn = g.pn;
    
    nanind = 0;
    while nanind == 0
        [k,dist] = dsearchn([lon(:) lat(:)], location);
        nanind = mask(k);
        if nanind == 0
            lon(k) = []; lat(k) = []; mask(k) = [];
            uvel(k) = [];
            Huvel(k) = [];
            pn(k) = [];
            vvel(k) = [];
            temp(k) = [];
        end
    end
    
    u_surf(fi) = uvel(k);
    Hu_surf(fi) = Huvel(k).*pn(k);
    v_surf(fi) = vvel(k);
    temp_surf(fi) = temp(k);
    
    for vi = 1:length(varis)
        vari = varis{vi};
        
        uvar = nc{['u_', varis{vi}]}(1,40,:,:);
        vvar = nc{['v_', varis{vi}]}(1,40,:,:);
        tempvar = nc{'temp_rate'}(1,40,:,:);
        
        skip = 1; npts = [0 0 0 0];
        [uvar_rho,vvar_rho,lon,lat,mask] = uv_vec2rho(uvar.*g.mask_u,vvar.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        
        udia = uvar_rho;
        vdia = vvar_rho;
        
        lon = g.lon_rho;
        lat = g.lat_rho;
        mask = g.mask_rho;
        
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
        temp_rate(fi) = tempvar(k);
        
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
%plot(sum(var_all(2:end,:),1),'r')
l = legend(varis)

figure; hold on; grid on
plot((udia_all(1,:)*60*60*24), 'k')
plot(u_surf)
plot(Hu_surf)