dum2=load('coast_sin.dat');
coa_lon=dum2(:,1); coa_lat=dum2(:,2);

lat_lim=[31 39]; lon_lim=[124 133];
figure; 
line_gap=3;
axesm('MapProjection','mercator','MapParallels',[],...
 'MapLatLimit',lat_lim,'MapLonLimit',lon_lim,...
 'MLabelLocation',line_gap,'MLineLocation',line_gap,'FontSize', 15, ...
 'PLabelLocation',line_gap,'PLineLocation',line_gap,'FontSize', 15, ...
 'GColor',.5*[1 1 1],'GLinestyle','-',...
 'MLabelParallel','south'); framem;gridm;mlabel;plabel; 

geoshow(coa_lat, coa_lon,'DisplayType','polygon','facecolor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7]);
axis tight; 
hold on; 
plotm(35,132,'k.','MarkerSize',8);