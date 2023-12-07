function [taux,tauy]=wind_stress(u,v);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%  function [taux,tauy]=wind_stress(u,v)                               %
%                                                                      %
%  This function computes wind stress using Large and Pond formula.    %
%                                                                      %
%  On Input:                                                           %
%                                                                      %
%     u         East-West wind component (m/s).                        %
%     v         North-South wind component (m/s).                       %
%                                                                      %
%  On Output:                                                          %
%                                                                      %
%     taux      East-West wind stress component (Pa).                  %
%     tauy      North-South wind stress component (Pa).                  %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
%  Compute wind stress.
%-----------------------------------------------------------------------
rhoa=1.22;

speed=sqrt(u.*u + v.*v);

Cd= (0.142 + 0.0764.*speed + 2.7./(speed+0.000001)).*0.001;

taux=rhoa*Cd.*speed.*u;
tauy=rhoa*Cd.*speed.*v;

return
