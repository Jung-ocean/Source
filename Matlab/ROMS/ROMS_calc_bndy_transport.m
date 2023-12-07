clear; clc; close all

trans_HYCOM_north_monthly_all = [];
trans_HYCOM_east_monthly_all = [];
for yi = 2001:2016
    yyyy = yi; tys = num2str(yyyy);
    
    filepath = 'G:\Model\ROMS\Case\NWP\input\';
    filename = ['roms_bndy_NWP_HYCOM_', tys, '.nc'];
    file = [filepath, filename];
    
    Hnc = netcdf(file);
    Hvn = Hnc{'v_north'}(:); Hue = Hnc{'u_east'}(:);
    close(Hnc);
    
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
            Hue2(i,ii,:) = squeeze(Hue(i,ii,:)).*masku_east;
        end
    end
    
    % % Velocity
    % % Northern boundary========================================================
    % xlimit = [140 162];
    % clim = [-0.1 0.1];
    % for i = 1:12
    %     figure
    %     pcolor(lon_v(1,:), 1:40, squeeze(Hvn2(i,:,:))); shading flat
    %     c = colorbar; caxis(clim); colormap('redblue'); c.FontSize = 15;
    %     c.Label.String = 'm/s'; c.Label.FontSize = 15;
    %     xlabel('Longitude'); ylabel('Layer'); xlim(xlimit)
    %     set(gca, 'FontSize', 15)
    %     title(['HYCOM northern bndy V 2001', num2char(i,2)], 'FontSize', 15)
    %     %saveas(gcf, ['HYCOM_bndy_vn_2001', num2char(i,2),'.png'])
    %
    % end
    %
    % % Eastern boundary=========================================================
    % xlimit = [46 52];
    % clim = [-0.3 0.3];
    % for i = 1:12
    %     figure
    %     pcolor(lat_u(:,1), 1:40, squeeze(Hue2(i,:,:))); shading flat
    %     c = colorbar; caxis(clim); colormap('redblue');
    %     c.FontSize = 15; c.Label.String = 'm/s'; c.Label.FontSize = 15;
    %     xlabel('Latitude'); ylabel('Layer'); xlim(xlimit)
    %     set(gca, 'FontSize', 15)
    %     title(['HYCOM eastern bndy U 2001', num2char(i,2)], 'FontSize', 15)
    %     %saveas(gcf, ['HYCOM_bndy_ue_2001', num2char(i,2),'.png'])
    %
    % end
    
    % Transport
    % Northern boundary========================================================
    lat_north = max(max(lat_v));
    lon_distance = 111*cos(lat_north*pi/180); % 위도 111km % 경도 111*cos(위도*pi/180) km
    
    lon_diff_all = diff(lon_v(1,:));
    lon_diff = mean(lon_diff_all);
    area_north = lon_diff.*lon_distance.*dzr_north*1000; % m^2
    
    for ii = 1:12
        trans_HYCOM_north(ii,:,:) = squeeze(Hvn2(ii, :,:)).*area_north;
    end
    trans_HYCOM_north_monthly = nansum(nansum(trans_HYCOM_north, 2), 3)./(10^6); % Sv
    trans_HYCOM_north_monthly_all = [trans_HYCOM_north_monthly_all; trans_HYCOM_north_monthly];
    
%     figure; hold on; grid on
%     plot(trans_HYCOM_north_monthly, 'LineWidth', 2)
%     legend('HYCOM', 'Location', 'SouthEast')
%     ylabel('Sv')
%     xlabel('Month')
%     set(gca, 'FontSize', 15)
%     title('Northern bndy transport', 'FontSize', 15)
    %saveas(gcf, 'transport_north.png')
    
    % Eastern boundary=========================================================
    range = [46 52];
    
    lat_diff_all = diff(lat_u(:,1));
    lat_diff = mean(lat_diff_all);
    area_east = lat_diff.*111.*dzr_east*1000; % m^2
    
    for ii = 1:12
        trans_HYCOM_east(ii,:,:) = squeeze(Hue2(ii, :,:)).*area_east;
    end
    
    trans_lat = lat_u(:,1);
    index = find(range(1) <= trans_lat & trans_lat <= range(2));
    
    trans_HYCOM_east_monthly = nansum(nansum(trans_HYCOM_east(:,:,index), 2), 3)./(10^6); % Sv
    trans_HYCOM_east_monthly_all = [trans_HYCOM_east_monthly_all; trans_HYCOM_east_monthly];
    
%     figure; hold on; grid on
%     plot(trans_HYCOM_east_monthly, 'LineWidth', 2)
%     legend('HYCOM', 'Location', 'SouthEast')
%     ylabel('Sv')
%     xlabel('Month')
%     set(gca, 'FontSize', 15)
%     title(['Eastern bndy transport from ', num2str(range(1)),  ' to ',num2str(range(2))], 'FontSize', 15)
    %saveas(gcf, 'transport_east_part.png')
    
end

xdate = [];
for yi = 2001:2016
    for mi = 1:12
        xdate = [xdate; yi mi];
    end
end
xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

color1 = [0 0.4470 0.7410];
color2 = [0.8500 0.3250 0.0980];

figure; hold on; grid on
plot(xdatenum, trans_HYCOM_east_monthly_all, 'LineWidth', 2, 'Color', color1)
plot(xdatenum, trans_HYCOM_north_monthly_all, 'LineWidth', 2, 'Color', color2)
%plot(xdatenum, movmean(trans_HYCOM_east_monthly_all, 13), 'LineWidth', 2, 'Color', color1)
%plot(xdatenum, movmean(trans_HYCOM_north_monthly_all, 13), 'LineWidth', 2, 'Color', color2)
datetick('x', 'yyyy')

%ylim([-0.4 0.35])
xlim([datenum(2000, 12, 31), datenum(2017, 1, 1)])
xlabel('Year', 'fontsize', 25)
ylabel('Transport (Sv)', 'fontsize', 25)
set(gca, 'FontSize', 25)
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
set(gca, 'XtickLabel', [2001:2016])

h = legend('Eastern boundary (46-52 \circN)', 'Northern boundary', 'Location', 'SouthEast');
h.FontSize = 25;
title('monthly boundary transport', 'FontSize', 25)

for yi = 1:16
    trans_HYCOM_east_yearly(yi) = mean(trans_HYCOM_east_monthly_all(12*yi-11 : 12*yi));
    trans_HYCOM_north_yearly(yi) = mean(trans_HYCOM_north_monthly_all(12*yi-11 : 12*yi));
end
figure; hold on; grid on
plot(2001:2016, trans_HYCOM_east_yearly, 'LineWidth', 2, 'Color', color1)
plot(2001:2016, trans_HYCOM_north_yearly, 'LineWidth', 2, 'Color', color2)
plot(2001:2016, [2001:2016]*0, 'k', 'Linewidth', 2)
xlabel('Year', 'fontsize', 25)
ylabel('Transport (Sv)', 'fontsize', 25)
set(gca, 'FontSize', 25)

h = legend('Eastern boundary (46-52 \circN)', 'Northern boundary', 'Location', 'NorthEast');
h.FontSize = 25;
title('Yearly boundary transport', 'FontSize', 25)