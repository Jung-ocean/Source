%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ROMS forcing using the Lab output
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear; close all;

casename = 'Lab';
g = grd(casename);

target_year = 2018; tys = num2str(target_year);
refdate = datenum(2011,1,1);

cycle_length = yeardays(target_year)+0.25;

filepath_all = ['H:\', tys, '\'];

varis = {'Tair', 'Pair', 'Uwind', 'Vwind', 'Qair', 'swrad', 'rain'};

for vi = 1:length(varis)

    vari = varis{vi};
        
    switch vari
        case {'swrad', 'rain'}
            ot = (datenum(target_year,1,1):1:datenum(target_year+1,1,1)) - refdate;
        otherwise
            ot = (datenum(target_year,1,1):6/24:datenum(target_year+1,1,1)) - refdate;
    end
    
    vari_interp = zeros([length(ot), size(g.lon_rho)]);
    
    % Generate forcing file and write data
    outfname = [vari, '_', casename, '_ECMWF_', num2str(target_year), '.nc'];
    create_frc_file(outfname,vari,vari_interp,ot - ot(1),cycle_length);
    
    % Write longitude and latitude information
    nc = netcdf.open(outfname,'write');
    lon_rho_trans = g.lon_rho'; lat_rho_trans = g.lat_rho';
    lon_ID = netcdf.inqVarID(nc,'lon_rho');
    netcdf.putVar(nc, lon_ID, lon_rho_trans);
    lat_ID = netcdf.inqVarID(nc,'lat_rho');
    netcdf.putVar(nc, lat_ID, lat_rho_trans);
    netcdf.close(nc);

    nc = netcdf(outfname, 'w');
    for ti = 1:length(ot)
        filedate = datestr(ot(ti) + refdate, 'yyyymmdd')
        fname = ['UM_yw3km_', vari, '.nc'];
        file = [filepath_all, filedate, '00\', fname];
        fnc = netcdf(file);
        if isempty(fnc)
            filedate = datestr(datenum(filedate, 'yyyymmdd') - 1, 'yyyymmdd');
            file = [filepath_all, filedate, '00\', fname];
            fnc = netcdf(file);
        end
        fnct = fnc{'ocean_time'}(:);
        
        switch vari
            case {'swrad', 'rain'}
                meandate = datevec(ot(ti));
                fdate = datevec(fnct);
                index = find(fdate(:,2) == meandate(:,2) & fdate(:,3) == meandate(:,3));
                if length(index) < 3
                    while length(index) < 3
                        close(fnc)
                        disp(['Empty ', filedate])
                        filedate = datestr(datenum(filedate, 'yyyymmdd') - 1, 'yyyymmdd');
                        file = [filepath_all, filedate, '00\', fname];
                        fnc = netcdf(file);
                        fnct = fnc{'ocean_time'}(:);
                        meandate = datevec(ot(ti));
                        fdate = datevec(fnct);
                        index = find(fdate(:,2) == meandate(:,2) & fdate(:,3) == meandate(:,3));
                    end
                end
                    
                fncf = fnc{vari}(index,:,:);
                close(fnc)
                
                nc{vari}(ti,:,:) = mean(fncf);
            otherwise
                index = find(fnct == ot(ti));
                if isempty(index)
                    while isempty(index)
                        close(fnc)
                        disp(['Empty ', filedate])
                        filedate = datestr(datenum(filedate, 'yyyymmdd') - 1, 'yyyymmdd');
                        file = [filepath_all, filedate, '00\', fname];
                        fnc = netcdf(file);
                        fnct = fnc{'ocean_time'}(:);
                        index = find(fnct == ot(ti));
                    end
                end
                    
                fncf = fnc{vari}(index,:,:);
                close(fnc)
                
                nc{vari}(ti,:,:) = fncf;
        end
             
    end
    vari_output = nc{vari}(:);
    close(nc)
    
    % Plot
    figure; plot(mean(mean(vari_output,2),3))
    title(vari)
    
    disp(['Compeleted: ', vari])
end