%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save Merged_MMv5.1_podaac monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
filepath = '/data/jungjih/Observations/Satellite_SSH/Merged/Merged_MMv5.2_podaac/data/';
% filenum_all = 949:1116;
filenum_all = 931:1154;
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

timenum_all = [datenum(2018, 1:12, 15), datenum(2019, 1:12, 15), datenum(2020, 1:12, 15) datenum(2021, 1:12, 15) datenum(2022, 1:12, 15) datenum(2023, 1:12, 15)];
timevec_all = datevec(timenum_all);
ADT_month_sum = zeros(length(timenum_all),14106);
num_data = zeros(length(timenum_all),14106);
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
%         mdt = griddata(lon_DTU15, lat_DTU15, mdt_DTU15, lon, lat);
        lat_ref = lat;
        lon_ref = lon;
    end
    load(['mdt_', num2str(length(lon)), '.mat']);

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

    for ti = 1:length(timenum_all)
        index = find(timevec(:,1) == timevec_all(ti,1) & timevec(:,2) == timevec_all(ti,2));
        lon_tmp = lon(index);
        lat_tmp = lat(index);
        if ~isempty(index)
            adt_tmp = adt(index);
            nanind = isnan(adt_tmp);
            adt_tmp(isnan(adt_tmp) == 1) = 0;

            ADT_month_sum(ti,index) = ADT_month_sum(ti,index)+adt_tmp';
            num_data(ti,index) = num_data(ti,index) + (~nanind)';
        end
    end
end

ADT_monthly = ADT_month_sum./num_data;

save ADT_monthly.mat timenum_all timevec_all ADT_monthly ADT_month_sum num_data lon_ref lat_ref