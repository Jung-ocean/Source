function vari = load_BSf_2d_daily(g, vari_str, datenum_target)

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/'];
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
disp(file)

vari = ncread(file, vari_str);

end