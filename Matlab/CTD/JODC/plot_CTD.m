clear;

readtable('175W-180W60N-65N.odv.txt')

Cruise = W180W60N65N(:,1);
station	= W180W60N65N(:,2);
Type = W180W60N65N(:,3);
yyyymmdd = W180W60N65N(:,4);
HHMM = W180W60N65N(:,5);
lon = W180W60N65N(:,6);
lat = W180W60N65N(:,7);
h = W180W60N65N(:,8);
depth = W180W60N65N(:,9);
temp = W180W60N65N(:,13);
salt = W180W60N65N(:,15);

station = table2array(station);
lon = table2array(lon);
lat = table2array(lat);

salt = table2array(salt);
temp = table2array(temp);
depth = table2array(depth);

yyyymmdd = table2array(yyyymmdd);
timenum = datenum(yyyymmdd);
timevec = datevec(timenum);

yyyy_all = 1988:1989;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy, '%04i');
    
    index = find(timevec(:,1) == yyyy);
    timevec(index,:)

    figure; hold on;
    plot_map('Gulf_of_Anadyr', 'mercator', 'l')
    plotm(lat(index), lon(index), '.r');
    title(ystr)
end


yyyy = 1992;
index = find(timevec(:,1) == yyyy);
sta = station(index);
sta_unique = unique(sta);

figure; hold on; grid on;
for si = 1:length(sta_unique)
    sindex = find(find(timevec(:,1) == yyyy) & sta == sta_unique(si))

    plot(salt(sindex), -depth(sindex))
end