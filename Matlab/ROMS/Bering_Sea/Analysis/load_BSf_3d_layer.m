function vari = load_BSf_3d_layer(g, vari_str, layer, datenum_target, isfill)

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/'];
filenum = datenum_target - datenum(2018,7,1) + 1;
fstr = num2str(filenum, '%04i');
filename = ['Dsm4_avg_', fstr, '.nc'];
file = [filepath, filename];

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