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

start_date = datenum(2018,7,1);
yyyy = 2018;
mm_all = 8;

depth_ind = [45, 45, 45, 45, 30, 45, 45, 45];

% Read SCHISM grid
Mobj.dt = 120;
Mobj.coord = 'geographic';
hgrid_file = '../hgrid.gr3';
Mobj = read_schism_hgrid(Mobj, hgrid_file);

switch variable
    case 'temperature'
        vari_str_SCHISM = variable;
        climit = [5 20];
        unit = '^oC';
    case 'salinity'
        vari_str_SCHISM = variable;
        climit = [31.5 33.5];
        unit = 'g/kg';
end

figure; hold on;
set(gcf, 'Position', [1 1 1900 900])
t = tiledlayout(3,3);

ystr = num2str(yyyy);
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');
    
    title(t, ['Monthly SST (', ystr, mstr, ')'], 'FontSize', 25)

    % OSTIA
    OSTIA_filepath = '/data/jungjih/Observations/Satellite_SST/OSTIA/monthly/';
    OSTIA_filename = ['OSTIA_', ystr, mstr, '.nc'];
    OSTIA_file = [OSTIA_filepath, OSTIA_filename];
    lon_OSTIA = double(ncread(OSTIA_file, 'lon'));
    lat_OSTIA = double(ncread(OSTIA_file, 'lat'));
    vari_OSTIA = ncread(OSTIA_file, 'analysed_sst')' - 273.15; % K to dec C
    
    index1 = find(lon_OSTIA < 0);
    index2 = find(lon_OSTIA > 0);

    lon_OSTIA = [lon_OSTIA(index2); lon_OSTIA(index1)+360];
    vari_OSTIA = [vari_OSTIA(:,index2) vari_OSTIA(:,index1)];

    lonind = find(lon_OSTIA > min(Mobj.lon) -1 & lon_OSTIA < max(Mobj.lon) +1);
    latind = find(lat_OSTIA > min(Mobj.lat) -1 & lat_OSTIA < max(Mobj.lat) +1);

    lon_OSTIA_sub = lon_OSTIA(lonind);
    lat_OSTIA_sub = lat_OSTIA(latind);
    [lon_OSTIA2, lat_OSTIA2] = meshgrid(lon_OSTIA_sub, lat_OSTIA_sub);
    vari_OSTIA_sub = vari_OSTIA(latind, lonind);
    mask = ~isnan(vari_OSTIA_sub);
    mask = mask./mask;

    nexttile(1);
    pcolor(lon_OSTIA2, lat_OSTIA2, vari_OSTIA_sub); shading interp
    colormap jet
    xlim([min(Mobj.lon) max(Mobj.lon)])
    ylim([min(Mobj.lat) max(Mobj.lat)])
    caxis(climit)
    c = colorbar;
    c.Title.String = unit;
    title('OSTIA')

    for si = 1:length(SCHISM_expnames)
        expname = SCHISM_expnames{si};

        % SCHISM
        if strcmp(expname, 'noshapiro_dt60_kkl_sigma30')
            SCHISM_filepath = ['/data/jungjih/Models/SCHISM/test_schism/v1_SMS_sigma/gen_input/v1_SMS_sigma/outputs_noshapiro_dt60_kkl/'];
        else
            SCHISM_filepath = ['../outputs_', expname, '/'];
        end

        SCHISM_filename = [vari_str_SCHISM, '_', ystr, mstr, '.nc'];

        SCHISM_file = [SCHISM_filepath, SCHISM_filename];
        vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM));
        vari_SCHISM_surf = vari_SCHISM(depth_ind(si),:)';

        vari_SCHISM_interp = griddata(Mobj.lon, Mobj.lat, double(vari_SCHISM_surf), lon_OSTIA2, lat_OSTIA2);
        vari_SCHISM_interp = vari_SCHISM_interp.*mask;

        nexttile(si+1)
        pcolor(lon_OSTIA2, lat_OSTIA2, vari_SCHISM_interp); shading interp
        colormap jet
        xlim([min(Mobj.lon) max(Mobj.lon)])
        ylim([min(Mobj.lat) max(Mobj.lat)])
        caxis(climit)
        c = colorbar;
        c.Title.String = unit;
        title(SCHISM_expnames{si}, 'interpreter', 'none');

        disp([num2str(si), ' / ', num2str(length(SCHISM_expnames))])
    end
end
t.TileSpacing = 'compact';
t.Padding = 'compact';

print('monthly_SST_w_OSTIA', '-dpng')