function [status,result] = unzip7(file, outdir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Uncompress compressed file using 7zip
% 
% usage: [status, result] = unzip(File, Outputdir)
%
% J. JUNG 2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    outdir = '.';
end

[status,result] = ... 
    system(['"D:\Program Files\7-Zip\7z.exe" -y x ' '"' file '"' ' -o' '"' outdir '"']); 

return