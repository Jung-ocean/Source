clear; clc; warning('off')

Year = 2016;
Zippath = ['D:\Data\Ocean\KODC\준실시간 한국근해 해양관측자료 서비스\', num2char(Year,4),  '\'];
Ziplist = dir(fullfile(Zippath,'*.zip'));

Data_all = [];

disp(' '); disp(['Reading Position Data ...']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Posit, Lat, Lon] = textread('NSOposition.txt','%s %f %f','headerlines',1);
A = [Posit{:}];
for i = 1:length(Posit)
   position(i) = str2num([A(6*i-5:6*i-3),A(6*i-1:6*i)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(Ziplist)
    disp(' '); disp(['Unzipping ', Ziplist(i).name, ' ...']);
    unzip([Zippath, Ziplist(i).name],'temp')
    disp(' '); disp(['End Unzipping ', Ziplist(i).name, ' ...']);
    fpath = '.\temp\';
    
    flist = dir(fullfile(fpath, '*_d.txt'));
    if isempty(flist)
        flist = dir(fullfile(fpath, '*_*.txt'));
    end

disp(' '); disp(['Reading Date Data ...']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fileID = fopen([fpath, 'ObservationTimeKST.txt']);
    formatSpec = '%s';
    N = 8; C_text = textscan(fileID,formatSpec,N,'Delimiter',' ');
    
    stdata = [];
    while ~feof(fileID)
        N = 13; C_value = textscan(fileID,formatSpec,N,'Delimiter',' ');
        strdata = C_value{:};
        
        if ~isempty(strdata)
            ST = cell2mat(strdata(3));
            YYYY = cell2mat(strdata(7));
            MMM = cell2mat(strdata(9));
            DD = cell2mat(strdata(11));
            
            stdata = [stdata; str2num(ST), datenum([YYYY,MMM,DD],'yyyymmmdd')];
        end
    end
    fclose(fileID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            

disp(' '); disp(['Data Processing ...']);
    for ii = 1:length(flist)
        
        fname = flist(ii).name;
        if length(fname) >= 19
            stname = str2num(fname(end-10:end-6));
        else
            stname = str2num(fname(end-8:end-4));
        end    
        
        [Depth, Temp, Salinity] = textread([fpath, fname]);
        
        Posit_all = []; ftime_all = []; Lat_all = []; Lon_all = [];
        for iii = 1:length(Depth)
            Posit_all = [Posit_all; stname];
            Posit_ind = find(stname == position);
            Lat_all = [Lat_all; Lat(Posit_ind)];
            Lon_all = [Lon_all; Lon(Posit_ind)];
            Posit_ind2 = find(stname == stdata(:,1));
            ftime_all = [ftime_all; str2num(datestr(stdata(Posit_ind2(1),2),'yyyymmdd'))];
        end
        
        Data_all = [Data_all; Posit_all ftime_all Lon_all Lat_all Depth Temp, Salinity];
    end
    disp(' '); disp(['End Data Processing ...']);
    delete('.\temp\*')
end

fid = fopen(['KODC', num2char(Year,4), '.txt'],'w');
fprintf(fid,'%s', '% ST  yyyymmdd    LON         LAT    DEP  Temp       Salt ');
fprintf(fid,'\n');
 for j = 1:length(Data_all)
     fprintf(fid, '%d %d %10f %10f %3d %10f %10f',Data_all(j,:));
     fprintf(fid,'\n');
 end
 fclose(fid);