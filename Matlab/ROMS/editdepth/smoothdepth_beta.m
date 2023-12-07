%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Recover ROMS grid depth
%       Beta ver
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

% New grid
filepath = 'G:\test_grid\';
filename = 'test.nc';
new_gridfile = [filepath, filename];

% Read data from new grid file
nc = netcdf(new_gridfile);
lon_rho = nc{'lon_rho'}(:);
lat_rho = nc{'lat_rho'}(:);
mask_rho = nc{'mask_rho'}(:);
h = nc{'h'}(:);
close(nc)

figure; hold on;

total_index = 1;
index = 1;
while total_index == 1 % entire loop
    
    % Set the range of longitude and latitude
    while index == 1;
        pcolor(lon_rho, lat_rho, h.*mask_rho./mask_rho); shading flat
        title('Set your area using Zoom In, Zoom Out, and Pan button. And press Enter')
        zoom on
        pause
        
        xlimit = get(gca, 'xlim');
        ylimit = get(gca, 'ylim');
        
        xindex = find(lon_rho(1,:) > xlimit(1) & lon_rho(1,:) < xlimit(2));
        yindex = find(lat_rho(:,1) > ylimit(1) & lat_rho(:,1) < ylimit(2));
        
        hp = pcolor(h.*mask_rho./mask_rho);
        xlim([xindex(1) xindex(end)]); ylim([yindex(1) yindex(end)]);
        h_limited = h(yindex, xindex);
        caxis([0 max(max(h_limited))]);
        colorbar;
        
        index = index+1;
    end
    
    % Set the range of depth
    while index == 2;
        title('Input your depth range (ex. [0 100])')
        
        prompt = [' depth range? [depth_min depth_max] '];
        climit = input(prompt);
        caxis(climit)
        prompt = [' Again? y or n ']; value = input(prompt, 's');
        if isempty(value)
            value = 'y';
        end
        if strcmp(value, 'y')
            index = 2;
        elseif strcmp(value, 'n')
            index = index+1;
        end
    end
    
    % Edit the depth of new grid file
    while index == 3;
        title('Select the tile to be recovered. If you are done, press Enter')
        
        [lon1, lat1] = ginput(1);
        if isempty(lon1)
            break
        end
        
        lat2 = floor(lat1);
        lon2 = floor(lon1);
        
        value = [];
        for i = -1:1
            for ii = -1:1
                value = [value; h(lat2+i, lon2+ii)];
            end
        end
        h(lat2,lon2) = mean(value);
        hp.CData(lat2, lon2) = h(lat2,lon2);
    end
    
    disp(' '); disp(' Which stage do you want to go to? ')
    prompt = [' area(1), depth(2), edit(3), save(4), nothing (You know nothing, Jon Snow) (5) '];
    index = input(prompt);
    
    % Whether or not save modified depth to the new grid file
    if index == 4
        nc = netcdf(new_gridfile, 'w');
        nc{'h'}(:) = h;
        close(nc)
        disp(' '); disp(' Saving is completed, Bye ~ ')
        total_index = 2;
    elseif index == 5
        disp(' '); disp(' Nothing happened, Bye ~ ')
        total_index = 2;
    end
    
end % entire end