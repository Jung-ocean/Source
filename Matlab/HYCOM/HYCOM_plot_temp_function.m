function HYCOM_plot_temp_function(filename, variname, layer_ind, domain_case, contour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HYCOM_plot_temp_function(filename, variname, depth_ind, casename, domain_case, contour)
%
%   filename: model output filename (usually netcdf format)
%   variname: temperature variable name in model output file (ex, 'temp', 'temperautre' ... )
%   layer_ind: layer number you want to plot
%   domain_case: domain case (figure)
%   contour: 'contour on' or 'contour off'
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clim = [10 30];
contour_interval = [clim(1):2:clim(2)];
colorbarname = 'Temperature (deg C)';
colormapname = 'parula';

nc = netcdf(filename);

lon = nc{'longitude'}(:);
lat = nc{'latitude'}(:);
dep = nc{'depth'}(:);
if layer_ind < 0
    layer_ind = -layer_ind;
end
dist_dep = (dep - layer_ind).^2;
index = find(dist_dep == min(dist_dep));
dstr = num2str(dep(index));

vari = nc{variname}(1,index,:,:);

close(nc)

vari(vari > 100) = NaN;

map_J(domain_case)

warning off
m_pcolor(lon, lat, vari); colormap(colormapname); shading flat;

if strcmp(contour, 'contour on')
    [cs, h] = m_contour(lon, lat, vari, contour_interval, 'k');
    clabel(cs, h);
end

c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);

title([dstr, 'm'])

end