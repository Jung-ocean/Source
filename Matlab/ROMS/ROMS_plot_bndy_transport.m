clear; clc; close all

%filepath = 'G:\Model\ROMS\Case\NWP\input\';
filepath = '.\';
yyyy = [1980:2015];

g = grd('NWP');
maskv = g.mask_v; maskv2 = maskv./maskv;
masku = g.mask_u; masku2 = masku./masku;
lon_u = g.lon_u; lat_u = g.lat_u;
lon_v = g.lon_v; lat_v = g.lat_v;
z_w = g.z_w; dzr = z_w(2:end,:,:)-z_w(1:end-1,:,:);

maskv_north = maskv2(end,:); dzr_north = squeeze(dzr(:,end,:));
maskv_south = maskv2(1,:); dzr_south = squeeze(dzr(:,1,:));
masku_east = masku2(:,end); dzr_east = squeeze(dzr(:,:,end));
masku_west = masku2(:,1); dzr_west = squeeze(dzr(:,:,1));

for yi = 1:length(yyyy)
    tys = num2str(yyyy(yi));
    nc = netcdf([filepath, 'roms_bndy_NWP_SODA3_', tys, '.nc']);
    vn = nc{'v_north'}(:); vs = nc{'v_south'}(:);
    ue = nc{'u_east'}(:); uw = nc{'u_west'}(:);
    close(nc);
    
    for i = 1:12
        for ii = 1:40
            vn_mask(i,ii,:) = squeeze(vn(i,ii,:)).*maskv_north';
            vs_mask(i,ii,:) = squeeze(vs(i,ii,:)).*maskv_south';
            ue_mask(i,ii,:) = squeeze(ue(i,ii,:)).*masku_east;
            uw_mask(i,ii,:) = squeeze(uw(i,ii,:)).*masku_west;
        end
    end
    
    % Transport
    % Northern boundary========================================================
    %lat_north = max(max(lat_v));
    %lon_distance = 111*cos(lat_north*pi/180); % 위도 111km % 경도 111*cos(위도*pi/180) km
    
    lon_diff_all = 1./g.pm;
    lon_diff = lon_diff_all(end,:);
    area_north = lon_diff.*dzr_north; % m^2
    
    for ii = 1:12
        trans_north(ii,:,:) = squeeze(vn_mask(ii, :,:)).*area_north;
    end
    trans_north_monthly(12*yi-11:12*yi) = nansum(nansum(trans_north, 2), 3)./(10^6); % Sv
    
    % Southern boundary========================================================
    %lat_north = max(max(lat_v));
    %lon_distance = 111*cos(lat_north*pi/180); % 위도 111km % 경도 111*cos(위도*pi/180) km
    
    range = [114 121];
    lon_south = lon_v(1,:);
    index = find(range(1) <= lon_south & lon_south <= range(2));
    
    lon_diff_all = 1./g.pm;
    lon_diff = lon_diff_all(1,:);
    area_south = lon_diff.*dzr_south; % m^2
    
    %vs_mask(:,1:layer_south_west(1),:) = NaN;
    
    for ii = 1:12
        trans_south(ii,:,:) = squeeze(vs_mask(ii,:,:)).*area_south;
    end
    trans_south_monthly(12*yi-11:12*yi) = nansum(nansum(trans_south(:,:,index), 2), 3)./(10^6); % Sv
    
    % Eastern boundary=========================================================
    range = [46 52];
    
    lat_diff_all = 1./g.pn;
    lat_diff = lat_diff_all(:,end);
    area_east = lat_diff'.*dzr_east; % m^2
    
    for ii = 1:12
        trans_east(ii,:,:) = squeeze(ue_mask(ii, :,:)).*area_east;
    end
    
    trans_lat = lat_u(:,end);
    index = find(range(1) <= trans_lat & trans_lat <= range(2));
    
    trans_east_monthly((12*yi-11:12*yi)) = nansum(nansum(trans_east(:,:,index), 2), 3)./(10^6); % Sv
    
    % Western boundary=========================================================
    
    lat_diff_all = 1./g.pn;
    lat_diff = lat_diff_all(:,1);
    area_west = lat_diff'.*dzr_west; % m^2
    
    %uw_mask(:,1:layer_south_west(1),:) = NaN;
    
    for ii = 1:12
        trans_west(ii,:,:) = squeeze(uw_mask(ii,:,:)).*area_west;
    end
    
    trans_west_monthly((12*yi-11:12*yi)) = nansum(nansum(trans_west, 2), 3)./(10^6); % Sv
end

xdate = [];
for yi = yyyy(1):yyyy(end)
    for mi = 1:12
        xdate = [xdate; yi mi];
    end
end
xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

figure; hold on; grid on
plot(xdatenum, trans_north_monthly, 'o-', 'LineWidth', 2)
plot(xdatenum, movmean(trans_north_monthly, 13), 'LineWidth', 2)
plot(xdatenum, zeros(length(xdatenum)), 'k', 'LineWidth' ,2)
xlabel('Year'); ylabel('Sv')
xlim([datenum(yyyy(1)-1, 12, 31), datenum(yyyy(end)+1, 1, 1)])
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
datetick('x', 'yy')
set(gca, 'FontSize', 15)
title('Northern bndy transport', 'FontSize', 15)
%saveas(gcf, 'transport_north.png')

figure; hold on; grid on
plot(xdatenum, trans_east_monthly, 'o-', 'LineWidth', 2)
plot(xdatenum, movmean(trans_east_monthly, 13), 'LineWidth', 2)
plot(xdatenum, zeros(length(xdatenum)), 'k', 'LineWidth' ,2)
xlabel('Year'); ylabel('Sv')
xlim([datenum(yyyy(1)-1, 12, 31), datenum(yyyy(end)+1, 1, 1)])
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
datetick('x', 'yy')
set(gca, 'FontSize', 15)
title(['Eastern bndy transport from ', num2str(range(1)),  ' to ',num2str(range(2))], 'FontSize', 15)
%saveas(gcf, 'transport_east_part.png')

figure; hold on; grid on
plot(xdatenum, trans_north_monthly + trans_east_monthly, 'o-', 'LineWidth', 2)
plot(xdatenum, movmean(trans_north_monthly + trans_east_monthly, 13), 'LineWidth', 2)
plot(xdatenum, zeros(length(xdatenum)), 'k', 'LineWidth' ,2)
xlabel('Year'); ylabel('Sv')
xlim([datenum(yyyy(1)-1, 12, 31), datenum(yyyy(end)+1, 1, 1)])
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
datetick('x', 'yy')
set(gca, 'FontSize', 15)
title('Northern + Eastern(part) bndy transport', 'FontSize', 15)
%saveas(gcf, 'transport_north+east.png')