function [lon, lat, u, v] = load_HFR_monthly(yyyy,mm)

    ystr = num2str(yyyy);
    mstr = num2str(mm, '%02i');
    
    filepath = ['/data/jungjih/Observations/Surface_current/HFR/monthly/'];
    filename = ['HFR_monthly_', ystr, mstr, '.nc'];
    file = [filepath, filename];

    lon = double(ncread(file, 'lon'));
    lat = double(ncread(file, 'lat'));
    u = ncread(file, 'u_mean')*100;
    v = ncread(file, 'v_mean')*100;
    n_obs = ncread(file, 'n_obs');

    % Data which have percent coverage larger than ~50% (13/25) will be used
    index = find(n_obs < 13);
    if ~isempty(index)
        u(index) = NaN;
        v(index) = NaN;
    end

    disp(['Loading HFR surface currents (cm/s) in ', ystr, mstr])
end
