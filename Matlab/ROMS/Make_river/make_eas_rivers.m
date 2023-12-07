
%
% mean seasoanl cycle of river flow from ChangJiang River
% from 1976 to 1979. station is Datong, China (117.61E, 30.76N).
% The seasonal cyle is silmar to Fig. 5 of 
% (Dai and Trenberth, J. of Hydro., 2002)
%


%  River.flag can have any of the following values:
%             = 0,  All Tracer source/sink are off.
%             = 1,  Only temperature is on.
%             = 2,  Only salinity is on.
%             = 3,  Both temperature and salinity are on. 


season_cycle=[9650 9257.5 11632.5 21150 32450 41425 ...
	      47300 36925 33025 27000 19350 11215];

avgflow=mean(season_cycle); %25031.7
season_cycle=season_cycle./avgflow;

r = 1;
Name = 'ChangJiang+Huai';
River.Name(r,1:length(Name)) = Name;
River.lon(r) = 120.0;
River.lat(r) = 31.9;
River.flag(r) = 3;
filen='RivDis';
River.file(r,1:length(filen))=filen;
River.area(r)=1794+244;
River.pfact(r)=1;
River.flow_mean(r)=31741.0;
River.trans(r,1:12)=season_cycle.*River.flow_mean(r);

r = 2;
Name = 'HuangHe';
River.Name(r,1:length(Name)) = Name;
River.lon(r) = 118.5;
River.lat(r) = 37.5;
River.flag(r) = 3;
filen='RivDis';
River.file(r,1:length(filen))=filen;
River.area(r)=894;
River.pfact(r)=1;
River.flow_mean(r)=1490.0;
River.trans(r,1:12)=season_cycle.*River.flow_mean(r);

save eas_rivers_discharge River
