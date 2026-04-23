function [mask_u,mask_v,mask_psi]=mask_rho_2_uvpsi(mask_rho);

mask_u=0.5*(mask_rho(1:end-1,:)+mask_rho(2:end,:));
mask_u(find(mask_u~=1))=0;

mask_v=0.5*(mask_rho(:,1:end-1)+mask_rho(:,2:end));
mask_v(find(mask_v~=1))=0;

mask_psi=0.25*(mask_rho(1:end-1,1:end-1)+...
               mask_rho(1:end-1,2:end  )+...
               mask_rho(2:end  ,1:end-1)+...
               mask_rho(2:end  ,2:end  ));
mask_psi(find(mask_psi~=1))=0;

