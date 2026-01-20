function vari = load_BSf_daily(exp, vari_str, datenum_target)

filenum = datenum_target - datenum(2018,7,1) + 1;
try
    file = get_ncfilename(exp, 'avg', filenum);
    vari = ncread(file, vari_str);
    disp(['Loading ', vari_str, ' on ', datestr(datenum_target, 'yyyymmdd'), ' from ', file])
    if isempty(vari)
        disp([vari_str, ' is empty'])
    end
catch
    vari = NaN;
    disp(['No such file: ', exp, ' on ', datestr(datenum_target, 'yyyymmdd')])
end

% if strcmp(exp, 'Dsm4')
%     if filenum == 0119
%         file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/Dsm4_rhZop05/Sum_2018_Dsm4_rhZop05_avg_0119.nc';
%     elseif filenum == 1640
%         file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
%     elseif filenum == 1826
%         file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
%     end
% end

end