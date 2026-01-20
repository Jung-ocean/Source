function [timenum_all, vari_all] = load_BSf_1d(g, vari_str, layer, datenum_start, datenum_end, lat_target, lon_target)

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/'];

lstr = num2str(layer);
latstr = num2str(lat_target);
lonstr = num2str(lon_target);

lon = g.lon_rho;
lat = g.lat_rho;
F = scatteredInterpolant(lat(:),lon(:),0.*lat(:));

timenum_all = [];
vari_all = [];
for di = datenum_start:datenum_end
    datenum_target = di;
    dstr = datestr(datenum_target, 'yyyymmdd');
    filenum = datenum_target - datenum(2018,7,1) + 1;
    fstr = num2str(filenum, '%04i');

    filename = ['Dsm4_avg_', fstr, '.nc'];
    file = [filepath, filename];
    
    if filenum == 0119
        file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/Dsm4_rhZop05/Sum_2018_Dsm4_rhZop05_avg_0119.nc';
    elseif filenum == 1640
        file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
    elseif filenum == 1826
        file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
    end

    if exist(file)
        try
            vari = ncread(file, vari_str, [1 1 layer 1], [Inf Inf 1 1]);
        catch
            timenum_all = [timenum_all; datenum_target];
            vari_all = [vari_all; NaN];
            continue
        end
        timenum_all = [timenum_all; datenum_target];

        F.Values = vari(:);
        vari_tmp = F(lat_target, lon_target);
        vari_all = [vari_all; vari_tmp];
    else
        timenum_all = [timenum_all; datenum_target];
        vari_all = [vari_all; NaN];
    end

    disp(['Loading ROMS ', vari_str, ' layer = ',lstr, ' lat = ', latstr, ' lon = ', lonstr, ' on ', dstr]);
end