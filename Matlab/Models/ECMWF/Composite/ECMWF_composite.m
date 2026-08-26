clear; clc

n = 15; % int16
yyyy = 2018; yts = num2str(yyyy);
mm = 1:12;

%filenum = '1'; filename_all = {'airT', 'dewt', 'msl', 'u10', 'v10'}; vari_all = {'t2m', 'd2m', 'msl', 'u10', 'v10'}; vari_all2 = {'TMP_2maboveground', 'DPT_2maboveground', 'PRES_meansealevel', 'UGRD_10maboveground', 'VGRD_10maboveground'};
filenum = '2'; filename_all = {'ssrd', 'tp'}; vari_all = {'ssrd', 'tp'}; vari_all2 = {'NSWRF_surface', 'TPRATE_surface'};

filepath = ['D:\Data\Atmosphere\ECMWF_interim\', yts, '\'];

for vi = 1:length(vari_all)
    clearvars -except n vi filenum filename_all vari_all mm yyyy yts filepath vari_all2
    
    vari = vari_all{vi};
    filename_yyyy = ['ECMWF_Interim_', filename_all{vi}, '_', yts, '.nc'];
    
    dataMax_all = [];
    dataMin_all = [];
    time_all = [];
    
    for mi = 1:length(mm)
        month = mm(mi); tms = num2char(month,2);
        disp([vari, ' month = ', tms])
        
        filename = [tms, '-', filenum, '.nc'];
        file = [filepath, filename];
        nc = netcdf(file);
        
        if month > 10
            
            varii = vari_all2{vi};
            varii_raw = nc{varii}(:);
            vari_unpacked = varii_raw;
            
            if strcmp(varii, 'TPRATE_surface')
                vari_unpacked = varii_raw/1000;
            end
            
            
        else
            vari_raw = nc{vari}(:);
            vari_scale_factor = nc{vari}.scale_factor(:);
            vari_add_offset = nc{vari}.add_offset(:);
            
            vari_unpacked = vari_raw.*vari_scale_factor + vari_add_offset;
        end
        close(nc)
        
        dataMax_tmp = max(max(max(vari_unpacked)));
        dataMin_tmp = min(min(min(vari_unpacked)));
        
        dataMax_all = [dataMax_all; dataMax_tmp];
        dataMin_all = [dataMin_all; dataMin_tmp];
        
    end
    
    dataMax = max(dataMax_all);
    dataMin = min(dataMin_all);
    
    scale_factor = (dataMax - dataMin) / (2^n - 1);
    add_offset = dataMin;
    
    ncyyyy = netcdf(filename_yyyy, 'w');
    ncyyyy{vari}.scale_factor(:) = scale_factor;
    ncyyyy{vari}.add_offset(:) = add_offset;
    
    ncyyyy{'time'}(:) = -1;
    ncyyyy{vari}(:) = 0;
    
    vari_time_all = [];
    vari_packed_all = [];
    
    for mi = 1:length(mm)
        month = mm(mi); tms = num2char(month,2);
        disp(['month = ', tms])
        
        filename = [tms, '-', filenum, '.nc'];
        file = [filepath, filename];
        
        nc = netcdf(file);
        vari_time = nc{'time'}(:);
        
        if month > 10
            vari_time_TIGGE = vari_time/60/60/24 + datenum(1970,1,1);
            vari_time = (vari_time_TIGGE - datenum(1900,1,1))*24;
            
            varii = vari_all2{vi};
            varii_raw = nc{varii}(:);
            vari_unpacked = varii_raw;
            
            if strcmp(varii, 'TPRATE_surface')
                vari_unpacked = varii_raw/1000;
            end
            
            vari_unpacked = flip(vari_unpacked,2);
            
        else
            vari_raw = nc{vari}(:);
            vari_scale_factor = nc{vari}.scale_factor(:);
            vari_add_offset = nc{vari}.add_offset(:);
            
            vari_unpacked = vari_raw.*vari_scale_factor + vari_add_offset;
        end
        close(nc)
        
        vari_packed = round( (vari_unpacked - add_offset)./scale_factor );
        
        vari_time_all = [vari_time_all; vari_time];
        vari_packed_all = [vari_packed_all; vari_packed];
        
    end

    vari_time_unique = unique(vari_time_all);
    for ti = 1:length(vari_time_unique)
        index = find(vari_time_all == vari_time_unique(ti));
        vari_packed_all_unique = vari_packed_all(index(1),:,:);
    
        ncyyyy{'time'}(ti) = vari_time_unique(ti);
        ncyyyy{vari}(ti,:,:) = int16(vari_packed_all_unique);
        
    end
            
    close(ncyyyy)
    
end