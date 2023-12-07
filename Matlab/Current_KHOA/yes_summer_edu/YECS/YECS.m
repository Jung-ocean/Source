clear all; close all; 
%% load data
DATA_C = importdata('plot_data_cold_sum'); 
DATA_O = importdata('plot_data_others_sum');
DATA_W = importdata('plot_data_warm_sum'); 
%% define coordinates value 
lon_C = DATA_C(:,1); lat_C = DATA_C(:,2); 
lon_O = DATA_O(:,1); lat_O = DATA_O(:,2); 
lon_W = DATA_W(:,1); lat_W = DATA_W(:,2); 
%% make arrow 
% 1) 
a = [130.9,29.66]; b = [130.1,29.1]; c = [130.28,30.4]; 
x1 = [a(1) b(1) c(1)]; y1= [a(2) b(2) c(2)]; 
% 2) 
a = [130.9,34.78]; b = [130.35,34.70]; c = [130.7,34.25]; 
x2 = [a(1) b(1) c(1)]; y2= [a(2) b(2) c(2)]; 
% 3) 
a = [130.9,35.87]; b = [130.6,35.64]; c = [130.6,36.1]; 
x3 = [a(1) b(1) c(1)]; y3= [a(2) b(2) c(2)]; 
% 4) 
a = [130.9,38.15]; b = [130.6,38.00]; c = [130.7,38.45]; 
x4 = [a(1) b(1) c(1)]; y4= [a(2) b(2) c(2)]; 
%% plot current data 
figure;
m_proj('mercator','lon',[119 131.5],'lat',[24 40]); hold on; 
%m_plot(lon_C, lat_C,'.', 'color',[31/255 25/255 255/255],'markersize',1); 
%m_plot(lon_O, lat_O,'.', 'color',[218/255 155/255 31/255],'markersize',1); 
m_plot(lon_W, lat_W,'.', 'color',[234/255 25/255 0/255],'markersize',1); 
% 1) 
[x1,y1] = m_ll2xy(x1, y1); h1= fill(x1,y1,[234/255 25/255 0/255]); 
set(h1,'edgecolor',[234/255 25/255 0/255]); 
% 2) 
[x2,y2] = m_ll2xy(x2, y2); h2= fill(x2,y2,[234/255 25/255 0/255]); 
set(h2,'edgecolor',[234/255 25/255 0/255]); 
% 3) 
[x3,y3] = m_ll2xy(x3, y3); h3= fill(x3,y3,[234/255 25/255 0/255]); 
set(h3,'edgecolor',[234/255 25/255 0/255]); 
% 4) 
[x4,y4] = m_ll2xy(x4, y4); h4= fill(x4,y4,[234/255 25/255 0/255]); 
set(h4,'edgecolor',[234/255 25/255 0/255]); 
%% rgb:[222 184 135]
m_gshhs_i('color','k'); m_gshhs_i('patch',[.95 .95 .95]); 
set(gca,'fontsize',10); set(gcf,'color','w'); 
m_grid('XTick', 3, 'YTick', 3, ... 
    'LineWidth', 2, 'LineStyle', 'none', 'TickStyle', 'dd', 'TickDir', 'out', 'FontSize', 12, ...
    'FontWeight', 'bold','FontName', 'Times');
%% save figure 
saveas(gcf, 'a.png')