clear; clc; close all

variable = 'temperature';
expname = 'control';
issurf = 1;
depth_ind = 45;
depth_ind_HYCOM = 1;
start_date = datenum(2018,7,1);
day_all = [1 7 14 21 28 35 42 49 56 63];
%day_all = [1 7 14 21];

% Read ROMS grid
g = grd('BSf');

% Read SCHISM grid
% Mobj.time = (datetime(2018,7,1):hours(1):datetime(2018,6,3))';
% Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 60;
Mobj.coord = 'geographic';
hgrid_file = '../hgrid.gr3';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj.lon = Mobj.lon - 360;
% vgrid_file = '/data/jungjih/Models/SCHISM/test_schism/vgrid.in';
% Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

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
xlimit = [-206 -156];
ylimit = [49 66.5];

figure; hold on;
set(gcf, 'Position', [1 1 1800 500])
tiledlayout(1,3)
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

    % ROMS
    ROMS_filepath = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';
    ROMS_filename = ['Dsm2_spng_avg_', num2str(day, '%04i'), '.nc'];
    ROMS_file = [ROMS_filepath, ROMS_filename];
    vari_ROMS = ncread(ROMS_file, vari_str_ROMS);
    vari_ROMS = squeeze(vari_ROMS(:,:,depth_ind))';

    % SCHISM
    SCHISM_filepath = ['../outputs_', expname, '/'];
    if issurf == 1
        SCHISM_filename = [vari_str_SCHISM, '_surf_', num2str(day), '.nc'];
        SCHISM_file = [SCHISM_filepath, SCHISM_filename];
        vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM));
    else
        SCHISM_filename = [vari_str_SCHISM, '_', num2str(day), '.nc'];
        SCHISM_file = [SCHISM_filepath, SCHISM_filename];
        vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM, [depth_ind, 1, 1], [1, Inf, Inf]));
    end
    vari_SCHISM = mean(vari_SCHISM,2);

    % Plot
    ax1 = nexttile(1); cla(ax1)
    p1 = pcolor(lon_HYCOM, lat_HYCOM, vari_HYCOM); shading interp
    colormap jet

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['HYCOM surface ', variable, ' ', datestr(timenum, 'mmm dd, yyyy')])

    ax2 = nexttile(2); cla(ax2);
    p2 = pcolor(g.lon_rho, g.lat_rho, vari_ROMS.*g.mask_rho./g.mask_rho); shading interp
    colormap jet

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['ROMS surface ', variable, ' ', datestr(timenum, 'mmm dd, yyyy')])

    ax3 = nexttile(3);
    if di == 1
        p3 = disp_schism_var(Mobj, vari_SCHISM, 'EdgeColor', 'none');
        colormap jet
        cb = colorbar;
        cb.Layout.Tile = 'east';
        cb.Title.String = unit;
    else
        p3.FaceVertexCData = vari_SCHISM;
    end
    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['SCHISM surface ', variable, ' ', datestr(timenum, 'mmm dd, yyyy')])

    set(gcf, 'Position', [1 1 1800 500])
    pause(3)
    set(gcf, 'Position', [1 1 1800 500])
    pause(3)

    print(['cmp_SCHISM_surf_',variable, '_w_HYCOM_ROMS_', datestr(timenum, 'yyyymmdd')] ,'-dpng')
end