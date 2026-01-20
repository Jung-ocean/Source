function [p_bc, dz] = calc_p_bc(g, zeta, temp, salt, rhob, depth_rhob)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates baroclinic pressure
%
% zeta        : Sea surface height [lon x lat]
% temp        : Temperature [lon x lat x sigma]
% salt        : Salinity [lon x lat x sigma]
% rhob        : Background density [depth x 1]
% depth_rhob  : Depth levels for background density [depth x 1]
%
% p_bc        : Baroclinic pressure
% dz          : Vertical layer thickness for baroclinic pressure
%
% J. Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gconst = 9.8; % m/s^2

SA = salt;
pt = temp;
CT = gsw_CT_from_pt(SA,pt);
pden = gsw_rho(SA,CT,0);

% will be integrated from -H to eta (not 0)
z = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
z_w = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
dz = z_w(:,:,2:end) - z_w(:,:,1:end-1);

z_vec = z(:); 
rhob_z_vec = interp1(depth_rhob, rhob, z_vec);
rhob_z = reshape(rhob_z_vec, size(z));
rho_prime = pden - rhob_z;

% Pressure perturbation, pb is omitted here
integrand = rho_prime.*gconst;
p = -cumsum(integrand.*dz,3);
% Depth-averaged
pbar = sum(p.*dz,3)./sum(dz,3);
% Baroclinic pressure
p_bc = p-pbar;

end