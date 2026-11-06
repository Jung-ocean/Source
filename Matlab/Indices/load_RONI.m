function vari = load_RONI(timenum)

filepath = '/data/jungjih/Indices/RONI/';
filename = 'RONI.ascii.txt';
file = [filepath, filename];

data = readtable(file);

season = table2array(data(:,1));
yyyy = table2array(data(:,2));
RONI = table2array(data(:,3));

timevec = datevec(timenum);
yyyy_unique = unique(timevec(:,1));

vari = NaN(length(timenum),1);
for yi = 1:length(yyyy_unique)
    yyyy_tmp = yyyy_unique(yi);
    RONI_tmp = RONI(yyyy == yyyy_tmp);

    index = find(timevec(:,1) == yyyy_tmp);
    mm_tmp = timevec(index,2);
    vari(index) = RONI_tmp(mm_tmp);
end

disp(['Loading RONI'])

end