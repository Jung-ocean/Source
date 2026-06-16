function [lon, lat, u, v] = load_HFR_bragg_daily(timenum)

    yyyymmdd = datestr(timenum, 'yyyy.mm.dd');
    
    filepath = ['/data/jungjih/RTDAOW2/Data/HFR/'];
    filename = ['Q1W.', yyyymmdd];
    file = [filepath, filename];

    data = load(file);
    lon = data(:,1);
    lat = data(:,2);
    percent = data(:,3);
    u = data(:,4);
    v = data(:,5);

    % Data which have percent coverage larger than 50% will be used
    index = find(percent <= 50);
    if ~isempty(index)
        u(index) = NaN;
        v(index) = NaN;
    end

    disp(['Loading bragg HFR surface currents (cm/s) on ', yyyymmdd])
end
