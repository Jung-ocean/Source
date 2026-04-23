%while htoggle==1

set(hmaskreg,'Value',0);

while get(htoggle,'Value')==1
 [lon0,lat0,button] = ginput(1);

% make sure the mouse click is in the visible frame
% if it is not cancel the mask-toggle operation.
 lon_lims=get(ha,'xlim');
 lat_lims=get(ha,'ylim');
 if (button==1 & lon0>lon_lims(1) & lon0<lon_lims(2) & lat0>lat_lims(1) ...
               & lat0<lat_lims(2)) 

% SD need a more precise method for finding the index of the point we are picking
% if the grid is curvilinear at all.
% calculate the 'distance' between the point and each grid point
  for ii=1:length(lon_rho(:,1))
     dist(ii,:)= (lon0-lon_rho(ii,:)).^2+(lat0-lat_rho(ii,:)).^2;
  end
% and find the one it's closest to...
  [i0,i1]=find(dist==min(min(dist)));

%  [tmp,i0]=min(abs(lon_rho(:,1)-lon0));
%  [tmp,i1]=min(abs(lat_rho(1,:)-lat0));

  if mask_rho1(i0,i1)==0
   mask_rho1(i0,i1)=1;
   ln='bs';
  else
   mask_rho1(i0,i1)=0;
   ln='gs';
  end

  pln=plot(lon_rho(i0,i1),lat_rho(i0,i1),ln,'markersize',mrksize);
 else
  set(htoggle,'Value',0);
 end
end
