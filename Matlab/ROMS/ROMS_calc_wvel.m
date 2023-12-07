clear; clc; close all

g = grd('NWP');

yyyy = 1980:2015; 
mm = 7:8;

distance_coastal = 5; % 50km

rho = 1027;
f = 10^-4;
rhof = rho.*f;

trans_pumping = [];
for yi = 1:length(yyyy)
    yts = num2str(yyyy(yi));

[lon_lim, lat_lim] = domain_J('YECS_small');
[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, lon_lim, lat_lim);

lon = g.lon_rho(lat_ind, lon_ind);
lat = g.lat_rho(lat_ind, lon_ind);

unc = netcdf(['G:\Model\ROMS\Case\NWP\input\Uwind_NWP_ECMWF_', yts, '.nc']);
vnc = netcdf(['G:\Model\ROMS\Case\NWP\input\Vwind_NWP_ECMWF_', yts, '.nc']);

ot = unc{'Uwind_time'}(:);
date_vec = datevec(ot + datenum(yyyy(yi),1,1));

w_all = [];
for mi = 1:length(mm)
    mts = num2char(mm,2);
    tindex = find(date_vec(:,2) == mm(mi));
    
    %u_target = squeeze(mean(unc{'Uwind'}(tindex, :, :)));
    %v_target = squeeze(mean(vnc{'Vwind'}(tindex, :, :)));
    
    u_target = unc{'Uwind'}(tindex, lat_ind, lon_ind);
    v_target = vnc{'Vwind'}(tindex, lat_ind, lon_ind);
    
    r = sqrt(u_target.*u_target + v_target.*v_target);
    theta = atan2(v_target,u_target);
    
    tau = stresslp(r,10); % wind stress scalar
    
    tau_x = tau./r.*u_target;
    tau_y = tau./r.*v_target;
    
    dx = 1./g.pm(lat_ind,lon_ind);
    dy = 1./g.pn(lat_ind,lon_ind);
    
    for ti = 1:length(tau_x)
        dtau_x = v2rho_2d( squeeze(diff(tau_x(ti,:,:),1,2)) );
        dtau_y = u2rho_2d( squeeze(diff(tau_y(ti,:,:),1,3)) );
        
        curltau(ti,:,:) = -( dtau_y./dx - dtau_x./dy );
        
    end
    
    w = curltau ./ (rhof) ;
    w_all = [w_all; w];
    
end

load(['..\Ekman\point.mat'])
lat_index = []; lon_index = [];
for i = 1:20
    lat_index = [lat_index; find(lat_ind == y(i))];
    lon_index = [lon_index; find(lon_ind == x(i))];
end

trans_pumping_tmp = zeros;
for ii = 1:length(lon_index)
    w_tmp = w_all(:,lat_index:-1:lat_index-(distance_coastal-1),lon_index(ii));
    dxdy = dx(lat_index:-1:lat_index-(distance_coastal-1),lon_index(ii)).*dy(lat_index:-1:lat_index-4,lon_index(ii));
    Ekman_tmp = w_tmp*dxdy;
    trans_pumping_tmp = trans_pumping_tmp + Ekman_tmp;
end

trans_pumping(yi,:) = trans_pumping_tmp;

end

%==========================================================================
figure; hold on;
map_J('YECS_small');
m_pcolor(g.lon_rho, g.lat_rho, w.*g.mask_rho./g.mask_rho);  shading interp
colormap('redblue')

caxis([-5e-6 5e-6])

c = colorbar;
%c.Label.String = 'Wind stress curl (N/m^3)';
c.Label.String = 'W-velocity (m/s)';
c.FontSize = 15;

%title([datestr(datevec(mts, 'mm'), 'mmm'), ' ', yts], 'FontSize', 20)
saveas(gcf, ['wvel_tauxy_', yts, mts, '_ms.png'])
%saveas(gcf, ['windstress_curl_', yts, mts, '.png'])
%==========================================================================
% figure; hold on;
% map_J('YECS_small');
% m_pcolor(g.lon_rho, g.lat_rho, w_month.*g.mask_rho./g.mask_rho);
% colormap('redblue')
%
% caxis([-10 10])
%
% c = colorbar;
% c.Label.String = 'W-velocity (m/month)';
% c.FontSize = 15;
%
% title([datestr(datevec(mts, 'mm'), 'mmm'), ' ', yts], 'FontSize', 20)
% saveas(gcf, ['wvel_tauxy_', yts, mts, '_mmonth.png'])
%==========================================================================