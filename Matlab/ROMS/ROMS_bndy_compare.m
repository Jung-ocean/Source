clear; clc; close all

filepath = 'G:\Model\ROMS\Case\NWP\input\';

Hnc = netcdf([filepath, 'roms_bndy_NWP_SODA3_2001_old.nc']);
Hvn = Hnc{'v_north'}(:); Hue = Hnc{'u_east'}(:);
close(Hnc);

Snc = netcdf([filepath, 'roms_bndy_NWP_SODA3_2001.nc']);
Svn = Snc{'v_north'}(:); Sue = Snc{'u_east'}(:);
close(Snc);

g = grd('NWP');
maskv = g.mask_v; maskv2 = maskv./maskv;
masku = g.mask_u; masku2 = masku./masku;
lon_u = g.lon_u; lat_u = g.lat_u;
lon_v = g.lon_v; lat_v = g.lat_v;
z_w = g.z_w; dzr = z_w(2:end,:,:)-z_w(1:end-1,:,:);

maskv_north = maskv2(end,:); dzr_north = squeeze(dzr(:,end,:));
masku_east = masku2(:,end); dzr_east = squeeze(dzr(:,:,end));

for i = 1:12
    for ii = 1:40
        Hvn2(i,ii,:) = squeeze(Hvn(i,ii,:)).*maskv_north';
        Svn2(i,ii,:) = squeeze(Svn(i,ii,:)).*maskv_north';
        Hue2(i,ii,:) = squeeze(Hue(i,ii,:)).*masku_east;
        Sue2(i,ii,:) = squeeze(Sue(i,ii,:)).*masku_east;
    end
end

% Velocity
% Northern boundary========================================================
xlimit = [140 162];
clim = [-0.1 0.1];
for i = 1:12
    figure
    pcolor(lon_v(1,:), 1:40, squeeze(Hvn2(i,:,:))); shading flat
    c = colorbar; caxis(clim); colormap('redblue'); c.FontSize = 15;
    c.Label.String = 'm/s'; c.Label.FontSize = 15;
    xlabel('Longitude'); ylabel('Layer'); xlim(xlimit)
    set(gca, 'FontSize', 15)
    title(['HYCOM northern bndy V 2001', num2char(i,2)], 'FontSize', 15)
    %saveas(gcf, ['HYCOM_bndy_vn_2001', num2char(i,2),'.png'])
    
    figure
    pcolor(lon_v(1,:), 1:40, squeeze(Svn2(i,:,:))); shading flat
    c = colorbar; caxis(clim); colormap('redblue'); c.FontSize = 15;
    c.Label.String = 'm/s'; c.Label.FontSize = 15;
    xlabel('Longitude'); ylabel('Layer'); xlim(xlimit)
    set(gca, 'FontSize', 15)
    title(['SODA northern bndy V 2001', num2char(i,2)], 'FontSize', 15)
    %saveas(gcf, ['SODA3_bndy_vn_2001', num2char(i,2),'.png'])
    
end

% Eastern boundary=========================================================
xlimit = [46 52];
clim = [-0.3 0.3];
for i = 1:12
    figure
    pcolor(lat_u(:,1), 1:40, squeeze(Hue2(i,:,:))); shading flat
    c = colorbar; caxis(clim); colormap('redblue');
    c.FontSize = 15; c.Label.String = 'm/s'; c.Label.FontSize = 15;
    xlabel('Latitude'); ylabel('Layer'); xlim(xlimit)
    set(gca, 'FontSize', 15)
    title(['HYCOM eastern bndy U 2001', num2char(i,2)], 'FontSize', 15)
    %saveas(gcf, ['HYCOM_bndy_ue_2001', num2char(i,2),'.png'])
    
    figure
    pcolor(lat_u(:,1), 1:40, squeeze(Sue2(i,:,:))); shading flat
    c = colorbar; caxis(clim); colormap('redblue'); c.FontSize = 15;
    c.Label.String = 'm/s'; c.Label.FontSize = 15;
    xlabel('Latitude'); ylabel('Layer'); xlim(xlimit)
    set(gca, 'FontSize', 15)
    title(['SODA eastern bndy U 2001', num2char(i,2)], 'FontSize', 15)
    %saveas(gcf, ['SODA3_bndy_ue_2001', num2char(i,2),'.png'])
    
end

% Transport
% Northern boundary========================================================
lat_north = max(max(lat_v));
lon_distance = 111*cos(lat_north*pi/180); % 위도 111km % 경도 111*cos(위도*pi/180) km

lon_diff_all = 1./g.pm;
lon_diff = lon_diff_all(end,:);
area_north = lon_diff.*dzr_north; % m^2

for ii = 1:12
    trans_HYCOM_north(ii,:,:) = squeeze(Hvn2(ii, :,:)).*area_north;
    trans_SODA3_north(ii,:,:) = squeeze(Svn2(ii, :,:)).*area_north;
end
trans_HYCOM_north_monthly = nansum(nansum(trans_HYCOM_north, 2), 3)./(10^6); % Sv
trans_SODA3_north_monthly = nansum(nansum(trans_SODA3_north, 2), 3)./(10^6); % Sv

figure; hold on; grid on
plot(trans_HYCOM_north_monthly, 'LineWidth', 2)
plot(trans_SODA3_north_monthly, 'LineWidth', 2)
legend('HYCOM', 'SODA3', 'Location', 'SouthEast')
ylabel('Sv')
xlabel('Month')
set(gca, 'FontSize', 15)
title('Northern bndy transport', 'FontSize', 15)
saveas(gcf, 'transport_north.png')

% Eastern boundary=========================================================
range = [46 52];

lat_diff_all = 1./g.pn;
lat_diff = lat_diff_all(:,end);
area_east = lat_diff'.*dzr_east; % m^2

for ii = 1:12
    trans_HYCOM_east(ii,:,:) = squeeze(Hue2(ii, :,:)).*area_east;
    trans_SODA3_east(ii,:,:) = squeeze(Sue2(ii, :,:)).*area_east;
end

trans_lat = lat_u(:,1);
index = find(range(1) <= trans_lat & trans_lat <= range(2));

trans_HYCOM_east_monthly = nansum(nansum(trans_HYCOM_east(:,:,index), 2), 3)./(10^6); % Sv
trans_SODA3_east_monthly = nansum(nansum(trans_SODA3_east(:,:,index), 2), 3)./(10^6); % Sv

figure; hold on; grid on
plot(trans_HYCOM_east_monthly, 'LineWidth', 2)
plot(trans_SODA3_east_monthly, 'LineWidth', 2)
legend('HYCOM', 'SODA3', 'Location', 'SouthEast')
ylabel('Sv')
xlabel('Month')
set(gca, 'FontSize', 15)
title(['Eastern bndy transport from ', num2str(range(1)),  ' to ',num2str(range(2))], 'FontSize', 15)
saveas(gcf, 'transport_east_part.png')
