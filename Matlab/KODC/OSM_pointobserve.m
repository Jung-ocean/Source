figure; hold on
dum2=load('coast_sin.dat'); coa_lon=dum2(:,1); coa_lat=dum2(:,2);
geoshow(coa_lat, coa_lon,'DisplayType','polygon','facecolor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7]);
xlabel('Longitude(^oE)', 'fontsize', 15)
ylabel('Latitude(^oN)', 'fontsize', 15)
set(gca, 'fontsize', 15)
ylim([33 37])
xlim([124 130])

plot(126+18/60+31/3600, 34+22/60+40/3600,'.r', 'Markersize', 30) % 진도
plot(126+45/60+35/3600, 34+18/60+56/3600,'.r', 'Markersize', 30) % 완도
plot(127+18/60+32/3600, 34+1/60+42/3600,'.r', 'Markersize', 30) % 거문
plot(128+41/60+57/3600, 34+48/60+5/3600,'.r', 'Markersize', 30) % 거제