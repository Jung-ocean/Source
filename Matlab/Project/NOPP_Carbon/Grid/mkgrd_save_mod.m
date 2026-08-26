set(htoggle, 'Value',0);
set(hmaskreg,'Value',0);

[mask_u,mask_v,mask_psi]=mask_rho_2_uvpsi(mask_rho1);

% OUTPUT:
ncwrite(outfile,'mask_rho',mask_rho1);
ncwrite(outfile,'mask_u',mask_u);
ncwrite(outfile,'mask_v',mask_v);
ncwrite(outfile,'mask_psi',mask_psi);
