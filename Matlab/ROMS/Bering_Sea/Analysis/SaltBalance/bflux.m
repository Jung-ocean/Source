function [Bflux]=bflux(Fu,Fv,mask_u,mask_v,mask_ave)

% Volume flux outside the area defined by mask_ave
% Fu, Fv are three dim arrays (m3 / s) such as Huon, Hvom
% (can be used for temp flux computation as well)

[xi_rho,eta_rho]=size(mask_ave);

FU=sum(Fu,3);
FV=sum(Fv,3);
% FU(mask_u==0)=0;
% FV(mask_v==0)=0;
divU=nan*zeros(xi_rho,eta_rho);
ii=2:xi_rho-1;
jj=2:eta_rho-1;
divU(ii,jj)=FU(ii,jj)-FU(ii-1,jj)+FV(ii,jj)-FV(ii,jj-1);
divU(mask_ave==0)=0;
Bflux=sum(sum(divU)); % volume flux outside the ave area, m3/s
  