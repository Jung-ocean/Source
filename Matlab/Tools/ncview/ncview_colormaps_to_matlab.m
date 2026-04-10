% This is a script to convert ncview colormaps to matlab colormaps.

cmfile.dir = '/home/server/pi/homes/jungjih/Source/Matlab/Tools/ncview/';
cmfile.postfixes = {'3gauss' '3saw' 'banded' 'blue_red' 'blu_red' 'bright' ...
                 'bw' 'default' 'detail' 'extrema' 'helix2' 'helix' ...
                 'hotres' 'jaisn2' 'jaisnb' 'jaisnc' 'jaisnd' 'jaison' ...
                 'jet' 'manga' 'rainbow' 'roullet' 'ssec' 'wheel'};
num_header_lines=[24 24 1 1 1 1 ...
                  24 24 24 24 24 24 ...
                  24 1 1 1 1 1 ...
                  1 1 1 1 24 1];


for ic = 1:length(cmfile.postfixes)
    cmfile.name = sprintf('%s/colormaps_%s.h',cmfile.dir, cmfile.postfixes{ic});
    fileid = fopen(cmfile.name,'r');
    C = textscan(fileid,'%d %d %d','delimiter',',','HeaderLines',num_header_lines(ic))
     
    for ik = 1:length(C{1})
       eval(sprintf(['cm_%s(ik,:) = [double(C{1}(ik)) double(C{2}(ik)) double(C{3}(ik))]./255;'],cmfile.postfixes{ic}));
    end
end

save ncview_colormaps cm*