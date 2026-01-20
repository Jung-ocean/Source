function vari = load_models_2d_climate(model, g, vari_str, layer, mm)

lstr = num2str(layer);
mstr = num2str(mm, '%02i');

h = g.h;
lat = g.lat_rho;
lon = g.lon_rho;

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

    case 'BSf'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/climate/';
        filename = ['Dsm4_climate_', mstr, '.nc'];
        file = [filepath, filename];
end

if exist(file)
    vari = ncread(file, vari_str, [1 1 layer 1], [Inf Inf 1 Inf]);
    disp(['Loading ', model, ' ', vari_str, ' layer ', lstr, ' climate ', mstr, '...'])
else
    vari = NaN(size(depth_target));
    disp(['No data: no such file'])
end

end