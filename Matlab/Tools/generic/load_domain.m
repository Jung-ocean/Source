function [lon, lat] = load_domain(casename)

switch casename
    case 'US_west'
        lon = [-129.9873 -122.1182]; lat = [40.6590 49.9874];
    case 'US_west_HFR'
        lon = [-127 -123]; lat = [43 47];
    case 'WCOFS'
        lon = [-147.5 -110]; lat = [17.5 57.5];
    case 'Bering_Arctic'
        lon = [-185 -155]; lat = [45 85];
    case 'Bering'
        lon = [-205.9832 -156.8640]; lat = [49.1090 66.3040];
    case 'NW_Bering'
        lon = [-200 -175]; lat = [57 66.3040];
    case 'Eastern_Bering'
        lon = [-185 -156.8640]; lat = [49.1090 66.3040];
    case 'Trawl'
        lon = [-180 -156.8640]; lat = [54 66.3040];
    case 'Bristol_Bay'
        lon = [-165 -156.8640]; lat = [57 61];
    case 'North_Kamchatka'
        lon = [168 180]; lat = [58 63];
    case 'Gulf_of_Anadyr'
        lon = [-185 -170]; lat = [60 66.3040];
    case 'Gulf_of_Anadyr_large'
        lon = [-187.5 -167.5]; lat = [58 66.3040];
    case 'Gulf_of_Anadyr_west'
        lon = [-190 -170]; lat = [60 66.3040];
    case 'NE_Pacific'
        lon = [-210 -110]; lat = [25 67];
    case 'Felicio'
        lon = [-185 -157]; lat = [49.5 66.5];
end

end % function load_domain