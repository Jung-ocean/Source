function [timenum, vari] = load_NDBC(station, vari_str, yyyy_target)

ystr = num2str(yyyy_target);

filepath = ['/data/jungjih/Observations/NDBC/', station, '/'];
filename = [lower(station), 'h', ystr, '.txt'];
file = [filepath, filename];

data = readtable(file);
varnames = data.Properties.VariableNames;

yyyy = table2array(data(:,1));
mm = table2array(data(:,2));
dd = table2array(data(:,3));
HH = table2array(data(:,4));
MM = table2array(data(:,5));
timenum = datenum(yyyy,mm,dd,HH,MM,0);

switch vari_str
    case 'wind'
        wdirind = find(contains(varnames, 'WDIR') == 1);
        wdir = table2array(data(:,wdirind)); % the direction the wind is coming from in degrees clockwise from true N
        wspdind = find(contains(varnames, 'WSPD') == 1);
        wspd = table2array(data(:,wspdind)); % m/s
        
        theta = deg2rad(wdir);
        uwind = -wspd.*sin(theta); % eastward positive
        vwind = -wspd.*cos(theta); % northward positive
        vari.uwind = uwind;
        vari.vwind = vwind;
    case 'airT'
        index = find(contains(varnames, 'ATMP') == 1);
        vari = table2array(data(:,index));
end

end