function [z]=get_z3D_use_zeta(h,zeta,r_or_w,N,Vtransform,Vstretching,theta_s,theta_b,Tcline)

[nx,ny]=size(h);

% s-coord of the section:
if strcmp(r_or_w,'r')
 kgrid=0; % 0 for rho, 1 for W points
 N1=N;
else 
 kgrid=1;
 N1=N+1;
end
column=1;
plt=0;

z=zeros(nx,ny,N1);
for jsect=1:ny
 [z1,sc,Cs]=scoord_new(h,zeta,theta_s,theta_b,Tcline,N,...
                      kgrid,column,jsect,Vtransform,Vstretching,plt);
 z(:,jsect,:)=reshape(z1,[nx 1 N1]);
end
