function factor = bio_unit_factor(from_units, to_units)

%
% BIO_UNIT_FACTOR:  Multiplicative factor between two concentration units
%
% factor = bio_unit_factor(from_units, to_units)
%
% Computes the multiplicative factor to convert a biology tracer value
% expressed in 'from_units' to 'to_units'.  Units are expected to follow
% the usual ROMS biology tracer convention:
%
%    <scale prefix><mole|gram>[_<quantity>] <per-volume>
%
% for example:  'millimole_nitrogen meter-3', 'micromole_nitrogen liter-1',
%               'milligrams_chlorophyll meter-3', 'milligrams meter-3'.
%
% On Input:
%
%    from_units    Units string of the source value (string)
%    to_units      Units string of the desired value (string)
%
% On Output:
%
%    factor        Multiplicative conversion factor such that:
%                     value_in_to_units = value_in_from_units * factor
%                   Returns NaN if the units cannot be reconciled (for
%                   example, different underlying quantities such as
%                   nitrogen versus carbon, or an unrecognized unit
%                   string).
%

factor = NaN;

fp = parse_conc_units(from_units);
tp = parse_conc_units(to_units);

if (isempty(fp) || isempty(tp)),
  return
end

%  If both units name a quantity (e.g. 'nitrogen', 'carbon',
%  'chlorophyll'), they must agree.  An empty quantity (e.g. plain
%  'milligrams meter-3') is treated as a wildcard.

if (~isempty(fp.quantity) && ~isempty(tp.quantity) &&                    ...
    ~strcmpi(fp.quantity, tp.quantity)),
  return
end

factor = (fp.scale/tp.scale) * (fp.volume/tp.volume);

return

%--------------------------------------------------------------------------

function p = parse_conc_units(units)

%
%  Parses a concentration units string of the form:
%
%     <scale prefix><mole|gram(s)>[_<quantity>] <per-volume>
%
%  into its scale factor (relative to mole or gram), base quantity name
%  (e.g. 'nitrogen', 'carbon', 'chlorophyll', or '' if unspecified), and
%  per-volume factor (relative to meter-3).  Returns [] if the string
%  cannot be parsed.
%

p = [];

units = lower(strtrim(units));
parts = regexp(units, '\s+', 'split');

if (length(parts) ~= 2),
  return
end

mass_part = parts{1};
vol_part  = parts{2};

%  Recognized scale prefixes (relative to the base mole/gram unit).

scales = {'nano', 1.0e-9; 'micro', 1.0e-6; 'milli', 1.0e-3;              ...
          'centi', 1.0e-2; 'kilo',  1.0e+3};

prefix_scale = 1;
rest = mass_part;
for n=1:size(scales,1),
  pre = scales{n,1};
  if (strncmp(rest, pre, length(pre))),
    prefix_scale = scales{n,2};
    rest = rest(length(pre)+1:end);
    break
  end
end

%  Recognized base units: mole or gram(s).

bases = {'mole', 'grams', 'gram'};

found_base = false;
for n=1:length(bases),
  b = bases{n};
  if (strncmp(rest, b, length(b))),
    rest = rest(length(b)+1:end);
    found_base = true;
    break
  end
end

if (~found_base),
  return
end

%  Optional quantity name after an underscore (e.g. 'nitrogen').

quantity = '';
if (~isempty(rest) && rest(1) == '_'),
  quantity = rest(2:end);
end

%  Recognized per-volume units (relative to meter-3).

switch (vol_part)
  case 'meter-3'
    vol_scale = 1;
  case 'liter-1'
    vol_scale = 1.0e+3;             % 1 L-1 concentration = 1000x m-3
  case 'centimeter-3'
    vol_scale = 1.0e+6;             % 1 cm-3 concentration = 1e6x m-3
  otherwise
    return                         % unrecognized per-volume unit
end

p.scale    = prefix_scale;
p.quantity = quantity;
p.volume   = vol_scale;

return
