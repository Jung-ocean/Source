%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare two ROMS outputs through area-averaged
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
filenum_all = 1:152;
depth_target = 200; % m
layer = 45;

switch vari_str
    case 'salt'
        ylimit = [31 34.5];
        unit = 'g/kg';
    case 'temp'
        climit = [0 20];
        unit = '^oC';
end

filepath_all = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/';
case_control = 'Dsm_1';
filepath_control = [filepath_all, case_control, '/'];

case_exp = 'Dsm_1rnoff';
filepath_exp = [filepath_all, case_exp, '/'];

% Load grid information
grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);
lon = g.lon_rho;
lat = g.lat_rho;
mask = g.mask_rho./g.mask_rho;
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;
area = dx.*dy.*mask;

index_shelf = find(h < depth_target);
index_basin = find(h > depth_target);

timenum_all = zeros(length(filenum_all),1);
vari_control_shelf = zeros(length(filenum_all),1);
vari_control_basin = zeros(length(filenum_all),1);
vari_exp_shelf = zeros(length(filenum_all),1);
vari_exp_basin = zeros(length(filenum_all),1);
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    
    filepattern_control = fullfile(filepath_control,(['*avg*',fstr,'*.nc']));
    filename_control = dir(filepattern_control);
    file_control = [filepath_control, filename_control.name];

    vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    vari_control_shelf(fi) = sum(vari_control(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
    vari_control_basin(fi) = sum(vari_control(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');

    time = ncread(file_control, 'ocean_time');
    time_units = ncreadatt(file_control, 'ocean_time', 'units');
    time_ref = datenum(time_units(end-18:end), 'yyyy-mm-dd HH:MM:SS');
    timenum = time_ref + time/60/60/24;
    timenum_all(fi) = timenum;

    filepattern_exp = fullfile(filepath_exp,(['*avg*',fstr,'*.nc']));
    filename_exp = dir(filepattern_exp);
    file_exp = [filepath_exp, filename_exp.name];

    vari_exp = ncread(file_exp,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    vari_exp_shelf(fi) = sum(vari_exp(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
    vari_exp_basin(fi) = sum(vari_exp(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');
    
    disp([fstr, ' / ', num2str(filenum_all(end), '%04i'), '...'])
end % fi
timevec = datevec(timenum_all);
xtic_list = datenum(unique(timevec(:,1)), unique(timevec(:,2)), 1);

% Plot
h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 1 1500 400])
t = tiledlayout(1,2);

%ttitle = annotation('textbox', [.44 .85 .1 .1], 'String', ['Area-averaged ', vari_str]);
%ttitle.FontSize = 25;
%ttitle.EdgeColor = 'None';

% Tile 1
nexttile(1); hold on; grid on
T1p1 = plot(timenum_all, vari_control_shelf, '-r', 'LineWidth', 2);
T1p2 = plot(timenum_all, vari_exp_shelf, '--b', 'LineWidth', 2);
xticks(xtic_list);
datetick('x', 'mmm dd, yyyy', 'keepticks')
xlim([timenum_all(1)-1 timenum_all(end)])
ylim(ylimit);
ylabel(unit)
title(['Shelf area averaged (< ', num2str(depth_target), ' m)'])
l = legend([T1p1, T1p2], case_control, case_exp, 'Interpreter', 'none');
l.Location = 'NorthWest';
l.FontSize = 15;

% Tile 2
nexttile(2); hold on; grid on
T2p1 = plot(timenum_all, vari_control_basin, '-r', 'LineWidth', 2);
T2p2 = plot(timenum_all, vari_exp_basin, '--b', 'LineWidth', 2);
xticks(xtic_list);
datetick('x', 'mmm dd, yyyy', 'keepticks')
xlim([timenum_all(1)-1 timenum_all(end)])
ylim(ylimit);
ylabel(unit)
title(['Basin area averaged (> ', num2str(depth_target), ' m)'])
l = legend([T2p1, T2p2], case_control, case_exp, 'Interpreter', 'none');
l.Location = 'SouthWest';
l.FontSize = 15;

pause(1)
print(strcat('compare_area_averaged_', vari_str),'-dpng');