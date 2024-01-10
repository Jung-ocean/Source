function [lon, lat] = river_mouth_point(river)

switch river
    case 'Anadyr'
        location = [64.8, 176.4];
    case 'Yukon'
        location = [63.0, 195.5];
    case 'Kamchatka'
        location = [56.2, 162.5];
    case 'Kuskokwim'
        location = [60.3, 197.7];
    case 'Nushagak'
        location = [59, 201.5];
    case 'Kvichak'
        location = [58.8 203];
end

lon = location(2);
lat = location(1);

end