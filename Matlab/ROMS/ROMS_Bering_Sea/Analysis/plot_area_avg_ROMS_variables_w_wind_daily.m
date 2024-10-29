%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS area averaged variables with wind daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all

yyyy = 2020;
ystr = num2str(yyyy);
mm_all = 1:2;
startdate = datenum(2018,7,1);

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

filepath_con = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';
region =  'Gulf_of_Anadyr';
polygon = [;
    -181.1407   62.6194
    -173.5578   64.6246
    -180.0089   66.2790
    -184.7623   64.8251
    -181.1407   62.6194
    ];

[in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
mask_target = in./in;
area_target = area.*mask_target;

% Wind
filepath_wind = ['/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/'];

polygon_wind = [;
    -181.1407   62.6194
    -173.5578   64.6246
    -171.1441   63.6253
    -178.4787   61.5
    -181.1407   62.6194
    ];

angle = azimuth(61.9925, -179.7011, 64.2886, -172.2554);

figure; hold on; grid on;
plot_map('Bering', 'mercator', 'l')
plotm(polygon(:,2), polygon(:,1))
plotm(polygon_wind(:,2), polygon_wind(:,1), 'LineWidth', 2)

ind = 0;
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filename_wind = ['BSf_ERA5_', ystr, '_', mstr, '_ni2_a_frc.nc'];
    file_wind = [filepath_wind, filename_wind];

    for di = 1:eomday(yyyy,mm)
        ind = ind+1;
        dd = di; dstr = num2str(dd, '%02i');

        filenum = datenum(yyyy,mm,dd) - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['Dsm2_spng_avg_', fstr, '.nc'];
        file_con = [filepath_con, filename];
        vari = ncread(file_con, 'zeta')';

        vari_target(ind) = sum(vari(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

        % wind region
        skip = 1;
        npts = [0 0 0 0];

        % surface current
        u = ncread(file_con, 'u', [1,1,g.N,1], [Inf Inf,1,1])';
        v = ncread(file_con, 'v', [1,1,g.N,1], [Inf Inf,1,1])';

        [u,v,lonred,latred,maskred] = uv_vec2rho(u,v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

        current_nor = cosd(angle).*u - sind(angle).*v;
        current_tan = sind(angle).*u + cosd(angle).*v;
        current_nor_target(ind) = sum(current_nor(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');
        current_tan_target(ind) = sum(current_tan(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

        % depth averaged velocity
        ubar = ncread(file_con, 'ubar')';
        vbar = ncread(file_con, 'vbar')';

        [ubar,vbar,lonred,latred,maskred] = uv_vec2rho(ubar,vbar,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

        bar_nor = cosd(angle).*ubar - sind(angle).*vbar;
        bar_tan = sind(angle).*ubar + cosd(angle).*vbar;
        bar_nor_target(ind) = sum(bar_nor(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');
        bar_tan_target(ind) = sum(bar_tan(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

        % surface stress
        sustr = ncread(file_con, 'sustr')';
        svstr = ncread(file_con, 'svstr')';
        
        [sustr,svstr,lonred,latred,maskred] = uv_vec2rho(sustr,svstr,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

        str_nor = cosd(angle).*sustr - sind(angle).*svstr;
        str_tan = sind(angle).*sustr + cosd(angle).*svstr;
        str_target(ind) = sum(str_tan(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

        % ice concentration
        aice = ncread(file_con, 'aice')';
        aice_target(ind) = sum(aice(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

        % wind
        ot = ncread(file_wind, 'sfrc_time');
        lat = ncread(file_wind, 'lat')';
        lon = ncread(file_wind, 'lon')';

        [in, on] = inpolygon(lon, lat, polygon_wind(:,1), polygon_wind(:,2));
        mask_wind = in./in;

        timenum = (ot + datenum(1968,5,23));
        timevec = datevec(timenum);
        index = find(timevec(:,3) == dd);

        uwind = ncread(file_wind, 'Uwind', [1, 1, index(1)], [Inf Inf, length(index)]);
        uwind_daily = mean(uwind,3)';
        vwind = ncread(file_wind, 'Vwind', [1, 1, index(1)], [Inf Inf, length(index)]);
        vwind_daily = mean(vwind,3)';

        wind_nor = cosd(angle).*uwind_daily - sind(angle).*vwind_daily;
        wind_tan = sind(angle).*uwind_daily + cosd(angle).*vwind_daily;

        wind_tan_mask = wind_tan.*mask_wind;
        wind_target(ind) = mean(wind_tan_mask(:), 'omitnan');

        disp([datestr(datenum(yyyy,mm,dd), 'yyyymmdd')])
    end
end

timenum = datenum(yyyy,mm_all(1),1):datenum(yyyy,mm_all(end),eomday(yyyy,mm));

load(['trans_', ystr, '.mat'])

vari1 = wind_target;
% vari1 = trans(1,:)/1e6;
vari2 = trans(1,:)/1e6;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1200 500])
plot(timenum, vari1, 'LineWidth', 4, 'Color', 'k');
xticks([datenum(yyyy,1:12,1)])
xlim([datenum(yyyy,1,1)-1 datenum(yyyy,3,1)])
datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylimit = get(gca, 'Ylim');
ylim([-max(abs(ylimit)) max(abs(ylimit))])
% ylim([-.5 .5])
% ylabel('m');

tmp = -50:50;
p = pcolor(timenum, tmp, repmat(aice_target', [1, length(tmp)])');
shading interp
colormap bone
caxis([0 1])
c = colorbar;
uistack(p, 'bottom')

yyaxis right
plot(timenum, vari2, 'LineWidth', 4);
ylimit = get(gca, 'Ylim');
ylim([-max(abs(ylimit)) max(abs(ylimit))])
% ylim([-.5 .5])
% ylabel('N/m^2')

plot(timenum, zeros(size(timenum)), '-k')

dd

figure; hold on; grid on
plot(vari1, vari2, 'o')
index = find(aice_target > 0.8);
plot(vari1(index), vari2(index), 'ro')
