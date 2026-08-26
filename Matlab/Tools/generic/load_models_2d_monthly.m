function vari = load_models_2d_monthly(model, expname, vari_str, layer, yyyy, mm)

lstr = num2str(layer);
if yyyy == 9999
    ystr = 'climate';
else
    ystr = num2str(yyyy);
end
mstr = num2str(mm, '%02i');

switch model
    case 'NANOOS'
        filepath = '/data/jungjih/Models/NANOOS/daily/';
        filename = ['NANOOS_', yyyymmdd, '.nc'];
        file = [filepath, filename];

    case 'WCOFS'
        filepath = '/data/jungjih/Models/WCOFS/monthly_3D/';
        filename = ['WCOFS_monthly_', ystr, mstr, '.nc'];
        file = [filepath, filename];

    case 'LiveOcean'
        filepath = '/data/jungjih/Models/LiveOcean/monthly/';
        filename = ['monthly_', ystr, mstr, '.nc'];
        file = [filepath, filename];

    case 'Oregon_1km'
        filepath = ['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Outputs/Output_', expname, '/monthly/'];
        filename = ['monthly_', ystr, mstr, '.nc'];
        file = [filepath, filename];

    case 'Dsm4'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/monthly/';
        filename = [model, '_', ystr, mstr, '.nc'];
        file = [filepath, filename];

    case 'Dsm4_mk2'
        if yyyy == 9999
            filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_mk2/climate/';
            filename = [model, '_', ystr, '_', mstr, '.nc'];
        else
            filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_mk2/monthly/';
            filename = [model, '_', ystr, mstr, '.nc'];
        end
        file = [filepath, filename];

    case 'BSf_s7b3'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_s7b3/monthly/';
        filename = ['Dsm4_', ystr, mstr, '.nc'];
        file = [filepath, filename];
end

info = ncinfo(file, vari_str);
dim = length(info.Dimensions);

if exist(file)
    if dim == 3
        vari = ncread(file, vari_str);
        disp(['Loading ', model, ' ', vari_str, ' ', ystr, ' ', mstr, '...'])
    else
        vari = ncread(file, vari_str, [1 1 layer 1], [Inf Inf 1 Inf]);
        disp(['Loading ', model, ' ', vari_str, ' layer ', lstr, ' ', ystr, ' ', mstr, '...'])
    end
else
    vari = NaN(size(depth_target));
    disp(['No data: no such file'])
end

end