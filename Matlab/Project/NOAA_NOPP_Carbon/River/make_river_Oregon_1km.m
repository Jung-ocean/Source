%  This script will create a river runoff FORCING NetCDF file.
%
%  Paul Goodman's modification of useast_rivers.m (J. Wilkin)
%  BJ Choi's modification AUG 2, 2004.
%  JJ, 04/10/2026
%
%  River.lon  = nominal longitude of river mouth (this routine finds i,j)
%  River.lat  = nominal latitude of river mouth (this routine finds i,j)
%
%  River.dir  = 0 for flow entering cell through u-direction face
%             = 1 for flow entering cell through v-direction face
%
%  River.Xpos,Ypos = the i,j index of the u-point or v-point location on
%             the ROMS C-grid thyat defines the face of the cell through
%             which the river enters.
%             The river input is added to the appropriate ubar, vbar, u,
%             v, and tracer fluxes on this face.
%
%  River.sens = 1 for river flow in the positive u or v direction
%             = -1 for river flow in the negative u or v direction,
%             This factor multiplies the river flow rate Q (>0) (see
%             sources.h for why this is done)
%
%  River.flag can have any of the following values:
%             = 0,  All Tracer source/sink are off.
%             = 1,  Only temperature is on.
%             = 2,  Only salinity is on.
%             = 3,  Both temperature and salinity are on.
clear; clc; close all

IWRITE = 1;
IPLOT = 0;

domain = 'Oregon_1km';
g = grd(domain);
N = g.N;
refdate = datenum(2024,1,1);

Fname = ['river_', domain, '.nc'];

yyyy = 2024;
timenum_target = datenum(yyyy-1,12,31,12,0,0):datenum(yyyy+1,1,1,12,0,0);

