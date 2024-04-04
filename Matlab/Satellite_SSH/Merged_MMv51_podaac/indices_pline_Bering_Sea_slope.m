function [lon, lat] = indices_pline_Bering_Sea_slope(i)

lonlat = load('lonlat_pline_Bering_Sea_slope.mat');

index_pline_Bering_Sea_slope = {;
    9437:9499;
    13329:13685;
    3680:4149;
    7800:8257;
    11815:12284;
    2190:2634;
    6305:6682;
    10350:10691;
    768:1073;
    4900:5190;
    8925:9203;
    12960:13210;
    3400:3649};

lon = lonlat.lon(index_pline_Bering_Sea_slope{i});
lat = lonlat.lat(index_pline_Bering_Sea_slope{i});

end