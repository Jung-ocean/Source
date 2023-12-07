function [status,result] = nco_ncks_time(File)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Make time record using NCKS in Windows
% 
% usage: [status, result] = nco_ncks_time(Filelists, Outputname)
%
%
% J. JUNG 2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[status,result] = ... 
system(['C:\nco\ncks.exe --mk_rec_dmn time ', File, ' ', File(1:end-3), '_time.nc']); 

return