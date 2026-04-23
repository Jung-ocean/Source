function [rx1,ry1] = rfactor1(z)
%rfactor1 - this function calculates the Haney r-factor, that checks the
% effect of the s-coordinate gradient in x and y and it's potential 
% role in producing pressure gradient errors

dz = diff(z,1,3);
dhk= diff(dz,1,3);
Lp = length(z(:,1,1));
Mp = length(z(1,:,1));
N = length(dz(1,1,:));
rx1k = zeros([Lp-1 Mp N-1]);
ry1k = zeros([Lp Mp-1 N-1]);
for ik=1:N-1
    dhx = abs(diff(dz(:,:,ik+1).*mask_rho,1,1) + ...
        diff(dz(:,:,ik  ).*mask_rho,1,1));
    dhy = abs(diff(dz(:,:,ik+1).*mask_rho,1,2) + ...
        diff(dz(:,:,ik  ).*mask_rho,1,2));
    dhsx = dhk(1:end-1,:,ik)+dhk(2:end,:,ik);
    dhsy = dhk(:,1:end-1,ik)+dhk(:,2:end,ik);
    rx1k(:,:,ik) = dhx./dhsx;
    ry1k(:,:,ik) = dhy./dhsy;
end
rx1 = max(rx1k,[],3).*mask_u;
ry1 = max(ry1k,[],3).*mask_v;


end