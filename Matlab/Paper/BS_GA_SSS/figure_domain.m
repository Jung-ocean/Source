clear; clc; close all

g = grd('BSf');

figure; hold on; grid on;

% Entire domain
set(gcf, 'Position', [1 200 800 800])

subplot('Position',[.1,.65,.8,.3]); hold on;
plot_map('Bering', 'mercator', 'l')
text(-0.5, 1.57, 'a', 'FontSize', 20)
mlabel('FontSize', 12);
plabel('FontSize', 12);

pcolorm(g.lat_rho, g.lon_rho, g.h.*g.mask_rho./g.mask_rho);
colormap depth
c = colorbar;
c.Title.String = 'm';
c.FontSize = 12;
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k')

plot_map('Bering', 'mercator', 'l')
mlabel('FontSize', 12);
plabel('FontSize', 12);

[lon, lat] = load_domain('Gulf_of_Anadyr_large');
plotm([lat(1) lat(1) lat(2) lat(2) lat(1)], [lon(1) lon(2) lon(2) lon(1) lon(1)], '-r', 'LineWidth', 2)

% Study area
subplot('Position',[.24,.05,.50,.55]); hold on;
plot_map('Gulf_of_Anadyr_large', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'Color', [.5 .5 .5])
text(-0.2, 1.57, 'b', 'FontSize', 20)
mlabel('FontSize', 12);
plabel('FontSize', 12);

% set(gca, 'Position', [.44,.15,.4,.75]);

% Text on map
% % Anadyr River
% text('Clipping','on','FontWeight','bold','FontSize',14,...
%     'String',{'Anadyr','River'},...
%     'Position',[-0.12713139509913 1.52353256571762 0],...
%     'Color',[0 0 1]);
% % Gulf of Anadyr
% text('Clipping','on','FontWeight','bold','FontSize',18,...
%     'String',{'Gulf of','Anadyr'},...
%     'Position',[-0.0295100415253483 1.46194593997308 0]);
% % Anadyr Strait
% text('Clipping','on','FontWeight','bold','FontSize',14,...
%     'Rotation',30,...
%     'String','Anadyr Strait',...
%     'Position',[0.0445249447420165 1.44032510327554 0]);
% % Cape Navarin
% text('Clipping','on','FontWeight','bold','FontSize',14,...
%     'String',{'Cape','Navarin'},...
%     'Position',[-0.0550619394406335 1.38791095370572 0]);
% % Chukchi Peninsula
% text('Clipping','on','FontWeight','bold','FontSize',14,...
%     'String',{'Chukchi','Peninsula'},...
%     'Position',[0.0176626930874859 1.54056716432781 0]);

% Create text
text('Clipping','on','FontWeight','bold',...
    'String',{'Anadyr','River'},...
    'Position',[-0.159762414044122 1.51014548102224 0],...
    'Color',[0 0 1]);

% Create text
text('Clipping','on','FontWeight','bold','FontSize',14,...
    'String',{'Gulf of','Anadyr'},...
    'Position',[-0.0211431135907348 1.45274231924501 0]);

% Create text
text('Clipping','on','FontWeight','bold','Rotation',30,...
    'String',{'Anadyr','Strait'},...
    'Position',[0.0763192708935473 1.45956903752515 0]);

% Create text
text('Clipping','on','FontWeight','bold',...
    'String','Cape Navarin',...
    'Position',[-0.0943865007333165 1.3904210320861 0]);

% Create text
text('Clipping','on','FontWeight','bold',...
    'String',{'Chukchi','Peninsula'},...
    'Position',[0.0176626930874858 1.54056716432781 0]);

% Create text
text('Clipping','on','FontWeight','bold',...
    'String','Navarin Canyon',...
    'Position',[-0.0727001286063388 1.36067821373362 0]);

% Create text
text('Clipping','on','FontWeight','bold',...
    'String',{'Bering','Strait'},...
    'Position',[0.12643275623746 1.5363837003605 0]);

% Create text
text('Clipping','on','FontWeight','bold',...
    'String',{'St. Lawrence','Island'},...
    'Position',[0.0879448877382382 1.41004308854784 0]);

% Create text
text('Clipping','on','FontWeight','bold',...
    'String',{'St. Matthew','Island'},...
    'Position',[0.0586606399670914 1.30796656774556 0]);

% Area plot
[mask, area] = mask_and_area('Gulf_of_Anadyr', g);
mask_map = mask;
mask_map(isnan(mask_map) == 1) = 0;
[c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], 'LineWidth', 2, 'LineStyle', '-', 'Color', 'r');
set(h.Children(2), 'FaceColor', 'none')
% set(h.Children(2), 'FaceAlpha', 0.4)
set(h.Children(3), 'FaceColor', 'none')

% Common area plot
load /data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr_common/mask_common.mat
dx = 1./g.pm; dy = 1./g.pn;
mask = (mask_common./mask_common);
area = dx.*dy.*mask;
mask_map = mask;
mask_map(isnan(mask_map) == 1) = 0;
[c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], 'LineWidth', 2, 'LineStyle', '--', 'Color', 'r');
set(h.Children(2), 'FaceColor', 'none')
% set(h.Children(2), 'FaceAlpha', 0.4)
set(h.Children(3), 'FaceColor', 'none')

% Vertical section
% lon_line = [-180.0870 -176.9945];
% lat_line = [64.9931, 63.3551];
% plotm(lat_line, lon_line, '-g', 'LineWidth', 2)

dd
exportgraphics(gcf,'figure_domain.png','Resolution',150) 