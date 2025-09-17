function vari = load_BSf_3d_layer(g, vari_str, layer, datenum_target, isfill)

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

zeta = ncread(file, 'zeta');
z = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
vari_sigma = squeeze(ncread(file, vari_str));

if layer < 0
    vari_bottom = squeeze(vari_sigma(:,:,1));
    vari = vinterp_J(vari_sigma,z,layer);
    if isfill == 1
        vari(isnan(vari) == 1) = vari_bottom(isnan(vari) == 1);
    end
else
    vari = squeeze(vari_sigma(:,:,layer));
end

end