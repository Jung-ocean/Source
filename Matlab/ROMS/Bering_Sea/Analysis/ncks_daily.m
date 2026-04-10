clear; clc

exp = 'Dsm4_mk2';

datenum_ref = datenum(2018,7,1);
datenum_start = datenum(2019,1,1);
datenum_end = datenum(2023,12,31);

for di = datenum_start:datenum_end
    timenum = di;
    filenum = timenum - datenum_ref + 1;
    fstr = num2str(filenum, '%04i');
    
    file = get_ncfilename(exp, 'avg', filenum);
    
    if exist(file)
        % zeta
        command = ['ncks -C -v zeta,ocean_time ', file, ' ./zeta_', fstr, '.nc'];
        system(command)

        % SSS
        command = ['ncks -C -d s_rho,44 -v salt,ocean_time ', file, ' ./SSS_', fstr, '.nc'];
        system(command)
    end
end