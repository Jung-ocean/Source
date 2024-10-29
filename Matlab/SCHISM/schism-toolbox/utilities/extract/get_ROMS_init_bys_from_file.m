function DS = get_ROMS_init_bys_from_file(Mobj, ROMS_file) 
%% Parse inputs 
init_time = Mobj.time(1);

varList1 = {'zeta','salt','temp'};
varList2 = {'ssh','salt','temp'};
dim_order = [3 2 1];

nVars = numel(varList1);
for iVar = 1:nVars
    rawName = varList1{iVar};
    newName = varList2{iVar};
    D.lon = ncread(ROMS_file, 'lon_rho')' + 360;
    D.lat = ncread(ROMS_file, 'lat_rho')';
%     D.depth = ncread(ROMS_file, 'depth');
    D.time = init_time;
    varRaw = squeeze(ncread(ROMS_file, rawName));
    switch ndims(varRaw)
        case 2
            D.var = permute(varRaw, dim_order(2:3));
        case 3
            D.var = permute(varRaw, dim_order);
    end
    DS.(newName) = D;
    clear D
end

end
