function vari = load_SIE(yyyy_target, Mar_or_Sep)

filepath = '/data/jungjih/Indices/SIE/';
filename = 'Meier_SeaIceMonthlyExtentTrends_1979-2025_v1_Final.csv';
file = [filepath, filename];

data = importdata(file);
data = data.data;
yyyy = data(:,1);
index = find(yyyy == yyyy_target);
if strcmp(Mar_or_Sep, 'Mar')
    vari = data(index,2);
elseif strcmp(Mar_or_Sep, 'Sep')
    vari = data(index,3);
else
    vari = NaN;
end

disp(['Loading SIE'])

end