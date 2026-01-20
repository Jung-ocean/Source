function vari = load_models_3d_monthly(model, vari_str, yyyy, mm)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

switch model
    case 'NANOOS'
        filepath = '/data/jungjih/Models/NANOOS/daily/';
        filename = ['NANOOS_', yyyymmdd, '.nc'];
        file = [filepath, filename];

    case 'WCOFS'
        yyyymmdd = datestr(datenum_target+1, 'yyyymmdd');
        disp('Adding a day to the WCOFS data...')

        filepath = '/data/jungjih/Models/WCOFS/daily_3D/';
        filename = ['nos.wcofs.avg.nowcast.', yyyymmdd, '.t03z.nc'];
        file = [filepath, filename];
        if ~exist(file)
            filename = ['wcofs.t03z.', yyyymmdd, '.avg.nowcast.nc'];
            file = [filepath, filename];
        end

    case 'Dsm4'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/monthly/';
        filename = [model, '_', ystr, mstr, '.nc'];
        file = [filepath, filename];

    case 'Dsm4_mk2'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_mk2/monthly/';
        filename = [model, '_', ystr, mstr, '.nc'];
        file = [filepath, filename];

    case 'BSf_s7b3'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_s7b3/monthly/';
        filename = ['Dsm4_', ystr, mstr, '.nc'];
        file = [filepath, filename];
end

if exist(file)
    vari = ncread(file, vari_str);
    disp(['Loading ', model, ' ', vari_str, ' ', ystr, mstr, '...'])
else
    vari = NaN(size(depth_target));
    disp(['No data: no such file'])
end

end