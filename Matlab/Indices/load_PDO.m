function vari = load_PDO(yyyy_target, mm_all)

filepath = '/data/jungjih/Indices/PDO/';

filename = 'ersst.v5.pdo.dat';
file = [filepath, filename];
data = importdata(file);
data = data.data;
yyyy = data(:,1);
PDO = data(:,2:end);

index = find(yyyy == yyyy_target);
vari = PDO(index,mm_all);

disp(['Loading PDO'])

end