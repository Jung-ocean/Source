function [period, amp, phase, names] = reshape_to_grid ( tidal_constituents, grid_ncfile )
% RESHAPE_TO_GRID:  
%
% PARAMETERS:
% Input:
%     tidal_constituents:
%         The tidal constituents are structures where each structure 
%         has the following fields
%
%           Name:  
%               a character string
%           Amplitude, Phase:
%               1D arrays
%           Period:
%               a scalar
%
%     grid_ncfile:
%         NetCDF file with ROMS grid defined
%
% Output:
%     period:
%         1D array, period of each constituent
%     amp, phase:
%         2D arrays, same size as grid defined in grid_ncfile
%     names
%         cell array of tidal constituent names
%     
%     
% We want to re-arrange the amplitude and phase into arrays corresponding to
% the grid size.  The grid is given in the grid_ncfile.

lon = ncread( grid_ncfile, 'lon_rho' );
varsize=size(lon);
r = varsize(1);
c = varsize(2);

num_constituents = length(tidal_constituents);
for j=1:num_constituents
	names{j} = tidal_constituents(j).Name;
	period(j,1) = tidal_constituents(j).Period;
	amp(j,:,:) = reshape ( tidal_constituents(j).Amplitude, r, c );
	phase(j,:,:) = reshape ( tidal_constituents(j).Phase, r, c );
end

return