rfilepath = '/data/jungjih/Observations/USGS/Oregon_daily/';
rfiles = dir([rfilepath, '*.csv']);
r = 0;
for fi = 1:length(rfiles)
    rfile = [rfilepath, rfiles(fi).name];
    rdata = readtable(rfile);
    timenum = datenum(table2array(rdata(:,5)));
    if length(timenum) == length(timenum_target)
        r = r+1;
        River.num(r) = r;

        tmp = split(rfiles(fi).name, {'_', '.'});
        river_name = [tmp{end-2}, ' ', tmp{end-1}];
        river_location = table2array(rdata(:,12));
        tmp = str2num(river_location{1});
        River.lon(r) = tmp(1);
        River.lat(r) = tmp(2);

        % case flow enters cell through u-direction face
        glon = g.lon_u;
        glat = g.lat_u;
        % keep only u-faces that are coastline
        drhomask = diff(g.mask_rho);
        notcoast = find(drhomask==0);
        glon(notcoast) = NaN;
        glat(notcoast) = NaN;
        % find the u-face closest to the river mouth
        [I,J,du] = closest(glon,glat,River.lon(r),River.lat(r));

        % assume this is best option until we test v-face
        River.Xpos(r) = I;
        River.Ypos(r) = J-1; % ROMS u points start from index j=0
        River.dir(r)  = 0;
        River.sens(r) = drhomask(I,J);
        River.glon(r) = glon(I,J);
        River.glat(r) = glat(I,J);

        % case flow enters cell through v-direction face
        glon = g.lon_v;
        glat = g.lat_v;
        % keep only v-faces that are coastline
        drhomask = diff(g.mask_rho')';
        notcoast = find(drhomask==0);
        glon(notcoast) = NaN;
        glat(notcoast) = NaN;
        % find the v-face closest to the river mouth
        [I,J,dv] = closest(glon,glat,River.lon(r),River.lat(r));

        if dv < du
            % overwrite because v-face result is closer to river mouth
            River.Xpos(r) = I-1; % ROMS v points start from index i=0
            River.Ypos(r) = J;
            River.dir(r)  = 1;
            River.sens(r) = drhomask(I,J);
            River.glon(r) = glon(I,J);
            River.glat(r) = glat(I,J);
        end

        river_discharge = table2array(rdata(:,6));
        river_unit = table2array(rdata(:,7));
        if strcmp(river_unit{1}, 'ft^3/s')
            river_discharge = river_discharge.*0.0283168; % ft^3/s to m^3/s
        end

        River.Name{r} = river_name;
        River.vshape(r,1:N) = 1/N;
        River.trans(r,:) = River.sens(r)*river_discharge;

        % Temperature
        [lon_sat, lat_sat, SST_sat] = load_OSTIA_river_point(River.glon(r), River.glat(r), timenum_target);
        for ni = 1:N
            River.temp(r,ni,:) = SST_sat;
        end
    end

    disp(river_name)
end

% Salinity
River.salt = 0.*River.temp;

Nrivers = length(River.Name);

% plot the original and selected lon/lat to check that the lookup was done
% sensibly
if IPLOT
    addpath('/home/server/pi/homes/jungjih/Source/Matlab/ROMS/ROMS_Wilkin');
    figure; hold on; grid on;
    set(gcf, 'Position', [1 200 800 800])

    pcolorjw(g.lon_rho,g.lat_rho,g.mask_rho./g.mask_rho)

    for ri = 1:Nrivers
        switch River.dir(ri)
            case 0
                if River.sens(ri) == 1
                    sym = '>';
                elseif River.sens(ri) == -1
                    sym = '<';
                end
            case 1
                if River.sens(ri) == 1
                    sym = '^';
                elseif River.sens(ri) == -1
                    sym = 'v';
                end
        end

        han = plot(River.lon(ri),River.lat(ri),'bd');
        set(han,'markersize',10,'MarkerFaceColor',get(han,'color'))
        han = plot(River.glon(ri),River.glat(ri),['r', sym]);
        set(han,'markersize',10,'MarkerFaceColor',get(han,'color'))
        han = plot([River.lon(ri); River.glon(ri)],[River.lat(ri); River.glat(ri)],'r-');
        set(han,'linewidth',2)

        han = text(River.lon(ri),River.lat(ri),...
            [ ' (' int2str(ri) ') ' deblank(River.Name{ri})]);
        set(han,'fontsize',12)
    end

    xlim([-125 -122.5]);
    xlabel('Longitude (^oE)')
    ylabel('Latitude (^oN)')
    set(gca, 'FontSize', 12)
    title(['Blue = station, Red = river source and direction'], 'FontSize', 15)
    print('river_source', '-dpng')

    rmpath('/home/server/pi/homes/jungjih/Source/Matlab/ROMS/ROMS_Wilkin');
end

detailstr = ['The ' int2str(Nrivers) ' Rivers are : '];
for r=1:Nrivers
    detailstr = [detailstr int2str(r) '. ' strcat(River.Name{r}) ', '];
end
detailstr = [detailstr(1:end-2) '.'];

% River.time
ocean_time = timenum_target - refdate;
ocean_time(ocean_time < 0) = 0;
River.time = ocean_time;
River.time_units = 'days';

%-----------------------------------------------------------------------
%  Create empty river data FORCING NetCDF file.
%-----------------------------------------------------------------------

Nstr = num2str(N);
Nrstr = num2str(Nrivers);
yyyymmddHHMMSS = datestr(refdate, 'yyyy-mm-dd HH:MM:SS');
titlestr = [domain, ' River Forcing'];
grdstr = g.grd_file;
riverstr = detailstr;
historystr = ['created on ', datestr(today, 'yyyy-mm-dd')];

txt = fileread('frc_rivers.cdl');

oldStr = {'Nstr', 'Nrstr', 'yyyymmddHHMMSS', 'titlestr', 'grdstr', 'riverstr', 'historystr'};
newStr = {Nstr, Nrstr, yyyymmddHHMMSS, titlestr, grdstr, riverstr, historystr};

for i = 1:length(oldStr)
    txt = strrep(txt, oldStr{i}, newStr{i});
end

cdlname = [domain, '.cdl'];
fid = fopen(cdlname, 'w');
fwrite(fid, txt);
fclose(fid);

disp([ 'Creating ' Fname '...'])

command = ['ncgen -b -o ', Fname, ' ', cdlname];
system(command)

%-----------------------------------------------------------------------
%  Write river data into existing FORCING NetCDF file.
%-----------------------------------------------------------------------

disp([ 'Appending rivers data to ' Fname '...'])

% write_rivers
ncwrite(Fname, 'river', River.num);
ncwrite(Fname, 'river_direction', River.dir);
ncwrite(Fname, 'river_Xposition', River.Xpos);
ncwrite(Fname, 'river_Eposition', River.Ypos);
ncwrite(Fname, 'river_Vshape', River.vshape);
ncwrite(Fname, 'river_time', River.time);
ncwrite(Fname, 'river_transport', River.trans);
ncwrite(Fname, 'river_temp', River.temp);
ncwrite(Fname, 'river_salt', River.salt);