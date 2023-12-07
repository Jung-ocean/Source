function [status,result] = nco_ncra(Filelists, Outputname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% NCRA using NCO in Windows
% 
% usage: [status, result] = nco_ncra(Filelists, Outputname)
%
% Filelists should have a form of character
% ex) Filelists = [File1.nc
%                  File2.nc
%                     ...
%
% J. JUNG 2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

format = [];
for i = 1:size(Filelists,1)
    len = length(Filelists(i,:));
    format = [format, '%', num2str(len+1), 's'];
    Filelists_space(i,:) = [Filelists(i,:), ' '];
end

Files = sprintf(format, Filelists_space');

[status,result] = ... 
system(['C:\nco\ncra.exe ', Files, ' ', Outputname]); 

if status == 1
    disp(result)
end

return