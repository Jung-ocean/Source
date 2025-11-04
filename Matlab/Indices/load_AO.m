function vari = load_AO(yyyy_target, mm_all)

filepath = '/data/jungjih/Indices/AO/';

filename = 'monthly.ao.index.b50.current.ascii.table';
file = [filepath, filename];
data = importdata(file);
data = data.data;
yyyy = data(:,1);
AO = data(:,2:end);

index = find(yyyy == yyyy_target);
vari = AO(index,mm_all);

disp(['Loading AO'])

end