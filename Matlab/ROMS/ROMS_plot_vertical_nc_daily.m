%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section along constant latitude
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yyyy = 2020;
var_str = 'w'
fig_str = '205';
vec = 'off';

rotind = 1; theta = -20;

datenum_ref = datenum(yyyy,1,1);

filenumber = 153:213;
%filenumber = 163:164; % 2020 Jun. KODC
%filenumber = 232:233; % 2020 Aug. KODC
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');
titlestr = datestr(filenumber + datenum_ref -1, 'dd-mmm-yyyy');

yts = num2str(yyyy);
if yyyy == 9999; yts = 'avg'; end

casename = 'EYECS_20220110';
g = grd(casename);

if strcmp(fig_str, '400')
    domaxis = [34.0767 34.6 128.5 128.0833 -80 0]; % KODC 400 line
elseif strcmp(fig_str, '204')
    domaxis = [33.5967 34.3 127.0533 127.533 -120 0]; % KODC 204 line
elseif strcmp(fig_str, '205')
    domaxis = [33.6217 34.4167 128.1533 127.6667 -120 0]; % KODC 205 line
elseif strcmp(fig_str, '206')
    domaxis = [34.3733 34.6333 128.8283 128.4167 -120 0]; % KODC 206 line
end

for fi = 1:length(filenumber)
    %mm = mi;     tms = num2char(mm,2);
    %filename = ['monthly_', tys, tms, '.nc']; ncload(filename)
    
    filename = ['avg_', fns(fi,:), '.nc']; ncload(filename)
    
    depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
    if strcmp(var_str, 'w')
        depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w', 2);
    end
    
    depth(depth > 1000) = NaN;
    
    pdens = zeros(size(depth));
    for si = 1:g.N
        pres = sw_pres(squeeze(depth(si,:,:)), g.lat_rho);
        pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
    end
    density = pdens - 1000;
    
    var = eval(var_str);
    var(var > 1000) = NaN;
    
    skip = 1; npts = [0 0 0 0];
    for di = 1:g.N
        u_2d = squeeze(u(di,:,:));
        v_2d = squeeze(v(di,:,:));
        [u_rho(di,:,:),v_rho(di,:,:),lon,lat,mask] = uv_vec2rho(u_2d.*g.mask_u,v_2d.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        
        if rotind == 1
            u_rho(di,:,:) = cosd(theta)*u_rho(di,:,:) + -sind(theta)*v_rho(di,:,:);
            v_rho(di,:,:) = sind(theta)*u_rho(di,:,:) + cosd(theta)*v_rho(di,:,:);
        end
    end
    if strcmp(var_str,'u') || strcmp(var_str,'v')
        var = eval([var_str, '_rho']);
    end
    
    [x, Yi, data] = ROMS_plot_vertical_function(g, depth, var_str, var, domaxis);
    
    ax = get(gca);
    xlim([ax.XLim(1)-0.005 ax.XLim(2)+0.01])
    ylim([domaxis(5) domaxis(6)])
    ax.XAxis.TickDirection = 'out';
    ax.YAxis.TickDirection = 'out';
    ax.XAxis.LineWidth = 2;
    ax.YAxis.LineWidth = 2;
    
    if strcmp(vec, 'on')
        lon = g.lon_rho; lat = g.lat_rho;
        
        dist=sqrt((lon-domaxis(3)).^2+(lat-domaxis(1)).^2);
        min_dist=min(min(dist));
        dist2=sqrt((lon-domaxis(4)).^2+(lat-domaxis(2)).^2);
        min_dist2=min(min(dist2));
        [x1,y1]=find(dist==min_dist);
        [x2,y2]=find(dist2==min_dist2);
        lat1=lat(x1(1),y1(1));lon1=lon(x1(1),y1(1));
        lat2=lat(x2(1),y2(1));lon2=lon(x2(1),y2(1));
        
        lat_line=[min(lat1,lat2):0.05:max(lat1,lat2)];
        lon_line=(lat_line-lat1)*((lon2-lon1)/(lat2-lat1))+lon1;
        x=repmat(lat_line,g.N,1);
        x_label='Latitude(^oN)';
                
        w(w > 1000) = 0;
        for ni = 1:g.N
            w_rho(ni,:,:) = (w(ni,:,:) + w(ni+1,:,:))/2;
        end
        
        w_data=zeros(g.N,length(lat_line));
        v_data=zeros(g.N,length(lat_line));
        for k=1:1:g.N
            lon_range=lon(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
            lat_range=lat(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
            w_data_range=squeeze(w_rho(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
            v_data_range=squeeze(v(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
            depth_range=squeeze(depth(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
            w_data(k,:)=griddata(lon_range,lat_range,w_data_range,lon_line,lat_line);
            v_data(k,:)=griddata(lon_range,lat_range,v_data_range,lon_line,lat_line);
            Yi(k,:)=griddata(lon_range,lat_range,depth_range,lon_line,lat_line);
        end
        
        w = (v_data+sqrt(-1).*(-w_data.*1e5));
        h1 = psliceuv_w(x, Yi, w, 4, 0.5, 'k');
        
        title([titlestr(fi,:)], 'fontsize', 25)
        %title(titlename, 'FontSize', 25)
        box on
        saveas(gcf, [var_str, '_vertical_', fig_str, '_', casename, '_', filedate(fi,:), '.png'])
    else
        title([titlestr(fi,:)], 'fontsize', 25)
        %title(titlename, 'FontSize', 25)
        box on
        %setposition('vertical')
        plot(34.2936, 0, '.r', 'MarkerSize', 35)
        
        saveas(gcf, [var_str, '_vertical_', fig_str, '_', casename, '_', filedate(fi,:), '.png'])
    end
end