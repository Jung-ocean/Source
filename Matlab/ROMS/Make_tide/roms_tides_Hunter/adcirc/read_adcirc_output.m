function [z_constituents,u_constituents,v_constituents,lon,lat ] = read_adcirc_output ( input_adcirc_file )
% READ_ADCIRC_OUTPUT:  reads output of OTPS executable "extract_HC"
%
% The tidal constituents that are extracted can be one of
%         m2, s2, n2, k2, t2, l2, k1, o1, p1, q1, m1, j1, mf, mm, ssa, 
%         m4, and m6
%
% USAGE:  [output_constituents, lon, lat] = read_adcirc_output ( input_adcirc_file );
%
% PARAMETERS:
% Input:
%     input_adcirc_file:
%         ascii text file produces by "tides_v1.05a.out"
%
%
% Output:
%     output_constituents:
%         array of structures.  Each structure has the following fields:
%             Name
%             Period
%             Amplitude
%             Phase
%         The structure is sorted into descending order with respect to
%         the period.
%     lon, lat:
%         Optionally, the longitude and latitude of the points at which
%         the tidal harmonics are defined.
%
% 

afid = fopen ( input_adcirc_file, 'r' );
if afid == -1
	msg = sprintf ( '%s:  fopen failed on %s.\n', mfilename, input_otps_file );
	error ( msg );
end



%
% Get past the header
% ADCIRC produces a header that looks something like the following
%
%        Constituent             Elevation                East Velocity            North Velocity
%           Name/              Amplitude     Phase      Amplitude     Phase      Amplitude     Phase
%     Lon          Lat            (m)        (deg)         (m/s)      (deg)         (m/s)      (deg)
%

Ic=1;


%
% Scan thru it to get the number of lines

data=[];

flag=0;


while 1
%for i=1:30
	tline = fgetl ( afid );
	
        if length(tline) == 11 
          Ibl=find(~isspace(tline));
          constituents{Ic}=tline(Ibl);            
          Ic=Ic+1;
          flag=1;
        end
        if length(tline) == 99 & flag
          tmp=[];
          
          while length(tline) == 99
          tmp=[tmp;str2num(tline)];
          tline = fgetl ( afid );
       %   size(tmp)
          end
          
          data=cat(3,data,tmp);
          size(data)
     
        end
	if ~ischar ( tline )
		break;
	end

end

dims=size(data)



num_constituents = length(constituents);

%
% Classify the tidal components.
for j = 1:num_constituents
  
  lower(constituents{j})
  
	%
	% what is the period?
	switch ( lower(constituents{j}) )

	%
	% semi-diurnal components
	case 'm2'
		period(j) = 12.4206;
	case 's2'
		period(j) = 12.0000;
	case 'n2'
		period(j) = 12.6583;
	case 'k2'
		period(j) = 11.97;
	case 't2'
		period(j) = 12.01;
	case 'l2'
		period(j) = 12.19;

	%
	% Diurnal components
	case 'k1'
		period(j) = 23.9345;
	case 'o1'
		period(j) = 25.8193;
	case 'p1'
		period(j) = 24.07;
	case 'q1'
		period(j) = 26.87;
	case 'm1'
		period(j) = 24.86;
	case 'j1'
		period(j) = 23.10;

	%
	% Long period components
	case 'mf'
		period(j) = 327.86;
	case 'mm'
		period(j) = 661.30;
	case 'ssa'
		period(j) = 2191.43;

	case 'm4'
		period(j) = 6.21;

	case 'm6'
		period(j) = 4.14;

	otherwise
		msg = sprintf ( ['%s:  unknown tidal component  ' ...
                '%s\n'], constituents{j} );
              
                
               
		%error ( msg );
	end

end

period=period(2:end);
constituents(1)=[];
data=data(:,:,2:end);


%
% Get past the header
% ADCIRC produces a header that looks something like the following
%
%        Constituent             Elevation                East Velocity            North Velocity
%           Name/              Amplitude     Phase      Amplitude     Phase      Amplitude     Phase
%     Lon          Lat            (m)        (deg)         (m/s)      (deg)         (m/s)      (deg)
%
%
% Load the output structure with the proper components
for j = 1:length(period)
	z_constituents(j) = struct ( 'Name', constituents{j}, 'Amplitude', data(:,3,j), 'Phase', data(:,4,j), 'Period', period(j) );
end

for j = 1:length(period)
	u_constituents(j) = struct ( 'Name', constituents{j}, 'Amplitude', data(:,5,j), 'Phase', data(:,6,j), 'Period', period(j) );
end

for j = 1:length(period)
	v_constituents(j) = struct ( 'Name', constituents{j}, 'Amplitude', data(:,7,j), 'Phase', data(:,8,j), 'Period', period(j) );
end


%
% sort the periods into descending order, use that to sort the output into
% descending order with regards to the period.
%[dud, I] = sort ( period, 'descend' );
[dud, I] = sort ( period);% edited for a different
I=flipud(I);% version of sort
dud=flipud(dud);
lon=data(:,1,1);
lat=data(:,2,1);

z_constituents = z_constituents(I);
u_constituents = u_constituents(I);
v_constituents = v_constituents(I);
