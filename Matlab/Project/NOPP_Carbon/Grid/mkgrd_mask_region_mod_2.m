
while get(hmaskreg,'Value')==1
% SD modified from mask_region_mod, to grab an arbitrary region rather than
% a rectangle.  Double click to end selection.
  %[xpts,ypts] = getpts(hf);
  %polygon_x=[xpts; xpts(1)];
  %polygon_y=[ypts; ypts(1)];
  P = drawpolygon('Color','r');

  polygon_x = [P.Position(:,1); P.Position(1,1)];
  polygon_y = [P.Position(:,2); P.Position(1,2)];
  
% make sure the mouse click is in the visible frame
% if it is not cancel the mask-toggle operation.
 lon_lims=get(ha,'xlim');
 lat_lims=get(ha,'ylim');

 axis_box_x=[lon_lims(1) lon_lims(2) lon_lims(2) lon_lims(1) lon_lims(1)];
 axis_box_y=[lat_lims(1) lat_lims(1) lat_lims(2) lat_lims(2) lat_lims(1)];
 
 if inpolygon(P.Position(:,1),P.Position(:,2),axis_box_x,axis_box_y) 
  mask_pts=inpolygon(lon_rho,lat_rho,polygon_x,polygon_y);
  intmp=find(mask_pts==1);
%  in=findin(lon_rho(:,1),[coor(1) coor(1)+coor(3)]);
%  jn=findin(lat_rho(1,:),[coor(2) coor(2)+coor(4)]);
  mask_rho1(intmp)=0;
  delete(P);
  pln=plot(lon_rho(intmp),lat_rho(intmp),'gs','markersize',mrksize);
  set(hmaskreg,'Value',0);
 else
  fprintf('Mask Region cancelled /n')  
  delete(P);
  set(hmaskreg,'Value',0); 
 end
end