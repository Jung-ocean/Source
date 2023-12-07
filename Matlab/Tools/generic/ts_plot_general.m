function [c,h,x,y,dens_grid] = ts_plot_general(w,c,xlim,ylim)
% simple T?S plotting program by Jeff Book (U.S. Naval Research Laboratory)
% 2005.1.18, Edit by peter
% input is w which has the data
% 1st column of w is not important can be pressure
% 2nd column of w is all temperatures (degrees C)
% 3rd column of w is all the corresponding salinities (psu)
% input c is the color string 'r' for red; 'b' for blue; 'g' for green
% 'k' for black; 'y' for yellow; 'c' for cyan; 'm' for magenta
% output is c and h for labeling the density curves [example clabel(c,h,'manual')]
% output x is the grid of salinity values in the plot window
% output y is the grid of temperature values in the plot window
% dens_grid is the density of the waters having the gridded salinity and temperature
% density units are kg/m^3
% 

plot(w(:,3),w(:,2),[c '.'],'markersize',8)   % temp& salinity dot
hold on
% find the corners
%ylim = ([0 30]); %get(gca,'ylim')
%xlim = ([30 35]); %get(gca,'xlim')

% make the corner values into a grid with spacing of 0.01 psu and 0.1 degrees C
% if the contours are not smooth decrease the grid spacing
[x,y] = meshgrid([xlim(1):.01:xlim(2)],[ylim(1):.1:ylim(2)]);
% calculate the density of the grid 
% (calls the program sw_dens0.m,SW_SMOW.m ; must be in the path)
dens_grid = sw_dens0(x,y);
% plot density contours
[c,h] = contour(x,y,dens_grid-1000,[0:1:30],':b');   % black dotted line 
% label the graph
xlabel('Salinity')
ylabel('Temperature (^{\circ}C)')