clear; clc

filepath_org = '/data/jungjih/Project/NOPP_Carbon/Oregon_1km/Setups/Bio_LiveOcean/Diatoms_50/';

split_org = [50 50];
split_new = [80 20];

vari1 = 'Phytoplankton';
vari1_dependent1 = 'Chlorophyll';
vari1_dependent2 = 'Bacteria';
vari2 = 'Diatoms';
vari2_dependent = 'ChlD';

P = spitz_bio_params();
ChlN_phyto = P.ChlN_phyto;
Bacteria_fraction = P.Bacteria_fraction;
ChlN_diatom = P.ChlN_diatom;

% Initial
ini_org = [filepath_org, 'initial_Oregon_1km_LiveOcean_bio.nc'];
ini_new = ['initial_Oregon_1km_LiveOcean_bio.nc'];
copyfile(ini_org, ini_new);

% vari1
index = 1;
vari_tmp = ncread(ini_new, vari1);
vari_new = vari_tmp.*(sum(split_org)/split_org(index)).*(split_new(index)/sum(split_new));
ncwrite(ini_new, vari1, vari_new);
vari_dependent1 = vari_new.*ChlN_phyto;
ncwrite(ini_new, vari1_dependent1, vari_dependent1);
vari_dependent2 = vari_new.*Bacteria_fraction;
ncwrite(ini_new, vari1_dependent2, vari_dependent2);

% vari2
index = 2;
vari_tmp = ncread(ini_new, vari2);
vari_new = vari_tmp.*(sum(split_org)/split_org(index)).*(split_new(index)/sum(split_new));
ncwrite(ini_new, vari2, vari_new);
vari_dependent = vari_new.*ChlN_diatom;
ncwrite(ini_new, vari2_dependent, vari_dependent);

% Boundary
directions = {'west', 'south', 'north'};

% vari1
index = 1;
bndy_org = [filepath_org, 'boundary_Oregon_1km_bio_', vari1, '_5d_lpf.nc'];
bndy_new = ['boundary_Oregon_1km_bio_', vari1, '_5d_lpf.nc'];
copyfile(bndy_org, bndy_new);

bndy_dependent1_org = [filepath_org, 'boundary_Oregon_1km_bio_', vari1_dependent1, '_5d_lpf.nc'];
bndy_dependent1_new = ['boundary_Oregon_1km_bio_', vari1_dependent1, '_5d_lpf.nc'];
copyfile(bndy_dependent1_org, bndy_dependent1_new);

bndy_dependent2_org = [filepath_org, 'boundary_Oregon_1km_bio_', vari1_dependent2, '_5d_lpf.nc'];
bndy_dependent2_new = ['boundary_Oregon_1km_bio_', vari1_dependent2, '_5d_lpf.nc'];
copyfile(bndy_dependent2_org, bndy_dependent2_new);

for di = 1:length(directions)
    direction = directions{di};
    
    vari_str = [vari1, '_', direction];
    vari_tmp = ncread(bndy_new, vari_str);
    vari_new = vari_tmp.*(sum(split_org)/split_org(index)).*(split_new(index)/sum(split_new));
    ncwrite(bndy_new, vari_str, vari_new);
    
    vari_dependent1_str = [vari1_dependent1, '_', direction];
    vari_dependent1 = vari_new.*ChlN_phyto;
    ncwrite(bndy_dependent1_new, vari_dependent1_str, vari_dependent1);

    vari_dependent2_str = [vari1_dependent2, '_', direction];
    vari_dependent2 = vari_new.*Bacteria_fraction;
    ncwrite(bndy_dependent2_new, vari_dependent2_str, vari_dependent2);
end

% vari2
index = 2;
bndy_org = [filepath_org, 'boundary_Oregon_1km_bio_', vari2, '_5d_lpf.nc'];
bndy_new = ['boundary_Oregon_1km_bio_', vari2, '_5d_lpf.nc'];
copyfile(bndy_org, bndy_new);

bndy_dependent_org = [filepath_org, 'boundary_Oregon_1km_bio_', vari2_dependent, '_5d_lpf.nc'];
bndy_dependent_new = ['boundary_Oregon_1km_bio_', vari2_dependent, '_5d_lpf.nc'];
copyfile(bndy_dependent_org, bndy_dependent_new);

for di = 1:length(directions)
    direction = directions{di};
    
    vari_str = [vari2, '_', direction];
    vari_tmp = ncread(bndy_new, vari_str);
    vari_new = vari_tmp.*(sum(split_org)/split_org(index)).*(split_new(index)/sum(split_new));
    ncwrite(bndy_new, vari_str, vari_new);
    
    vari_dependent_str = [vari2_dependent, '_', direction];
    vari_dependent = vari_new.*ChlN_diatom;
    ncwrite(bndy_dependent_new, vari_dependent_str, vari_dependent);
end