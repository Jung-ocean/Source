clc; clear all; close all;

u = [0 1]; v = [1 1]; % southwestern
spd = sqrt(u.^2 + v.^2);

dir_to_trig_to = atan2(u./spd,v./spd);
dir = dir_to_trig_to * (180/pi) + 180;

mean_dir = mean(dir); 
mean_spd = mean(spd);

 WindRose(dir,spd,'AngleNorth',0,'AngleEast',90, ...
            'vwinds',[0 2 4 6 7 8 10],'TitleString',{'Wonsan'},...
            'FreqRound',2,'FreqLabelAngle',45);