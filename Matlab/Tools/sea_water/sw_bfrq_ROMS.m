
function [n2,q,p_ave] = sw_bfrq_ROMS(S,T,P,LAT)

% SW_BFRQ    Brunt-Vaisala Frequency Squared (N^2)
%===========================================================================
% SW_BFRQ  $Id: sw_bfrq.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $
%          Copyright (C) CSIRO, Phil Morgan  1993.
%
% USAGE:  [bfrq,vort,p_ave] = sw_bfrq(S,T,P,{LAT})
%
% DESCRIPTION:
%    Calculates Brunt-Vaisala Frequency squared (N^2) at the mid depths
%    from the equation,
%
%               -g      d(pdens)
%         N2 =  ----- x --------
%               pdens     d(z)
%
% This code also returns Potential Vorticity from q = f*N2/g.  The potential
% densities that are differenced to form d(pdens) are potential density
% values referenced to the mid-point pressures.  
%
% INPUT:  (all must have same dimensions MxN)
%   S   = salinity    [psu      (PSS-78) ]
%   T   = temperature [degree C (ITS-90)]
%   P   = pressure    [db]
%
%   OPTIONAL:
%      LAT     = Latitude in decimal degrees north [-90..+90]
%                May have dimensions 1x1 or 1xN where S(MxN).
%                (Will use sw_g instead of the default g=9.8 m^2/s)
%                (Will also calc d(z) instead of d(p) in numerator)
% OUTPUT:
%   bfrq  = Brunt-Vaisala Frequency squared (M-1xN)                  [s^-2]
%   vort  = Planetary Potential Vorticity   (M-1xN)               [(ms)^-1]
%           (if isempty(LAT) vort=NaN )
%   p_ave = Mid pressure between P grid     (M-1xN)                  [dbar]
%
% AUTHOR:  Phil Morgan 93-06-24, Lindsay Pender (Lindsay.Pender@csiro.au)
%          Greg Johnson (gjohnson@pmel.noaa.gov) added potential vorticity 
%          calcuation
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%
%   Bray, N. A. and N. P. Fofonoff, 1981: Available potential energy for 
%   MODE eddies.  Journal of Physical Oceanography, 11, 30-46.  
%
%   Gill, A. E., 1982: "Atmosphere-Ocean Dynamics", Academic Press,  
%   New York. ISBN: 0-12-283522-0; see eqn (3.7.9). 
%
%   Jackett, D. R. and T. J. McDougall, 1995: Minimal adjustment of 
%   hydrographic profiles to achieve static stability. Journal of 
%   Atmospheric and Oceanic Technology, 12, 381-389.
%
%   Millard R. C., W. B. Owens and N. P. Fofonoff, 1990: On the calculation
%   of the buoyancy frequency.  Deep-Sea Research, 37. 167-181. 
%

%=========================================================================

% Modifications
% 03-12-12. Lindsay Pender, Converted to ITS-90.
% 06-04-19. Lindsay Pender, Corrected sign of PV.
% 14-12-17. Trevor McDougall and Paul Barker, changes to the introductory 
%           comments. 

% CALLER:  general purpose
% CALLEE:  sw_dens.m sw_pden.m

%$Id: sw_bfrq.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $

%-------------
% Check Inputs
%-------------

error(nargchk(3, 4, nargin));

if nargin == 3
    LAT = [];
end

% Get S,T,P dimensions and check consistency

[ms,ns] = size(S);
[mt,nt] = size(T);
[mp,np] = size(P);

% Check S, T P and have the same shape

if (ms~=mt) | (ns~=nt) | (np~=np)
    error('S, T & P must have same dimensions')
end

% Check S and T have length at least of 2

if (ms * ns == 1)
    error('Length of T, S and P must be at least 2')
end

% If S, T and P are row vectors - transpose

if ms == 1
    S = S';
    T = T';
    P = P';
    transpose = 1;
else
    transpose = 0;
end

% If lat passed then verify dimensions

if ~isempty(LAT)
    [mL,nL] = size(LAT);
    if mL==1 & nL==1
        LAT = LAT*ones(size(S));
    else
        if (ms~=mL) | (ns~=nL)              % S & LAT are not the same shape
            if (ns==nL) & (mL==1)           % copy LATS down each column
                LAT = LAT( ones(1,ms), : );  % s.t. dim(S)==dim(LAT)
            else
                error('Inputs arguments have wrong dimensions')
            end
        end
    end
end

%------
% Begin
%------

if ~isempty(LAT)
    % note that sw_g expects height as argument
    Z = sw_dpth(P,LAT);
    g = sw_g(LAT,-Z);
    f = sw_f(LAT);
else
    Z = P;
    g = 9.8*ones(size(P));
    f = NaN*ones(size(P));
end %if

[m,n] = size(P);
%iup   = 1:m-1;
%ilo   = 2:m;
iup   = 2:m;
ilo   = 1:m-1;
p_ave = (P(iup,:)+P(ilo,:) )/2;
pden_up = sw_pden_ROMS(S(iup,:),T(iup,:),P(iup,:),p_ave);
pden_lo = sw_pden_ROMS(S(ilo,:),T(ilo,:),P(ilo,:),p_ave);

mid_pden = (pden_up + pden_lo )/2;
dif_pden = pden_up - pden_lo;
mid_g    = (g(iup,:)+g(ilo,:))/2;
dif_z    = diff(Z);
n2       = -mid_g .* dif_pden ./ (dif_z .* mid_pden);

mid_f    = f(iup,:);
q        = -mid_f .* dif_pden ./  (dif_z .* mid_pden);

if transpose
    n2    = n2';
    q     = q';
    p_ave = p_ave';
end

