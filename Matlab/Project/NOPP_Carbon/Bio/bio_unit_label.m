function label = bio_unit_label(units)

%
% BIO_UNIT_LABEL:  Compact plot label for a CF-style concentration unit
%
% label = bio_unit_label(units)
%
% Turns the verbose units string stored in the NetCDF files into a short
% label suitable for a colorbar or axis, using Matlab's TeX markup for
% the exponent.  For example:
%
%    'millimole_nitrogen meter-3'      ->  'mmol N m^{-3}'
%    'millimole_carbon meter-3'        ->  'mmol C m^{-3}'
%    'millimole_silica meter-3'        ->  'mmol Si m^{-3}'
%    'milligrams_chlorophyll meter-3'  ->  'mg Chl m^{-3}'
%
% Render it with the 'tex' interpreter so the exponent is superscripted.
%
% On Input:
%
%    units       Units string, as stored in the file (string)
%
% On Output:
%
%    label       Short label (string).  If the units cannot be parsed the
%                  input is returned unchanged.
%

label = units;

u = lower(strtrim(units));
parts = regexp(u, '\s+', 'split');

if (length(parts) ~= 2), return, end

mass_part = parts{1};
vol_part  = parts{2};

%  Scale prefix.

prefixes = {'nano', 'n'; 'micro', '\mu'; 'milli', 'm';                  ...
            'centi', 'c'; 'kilo', 'k'};

pre  = '';
rest = mass_part;
for n = 1:size(prefixes,1)
  p = prefixes{n,1};
  if (strncmp(rest, p, length(p))),
    pre  = prefixes{n,2};
    rest = rest(length(p)+1:end);
    break
  end
end

%  Base unit.

bases = {'mole', 'mol'; 'grams', 'g'; 'gram', 'g'};

base = '';
for n = 1:size(bases,1)
  b = bases{n,1};
  if (strncmp(rest, b, length(b))),
    base = bases{n,2};
    rest = rest(length(b)+1:end);
    break
  end
end

if (isempty(base)), return, end

%  Optional quantity after an underscore.

quantities = {'nitrogen', 'N'; 'carbon', 'C'; 'silica', 'Si';           ...
              'chlorophyll', 'Chl'; 'oxygen', 'O_2'; 'iron', 'Fe';      ...
              'phosphorus', 'P'};

qty = '';
if (~isempty(rest) && rest(1) == '_'),
  qname = rest(2:end);
  qty = qname;
  for n = 1:size(quantities,1)
    if (strcmp(qname, quantities{n,1})),
      qty = quantities{n,2};
      break
    end
  end
end

%  Per-volume part.

switch (vol_part)
  case 'meter-3'
    vol = 'm^{-3}';
  case 'liter-1'
    vol = 'L^{-1}';
  case 'centimeter-3'
    vol = 'cm^{-3}';
  otherwise
    return
end

if (isempty(qty)),
  label = [pre, base, ' ', vol];
else
  label = [pre, base, ' ', qty, ' ', vol];
end

return
