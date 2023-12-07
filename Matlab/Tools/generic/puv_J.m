function puv = puv_J(location)

switch location
    case 'ECMWF_YECS_small'
        puv.scale_factor = 2;
        puv.interval = 1;
        %puv.color = [.4 .4 .4];
        puv.color = [0.8510 0.3294 0.1020];
        
        puv.scale_value = 2.0; puv.scale_Loc = [127.5, 36.5];
        puv.scale_text = '2 m s^-^1'; puv.scale_text_Loc = [127.5, 36.3];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'ECMWF_raw_YECS_large'
         puv.scale_factor = 4;
         puv.interval = 1;
         puv.color = 'k';
%        puv.scale_factor = 6;
%        puv.interval = 2;
%        puv.color = [0 0.4510 0.7412];
        
        puv.scale_value = 2.0; puv.scale_Loc = [117, 42];
        puv.scale_text = '2 m s^-^1'; puv.scale_text_Loc = [117, 41.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'ECMWF_raw_YECS_large_diff'
        puv.scale_factor = 6;
        puv.interval = 3;
        %puv.color = 'blue';
        puv.color = 'k';
        
        puv.scale_value = 1.0; puv.scale_Loc = [117, 42];
        puv.scale_text = '1 m s^-^1'; puv.scale_text_Loc = [117, 41.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'ECMWF_raw_NWP_small'
        puv.scale_factor = 6;
        puv.interval = 5;
        %puv.color = 'blue';
        puv.color = [0 0.4510 0.7412];
        
        puv.scale_value = 2.0; puv.scale_Loc = [120, 45.5];
        puv.scale_text = '2 m s^-^1'; puv.scale_text_Loc = [120, 44.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'ECMWF_raw_NWP_small_diff'
        puv.scale_factor = 24;
        puv.interval = 5;
        %puv.color = 'blue';
        puv.color = [0 0.4510 0.7412];
        
        puv.scale_value = 1.0; puv.scale_Loc = [120, 45.5];
        puv.scale_text = '1 m s^-^1'; puv.scale_text_Loc = [120, 44.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
        case 'ECMWF_raw_ECMWF_pressure'
        puv.scale_factor = 6;
        puv.interval = 10;
        %puv.color = 'blue';
        puv.color = [0 0.4510 0.7412];
        
        puv.scale_value = 2.0; puv.scale_Loc = [120, 45.5];
        puv.scale_text = '2 m s^-^1'; puv.scale_text_Loc = [120, 44.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'ECMWF_raw_ECMWF_pressure_diff'
        puv.scale_factor = 24;
        puv.interval = 10;
        %puv.color = 'blue';
        puv.color = [0 0.4510 0.7412];
        
        puv.scale_value = 1.0; puv.scale_Loc = [120, 45.5];
        puv.scale_text = '1 m s^-^1'; puv.scale_text_Loc = [120, 44.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'ECMWF_YECS_large'
        puv.scale_factor = 3;
        puv.interval = 7;
        puv.color = 'blue';
        %puv.color = [0 0.4510 0.7412];
        
        puv.scale_value = 2.0; puv.scale_Loc = [127.5, 42.5];
        puv.scale_text = '2 m s^-^1'; puv.scale_text_Loc = [127.5, 42];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'UM_Jeju'
        color = [0 0 1];
        
        puv.scale_factor = 0.2;
        puv.interval = 10;
        puv.color = color;
        
        puv.scale_value = 10.0; puv.scale_Loc = [125.05, 35.2];
        puv.scale_text = '바람 10 m s^-^1'; puv.scale_text_Loc = [125.05, 35];
        puv.scale_text_color = color;
        puv.scale_color = color;
        
    case 'UM_google_Jeju'
        color = [0 0 1];
        
        puv.scale_factor = 0.02;
        puv.interval = 10;
        puv.color = color;
        
        puv.scale_value = 10.0; puv.scale_Loc = [125.2, 35.3];
        puv.scale_text = '바람 10 m s^-^1'; puv.scale_text_Loc = [125.2, 35.1];
        puv.scale_text_color = color;
        puv.scale_color = color;
        
    case 'YECS_small'
        puv.scale_factor = 3;
        puv.interval = 1;
        %puv.color = [.4 .4 .4];
        puv.color = 'blue';
        
        puv.scale_value = 2.0; puv.scale_Loc = [127.5, 36.5];
        puv.scale_text = '2 m s^-^1'; puv.scale_text_Loc = [127.5, 36.3];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'YECS_flt_small'
        puv.scale_factor = 20;
        puv.interval = 15;
        puv.color = 'w';
        
        puv.scale_value = 0.2; puv.scale_Loc = [127.5, 36.5];
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [127.5, 36.3];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
            
    case 'SS_sla'
        puv.scale_factor = 20;
        puv.interval = 5;
        puv.color = 'w';
        
        puv.scale_value = 0.2; puv.scale_Loc = [127.5, 35.5];
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [127.5, 35.3];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'southern'
        puv.scale_factor = 6;
        puv.interval = 3;
        puv.color = 'k';
        
        puv.scale_value = 0.3; puv.scale_Loc = [126.8, 35];
        puv.scale_text = '30 cm/s'; puv.scale_text_Loc = [126.8, 34.9];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'bar_southern'
        puv.scale_factor = 10;
        puv.interval = 1;
        puv.color = 'k';
        
        puv.scale_value = 0.1; puv.scale_Loc = [126.8, 35];
        puv.scale_text = '10 cm/s'; puv.scale_text_Loc = [126.8, 34.9];
        puv.scale_text_color = 'k';
        puv.scale_color = 'k'; puv.scale_text_fontsize = 15;
        
    case {'YECS_flt', 'YECS_large'}
        puv.scale_factor = 50;
        puv.interval = 7;
        puv.color = 'w';
        
        puv.scale_value = 0.2; puv.scale_Loc = [127.5, 36.5];
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [127.5, 36.3];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'EYECS'
        puv.scale_factor = 30;
        puv.interval = 10;
        puv.color = 'k';
        
        puv.scale_value = 0.5; puv.scale_Loc = [114, 33];
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [114, 32];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'AVISO_EYECS'
        puv.scale_factor = 30;
        puv.interval = 3;
        puv.color = 'k';
        
        puv.scale_value = 0.5; puv.scale_Loc = [114, 33];
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [114, 32];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
            
    case 'AVISO_southern'
        puv.scale_factor = 15;
        puv.interval = 1;
        puv.color = 'k';
        
        puv.scale_value = 0.2; puv.scale_Loc = [127, 35.1];
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [127, 35];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 15;
    
    case 'NP'
        puv.scale_factor = 200;
        puv.interval = 10;
        puv.color = 'k';
        
        puv.scale_value = 0.5; puv.scale_Loc = [115, 56];
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [115, 53];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'AVISO_NP'
        puv.scale_factor = 200;
        puv.interval = 10;
        puv.color = 'k';
        
        puv.scale_value = 0.5; puv.scale_Loc = [115, 56];
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [115, 53];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'KODC_small'
        puv.scale_factor = 15;
        puv.interval = 4;
        %puv.scale_factor = 30;
        %puv.interval = 8;
        puv.color = 'black';
        
        puv.scale_value = 0.2; puv.scale_Loc = [127.5, 36.5]; %puv.scale_Loc = [126.7, 35.1];
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [127.5, 36.3]; %puv.scale_text_Loc = [126.7, 35];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'KODC_mag'
        puv.scale_factor = 10;
        puv.interval = 1;
        puv.color = 'black';
        
        puv.scale_value = 0.1; puv.scale_Loc = [126.7, 34.9];
        puv.scale_text = '0.1 m s^-^1'; puv.scale_text_Loc = [126.7, 34.8];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'ECMWF_KODC_small'
        puv.scale_factor = 1;
        puv.interval = 5;
        puv.color = 'blue';
        
        puv.scale_value = 2; puv.scale_Loc = [127.5, 36.5];
        puv.scale_text = '2 m s^-^1'; puv.scale_text_Loc = [127.5, 36.3];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'ECMWF_southern'
        puv.scale_factor = 0.6;
        puv.interval = 2;
        puv.color = [0 0.4471 0.7412];
        
        puv.scale_value = 5; puv.scale_Loc = [126.7, 35.1];
        puv.scale_text = '5 m/s'; puv.scale_text_Loc = [126.7, 35];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 15;
        
    case 'ECMWF_raw_KODC_small'
        puv.scale_factor = 0.7;
        puv.interval = 4;
        %puv.color = 'blue';
        puv.color = [0 0.4510 0.7412];
        
        puv.scale_value = 5.0; puv.scale_Loc = [128.5, 36.5];
        puv.scale_text = '5 m s^-^1'; puv.scale_text_Loc = [128.5, 36.3];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red';
        
    case 'ECMWF_monthly'
        % wind
        %         puv.scale_factor = 3;
        %         puv.interval = 1;
        %         puv.color = 'blue';
        %
        %         puv.scale_value = 2.0; puv.scale_Loc = [123, 41];
        %         puv.scale_text = '2 m/s'; puv.scale_text_Loc = [123, 40.5];
        %         puv.scale_text_color = 'k';
        %         puv.scale_color = 'red';
        puv.scale_factor = 30;
        puv.interval = 5;
        puv.color = 'black';
        
        puv.scale_value = 0.2; puv.scale_Loc = [123, 41];
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [123, 40.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'NWP'
        puv.scale_factor = 20;
        puv.interval = 2;
        puv.color = 'black';
        
        puv.scale_value = 0.5; puv.scale_Loc = [120, 46];
        puv.scale_color = 'red';
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [120, 45];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'AVISO_NWP'
        puv.scale_factor = 20;
        puv.interval = 2;
        puv.color = 'black';
        
        puv.scale_value = 0.5; puv.scale_Loc = [120, 46];
        puv.scale_color = 'red';
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [120, 45];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'Philippines'
        puv.scale_factor = 15;
        puv.interval = 3;
        %puv.color = [.6 .6 .6];
        puv.color = 'black';
        
        puv.scale_value = 0.5; puv.scale_Loc = [120, 46];
        puv.scale_color = 'red';
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [120, 45];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'DA'
        puv.scale_factor = 15;
        puv.interval = 5;
        %puv.color = [.4 .4 .4];
        puv.color = 'black';
        
        puv.scale_value = 0.5; puv.scale_Loc = [127.2, 37];
        puv.scale_color = 'red';
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [127.2, 36.5];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'onshore'
        puv.scale_factor = 15;
        puv.interval = 5;
        %puv.color = [.4 .4 .4];
        puv.color = 'black';
        
        puv.scale_value = 0.5; puv.scale_Loc = [120.1, 29.3];
        puv.scale_color = 'red';
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [120.1, 29.8];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'S.Okhotsk'
        puv.scale_factor = 45;
        puv.interval = 5;
        %puv.color = [.4 .4 .4];
        puv.color = 'black';
        
        puv.scale_value = 0.3; puv.scale_Loc = [137.5, 50];
        puv.scale_color = 'red';
        puv.scale_text = '0.3 m s^-^1'; puv.scale_text_Loc = [137.5, 49.5];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case {'ECS', 'ECS2'}
        puv.scale_factor = 30;
        puv.interval = 5;
        %puv.color = [.4 .4 .4];
        puv.color = 'black';
        
        puv.scale_value = 0.2; puv.scale_Loc = [120.1, 29.3];
        puv.scale_color = 'red';
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [120.1, 29.8];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case {'AVISO_ECS', 'AVISO_ECS2'}
        puv.scale_factor = 30;
        puv.interval = 2;
        %puv.color = [.4 .4 .4];
        puv.color = 'black';
        
        puv.scale_value = 0.2; puv.scale_Loc = [120.1, 29.3];
        puv.scale_color = 'red';
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [120.1, 29.8];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'ES'
        puv.scale_factor = 25;
        puv.interval = 5;
        %puv.color = [.4 .4 .4];
        puv.color = 'black';
        
        puv.scale_value = 0.5; puv.scale_Loc = [129, 45];
        puv.scale_color = 'red';
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [129, 46];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'RV_ECS'
        puv.scale_factor = 15; % 10
        puv.interval = 4; % 8
        puv.color = 'black';
        
        puv.scale_value = 0.3; puv.scale_Loc = [128, 35.8];
        puv.scale_text = '30 cm/s'; puv.scale_text_Loc = [128, 35.5];
        puv.scale_text_color = 'k';
        puv.scale_color = 'red'; puv.scale_text_fontsize = 10;
        
    case 'LT'
        puv.scale_factor = 6;
        puv.interval = 3;
        puv.color = [.4 .4 .4];
        
        puv.scale_value = 0.2; puv.scale_Loc = [126.7, 35];
        puv.scale_text = '0.2 m s^-^1'; puv.scale_text_Loc = [126.7, 34.9];
        puv.scale_text_color = 'k';
        puv.scale_color = 'k'; puv.scale_text_fontsize = 10;
        
    case 'RV_NWP'
        puv.scale_factor = 20;
        puv.interval = 7;
        puv.color = 'black';
        
        puv.scale_value = 0.5; puv.scale_Loc = [137, 36.2];
        puv.scale_color = 'red';
        puv.scale_text = '0.5 m s^-^1'; puv.scale_text_Loc = [137, 35.7];
        puv.scale_text_color = 'k'; puv.scale_text_fontsize = 10;
        
end
end