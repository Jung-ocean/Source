function [lon_sat, lat_sat, SST_sat] = load_MODIS_monthly(yyyy,mm)

    ystr = num2str(yyyy);
    mstr = num2str(mm, '%02i');
    
    filepath = ['/data/jungjih/Observations/Satellite_SST/MODIS_Aqua/monthly/'];
    files = dir([filepath, '*', ystr, mstr, '*']);
    if length(files) == 1
        filename = files(1).name;
    else
        error('More than one files are found')
    end
    file = [filepath, filename];

    lon_sat = double(ncread(file, 'lon'));
    lat_sat = double(ncread(file, 'lat'));
    SST_sat = ncread(file, 'sst');
    qual_sst = ncread(file, 'qual_sst');

    lon1 = find(lon_sat > 0);
    lon2 = find(lon_sat < 0);
    lon_sat = [lon_sat(lon1)-360; lon_sat(lon2)];
    SST_sat = [SST_sat(lon1,:); SST_sat(lon2,:)];
    qual_sst = [qual_sst(lon1,:); qual_sst(lon2,:)];

    % Only a quality flag of 0 is selected
    % https://deotb6e7tfubr.cloudfront.net/s3-edaf5da92e0ce48fb61175c28b67e95d/podaac-ops-cumulus-docs.s3.us-west-2.amazonaws.com/modis/open/L3/docs/modis_sst.html?A-userid=jihun.jung&Expires=1780954173&Signature=WLHYiaEE0IZzViKdieQ9xdYapUBclUNPp37YEexng5J3FhImwlKQL1E4LxY7ZoJ0Na1iyZo5qt8M5QRRzYIa3S6AKhketdHY8cV3n2IJCctwaUqhiCXddZBXxn8cy4x-2zpBr0JXz0NPiE1baE~-sf2NYvF6kAyyF39tKnXz~~bydB0NR90AHf7okHv83fjjeOryveTWFnitI7d51XVTY8yBsaQ9GGG6hu~exUWoaene8hWapCqnvVFb9F8rPl8MxArA95qu4zXx3J-f6YqyQ0q9UkcRqUbDJHDUczr920OgwTY4rercfsRJ4vlWMFuTySGCCL4c3HjpqSR~pW7HLA__&Key-Pair-Id=K2ZRJX44OZF4UU
    index = find(qual_sst ~= 0);
    SST_sat(index) = NaN;

end