function adcirc2frc_v5(gfile,base_date,pred_date,ofile,dname)
%adcirc2frc_v5 Generete ADCIRC tidal forcing file for ROMS
%
%adcirc2frc_v5(gfile,base_date,pred_date,ofile,flag,dname) generates a ROMS tidal
%forcing  ofile using the ROMS gridfile gfile and the tidal
%reference time base_date in matlab time.pred_date is the nodal
%correction date in matlab time, usually equal to base_date. FLAG is a binary switch
%which alls the routine to call tides_ec2001.out, if
%necessary. NOTE: tides_ec2001.out takes a long time to run,
%particularly on a big grid, so its best to only run it once.
%
% %Example:
% gfile='espresso_grid_c05.nc'
% base_date=datenum(2006,1,1);
% pred_date=datenum(2006,1,1);
%
% ofile='tidetest_adcirc.nc';
%
% adcirc2frc_v5(gfile,base_date,pred_date,ofile,1,'ESPRESSO')
% %
%Requirements:
%T_TIDE tidal analysis package
%"tidal_ellipse" (Zhigang Xu) package, ap2ep.m
%Requires tides_ec2001.f to be compiled as tides_ec2001.out
%
%CONVERTED from otps2frc_v3.m  by Eli Hunter 10/18/07
%CONVERTED from adcirc2frc_v1.m  by Eli Hunter 1/10/08 - Changed to
%t_tide from tide_fac.f and added fprintf.  Routine was also changed to changed to use ADCIRC 2001 instead of 95.
%
% REVISED by Eli Hunter 8/2/2011 Added 'nodal', to t_vuf and changed Tide.period
% REVISED by Eli Hunter 6/10/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Create the input file for tides_ec2001
output_tide_in_file = 'tides.in';

lon_rho = ncread(gfile,'lon_rho');
lat_rho = ncread(gfile,'lat_rho');

% afid = fopen ( output_tide_in_file, 'w' );
% %
% % Just write out the number of points, then each point on its own line.
% fprintf ( afid, '%d\n', length(lon_rho) );
% fprintf ( afid, '%.8f %.8f\n', [lon_rho lat_rho]' );
% fclose ( afid );
%
% fprintf ( 'Created %s\n', output_tide_in_file );

disp(['Extracting  Harmonics'])

% IF flag  is set, then call tides_ec2001.out to generate
% interpolated ASCII file tides.out
% if flag
%   disp('Running Program')
%   [status,result] = system('adcirc_extract')
% end

mask_rho = ncread( gfile, 'mask_rho' );
land = find(mask_rho==0);
water = find(mask_rho==1);

% Read tidal constituent data int MATLAB
% fprintf ( 1, 'Reading %s...\n', ' ADCIRC DATA' );
% [z_hc,u_hc,v_hc, lon,lat ] = read_adcirc_output ('tides.out');
%
% %Convert output data to ROMS grid
% [period, z_amp, z_phase, names] = reshape_to_grid ( z_hc, gfile );
% [period, u_amp, u_phase, names] = reshape_to_grid ( u_hc, gfile );
% [period, v_amp, v_phase, names] = reshape_to_grid ( v_hc, gfile );

[z_amp ,z_phase,u_amp, u_phase ,v_amp, v_phase,names,period]=read_adcirc_tdb(lon_rho,lat_rho,mask_rho);


cnames=upper(char(names));
cnames=cnames(:,1:4);
% Make sure that the ADCIRC mask agrees with the ROMS mask.
% Fill in any points that ROMS thinks is water but ADCIRC thinks is land.
num_constituents = length(period);

a=t_getconsts;

for j = 1:num_constituents
    
    component = squeeze ( z_amp(j,:,: ) );
    z_amp(j,:,:) = match_roms_mask ( lon_rho, lat_rho, mask_rho, component );
    
    component = squeeze ( z_phase(j,:,: ) );
    z_phase(j,:,:) = match_roms_mask ( lon_rho, lat_rho, mask_rho, component );
    
    component = squeeze ( u_amp(j,:,: ) );
    u_amp(j,:,:) = match_roms_mask ( lon_rho, lat_rho, mask_rho, component );
    
    component = squeeze ( u_phase(j,:,: ) );
    u_phase(j,:,:) = match_roms_mask ( lon_rho, lat_rho, mask_rho, component );
    
    component = squeeze ( v_amp(j,:,: ) );
    v_amp(j,:,:) = match_roms_mask ( lon_rho, lat_rho, mask_rho, component );
    
    component = squeeze ( v_phase(j,:,: ) );
    v_phase(j,:,:) = match_roms_mask ( lon_rho, lat_rho, mask_rho, component );

    iconst(j)=strmatch(deblank(cnames(j,:)), a.name)
    
    Tide.period(j)=1/a.freq(iconst(j));
end


Tide.names = cnames;
Ntide = length(period);
[Lp,Mp] = size(lon_rho);


%***********************************************************************
% This is the call to t_vuf that
% will correct the phase to be at the user specified time.  Also, the amplitude
% is corrected for nodal adjustment.

% Reference latitude for 3rd order satellites (degrees) is
% set to 55.  You don't need to adjust this to your local latitude
% It could also be set to NaN as in Xtide, with very little effect.
% See T_VUF for more info.

reflat=55
[V,U,F]=t_vuf('nodal',base_date,iconst,reflat);
[Vp,Up,Fp]=t_vuf('nodal',pred_date,iconst,reflat);%Only used for nodal
%correction.

%vv and uu are returned in cycles, so * by 360 to get degrees or * by 2 pi to get radians
V=V*360;  % convert vv to phase in degrees
U=U*360;  % convert uu to phase in degrees
Vp=Vp*360;  % convert vv to phase in degrees
Up=Up*360;  % convert uu to phase in degrees
%
%This code is available if needed
%***********************************************************************



for k=1:Ntide;
    Fp(k)
    z_phase(k,:,:) = z_phase(k,:,:)- Up(k)-V(k);   % degrees
    z_amp(k,:,:) =z_amp(k,:,:) .* Fp(k);
    
    u_phase(k,:,:) =u_phase(k,:,:) - Up(k)-V(k);   % degrees
    u_amp(k,:,:) = u_amp(k,:,:) .* Fp(k);
    
    v_phase(k,:,:) = v_phase(k,:,:) - Up(k)-V(k);   % degrees
    v_amp(k,:,:) =v_amp(k,:,:) .* Fp(k);
    
end

z_phase=mod(z_phase,360);
u_phase=mod(u_phase,360);
v_phase=mod(v_phase,360);

z_amp = zero_out_land ( z_amp, land );
z_phase = zero_out_land ( z_phase, land );


Tide.Ephase    = z_phase(:,:,:);
Tide.Eamp      = z_amp(:,:,:);



%---------------------------------------------------------------------
%  Convert tidal current amplitude and phase lag parameters to tidal
%  current ellipse parameters: Major axis, ellipticity, inclination,
%  and phase.  Use "tidal_ellipse" (Zhigang Xu) package.
%---------------------------------------------------------------------
[major,eccentricity,inclination,phase]=ap2ep(u_amp,u_phase,v_amp,v_phase);

major = zero_out_land ( major, land );
eccentricity = zero_out_land ( eccentricity, land );
major = major;
Tide.Cmax=major;
Tide.Cmin=major.*eccentricity;
Tide.Cangle= zero_out_land ( inclination, land );
Tide.Cphase = zero_out_land ( phase, land );


write_roms_adcirc_ncfile_v2( Tide, gfile, ofile,base_date,dname);
