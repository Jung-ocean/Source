%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS zeta to Satellite L4 (CMEMS) data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
region = 'Eastern_Bering';
[lon_limit, lat_limit] = load_domain(region);

direction = 'p';
line = 15;
lstr = num2str(line, '%02i');

vari_str = 'zeta';
yyyy = 2019;
ystr = num2str(yyyy);
mm_seasonal = 8:10;
mm_start = mm_seasonal(1);
mm_end = mm_seasonal(end);
mstr = (datestr(datenum(yyyy,mm_seasonal,1), 'm'))';



switch vari_str
    case 'zeta'
        climit = [-0.2 0.2];
        unit = 'm';
end

% Model
filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/seasonal/'];
filename = ['Dsm4_2019_', mstr, '.nc'];
file = [filepath, filename];
zeta = ncread(file, 'zeta');

% ADT line data
filepath_line = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/zeta/vs_L2/v5.2/'];
filename_line = ['ADT_model_obs_', direction, 'line.mat'];
file_line = [filepath_line, filename_line];
ADT = load(file_line);
ADT = ADT.ADT;

lines_all = cell2mat(ADT.line);
lines_unique = unique(lines_all);
timenum_all = cell2mat(ADT.time);

lon_line = ADT.lon{line}+360;
lat_line = ADT.lat{line};
depth_line = -ADT.depth{line};

time_start = datenum(yyyy,mm_seasonal(1),1)-1;
time_end = datenum(yyyy,mm_seasonal(end),eomday(yyyy,mm_seasonal(end)))+1;

tindex = find(lines_all == line & ...
    timenum_all > time_start & ...
    timenum_all < time_end);

ADT_obs = zeros;
ADT_model = zeros;
for ti = 1:length(tindex)
    timenum_tmp = timenum_all(tindex(ti));
    ADT_obs_tmp = ADT.obs{tindex(ti)};
    ADT_model_tmp = ADT.model{tindex(ti)};
    
    ADT_obs = ADT_obs + ADT_obs_tmp;
    ADT_model = ADT_model + ADT_model_tmp;

    % Save data as csv
    data = [(lon_line.*0)+str2num(datestr(timenum_tmp,'yyyymmdd')) lon_line lat_line depth_line ADT_obs_tmp' ADT_model_tmp'];
    data_table = array2table(data);
    data_table.Properties.VariableNames(1:6) = {'Time (Round down)', 'Longitude (^oE)', 'Latitude (^oN)', 'Model depth (m)' 'Observation ADT (m)', 'Model ADT (m)'};
    writetable(data_table, ['pline_', lstr, '_', datestr(timenum_tmp, 'yyyymmdd'), '.csv'])
end
ADT_obs_season = ADT_obs/length(tindex);
ADT_model_season = ADT_model/length(tindex);

% Demean
ADT_obs_season = ADT_obs_season - mean(ADT_obs_season, 'omitnan');
ADT_model_season = ADT_model_season - mean(ADT_model_season, 'omitnan');

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;

figure; 
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,2);
title(t, [datestr(datenum(yyyy,mm_start,1), 'mmm'), ' - ', datestr(datenum(yyyy,mm_end,1), 'mmm, yyyy')], 'FontSize', 20);

nexttile(1); hold on;
plot_map(region, 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k')
p = pcolorm(g.lat_rho, g.lon_rho, zeta);
uistack(p, 'bottom')
caxis(climit)
colormap(turbo(16))
c = colorbar;
c.Title.String = unit;
c.FontSize = 12;
plotm(lat_line, lon_line, '--k', 'LineWidth', 2);
title('Model (ROMS) zeta', 'FontSize', 15)

nexttile(2); hold on; grid on;
pm = plot(abs(lon_line-360), ADT_model_season, '-k', 'LineWidth', 2);
po = plot(abs(lon_line-360), ADT_obs_season, '-r', 'LineWidth', 2);
xlim([abs(lon_limit(2)) abs(lon_limit(1))])
set(gca, 'XDir','reverse')
xlabel('Longitude (^oW)')
ylabel('m')
set(gca, 'FontSize', 12)
l = legend([po, pm], 'Satellite L2', 'Model (ROMS)');
l.Location = 'NorthWest';
l.FontSize = 15;
title('Demeaned absolute dynamic topography', 'FontSize', 15);

print(['plot_zeta_and_cmp_to_L2_seasonal_', direction, 'line_', lstr, '_', ystr, '_', mstr], '-dpng')