function h = plot_contourf(ax, lat, lon, vari, color, climit, contour_interval)

if isempty(ax)
    ax = gca;
end
   
% Convert lat/lon to figure (axis) coordinates
[x, y] = mfwdtran(lat, lon);
vari(vari < climit(1)) = climit(1);
vari(vari > climit(2)) = climit(2);

[cs, h] = contourf(ax, x, y, vari, contour_interval, 'LineColor', 'none');
uistack(h, 'bottom');
colormap(ax, color);
caxis(ax, climit);