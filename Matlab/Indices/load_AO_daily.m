function vari = load_AO_daily(timenum_target)

filepath = '/data/jungjih/Indices/AO/';

filename = 'norm.daily.ao.index.b500101.current.ascii';
file = [filepath, filename];
data = importdata(file);
yyyy = data(:,1);
mm = data(:,2);
dd = data(:,3);
timenum = datenum(yyyy,mm,dd);
AO = data(:,4);

vari = NaN(length(timenum_target),1);
index = find(ismember(timenum,timenum_target)==1);
vari(1:length(timenum_target)) = AO(index);

disp(['Loading AO'])

end