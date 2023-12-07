clear all; close all; clc; 
%% load data 
DATA_C = importdata('./plot_data_cold_small'); 
DATA_O = importdata('./plot_data_others_small'); 
DATA_W = importdata('./plot_data_warm_small'); 
%% define coordinates value 
lon_C = DATA_C(:,1); lat_C = DATA_C(:,2); 
lon_O = DATA_O(:,1); lat_O = DATA_O(:,2); 
lon_W = DATA_W(:,1); lat_W = DATA_W(:,2); 
%% plot current data 
figure 
m_proj('mercator','lon',[116 146],'lat',[26 46]); hold on; 
%m_plot(lon_C, lat_C,'.', 'color',[31/255 25/255 255/255],'markersize',1); 
%m_plot(lon_O, lat_O,'.', 'color',[204/255 204/255 204/255],'markersize',1); 
m_plot(lon_W, lat_W,'.', 'color',[234/255 25/255 0/255],'markersize',1); 
m_gshhs_i('color','k'); m_gshhs_i('patch',[.95 .95 .95]); 
%% rgb:[222 184 135] 
set(gca,'fontsize',10); set(gcf,'color','w'); 
m_grid('XTick', 0, 'YTick', 0, ... 
    'LineWidth', 2, 'LineStyle', 'none', 'TickStyle', 'dd', 'TickDir', 'out', 'FontSize', 12, ...
    'FontWeight', 'bold','FontName', 'Times');
%% save figure 
%print('-dpng', '-r500', 'figure/fig_matlab_small');