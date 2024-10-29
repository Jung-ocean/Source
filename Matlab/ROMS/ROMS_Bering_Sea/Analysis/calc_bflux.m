function trans = calc_bflux(uice, vice, hice, dx, dy, mask_ave, mask_rho, pdirection)

[xi_rho,eta_rho]=size(mask_ave);

dxdy = dx.*dy;
dy_u = rho2u_2d(dy')';
dx_v = rho2v_2d(dx')';

hice_u = rho2u_2d(hice')';
hice_v = rho2v_2d(hice')';

index = find(mask_rho == 1 &  mask_ave == 1);
mask_out = 2*ones(xi_rho,eta_rho);
mask_out(mask_rho == 0) = 0;
mask_out(index) = 1;

transA = 0;
for ii=2:xi_rho-1
    for jj=2:eta_rho-1

        rho = mask_out(ii,jj);
        N = mask_out(ii,jj+1);
        E = mask_out(ii+1,jj);
        W = mask_out(ii-1,jj);
        S = mask_out(ii,jj-1);

        if rho == 1
            if N == 2 | E == 2 | W == 2 | S == 2
                uwest = dxdy(ii,jj).*dy_u(ii-1,jj).*uice(ii-1,jj).*hice_u(ii-1,jj);
                ueast = dxdy(ii,jj).*dy_u(ii+1,jj).*uice(ii+1,jj).*hice_u(ii+1,jj);

                vsouth = dxdy(ii,jj).*dx_v(ii,jj-1).*vice(ii,jj-1).*hice_v(ii,jj-1);
                vnorth = dxdy(ii,jj).*dx_v(ii,jj+1).*vice(ii,jj+1).*hice_v(ii,jj+1);

                if N == 2
                    transA = transA + pdirection(2)*vnorth;
                end
                if E == 2
                    transA = transA + pdirection(1)*ueast;
                end
                if W == 2
                    transA = transA + pdirection(1)*uwest;
                end
                if S == 2
                    transA = transA + pdirection(2)*vsouth;
                end

            end
        end
    end
end

dxdy(mask_ave == 0) = 0;
A=sum(dxdy,'all');

trans = transA./A;

end