function [timenum_all, vari_all] = load_models_1d(model, vari_str, datenum_start, datenum_end, lat_target, lon_target);

g = grd(model);
lon = g.lon_rho;
lat = g.lat_rho;

F = scatteredInterpolant(lat(:),lon(:),0.*lat(:));

timenum_all = [];
vari_all = [];
for di = datenum_start:datenum_end
    datenum_target = di;
    dstr = datestr(datenum_target, 'yyyymmdd');
    filepath = ['/data/jungjih/Models/WCOFS/noaa-nos-ofs-pds.s3.amazonaws.com/wcofs/netcdf/', datestr(datenum_target, 'yyyy/mm/dd'), '/'];

    for ti = 1:24
        tstr = num2str(ti, '%03i');
        filename = ['wcofs.t03z.', dstr, '.2ds.f', tstr, '.nc'];
        file = [filepath, filename];
        ot = ncread(file, 'ocean_time');
        vari = ncread(file, vari_str);

        timenum = ot/60/60/24 + datenum(2016,1,1);
        timenum_all = [timenum_all; timenum];

        F.Values = vari(:);
        vari_tmp = F(lat_target, lon_target);
        vari_all = [vari_all; vari_tmp];
    end
end







g = grd('NANOOS');
lon = g.lon_rho;
lat = g.lat_rho;
filepath = '/home/server/ftp/dist/tides/ingria/ORWA/';
timenum_all = [];
vari_all = [];
for di = datenum_start:datenum_end
    datenum_target = di;
    dstr = datestr(datenum_target, 'dd-mmm-yyyy');
    filenum = datenum_target - datenum(2005,1,1) + 1;
    fstr = num2str(filenum);
    filename = ['ocean_his_', fstr, '_', dstr, '.nc'];
    file = [filepath, filename];
    ot = ncread(file, 'ocean_time');
    vari = ncread(file, vari_str);

    timenum = ot/60/60/24 + datenum(2005,1,1);
    timenum_all = [timenum_all; timenum]; 

    for ti = 1:length(timenum)
        vari_tmp = interp2(lat, lon, squeeze(vari(:,:,ti)), lat_target, lon_target);
        vari_all = [vari_all; vari_tmp];
    end
end