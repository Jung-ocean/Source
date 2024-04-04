function DS = get_hycom_init_bys_from_file(Mobj, hycom_file) 
%% Parse inputs 
init_time = Mobj.time(1);

varList1 = {'surf_el','salinity','temperature'};
varList2 = {'ssh','salt','temp'};
dim_order = [2 1 3];

nVars = numel(varList1);
for iVar = 1:nVars
    rawName = varList1{iVar};
    newName = varList2{iVar};
    D.lon = ncread(hycom_file, 'xlon');
    D.lat = ncread(hycom_file, 'ylat');
    D.depth = ncread(hycom_file, 'depth');
    D.time = init_time;
    varRaw = squeeze(ncread(hycom_file, rawName));
    switch ndims(varRaw)
        case 2
            D.var = permute(varRaw, dim_order(1:2));
        case 3
            D.var = permute(varRaw, dim_order);
    end
    DS.(newName) = D;
    clear D
end

end
