function [lon_lim, lat_lim] = domain_J(location)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Domain_list = 'KODC_large',      lon_lim = [124 133]; lat_lim = [31 39]
%               'YECS_small',      lon_lim = [124 130]; lat_lim = [33 37]
%               'JWLee',           lon_lim = [124 130]; lat_lim = [33 38]
%               'YECS_large',      lon_lim = [117 130]; lat_lim = [27 41]
%               'YECS_flt',        lon_lim = [117.5 130.3]; lat_lim = [31 41]
%               'NWP',             lon_lim = [117 160]; lat_lim = [16 50]
%               'DA',              lon_lim = [123 135]; lat_lim = [30 41]
%               'TI',              lon_lim = [124 126.7]; lat_lim = [32 34]
%               'ECMWF_monthly'    lon_lim = [120 130]; lat_lim = [30 40]
%               'ECMWF_pressure'   lon_lim = [80 160]; lat_lim = [10 55]
%               'onshore'          lon_lim = [120 133]; lat_lim = [22 32]
%               'KS'               lon_lim = [125 132]; lat_lim = [30 36]
%               'Tsugaru'          lon_lim = [139.5 142]; lat_lim = [40.5 42.5]
%               'Soya'             lon_lim = [138 146]; lat_lim = [43 49];
%               'S.Okhotsk'        lon_lim = [137 162]; lat_lim = [41 52];
%               'Taean'            lon_lim = [125 128]; lat_lim = [35 38]
%
% [lon_lim, lat_lim] = domain_J('Domain_list')
%
% J. Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch location
    case 'KODC_large'
        lon_lim = [124 133]; lat_lim = [31 39];
        
    case 'KODC_small'
        lon_lim = [124 130]; lat_lim = [33 37];
        
    case 'YECS_small'
        lon_lim = [124 132]; lat_lim = [33 37];
        
    case 'S2'
        lon_lim = [127.9 128.1]; lat_lim = [34.4 34.5];
        
    case 'YECS_large'
        lon_lim = [116 130]; lat_lim = [29 43];
        
    case 'YECS_flt'
        lon_lim = [117.5 130.3]; lat_lim = [31 41];
        
    case 'YECS_flt_small'
        lon_lim = [123 130]; lat_lim = [32 37];
        
    case 'NWP'
        lon_lim = [115 162]; lat_lim = [15 52];
        
    case 'NP'
        lon_lim = [98 284]; lat_lim = [-20 65];
        
    case 'NWP_small'
        lon_lim = [118 152]; lat_lim = [18 48];
        
    case 'Philippines'
        lon_lim = [110 162]; lat_lim = [10 52];
        
    case 'DA'
        lon_lim = [123 135]; lat_lim = [30 41];
        
    case 'KODC_mag'
        lon_lim = [126 129]; lat_lim = [33.5 35];
        
    case 'ECMWF_monthly'
        lon_lim = [119 134]; lat_lim = [30 42];
        
    case 'ECMWF_pressure'
        lon_lim = [110 200]; lat_lim = [-10 60];
        
    case 'onshore'
        lon_lim = [120 133]; lat_lim = [22 33];
        
    case 'KS'
        lon_lim = [125 132]; lat_lim = [30 36];
        
    case 'Tsugaru'
        lon_lim = [139 145]; lat_lim = [40.5 42.5];
        
    case 'Soya'
        lon_lim = [138 146]; lat_lim = [43 49];
        
    case 'N.East'
        lon_lim = [137 146]; lat_lim = [38 50];
        
    case 'S.Okhotsk'
        lon_lim = [137 162]; lat_lim = [41 52];
        
    case 'Taean'
        lon_lim = [125 128]; lat_lim = [35 38];
        
    case 'Jeju'
        lon_lim = [125 129]; lat_lim = [32 35.5];
        
    case 'Antarctica'
        lon_lim = [180 210]; lat_lim = [-90 -65];
        
    case 'windstress_onshore'
        lon_lim = [120 130]; lat_lim = [25 35];
        
    case 'windstress_YSBCW'
        lon_lim = [117 127]; lat_lim = [30 42];
        
    case 'windstress_southern'
        lon_lim = [126.5 129]; lat_lim = [33.8 35];
        
    case 'current_southern'
        lon_lim = [126.5 129]; lat_lim = [33.8 34.2];
        
    case 'airT_YSBCW'
        lon_lim = [117 127]; lat_lim = [33 42];
        
    case 'Luzon'
        lon_lim = [116 126]; lat_lim = [15 25];
        
    case 'southern_open'
        lon_lim = [127 129.2]; lat_lim = [33.2 34];
        
    case 'Taiwan'
        lon_lim = [117 124]; lat_lim = [20 28];
        
    case 'NWP_SW'
        lon_lim = [115 130]; lat_lim = [15 26];
        
    case 'SS_sla'
        lon_lim = [124 134]; lat_lim = [32 36];
        
    case 'ECS'
        lon_lim = [119 134]; lat_lim = [26 36];
        
    case 'ECS2'
        lon_lim = [119 134]; lat_lim = [24 36];
        
    case 'ES'
        lon_lim = [127 144]; lat_lim = [33 52];
        
    case 'RV_ECS'
        lon_lim = [122 132]; lat_lim = [30 38];
        
    case 'LT'
        lon_lim = [126.125 129.125]; lat_lim = [33.125 35.125];
        
    case 'RV_NWP'
        lon_lim = [118 150]; lat_lim = [15 40];
        
    case 'LTRANS'
        lon_lim = [120 132]; lat_lim = [26.5 36];
        
    case 'EYECS'
        lon_lim = [113 145]; lat_lim = [30 54];
        
    case 'EYECS_topo'
        lon_lim = [116 145]; lat_lim = [29 54];
        
    case 'southern'
        lon_lim = [126 129.5]; lat_lim = [33.2 35.3];
        
    case 'southern_bank'
        lon_lim = [126 129.5]; lat_lim = [33.2 35.3];
        
    case 'upwelling_studyarea'
        lon_lim = [116 143]; lat_lim = [28 46];
        
    case 'yeonpyeong'
        lon_lim = [124 128]; lat_lim = [36 39];
        
    case 'PDO'
        lon_lim = [110 200]; lat_lim = [-10 70];
end
end