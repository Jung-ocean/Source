function freq = load_tidal_frequency(constituent)

% Load tidal frequency in cpd
% https://tidesandcurrents.noaa.gov/publications/Tidal_Analysis_and_Predictions.pdf

switch constituent
    case 'M2' % Principal lunar semidiurnal constituent
        freq = 1.9323;
    case 'S2' % Principal solar semidiurnal constituent
        freq = 2.0000;
    case 'K1' % Lunar diurnal constituent
        freq = 1.0027;
    case 'O1' % Lunar diurnal constituent
        freq = 0.9295;
    case 'N2' % Larger lunar elliptic semidiurnal constituent
        freq = 1.8960;
    case 'K2' % Lunisolar semidiurnal constituent
        freq = 2.0055;
    case 'P1' % Solar diurnal constituent
        freq = 0.9973;
    case 'Q1' % Larger lunar elliptic diurnal constituent
        freq = 0.8932;
end

disp(['Loading ', constituent, ' frequency in cpd (', num2str(1/(freq/24)), ' hour) ...'])

end