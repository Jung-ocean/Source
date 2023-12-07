clear; clc

yyyy = 2019; ystr = num2str(yyyy);
line = '04_TSB';

filepath = ['D:\Data\Ocean\ADCP\국립해양조사원_남해_해류조사_자료\', ystr, '\'];

filelist = dir([filepath, '*', line, '*']);

for i = 1:length(filelist)
    
    file = [filepath ,filelist(i).name];
    data = read_ADCP_function(file);
    
    yyyy = table2array(data(:,1));
    mm = table2array(data(:,2));
    dd = table2array(data(:,3));
    HH = table2array(data(:,4));
    MM = table2array(data(:,5));
    SS = table2array(data(:,6));

    lat = table2array(data(:,7));
    lon = table2array(data(:,8));
    
    for j = 1:length(yyyy)
        uchar = char(table2array(data(j,9)));
        vchar = char(table2array(data(j,10)));
        
        if strcmp(uchar, 'NaN')
            uvel(i,j) = NaN;
            vvel(i,j) = NaN;
        else
            uvel(i,j) = str2num(uchar);
            vvel(i,j) = str2num(vchar);
        end
        
        y(j) = lat(j);
    end
    
    try
        depth(i) = str2num(file(end-8:end-6));
    catch
        depth(i) = str2num(file(end-7:end-6));
    end
    
end

%uvel(abs(uvel) > 50) = NaN;

figure; 
pcolor(y, -depth, uvel)
xlabel('Depth (m)')
ylabel('Latitude (^oN)')
shading interp
colormap('redblue2')
c = colorbar;
c.Title.String = 'cm/s';
caxis([-50 50])
set(gca ,'FontSize', 15)

saveas(gcf, [line, '_', ystr, '.png'])
