function DS = get_hycom_bdry_bys_from_file(Mobj, hycom_file) %#ok<*STOUT>
%% Parse inputs
% time_unit = 'days';
% bdry_time = unique(dateshift(Mobj.time, 'start', time_unit));
% cdate = datestr(bdry_time(1), 'yyyymmdd');

Hf.lon = ncread(hycom_file, 'xlon');
Hf.lat = ncread(hycom_file, 'ylat');
Hf.depth = abs(ncread(hycom_file, 'depth'));
Hf.time = ncread(hycom_file, 'time')/24 + datetime(2000,1,1);

nLons = numel(Hf.lon);
nLats = numel(Hf.lat);
nDeps = numel(Hf.depth);
nTimes = numel(Hf.time);
nNodes_obc = Mobj.nNodes_obc;

%% Interpolation
varList = {'surf_el', 'temperature', 'salinity', 'water_u', 'water_v'}; % variable names in the original dataset
nickList = {'ssh', 'temp', 'salt', 'uvel', 'vvel'};  % standard variable names

nVars = numel(varList);
for iVar = 1:nVars

    D.ind = Mobj.obc_nodes_tot;
    D.lon = Mobj.lon(D.ind);
    D.lat = Mobj.lat(D.ind);
    D.depth = abs(Hf.depth);
    D.time = Hf.time;
    D.unit_time = 'day';

    indLon = minfind(Hf.lon, D.lon);
    indLat = minfind(Hf.lat, D.lat);
    indBnd = sub2ind([nLats, nLons], indLat, indLon);

    varName = varList{iVar};
    nickName = nickList{iVar};
    if strcmp(nickName, 'ssh')
        varAll = zeros(nNodes_obc, 1, nTimes);
    else
        varAll = zeros(nNodes_obc,nDeps, nTimes);
    end
    for iTime = 1:nTimes
%         progressbar(iTime/nTimes)
%         cdate = datestr(bdry_time(iTime), 'yyyymmdd');
       
        varTmp = ncread(hycom_file, varName);

        if strcmp(nickName, 'ssh')
            varTmp = varTmp';
            varAll(:,1,iTime) = varTmp(indBnd);
        else
            varTmp = permute(varTmp, [2, 1, 3]);
            varTmp = reshape(varTmp, [nLats*nLons nDeps]);
            varAll(:,:,iTime) = varTmp(indBnd, :);
        end
    end
    D.var = varAll;

    DS.(nickName) = D;
    clear D varAll
end

end

























































