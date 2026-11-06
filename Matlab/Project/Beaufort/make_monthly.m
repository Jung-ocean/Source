clear; clc;

vari_str = 'SIC';
switch vari_str
    case 'SIT'
        varname = 'sea_ice_thickness';
    case 'SIC'
        varname = 'sea_ice_concentration';
end

lonname = 'lon';
latname = 'lat';

yyyy_all = 2010:2025;
month_all = 1:12;

filepath_all = '/data/jungjih/Observations/Sea_ice/SIT/AWI/weekly/';

for yi = 1:length(yyyy_all)

    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(month_all)

        month = month_all(mi);
        mstr = sprintf('%02d', month);

        % Define the monthly input directory and output file
        filepath = fullfile(filepath_all, ystr, mstr);
        output_file = sprintf('%s_%s_%s.mat', vari_str, ystr, mstr);

        % Check whether the monthly directory exists
        if ~isfolder(filepath)
            fprintf('Skipping missing directory: %s\n', filepath);
            continue;
        end

        % Find all NetCDF files in the monthly directory
        files = dir(fullfile(filepath, '**', '*.nc'));

        if isempty(files)
            fprintf('Skipping month with no NetCDF files: %s\n', filepath);
            continue;
        end

        nFiles = numel(files);
        fprintf('\n%s-%s: Found %d NetCDF files.\n', ...
            ystr, mstr, nFiles);

        % Read longitude and latitude
        firstFile = fullfile(files(1).folder, files(1).name);

        lon = double(ncread(firstFile, lonname));
        lat = double(ncread(firstFile, latname));

        % Initialize accumulators
        sumvari = [];
        hasMissing = [];
        nTotal = 0;

        % Process all files and all time records in this month
        for iFile = 1:nFiles

            filename = fullfile(files(iFile).folder, files(iFile).name);

            fprintf('Processing %d/%d: %s\n', ...
                iFile, nFiles, files(iFile).name);

            % Read the selected variable
            info = ncinfo(filename, varname);
            data = double(ncread(filename, varname));

            % Handle the declared fill value, if present
            fillValue = [];

            for iAttr = 1:numel(info.Attributes)
                if strcmp(info.Attributes(iAttr).Name, '_FillValue')
                    fillValue = double(info.Attributes(iAttr).Value);
                    break;
                end
            end

            if ~isempty(fillValue)
                if isnan(fillValue)
                    data(isnan(data)) = NaN;
                else
                    data(data == fillValue) = NaN;
                end
            end

            % Treat all non-finite values as missing
            data(~isfinite(data)) = NaN;

            % Ensure that the time dimension is present
            if ndims(data) < 3
                data = reshape(data, size(data, 1), size(data, 2), 1);
            end

            % Initialize arrays using the spatial dimensions
            if isempty(sumvari)
                spatialSize = size(data);
                spatialSize = spatialSize(1:2);

                sumvari = zeros(spatialSize);
                hasMissing = false(spatialSize);
            end

            % Check spatial dimensions
            if size(data, 1) ~= size(sumvari, 1) || ...
                    size(data, 2) ~= size(sumvari, 2)
                error('Spatial dimensions do not match in file: %s', ...
                    filename);
            end

            % Accumulate every time record
            for it = 1:size(data, 3)

                slice = data(:, :, it);
                missing = isnan(slice);

                hasMissing = hasMissing | missing;

                % Add valid values; missing locations are masked later
                slice(missing) = 0;
                sumvari = sumvari + slice;

                nTotal = nTotal + 1;
            end
        end

        % Calculate the strict monthly mean
        % Every grid cell must have valid data in every record.
        vari = sumvari ./ nTotal;
        vari(hasMissing) = NaN;

        % Assign the result to the variable named SIC or SIT
        eval([vari_str, ' = vari;']);

        % Save the monthly result
        save(output_file, vari_str, 'lon', 'lat', '-v7.3');

        fprintf('Saved monthly result: %s\n', output_file);
        fprintf('Total files: %d, total records: %d\n', ...
            nFiles, nTotal);

    end
end