function [target_lon, target_lat] = read_point_2017(pointcase)

switch pointcase
    case '2017'
        target_lon = [131.5525, 130.6011, 129.1214, 128.4189, 126.9603, ...
            126.4922, 126.9658, 125.8003, 126.1942, 126.2703];
        target_lat = [38.0072, 37.7428, 34.9189, 34.2225, 34.2586, ...
            33.9117, 32.0903, 34.5442, 35.6525, 37.0067];
        
    case '2017_noTaean'
        target_lon = [131.5525, 130.6011, 129.1214, 128.4189, 126.9603, ...
            126.4922, 126.9658, 125.8003, 126.1942];
        target_lat = [38.0072, 37.7428, 34.9189, 34.2225, 34.2586, ...
            33.9117, 32.0903, 34.5442, 35.6525];
        
    case '2017_5'
        target_lon = [131.5525, 130.6011, 129.1214, 128.4189, 126.9603, ...
            126.4922, 126.9658, 125.8003, 126.1942, 126.5331];
        target_lat = [38.0072, 37.7428, 34.9189, 34.2225, 34.2586, ...
            33.9117, 32.0903, 34.5442, 35.6525, 37.3894];
end