function h = plot_contourf(lat, lon, vari, contour_interval, climit, color)

% Convert lat/lon to figure (axis) coordinates
[x, y] = mfwdtran(lat, lon);
vari(vari < climit(1)) = climit(1);
vari(vari > climit(2)) = climit(2);
[cs, h] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
caxis(climit)
colormap(color)
uistack(h, 'bottom')

end
