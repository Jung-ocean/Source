function vari = load_ALBSA(timenum_target, interval)

filepath = '/data/jungjih/Indices/ALBSA/';
switch interval
    case 'daily'
        filename = 'albsa.day.csv';
        file = [filepath, filename];
        data = readtable(file);
        yyyy = table2array(data(:,1));
        mm = table2array(data(:,2));
        dd = table2array(data(:,3));
        timenum = datenum(yyyy,mm,dd);
        ALBSA = table2array(data(:,4));
    case 'monthly'
        filename = 'albsa.ncepr1.csv';
        file = [filepath, filename];
        data = readtable(file);
        timenum = datenum(table2array(data(:,1)));
        ALBSA = table2array(data(:,2));
        timevec_target = datevec(timenum_target);
        timevec_target(:,3) = 1;
        timenum_target = datenum(timevec_target);
end

vari = NaN(length(timenum_target),1);
index = find(ismember(timenum,timenum_target)==1);
vari(1:length(timenum_target)) = ALBSA(index);

disp(['Loading ALBSA'])

end