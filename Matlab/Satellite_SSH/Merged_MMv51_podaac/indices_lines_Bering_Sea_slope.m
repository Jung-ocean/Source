function [lon, lat] = indices_lines_Bering_Sea_slope(direction, i)

lonlat = load('lonlat_lines_Bering_Sea_slope.mat');

index_pline_Bering_Sea_slope = {;
    10800:10881;
    1124:1207;
    5310:5407;
    9266:9543;
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
    12956:13210;
    3400:3649};

index_aline_Bering_Sea_slope = {;
    4:24;
    9548:9567;
    5415:5445;
    1215:1297;
    10891:10983;
    6876:6955;
    2737:2839;
    12327:12441;
    8283:8422;
    4176:4418;
    25:288;
    9568:9864;
    5455:5778;
    1298:1667;
    10984:11344;
    6956:7300;
    2843:3171;
    12444:12755;
    8453:8739;
    4447:4744;
    327:611;
    9932:10193;
    5847:6094;
    1746:1934;
    11408:11577;
    7377:7510;
    3237:3350;
    12823:12907;
    8823:8872};

    if strcmp(direction, 'a')
        index = index_aline_Bering_Sea_slope;
    else
        index = index_pline_Bering_Sea_slope;
    end

lon = lonlat.lon(index{i});
lat = lonlat.lat(index{i});

end