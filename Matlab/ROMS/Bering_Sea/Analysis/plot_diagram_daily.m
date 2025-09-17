%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS location-time diagram
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
varis = {'aice', 'str_n', 'zeta', 'v_n', 'SSS'};
yyyy = 2022;
ystr = num2str(yyyy);
mm_all = 1:7;

timenum_all = datenum(yyyy,mm_all(1),1):datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end)));

Trans_label = 'Koryak_coast_S';
domaxis = [-189.1117 -186.7350 60.6252 59.0932];
ylimit = [-500 0];

% Trans_label = 'Koryak_coast';
% domaxis = [-185.1117 -182.7350 62.1252 60.5932];
% ylimit = [-500 0];

% Trans_label = 'Cape_Navarin';
% domaxis = [-181.1100 -178.7333 62.7941 61.2621];
% ylimit = [-200 0];

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

% Load grid information
g = grd('BSf');

f1 = figure; hold on
t = tiledlayout(1,4);
t.TileSpacing = 'compact';
t.Padding = 'compact';
set(gcf, 'Position', [1 200 1800 500])

for vi = 1:length(varis)
    vari_str = varis{vi};
    if ~exist([vari_str, '_', Trans_label, '_', ystr, '.mat'])
        data = [];
        for ti = 1:length(timenum_all)
            timenum = timenum_all(ti);
            [x, data_tmp] = load_BSf_line_2d(g, vari_str, timenum, domaxis);
            
            data(ti,:) = data_tmp;
            disp([vari_str, ' ', datestr(timenum, 'yyyymmdd')])
        end
        save([vari_str, '_', Trans_label, '_', ystr '.mat'], 'timenum_all', 'x', 'data');
    end
end
asdf
load(['aice_', Trans_label, '.mat'])
nexttile(1);

% Figure properties
colormap = 'gray';
climit = [0 1];
interval = 0.1;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = '';

ax1 = nexttile(1); hold on; grid on;
p2 = plot_contourf([], x, timenum_all, data, color, climit, contour_interval);
xlim([min(x(:,1)) max(x(:,1))])
ylim(ylimit)
xticks(unique(floor(x(:,1))));
xlabel('Longitude');
ylabel('Depth (m)');
set(gca, 'FontSize', 12)
c = colorbar;
c.Title.String = unit;

title(['Salinity'], 'FontSize', 15);

% Make gif
gifname = ['vert_', savename, '_', Trans_label, '_', ystr, '_daily', '.gif'];

frame = getframe(f1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
if ti == 1
    imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
else
    imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
end

delete(p1)
delete(p2)
