function [timenum_all, vari_all] = load_SSS_sat_1d(sat, version, datenum_start, datenum_end, lat_target, lon_target)

timenum_all = [];
vari_all = [];
for di = datenum_start:datenum_end
    datenum_target = di;
    timenum_all = [timenum_all; datenum_target];
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_daily(sat, version, datenum_target);

    if isscalar(vari_sat)
        vari_all = [vari_all; NaN];
    else
        if strcmp(sat, 'SMOS_BEC')
            lat_sat2 = lat_sat;
            lon_sat2 = lon_sat;
            if ~exist('F')
                F = scatteredInterpolant(lat_sat2(:), lon_sat2(:), 0.*lat_sat2(:));
            end
            F.Values = vari_sat(:);
        else
            if ~exist('F')
                [lat_sat2, lon_sat2] = meshgrid(lat_sat, lon_sat);
                F = griddedInterpolant(lat_sat2', lon_sat2', 0.*lat_sat2');
            end
            F.Values = vari_sat';
        end

        vari_tmp = F(lat_target, lon_target);
        vari_all = [vari_all; vari_tmp];
    end

end