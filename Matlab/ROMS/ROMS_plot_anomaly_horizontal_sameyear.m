clear; clc; close all

yyyy = 2010:9999;
mm = 7:8;
layer = [0]; lts = num2str(layer);

g = grd('EYECS_20190904');
domain_case = 'southern';

var = 'zeta';
switch var
    case 'temp'
        colorbarname = 'Temperature (deg C)';
        clim = [-4 4];
        contour_interval = [clim(1):2:clim(2)];
    case 'speed'
        colorbarname = '(cm/s)';
        clim = [-100 100];
        contour_interval = [clim(1):20:clim(2)];
        colormapname = 'redblue2';
    case 'zeta'
        colorbarname = 'cm';
        clim = [0 15];
        contour_interval = [clim(1):5:clim(2)];
        colormapname = 'msl';
end

for yi = 1:length(yyyy)
    year_target = yyyy(yi); ystr = num2str(year_target);
    if year_target == 9999; ystr = 'avg'; end
    %filepath = ['G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\2013\'];
    filepath = '.\';
        
    for mi = 1:length(mm)
        month_target = mm(mi); mstr = num2char(month_target,2);
        
        filename = ['monthly_', ystr, mstr, '.nc'];
        
        targetfile = [filepath, filename];
        
        if strcmp(var, 'speed')
            skip = 1;
            npts = [0 0 0 0];

            u = get_hslice_J(targetfile,g,'u',layer,'r');
            v = get_hslice_J(targetfile,g,'v',layer,'r');
            
            masku2 = g.mask_u./g.mask_u;
            maskv2 = g.mask_v./g.mask_v;
            
            [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u.*masku2,v.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
            var_target = sqrt(u_rho.*u_rho + v_rho.*v_rho);
            
        else
            var_target = get_hslice_J(targetfile,g,var,layer,'r');
        end
            
            data_all(mi,:,:) = var_target;
            
    end
end

diffe = squeeze(data_all(2,:,:) - data_all(1,:,:));
if strcmp(var, 'temp')
else
    diffe = diffe*100;
end

warning off
figure
map_J(domain_case);
m_pcolor(g.lon_rho, g.lat_rho, diffe.*g.mask_rho./g.mask_rho); shading flat
colormap(colormapname);

[cs, h] = m_contour(g.lon_rho, g.lat_rho, diffe.*g.mask_rho./g.mask_rho, contour_interval, 'k');
h.LineWidth = 1;
clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold', 'LabelSpacing', 200);

c = colorbar; c.FontSize = 25;
%c.Label.String = colorbarname; c.Label.FontSize = 25;
c.Title.String = colorbarname; c.Title.FontSize = 25;
caxis(clim)

title(['SLD (Aug. - Jul. climate)'], 'FontSize', 25, 'FontWeight', 'bold')
%titlename = [datestr(datenum(mts, 'mm'), 'mmm'), ' - ', datestr(datenum(mts, 'mm')-30, 'mmm'), ' ', yts];
%title(titlename, 'FontSize', 25)
setposition(domain_case)
m_gshhs_i('patch', [.7 .7 .7])
%saveas(gcf, ['diff_sameyear_', var, '_layer', lts, '_', domain_case, '_', ystr,mstr, '.png'])
print('figure6b.tiff','-dtiff','-r600');