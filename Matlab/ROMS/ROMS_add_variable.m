clear; clc

filename = 'roms_grid_NWP_ver41_rdrag2.nc';
variname = 'rdrag2';

nccreate(filename, 'rdrag2', 'Dimensions', {'xi_rho', 'eta_rho'});
ncwriteatt(filename, 'rdrag2', 'long_name', 'Quadratic bottom drag coefficient used in the computation of momentum stress')
ncwriteatt(filename, 'rdrag2', 'units', 'nondimensional')