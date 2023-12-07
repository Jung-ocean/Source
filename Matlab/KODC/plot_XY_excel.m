clear; clc; close all

g = grd('EYECS_20190904');
mlon = g.lon_rho;
mlat = g.lat_rho;
modelfile = 'G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\2013\monthly_201308.nc';
nc = netcdf(modelfile);
mtemp_surf = nc{'temp'}(1,40,:,:);
close(nc)

year_all = [2013:2013];
casename = 'southern';
month_all = [8];
depth_all = [0];

line_all = [204 205 400 206];

fpath = 'D:\Data\Ocean\KODC\excel\';
figpath = 'D:\Data\Ocean\KODC\KODC_';
titletype = [''];

for yi = 1:length(year_all)
    year = year_all(yi); ystr = num2str(year);
    fname = [fpath, 'KODC_', ystr, '.xls'];
    
    [num, raw, txt] = xlsread(fname);
    
    obsline = txt(3:end,2); obspoint = txt(3:end,3);
    lat = txt(3:end, 5); lon = txt(3:end, 6);
    date = datenum(txt(3:end, 7));
    dep = txt(3:end, 8);
    temp = txt(3:end, 9);
    salt = txt(3:end, 11);
    
    data_cell = [obsline obspoint lat lon dep temp salt];
    datasize = size(data_cell);
    
    clearvars data
    for i = 1:datasize(1)
        for j = 1:datasize(2)
            if isempty(cell2mat(data_cell(i,j))) == 1
                data(i,j) = NaN;
            else
                data(i,j) = str2num(cell2mat(data_cell(i,j)));
            end
        end
    end
    
    data_all = [datevec(date) data];
    
    for mi = 1:length(month_all)
        month = month_all(mi); mstr = num2char(month,2);
        
        mindex = find(data_all(:,2) == month);
        data_m = data_all(mindex,:);
        
        for di = 1:length(depth_all)
            depth = depth_all(di);
            if depth > 99; charnum = 3; else; charnum = 2; end
            dstr = num2char(depth, charnum);
            
            dindex = find(data_m(:,11) == depth);
            data_md = data_m(dindex,:);
            
            nanind = find(isnan(mean(data_md,2)) == 1);
            data_md(nanind,:) = [];
            
            mtemp = [];
            otemp = [];
            for li = 1:length(line_all)
                line = line_all(li);
                lindex = find(data_md(:,7) == line);
                for pi = 1:length(lindex)
                    lon = data_md(lindex(pi), 10);
                    lat = data_md(lindex(pi), 9);
                    temp = data_md(lindex(pi), 12);
                    
                    londist = (mlon - lon).^2;
                    latdist = (mlat - lat).^2;
                    dist = sqrt(londist + latdist);
                    
                    index = find(dist == min(min(dist)));
                    mtemp = [mtemp; mtemp_surf(index)];
                    otemp = [otemp; temp];
                end
            end
        end
    end
end

figure; hold on; grid on
plot(mtemp, otemp, '.', 'MarkerSize', 30)
plot([0:100], [0:100], '-k')
xlim([24 30])
ylim([24 30])

ylabel('Obs. temperature');
xlabel('Model temperature');

set(gca, 'FontSize', 15)