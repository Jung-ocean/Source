%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save Merged_MMv5.1_podaac climate
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
filepath = '/data/sdurski/Observations/SSH/Merged_MMv5.1_podaac/';
%filenum_all = 949:1087;
filenum_all = 949:1039;
lon_range = [-205.9832 -156.8640]; lat_range = [49.1090 66.3040]; % Bering Sea
vari_str = 'adt'; % adt or ssha

% DTU15 data
DTU15 = load('/data/jungjih/Observations/Satellite_SSH/DTU15/DTU15_1min_Bering_Sea.mat');
lon_DTU15 = DTU15.lon_DTU15_Bering_Sea;
lat_DTU15 = DTU15.lat_DTU15_Bering_Sea;
mss_DTU15 = DTU15.mss_DTU15_Bering_Sea;
mdt_DTU15 = DTU15.mdt_DTU15_Bering_Sea;
geoid_DTU15 = DTU15.geoid_DTU15_Bering_Sea;

% Load grid information
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;
h = g.h.*mask;
%

switch vari_str
    case 'adt'
        climit = [0 0.8];
        title_header = 'Absolute dynamic topography';
        gifname_header = 'ADT';

    case 'ssha'
        climit = [-0.2 0.2];
        title_header = 'Sea level anomaly';
        gifname_header = 'SLA';
end

ADT_month_sum = zeros(12,13687);
num_data = zeros(12,13687);
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    file_target = dir([filepath, '*', fstr, '*.nc']);
    filename = file_target.name;
    file = [filepath, filename];

    time = ncread(file, 'time');

    lat = ncread(file, 'lat');
    lon = ncread(file, 'lon') - 360;

    index_lon = find(lon > lon_range(1) -1 & lon < lon_range(2) + 1);
    index_lat = find(lat > lat_range(1) -1 & lat < lat_range(2) + 1);
    [val,pos] = intersect(index_lon, index_lat);
    lat = lat(val);
    lon = lon(val);
    time = time(val)/60/60/24 + datenum(1992,1,1);
    timevec = datevec(time);

    %mssh = ncread(file, 'mssh').*1e-3; % units = mm to m
    %mssh = mssh(val);
    %geoid = geoidheight(lat,lon); % units = m, EGM96 Geopotential Model
    %mdt = mssh - geoid;
    if fi == 1
        mdt = griddata(lon_DTU15, lat_DTU15, mdt_DTU15, lon, lat);
        lat_ref = lat;
        lon_ref = lon;
    end
    ssha = ncread(file, 'ssha').*1e-3; % units = mm to m
    ssha = ssha(val);

    if issame(lat, lat_ref) == 0
        index = find(ismember(lat, lat_ref) == 1);
        lat = lat(index);
        lon = lon(index);
        ssha = ssha(index);
        timevec = timevec(index,:);
    end
    adt = mdt + ssha;

    for mi = 1:12
        index = find(timevec(:,2) == mi);
        lon_tmp = lon(index);
        lat_tmp = lat(index);
        if ~isempty(index)
            adt_tmp = adt(index);
            nanind = isnan(adt_tmp) == 1;
            adt_tmp(isnan(adt_tmp) == 1) = 0;

            index2 = find(timevec(:,2) == mi & ismember(lon,lon_tmp)==1 & ismember(lat,lat_tmp)==1);
            ADT_month_sum(mi,index2) = ADT_month_sum(mi,index2)+adt_tmp';
            num_data(mi,index2) = num_data(mi,index2) + (~nanind)';
        end
    end
end

ADT_monthly = ADT_month_sum./num_data;

save ADT_climate.mat ADT_monthly ADT_month_sum num_data lon_ref lat_ref