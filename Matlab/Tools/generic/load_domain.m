function [lon, lat] = load_domain(casename)

switch casename
    case 'US_west'
        lon = [-140 -110]; lat = [28 55];
    case 'Bering_Arctic'
        lon = [-185 -155]; lat = [45 85];
    case 'Bering'
        lon = [-205.9832 -156.8640]; lat = [49.1090 66.3040];
    case 'Eastern_Bering'
        lon = [-185 -156.8640]; lat = [49.1090 66.3040];
    case 'Bristol_Bay'
        lon = [-165 -156.8640]; lat = [57 61];
end

end % function load_domain