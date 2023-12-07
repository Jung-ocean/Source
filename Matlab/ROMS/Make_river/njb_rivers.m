%  This script adds river runoff data to an existing FORCING NetCDF file.

global IPRINT

IPRINT=0;
IWRITE=1;

Fname='/n7/arango/NJB/Jul00/Data/njb1_coamps_jul00b.nc';
Rname='/n0/arango/ocean/matlab/rivers/njb_rivers.dat';

N=25;                                   % Number of vertical levels

%-----------------------------------------------------------------------
%  Set out river name, location, and runoff direction.
%-----------------------------------------------------------------------
%
%  Notice that for now the river identification number is that of the
%  river count.  This variable is needed to fool ROMS generic IO
%  interphase; it can be any real number since will never used.
%
%  The River flag can have any of the following values:
%
%      River.flag(:) = 0,  All Tracer source/sink are off.
%      River.flag(:) = 1,  Only temperature is on.
%      River.flag(:) = 2,  Only salinity is on.
%      River.flag(:) = 3,  Both temperature and salinity are on. 
%

Name='Delaware-Schuylkill'; lstr=length(Name);
River.Name(1,1:lstr)=Name;
River.Xpos(1)=1;
River.Ypos(1)=22;
River.dir (1)=0;
River.num (1)=1;
River.flag(1)=2;

Name='Manasquan'; lstr=length(Name);
River.Name(2,1:lstr)=Name;
River.Xpos(2)=1;
River.Ypos(2)=187;
River.dir (2)=0;
River.num (2)=2;
River.flag(2)=2;

Name='Metedeconk'; lstr=length(Name);
River.Name(3,1:lstr)=Name;
River.Xpos(3)=1;
River.Ypos(3)=183;
River.dir (3)=0;
River.num (3)=3;
River.flag(3)=2;

Name='Hudson-Passaic et al.'; lstr=length(Name);
River.Name(4,1:lstr)=Name;
River.Xpos(4)=1;
River.Ypos(4)=239;
River.dir (4)=1;
River.num (4)=4;
River.flag(4)=2;

Name='Hudson-Passaic et al.'; lstr=length(Name);
River.Name(5,1:lstr)=' ';
River.Xpos(5)=2;
River.Ypos(5)=239;
River.dir (5)=1;
River.num (5)=5;
River.flag(5)=2;

Name='Hudson-Passaic et al.'; lstr=length(Name);
River.Name(6,1:lstr)=' ';
River.Xpos(6)=3;
River.Ypos(6)=239;
River.dir (6)=1;
River.num (6)=6;
River.flag(6)=2;

Name='Hudson-Passaic et al.'; lstr=length(Name);
River.Name(7,1:1)=' ';
River.Xpos(7)=4;
River.Ypos(7)=239;
River.dir (7)=1;
River.num (7)=7;
River.flag(7)=2;

Name='Hudson-Passaic et al.'; lstr=length(Name);
River.Name(8,1:1)=' ';
River.Xpos(8)=5;
River.Ypos(8)=239;
River.dir (8)=1;
River.num (8)=8;
River.flag(8)=2;

Nrivers=length(River.dir);

%-----------------------------------------------------------------------
%  Read in river data.
%-----------------------------------------------------------------------

Rdat=load(Rname);

scale =0.3048^3;

Year  =Rdat(:,1);
Month =Rdat(:,2);
Day   =Rdat(:,3);
temp  =Rdat(:,8);
runoff=Rdat(:,4:7).*scale;

%-----------------------------------------------------------------------
%  Fill river data into structure array.
%-----------------------------------------------------------------------
%
%  The nondimensional river mass transport vertical shape profile MUST
%  add to UNITY, sum(River.vshape(i,:))=1.

River.time=julian(Year,Month,Day,12.0)-2440000;
Nrec=length(River.time);

for i=1:Nrivers,
  if (i > 3),
    River.trans(i,:)=runoff(:,4)./5;       % The Hudson is distributed
  else                                     % over 5 points.
    River.trans(i,:)=runoff(:,i);
  end,
  River.vshape(i,1:N)=1/N;
end,

salt=0;
for i=1:Nrec,
  River.temp(:,:,i)=ones([Nrivers N]).*temp(i);
  River.salt(:,:,i)=ones([Nrivers N]).*salt;
end,

%-----------------------------------------------------------------------
%  Write river data into existing FORCING NetCDF file.
%-----------------------------------------------------------------------

if (IWRITE),
  [Vname,status]=wrt_rivers(Fname,River);
end,
