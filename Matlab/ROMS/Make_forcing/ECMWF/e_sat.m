function e_sat = e_sat(T)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Calculate Saturation Vapor Pressure
%       T: Temperature (K)
%       J. Jung
%
%       http://www.ecmwf.int/sites/default/files/elibrary/2015/9211-part-iv-physical-processes.pdf
%       Eq. 7.5 7.6 and A.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ti and T0 represent the threshold temperatures between which a mixed phase is allowed to exist
T0 = 273.16; % K
Ti = 250.16; % K

% Parameters set for saturation over water
a1_w = 611.21; % Pa
a3_w = 17.502;
a4_w = 32.19; % K
e_sat_w = a1_w.*exp(a3_w.*((T-T0) ./ (T-a4_w))); % e_sat with respect to water

% Parameters set for saturation over ice
a1_i = 611.21; % Pa
a3_i = 22.587;
a4_i = -0.7; % K
e_sat_i = a1_i.*exp(a3_i.*((T-T0) ./ (T-a4_i))); % e_sat with respect to ice

alpha = zeros(size(T));
alpha(T <= Ti) = 0;
alpha(T >= T0) = 1;
ind = find(T < T0 & T > Ti);
alpha(ind) = ((T(ind) - Ti)./(T0 - Ti)).^2;

e_sat = alpha.*e_sat_w + (1-alpha).*e_sat_i;