function h = plot_contourf(ax, x, y, vari, color, climit, contour_interval)

if isempty(ax)
    ax = gca;
end

vari(vari < climit(1)) = climit(1);
vari(vari > climit(2)) = climit(2);

if ismap == 1
    % Convert lat/lon to figure (axis) coordinates
    [xx, yy] = mfwdtran(x, y);
    [cs, h] = contourf(ax, xx, yy, vari, contour_interval, 'LineColor', 'none');
else
    [cs, h] = contourf(ax, x, y, vari, contour_interval, 'LineColor', 'none');
end

uistack(h, 'bottom');
colormap(ax, color);
caxis(ax, climit);