clear; clc; close all

variable = 'temperature';
SCHISM_expnames = {...
    'control', ...
    'noshapiro', ...
    'noshapiro_dt60', ...
    'noshapiro_dt60_kkl', ...
    'noshapiro_dt60_kkl_sigma30', ...
    'noshapiro_dt30_kkl', ...
    'dt60_kkl', ...
    'dt30_kkl', ...
    };

colors = {'r', 'g', 'b', [0.8510 0.3255 0.0980], [0.4941 0.1843 0.5569], [0.9294 0.6941 0.1255], [0.3020 0.7451 0.9333], [0.4667 0.6745 0.1882]};

start_date = datenum(2018,7,1);
day_all = [1 7 14 21 28 35 42 49 56 63];

depth_ind = [45, 45, 45, 45, 30, 45, 45, 45];
depth_ind_ROMS = 45;
depth_ind_HYCOM = 1;

area_lon = [-181.6958, -164.0734, -156.2762, -156.1014, -203.6888, -203.5839, -197.7797, -189.4930, -181.6958];
area_lat = [62.8803, 54.6888, 57.4548, 48.7048, 48.7846, 52.3750, 56.6569, 60.9122, 62.8803];

% Read ROMS grid
g = grd('BSf');

% Read SCHISM grid
Mobj.dt = 120;
Mobj.coord = 'geographic';
hgrid_file = '../hgrid.gr3';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj.lon = Mobj.lon - 360;

switch variable
    case 'temperature'
        vari_str_HYCOM = 'Temp';
        vari_str_ROMS = 'temp';
        vari_str_SCHISM = variable;
        climit = [5 20];
        unit = '^oC';
    case 'salinity'
        vari_str_HYCOM = 'Salt';
        vari_str_ROMS = 'salt';
        vari_str_SCHISM = variable;
        climit = [31.5 33.5];
        unit = 'g/kg';
end

HYCOM_SST = NaN(length(day_all),1);
ROMS_SST = NaN(length(day_all),1);
SCHISM_SST = NaN(length(day_all), length(SCHISM_expnames));

for di = 1:length(day_all)
    day = day_all(di);
    timenum = start_date + (day-1);

    % HYCOM
    HYCOM_filepath = '/data/sdurski/HYCOM_extract/Bering_Sea/2018/Time_Filtered/';
    HYCOM_filename = ['HYCOM_glbvBeringSea_', datestr(timenum, 'yyyymmdd'), '.nc'];
    HYCOM_file = [HYCOM_filepath, HYCOM_filename];
    lon_HYCOM = ncread('/data/sdurski/HYCOM_extract/Bering_Sea/2018/HYCOM_glbvBeringSea_20180701.nc', 'Longitude')';
    lat_HYCOM = ncread('/data/sdurski/HYCOM_extract/Bering_Sea/2018/HYCOM_glbvBeringSea_20180701.nc', 'Latitude')';
    vari_HYCOM = ncread(HYCOM_file, vari_str_HYCOM);
    vari_HYCOM = squeeze(vari_HYCOM(:,:,depth_ind_HYCOM))';

    in = inpolygon(lon_HYCOM, lat_HYCOM, area_lon, area_lat);
    mask_HYCOM = in./in;
    vari_HYCOM = vari_HYCOM.*mask_HYCOM;

    lat_HYCOM_1d = lat_HYCOM(:,1);
    wgs84 = wgs84Ellipsoid("m");
    d = distance(lat_HYCOM_1d,zeros(size(lat_HYCOM_1d)),lat_HYCOM_1d,zeros(size(lat_HYCOM_1d))+0.08,wgs84);
    area_HYCOM_1d = d.*0.04*111*1000;
    area_HYCOM = repmat(area_HYCOM_1d, [1, size(lon_HYCOM,2)]).*mask_HYCOM;
    
    HYCOM_SST(di) = sum(vari_HYCOM(:).*area_HYCOM(:), 'omitnan')./sum(area_HYCOM(:), 'omitnan');
%     HYCOM_SST(di) = mean(vari_HYCOM(:), 'omitnan');

    % ROMS
    ROMS_filepath = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';
    ROMS_filename = ['Dsm2_spng_avg_', num2str(day, '%04i'), '.nc'];
    ROMS_file = [ROMS_filepath, ROMS_filename];
    vari_ROMS = ncread(ROMS_file, vari_str_ROMS);
    vari_ROMS = squeeze(vari_ROMS(:,:,depth_ind_ROMS))';

    in = inpolygon(g.lon_rho, g.lat_rho, area_lon, area_lat);
    mask_ROMS = in./in;
    area_ROMS = (1./g.pm).*(1./g.pn).*mask_ROMS;
    vari_ROMS = vari_ROMS.*mask_ROMS;

    ROMS_SST(di) = sum(vari_ROMS(:).*area_ROMS(:), 'omitnan')./sum(area_ROMS(:), 'omitnan');
%     ROMS_SST(di) = mean(vari_ROMS(:), 'omitnan');

    for si = 1:length(SCHISM_expnames)
        expname = SCHISM_expnames{si};

        % SCHISM
        if strcmp(expname, 'noshapiro_dt60_kkl_sigma30')
            SCHISM_filepath = ['/data/jungjih/Models/SCHISM/test_schism/v1_SMS_sigma/gen_input/v1_SMS_sigma/outputs_noshapiro_dt60_kkl/'];
        else
            SCHISM_filepath = ['../outputs_', expname, '/'];
        end
        if strcmp(expname, 'dt30_kkl') && day == 63
            day = 60;
        end

        SCHISM_filename = [vari_str_SCHISM, '_', num2str(day), '.nc'];

        SCHISM_file = [SCHISM_filepath, SCHISM_filename];
        vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM, [depth_ind(si), 1, 1], [1, Inf, Inf]));
        vari_SCHISM = mean(vari_SCHISM,2);

        vari_SCHISM_interp = griddata(Mobj.lon, Mobj.lat, double(vari_SCHISM), g.lon_rho, g.lat_rho).*g.mask_rho./g.mask_rho;
        vari_SCHISM_interp = vari_SCHISM_interp.*mask_ROMS;

        SCHISM_SST(di,si) = sum(vari_SCHISM_interp(:).*area_ROMS(:), 'omitnan')./sum(area_ROMS(:), 'omitnan');
%         SCHISM_SST(di,si) = mean(vari_SCHISM, 'omitnan');
    end
    disp([num2str(di), ' / ', num2str(length(day_all))])
end

figure; hold on; grid on;
set(gcf, 'Position', [1 1 1200 600])

p(1) = plot(day_all, HYCOM_SST, '-ok', 'LineWidth', 2);
p(2) = plot(day_all, ROMS_SST, '-om', 'LineWidth', 2);
for si = 1:length(SCHISM_expnames)
    if strcmp(SCHISM_expnames{si}, 'dt30_kkl')
        day_all2 = day_all;
        day_all2(end) = 60;
        p(si+2) = plot(day_all2, SCHISM_SST(:,si), '-o', 'Color', colors{si});
    else
        p(si+2) = plot(day_all, SCHISM_SST(:,si), '-o', 'Color', colors{si});
    end
end
ylim([5 13])

xlabel('Day')
ylabel('SST (^oC)')
set(gca, 'FontSize', 12)

l = legend(p, [{'HYCOM'}, {'ROMS'}, SCHISM_expnames], 'interpreter', 'none');
l.FontSize = 12;
l.Location = 'NorthWest';

title('Area-averaged daily mean SST (from July 1st)')

print('area_averaged_SST', '-dpng')