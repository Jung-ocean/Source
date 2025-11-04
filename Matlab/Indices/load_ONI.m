function vari = load_ONI(timenum)

filepath = '/data/jungjih/Indices/ONI/';
filename = 'oni.ascii.txt';
file = [filepath, filename];

data = readtable(file);

season = table2array(data(:,1));
yyyy = table2array(data(:,2));
ONI = table2array(data(:,4));

timevec = datevec(timenum);
yyyy_unique = unique(timevec(:,1));

vari = NaN(length(timenum),1);
for yi = 1:length(yyyy_unique)
    yyyy_tmp = yyyy_unique(yi);
    ONI_tmp = ONI(yyyy == yyyy_tmp);

    index = find(timevec(:,1) == yyyy_tmp);
    mm_tmp = timevec(index,2);
    vari(index) = ONI_tmp(mm_tmp);
end

disp(['Loading ONI'])

end