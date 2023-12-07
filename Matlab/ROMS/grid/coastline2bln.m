 clear all; close all; clc
 
 filename = 'coast_sin.dat';
 
[xx, yy] = textread(['D:\Data\Ocean\Coast_line\', filename],'%f %f');
index = find(isnan(xx) == 1);

npoint = diff(index)-1;

xx(index(1:end-1)) = npoint;
yy(index(1:end-1)) = 0;

if isnan(xx(end)) == 1
    xx(end) = [];
    yy(end) = [];
end

base=[xx yy];

savefile = [filename(1:end-4), '.bln'];
fid=fopen(savefile,'w');
fprintf(fid,'%13.9f %13.9f\r\n',base');
fclose(fid);