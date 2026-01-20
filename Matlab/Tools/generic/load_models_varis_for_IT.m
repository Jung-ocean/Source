function [timenum, zeta, temp, salt, u_bc, v_bc] = load_models_varis_for_IT(model, g, datenum_start, datenum_end)

timenum = [];
zeta = NaN([size(g.lat_rho), 12*(datenum_end-datenum_start+1)]);
temp = NaN([size(g.lat_rho), g.N, 12*(datenum_end-datenum_start+1)]);
salt = NaN([size(g.lat_rho), g.N, 12*(datenum_end-datenum_start+1)]);
u_bc = NaN([size(g.lat_rho), g.N, 12*(datenum_end-datenum_start+1)]);
v_bc = NaN([size(g.lat_rho), g.N, 12*(datenum_end-datenum_start+1)]);
dataind = 0;
for di = datenum_start:datenum_end
    datenum_tmp = di;
    switch model
        case 'NANOOS'
            timenum_ref = datenum(2005,1,1);
            filepath = '/home/server/ftp/dist/tides/ingria/ORWA/';
            dstr = datestr(datenum_tmp, 'dd-mmm-yyyy');
            filenum = datenum_tmp - timenum_ref +1;
            fstr = num2str(filenum, '%04i');
            filename = ['ocean_his_', fstr, '_', dstr, '.nc'];
            file = [filepath, filename];
    end
    ot = ncread(file, 'ocean_time');
    timenum_tmp = ot/60/60/24 + timenum_ref;
    timenum = [timenum; timenum_tmp];

    for ti = 1:length(ot)
        dataind = dataind+1;

        zeta_tmp = ncread(file, 'zeta', [1 1 ti], [Inf Inf 1]);
        temp_tmp = ncread(file, 'temp', [1 1 1 ti], [Inf Inf Inf 1]);
        salt_tmp = ncread(file, 'salt', [1 1 1 ti], [Inf Inf Inf 1]);
        salt_tmp(salt_tmp < 0) = 0;
        u_tmp = ncread(file, 'u', [1 1 1 ti], [Inf Inf Inf 1]);
        ubar_tmp = ncread(file, 'ubar', [1 1 ti], [Inf Inf 1]);
        v_tmp = ncread(file, 'v', [1 1 1 ti], [Inf Inf Inf 1]);
        vbar_tmp = ncread(file, 'vbar', [1 1 ti], [Inf Inf 1]);

        zeta(:,:,dataind) = zeta_tmp;
        temp(:,:,:,dataind) = temp_tmp;
        salt(:,:,:,dataind) = salt_tmp;

        ubar_3d = repmat(ubar_tmp, [1 1 g.N]);
        u_bc_tmp = u_tmp - ubar_3d;
        vbar_3d = repmat(vbar_tmp, [1 1 g.N]);
        v_bc_tmp = v_tmp - vbar_3d;

        skip = 1;
        npts = [0 0 0 0];
        for ni = 1:g.N
            [urho,vrho,lonred,latred,maskred]=...
                uv_vec2rho_J(u_bc_tmp(:,:,ni),v_bc_tmp(:,:,ni),g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

            u_bc(:,:,ni,dataind) = urho;
            v_bc(:,:,ni,dataind) = vrho;
        end
    end

    disp(['Loading ', file, ' ...'])
end

end