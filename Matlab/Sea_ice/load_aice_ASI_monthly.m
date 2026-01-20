function [lat, lon, vari] = load_aice_ASI_monthly(yyyy, mm)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

if yyyy < 2012
    filepath = '/data/jungjih/Observations/Sea_ice/ASI/AMSR-E/monthly_ROMSgrid/';
    filename_head = 'asi-n6250-';
    version = '5.4';
elseif yyyy == 2012
    filepath = '/data/jungjih/Observations/Sea_ice/ASI/SSMIS/monthly_ROMSgrid/';
    filename_head = 'asi-SSMIS17-n6250-';
    version = '5';
else
    filepath = '/data/jungjih/Observations/Sea_ice/ASI/AMSR2/monthly_ROMSgrid/';
    filename_head = 'asi-AMSR2-n6250-';
    version = '5.4';
end
filename = [filename_head, ystr, mstr, '-v', version, '.nc'];
file = [filepath, filename];

if exist(file)
    lon = ncread(file,'longitude');
    lat = ncread(file,'latitude');
    vari_tmp = ncread(file,'z');
    vari = vari_tmp/100; % concentration to fraction
    disp(['Loading ASI aice ', ystr, mstr]);
else
    lat = NaN;
    lon = NaN;
    vari = NaN;
    disp(['No data in ', ystr, mstr]);
end

end
