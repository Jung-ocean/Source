function [timenum_all, lon_all, lat_all, vari_all] = load_models_zeta_point(model, datenum_start, datenum_end, lat_target, lon_target)

g = grd(model);
lon = g.lon_rho;
lat = g.lat_rho;
mask = g.mask_rho;

for li = 1:length(lon_target)
    lon_tmp = lon(:);
    lat_tmp = lat(:);
    mask_tmp = mask(:);

    mask_chk = 0;
    while mask_chk == 0
        dist = sqrt((lon_tmp - lon_target(li)).^2 + (lat_tmp - lat_target(li)).^2);
        index = find(dist == min(dist));
        mask_chk = mask_tmp(index);
        if mask_chk == 0
            lon_tmp(index) = NaN;
            lat_tmp(index) = NaN;
        end
    end
    dataind(li) = index;
end
lon_all = lon_tmp(dataind);
lat_all = lat_tmp(dataind);

switch model
    case 'NANOOS'
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
            vari = ncread(file, 'zeta');

            timenum = ot/60/60/24 + datenum(2005,1,1);
            timenum_all = [timenum_all; timenum];

            for ti = 1:length(timenum)
                vari_tmp = vari(:,:,ti);
                vari_tmp2 = vari_tmp(:);

                vari_all = [vari_all vari_tmp2(dataind)];
                
                disp(datestr(timenum(ti), 'yyyymmdd HH:MM ...'))
            end
        end

    case 'WCOFS'
        timenum_all = [];
        vari_all = [];
        for di = datenum_start:datenum_end
            datenum_target = di;
            dstr = datestr(datenum_target, 'yyyymmdd');
            ystr = datestr(datenum_target, 'yyyy');
            filepath = ['/data/jungjih/Models/WCOFS/', ystr, '/'];

            for ti = 1:24
                tstr = num2str(ti, '%03i');
                filename = ['nos.wcofs.2ds.n', tstr, '.', dstr, '.t03z.nc'];
                file = [filepath, filename];
                if ~exist(file)
                    filename = ['wcofs.t03z.', dstr, '.2ds.n', tstr, '.nc'];
                    file = [filepath, filename];
                end
                ot = ncread(file, 'ocean_time');
                vari = ncread(file, 'zeta');

                timenum = ot/60/60/24 + datenum(2016,1,1);
                timenum_all = [timenum_all; timenum];

                vari_tmp = vari(:);

                vari_all = [vari_all vari_tmp(dataind)];

                disp(datestr(timenum, 'yyyymmdd HH:MM ...'))
            end
        end
end