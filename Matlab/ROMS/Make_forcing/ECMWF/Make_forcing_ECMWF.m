%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ROMS forcing using the ECMWF data
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear; close all;

casename = 'NWP';
target_year = 2013; tys = num2str(target_year);
varis = {'Tair', 'Pair', 'Uwind', 'Vwind', 'Qair', 'swrad', 'rain'};
filename_varis = {'airT', 'msl', 'u10', 'v10', 'dewt', 'ssrd', 'tp'};

for vi = 1:length(varis)
    clearvars -except vi casename target_year tys varis filename_varis
    
    vari = varis{vi};
    variname_vari = filename_varis{vi};
    
    fpath = ['/data1/temp/ECMWF_interim/', variname_vari, '/'];
    fname = ['ECMWF_Interim_', variname_vari, '_', tys, '.nc'];
    
    ncfile = [fpath, fname];
    nc = netcdf(ncfile);
    time = nc{'time'}(:);
    % ECMWF time = hours since 1900-01-01 00:00:0.0
    ftime = time/24 + datenum(1900,01,01,0,0,0);
    
    latitude = nc{'latitude'}(:);
    longitude = nc{'longitude'}(:);
    
    switch vari
        case {'Tair', 'Pair', 'Uwind', 'Vwind', 'Qair'}
            interval_time = 6;
            ot = 0:interval_time/24:yeardays(target_year); % ot = ocean time
            time_forcing = datenum(target_year,1,1):interval_time/24:datenum(target_year+1,1,1);
            
            switch vari
                case 'Tair'
                    variable = nc{'t2m'}(:); % t2m = 2 metre temperature
                    scale_factor = nc{'t2m'}.scale_factor(:);
                    add_offset = nc{'t2m'}.add_offset(:);
                    
                    vari_Kelvin = variable.*scale_factor + add_offset;
                    vari_Celcius = vari_Kelvin - 273.15;
                    eval(['vari_', vari, '= vari_Celcius;'])
                    
                case 'Pair'
                    variable = nc{'msl'}(:); % msl = mean sea level pressure
                    scale_factor = nc{'msl'}.scale_factor(:);
                    add_offset = nc{'msl'}.add_offset(:);
                    
                    vari_Pa = variable.*scale_factor + add_offset;
                    vari_mbar = vari_Pa/100;
                    eval(['vari_', vari, '= vari_mbar;'])
                    
                case 'Uwind'
                    variable = nc{'u10'}(:); % u10 = 10 metre U wind component
                    scale_factor = nc{'u10'}.scale_factor(:);
                    add_offset = nc{'u10'}.add_offset(:);
                    
                    vari_ms = variable.*scale_factor + add_offset; % ms = m/s
                    eval(['vari_', vari, '= vari_ms;'])
                    
                case 'Vwind'
                    variable = nc{'v10'}(:); % v10 = 10 metre V wind component
                    scale_factor = nc{'v10'}.scale_factor(:);
                    add_offset = nc{'v10'}.add_offset(:);
                    
                    vari_ms = variable.*scale_factor + add_offset; % ms = m/s
                    eval(['vari_', vari, '= vari_ms;'])
                    
                case 'Qair'
                    Dair = nc{'d2m'}(:); % d2m = 2 metre dewpoint temperature
                    Dair_scale_factor = nc{'d2m'}.scale_factor(:);
                    Dair_add_offset = nc{'d2m'}.add_offset(:);
                    
                    tfpath = ['/data1/temp/ECMWF_interim/', filename_varis{1}, '/'];
                    tfname = ['ECMWF_Interim_', filename_varis{1}, '_', tys, '.nc'];
                    tncfile = [tfpath, tfname];
                    tnc = netcdf(tncfile);
                    Tair = tnc{'t2m'}(:); % t2m = 2 metre temperature
                    Tair_scale_factor = tnc{'t2m'}.scale_factor(:);
                    Tair_add_offset = tnc{'t2m'}.add_offset(:);
                    close(tnc)
                    
                    Dair_Kelvin = Dair.*Dair_scale_factor + Dair_add_offset;
                    Tair_Kelvin = Tair.*Tair_scale_factor + Tair_add_offset;
                    
                    Qair = 100*e_sat(Dair_Kelvin)./e_sat(Tair_Kelvin);
                    eval(['vari_', vari, '= Qair;'])
            end
            
        case {'swrad', 'rain'}
            interval_time = 12;
            ot = 0.5:1:yeardays(target_year); % ot = ocean time
            time_forcing = datenum(target_year,1,1,12,0,0):interval_time/24:datenum(target_year+1,1,1);
            
            switch vari
                case 'swrad'
                    variable = nc{'ssrd'}(:); % ssrd = Surface solar radiation downwards
                    scale_factor = nc{'ssrd'}.scale_factor(:);
                    add_offset = nc{'ssrd'}.add_offset(:);
                    
                    vari_Jm_2 = variable.*scale_factor + add_offset; % Jm_2 = J/m^2
                    vari_Wm_2 = vari_Jm_2/43200; % Wm_2 = W/m^2
                    
                    for i = 1:yeardays(target_year)
                        index_time1 = find(time_forcing(2*i-1) == ftime);
                        index_time2 = find(time_forcing(2*i) == ftime);
                        vari_Wm_2_24accumulated(i,:,:) = (vari_Wm_2(index_time1,:,:) + vari_Wm_2(index_time2,:,:))/2;
                    end
                    eval(['vari_', vari, '= vari_Wm_2_24accumulated;'])
                    
                case 'rain'
                    variable = nc{'tp'}(:); % tp = Total precipitation
                    scale_factor = nc{'tp'}.scale_factor(:);
                    add_offset = nc{'tp'}.add_offset(:);
                    
                    vari_m = variable.*scale_factor + add_offset; % m = meter
                    vari_ms_1 = vari_m./43200; % ms_1 = m/s
                    
                    for i = 1:yeardays(target_year)
                        index_time1 = find(time_forcing(2*i-1) == ftime);
                        index_time2 = find(time_forcing(2*i) == ftime);
                        vari_ms_1_24accumulated(i,:,:) = (vari_ms_1(index_time1,:,:) + vari_ms_1(index_time2,:,:))/2;
                    end
                    vari_kgms_1 = 1000*vari_ms_1_24accumulated; % kgms_1 = kgm/s, actually kg/m^2s
                    eval(['vari_', vari, '= vari_kgms_1;'])
            end
    end
    close(nc)
    
    g = grd(casename);
    lon_rho = g.lon_rho; lat_rho = g.lat_rho;
    lon_grid = g.lon_rho(1,:); lat_grid = g.lat_rho(:,1);
    [len_eta, len_xi] = size(g.mask_rho);
    
    index_lon = find(min(lon_grid) - 1 < longitude & max(lon_grid) + 1 > longitude);
    index_lat = find(min(lat_grid) - 1 < latitude & max(lat_grid) + 1 > latitude);
    
    longitude_range = longitude(index_lon);
    latitude_range = latitude(index_lat);
    
    [Xi,Yi] = meshgrid(longitude_range,latitude_range);
    
    vari_target = eval(['vari_', vari]);
    vari_interp = zeros(length(ot), len_eta, len_xi);  % Preallocating Arrays for speed
    
    switch vari
        case {'Tair', 'Pair', 'Uwind', 'Vwind', 'Qair'}
            for i = 1:length(time_forcing)
                tindex = find(time_forcing(i) == ftime);
                Zi = squeeze(vari_target(tindex,index_lat,index_lon));
                vari_interp(i,:,:) = griddata(Xi, Yi, Zi, lon_grid, lat_grid);
                if mod(i,100) == 0
                    disp(['I am in the middle of ', num2str(i), '/', num2str(length(time_forcing))])
                end
            end
        case {'swrad', 'rain'}
            for i = 1:length(ot)
                Zi = squeeze(vari_target(i,index_lat,index_lon));
                vari_interp(i,:,:) = griddata(Xi, Yi, Zi, lon_grid, lat_grid);
                if mod(i,100) == 0
                    disp(['I am in the middle of ', num2str(i), '/', num2str(length(ot))])
                end
            end
    end
    
    if leapyear(target_year)
        cycle_length = 366;
    else
        cycle_length = 365;
    end
    % Generate forcing file and write data
    outfname = [vari, '_', casename, '_ECMWF_', num2str(target_year), '.nc'];
    create_frc_file(outfname,vari,vari_interp,ot,cycle_length);
    
    % Write longitude and latitude information
    nc = netcdf.open(outfname,'write');
    lon_rho_trans = lon_rho'; lat_rho_trans = lat_rho';
    lon_ID = netcdf.inqVarID(nc,'lon_rho');
    netcdf.putVar(nc, lon_ID, lon_rho_trans);
    lat_ID = netcdf.inqVarID(nc,'lat_rho');
    netcdf.putVar(nc, lat_ID, lat_rho_trans);
    netcdf.close(nc);
    
    % Plot
    figure; plot(mean(mean(vari_interp,2),3))
    title(vari)
    
    disp(['Compeleted: ', vari])
end