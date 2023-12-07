%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Edit ROMS grid depth
%       Beta ver
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

% User defined variables (grid file path and grid file name)
grid_filepath = 'G:\Model\ROMS\Case\NWP_ET1K30\input\';
grid_filename = 'roms_grid_NWP_ET1K30.nc';

% Copy the grid file into new grid file
gridfile = [grid_filepath, grid_filename];
new_gridfile = ['.\new_', grid_filename];
copyfile(gridfile, new_gridfile)

% Read data from new grid file
nc = netcdf(new_gridfile);
lon_rho = nc{'lon_rho'}(:);
lat_rho = nc{'lat_rho'}(:);
mask_rho = nc{'mask_rho'}(:);
h = nc{'h'}(:);
close(nc)

% Set the range of longitude and latitude
figure; 
pcolor(lon_rho, lat_rho, h.*mask_rho./mask_rho); shading flat
title('Input your Longitude and Latitude range')

index = 0;
while index == 0;
    prompt = [' Longitude? [lon_min lon_max] ']; xlimit = input(prompt);
    prompt = [' Latitude? [lat_min lat_max] ']; ylimit = input(prompt);
    xlim(xlimit); ylim(ylimit);
    prompt = [' Again? y or n ']; value = input(prompt, 's');
    if isempty(value)
        value = 'y';
    end
    if strcmp(value, 'y')
        index = 0;
    elseif strcmp(value, 'n')
        index = 1;
    end
end

% Set the range of depth
xindex = find(lon_rho(1,:) > xlimit(1) & lon_rho(1,:) < xlimit(2));
yindex = find(lat_rho(:,1) > ylimit(1) & lat_rho(:,1) < ylimit(2));

hp = pcolor(h.*mask_rho./mask_rho);
xlim([xindex(1) xindex(end)]); ylim([yindex(1) yindex(end)]);
h_limited = h(yindex, xindex);
caxis([0 max(max(h_limited))]);
colorbar;

title('Input your depth range')

index = 0;
while index == 0;
    prompt = [' depth range? [depth_min depth_max] ']; climit = input(prompt);
    caxis([climit])
    prompt = [' Again? y or n ']; value = input(prompt, 's');
    if isempty(value)
        value = 'y'
    end
    if strcmp(value, 'y')
        index = 0;
    elseif strcmp(value, 'n')
        index = 1;
    end
end

% Edit the depth of new grid file
title('Select the tile and input your value. If you are done, press Enter')
index = 0;
while index == 0;
    [lon1, lat1] = ginput(1);
    
    if isempty(lon1)
        break
    end
    
    lat2 = floor(lat1);
    lon2 = floor(lon1);
    
    prompt = [' Original depth is ', num2str(h(lat2,lon2)), 'm, What is your depth? '];
    value = input(prompt);
    h(lat2,lon2) = value;
    hp.CData(lat2, lon2) = h(lat2,lon2);
end

% Whether or not save modified depth to the new grid file
prompt = [' Do you want to save your result to your new grid file? y or n ']; value = input(prompt, 's');
if isempty(value)
    value = 'y'
end
if strcmp(value, 'y')
    nc = netcdf(new_gridfile, 'w');
    nc{'h'}(:) = h;
    disp(' Saving is complete, Bye ~ ')
elseif strcmp(value, 'n')
    disp(' Nothing happened, Bye ~ ')
end