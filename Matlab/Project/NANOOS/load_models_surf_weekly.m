function vari = load_models_surf_weekly(model, vari_str, yyyy, mm, dd)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');
dstr = num2str(dd, '%02i');

switch model
    case 'NANOOS'
        filepath = '/data/jungjih/Models/NANOOS/weekly/';
        filename = ['NANOOS_weekly_', ystr, mstr, dstr, '.nc'];
        file = [filepath, filename];
        if exist(file)
            if ismember(vari_str, {'temp', 'salt'})
                vari = ncread(file, vari_str, [1 1 40 1], [Inf Inf 1 Inf]);
            elseif ismember(vari_str, {'u', 'v'})
                u_tmp = ncread(file, 'u', [1 1 40 1], [Inf Inf 1 Inf]);
                v_tmp = ncread(file, 'v', [1 1 40 1], [Inf Inf 1 Inf]);
                lon = ncread(file, 'lon_rho');
                lat = ncread(file, 'lat_rho');
                angle = ncread(file, 'angle');
                mask = ncread(file, 'mask_rho');

                skip = 1;
                npts = [0 0 0 0];
                [u,v,lonred,latred,maskred]=...
                    uv_vec2rho_J(u_tmp,v_tmp,lon,lat,angle,mask,skip,npts);

                vari = eval(vari_str);
            else
                vari = ncread(file, vari_str);
            end
        else
            vari = NaN(310, 522);
            disp(['No such file NANOOS weekly ', ystr, mstr, dstr])
        end
    case 'WCOFS'
        filepath = '/data/jungjih/Models/WCOFS/weekly_2D/';
        filename = ['WCOFS_2D_weekly_', ystr, mstr, dstr, '.nc'];
        file = [filepath, filename];
        if exist(file)
            if ismember(vari_str, {'temp', 'salt'})
                vari = ncread(file, [vari_str, '_sur']);
            elseif ismember(vari_str, {'u', 'v'})
                u_tmp = ncread(file, 'u_sur');
                v_tmp = ncread(file, 'v_sur');
                lon = ncread(file, 'lon_rho');
                lat = ncread(file, 'lat_rho');
                angle = ncread(file, 'angle');
                mask = ncread(file, 'mask_rho');

                skip = 1;
                npts = [0 0 0 0];
                [u,v,lonred,latred,maskred]=...
                    uv_vec2rho_J(u_tmp,v_tmp,lon,lat,angle,mask,skip,npts);

                vari = eval(vari_str);
            else
                vari = ncread(file, vari_str);
            end
        else
            vari = NaN(348,1016);
            disp(['No such file WCOFS weekly ', ystr, mstr, dstr])
        end
end

end