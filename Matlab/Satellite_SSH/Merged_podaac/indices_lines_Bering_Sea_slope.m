function [lon, lat] = indices_lines_Bering_Sea_slope(direction, i)

lonlat = load('lonlat_lines_Bering_Sea_slope.mat');

index_pline_Bering_Sea_slope = {;
9542:9841;
13693:14104;
3788:4264;
8030:8496;
12199:12676;
2254:2703;
6467:6851;
10672:11015;
796:1112;
5039:5333;
9194:9478;
13369:13625;
3511:3761;
7782:8005;
11998:12165;
};

index_aline_Bering_Sea_slope = {;
    2839:2949;
    12734:12852;
    8531:8671;
    4300:4555;
    33:307;
    9873:10175;
    5616:5940;
    1359:1730;
    11350:11710;
    7176:7521;
    2953:3282;
    12855:13167;
    8716:9005;
    4587:4885;
    356:641;
    10261:10516;
    6013:6260;
    1810:2002;
    11778:11950;
    7599:7733;
    3349:3462;
    13236:13322;
    9091:9145;
    4963:4990;
};

    if strcmp(direction, 'a')
        index = index_aline_Bering_Sea_slope;
    else
        index = index_pline_Bering_Sea_slope;
    end

lon = lonlat.lon(index{i});
lat = lonlat.lat(index{i});

end

% lon_tmp = -204.077;
% lat_tmp = 50.2497;
% 
% dist = sqrt((lon - lon_tmp).^2 + (lat - lat_tmp).^2);
% index1 = find(dist == min(dist))
% 
% lon_tmp = -202.8;
% lat_tmp = 49.1271;
% 
% dist = sqrt((lon - lon_tmp).^2 + (lat - lat_tmp).^2);
% index2 = find(dist == min(dist))
% 
% plot(lon(index1:index2), lat(index1:index2), '.g')