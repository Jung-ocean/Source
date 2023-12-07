function barot_prsgrd = ROMS_calc_barot(filename, direction)

nc = netcdf(filename);
zeta = nc{'zeta'}(:);
pm = nc{'pm'}(:);
pn = nc{'pn'}(:);

g = 10; % m/s^2

if strcmp(direction, 'u')
    
    dzeta = diff(zeta,1,2);
    dx = 1./pm;
    [ufield,vfield,pfield]=rho2uvp(dx);
    barot_prsgrd = -g*dzeta./ufield;
    
elseif strcmp(direction, 'v')
    
    dzeta = diff(zeta);
    dy = 1./pn;
    [ufield,vfield,pfield]=rho2uvp(dy);
    barot_prsgrd = -g*dzeta./vfield;
    
end