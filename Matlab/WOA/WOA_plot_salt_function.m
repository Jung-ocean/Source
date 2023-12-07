function WOA_plot_salt_function(filename, month, variname, layer_ind, domain_case, contour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SODA3_plot_temp_function(filename, month, variname, layer_ind, domain_case, contour)
%
%   filename: model output filename (usually netcdf format)
%   variname: temperature variable name in model output file (ex, 'temp', 'temperautre' ... )
%   layer_ind: depth you want to plot
%   domain_case: domain case (figure)
%   contour: 'contour on' or 'contour off'
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clim = [30 35];
contour_interval = [clim(1):.5:clim(2)];
colorbarname = 'g/kg';
colormapname = 'jet';
FS = 15;

nc = netcdf(filename);

lon = nc{'lon'}(:);
lat = nc{'lat'}(:);
dep = nc{'depth'}(:);
if layer_ind < 0
    layer_ind = -layer_ind;
end
dist_dep = (dep - layer_ind).^2;
index = find(dist_dep == min(dist_dep));
dstr = num2str(dep(index));

vari = nc{variname}(1,index,:,:);
vari_mv = nc{variname}.FillValue_(:);

close(nc)

vari(vari == vari_mv) = NaN;

map_J(domain_case)

warning off
m_pcolor(lon, lat, vari); colormap(colormapname); shading flat;

if strcmp(contour, 'contour on')
    [cs, h] = m_contour(lon, lat, vari, contour_interval, 'k');
    h.LineWidth = 2;
    clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
end

c = colorbar; c.FontSize = FS;
c.Title.String = colorbarname; c.Title.FontSize = FS;
%c.Label.String = colorbarname; c.Label.FontSize = FS;
caxis(clim);

title([dstr, 'm'])

end