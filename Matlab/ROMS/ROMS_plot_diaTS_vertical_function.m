function [loc, dir_str, Xi, Yi, data] = ROMS_plot_diaTS_vertical_function(g, depth, var_str, var, section, location, range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section
%       casename = model domain casename
%       var_str = variable name string
%       var = variable
%       section = 'lon' or 'lat'
%       location = constant longitude or latitude
%       range = section range [a b]
%
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scale_factor = 1e-6;

colormapname = 'parula';
clim = [-10 10]; clim_ = 0.5;
contourinterval = [clim(1):2:clim(2)];
colorbarname = '( x 10^-^6 ^oC/s )';

if strcmp(section, 'lon')
    dir_str = '(^oE)';
    loc_chk = g.lon_rho(1,:);
    lim_chk = g.lat_rho(:,1);
    loc_diff = abs(loc_chk - location);
    loc_ind = find(loc_diff == min(loc_diff));
    loc = loc_chk(loc_ind);
    
    Yi = squeeze(depth(:,:,loc_ind));
    data = squeeze(eval(['var(:,:,loc_ind)']));
    xind = find(lim_chk >= range(1) & lim_chk <= range(2));
    Xi = g.lat_rho(xind, loc_ind); Xi=repmat(Xi',g.N,1);
    data = data(:, xind);
    Yi = Yi(:, xind);
    
    data = data./(scale_factor);
    
    data(data > clim(2)) = clim(2);
    data(data < clim(1)) = clim(1);
        
    figure; hold on
    
    % make land
    datasize = size(Yi);
    index = find(Yi(1,:) == min(Yi(1,:)));
    Yi2 = repmat(Yi(:,index), [1, datasize(2)]);
    land = -1000*ones(size(Yi2));
    pcolor(Xi,Yi2,land); shading interp
    
    pcolor(Xi,Yi,data); shading interp; colormap(colormapname)
    
    cm = colormap(colormapname);
    cm = [[.9 .9 .9]; cm];
    cm2 = colormap(cm);
    clim2 = [clim(1)-clim_ clim(2)+clim_];
    
    [cs, h] = contour(Xi, Yi, data, contourinterval, 'k');
    clabel(cs,h,'LabelSpacing',144, 'FontSize', 15)
    caxis(clim2);
    c = colorbar; c.FontSize = 15;
    c.Limits = clim;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    %c.Label.Interpreter = 'none';
    
    set(gca, 'FontSize', 15)
    ylabel('Depth(m)', 'FontSize', 15)
    xlabel('Latitude(^oN)', 'FontSize', 15)
    
elseif strcmp(section, 'lat')
    dir_str = '(^oN)';
    loc_chk = g.lat_rho(:,1);
    lim_chk = g.lon_rho(1,:);
    loc_diff = abs(loc_chk - location);
    loc_ind = find(loc_diff == min(loc_diff));
    loc = loc_chk(loc_ind);
    
    Yi = squeeze(depth(:,loc_ind,:));
    data = squeeze(eval(['var(:,loc_ind,:)']));
    xind = find(lim_chk >= range(1) & lim_chk <= range(2));
    Xi = g.lon_rho(loc_ind, xind); Xi=repmat(Xi,g.N,1);
    data = data(:, xind);
    Yi = Yi(:, xind);
    
    data = data./(scale_factor);
    
    figure; hold on
    pcolor(Xi,Yi,data); shading interp; colormap(colormapname)
    [cs, h] = contour(Xi, Yi, data, contourinterval, 'k');
    clabel(cs,h,'LabelSpacing',144, 'FontSize', 15)
    caxis(clim);
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    %c.Label.Interpreter = 'none';
    
    set(gca, 'FontSize', 15)
    ylabel('Depth(m)', 'FontSize', 15)
    xlabel('Longitude(^oE)', 'FontSize', 15)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%