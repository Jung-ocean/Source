function P = spitz_bio_params()

%
% SPITZ_BIO_PARAMS:  Ratios used to build the Spitz biology tracers
%
% P = spitz_bio_params()
%
% Returns the ratios and background values used by make_spitz_bio.m to
% build the Spitz biology model initial conditions from a donor ROMS
% file whose biology is a BIO_FENNEL-type model (LiveOcean).  Keeping
% them here means every driver script that builds these tracers uses the
% same values.  A driver may override any field before passing P to
% make_spitz_bio.
%
% On Output:
%
%    P          Structure with fields:
%
%                 P.phyto_diatom_split  Fraction of donor 'phytoplankton'
%                                         assigned to Phytoplankton; the
%                                         remainder becomes Diatoms
%                 P.zoo_micro_split     Fraction of donor 'zooplankton'
%                                         assigned to Microzooplankton;
%                                         the remainder becomes
%                                         Mesozooplankton
%                 P.ChlN_phyto          Chl:N for small phytoplankton
%                                         (mg Chl per mmol N)
%                 P.ChlN_diatom         Chl:N for diatoms
%                                         (mg Chl per mmol N)
%                 P.SiN_ratio           Si:N for Silica from NO3 and
%                                         LDetS from LDetN
%                 P.CN_ratio            Redfield C:N for DOC from DON
%                 P.Bacteria_fraction   Bacteria as a fraction of
%                                         Phytoplankton
%                 P.Bio_background      Small non-zero background value
%                                         (millimole_nitrogen meter-3)
%

P.phyto_diatom_split = 0.8;      % donor phytoplankton -> Phytoplankton
P.zoo_micro_split    = 0.5;      % donor zooplankton   -> Microzooplankton
P.ChlN_phyto         = 0.6;      % Chl:N, small phytoplankton
P.ChlN_diatom        = 2.0;      % Chl:N, diatoms
P.SiN_ratio          = 1.0;      % Si:N, not Fe limited
P.CN_ratio           = 6.625;    % Redfield C:N
P.Bacteria_fraction  = 0.10;     % Bacteria as fraction of Phytoplankton
P.Bio_background     = 1.0e-2;   % small non-zero background
P.clamp_negative     = true;     % clamp interpolation undershoot at zero

return
