%  This script adds river runoff data to an existing FORCING NetCDF file.

global IPRINT

IPRINT=0;
IWRITE=1;

Fname='/n2/arango/Kagom/kagom_frc_test.nc';
Rname='/n2/arango/Kagom/kagom_surface_forcing.mat';

N=20;                                   % Number of vertical levels
Tstart=julian(1998,3,19,0)-2440000;     % Mar 19, 1998, 0000 UTC

%-----------------------------------------------------------------------
%  Set out river name, location, and runoff direction.
%-----------------------------------------------------------------------
%
%  Notice that for now the river identification number is that of the
%  river count.  This variable is needed to fool ROMS generic IO
%  interphase; it can be any real number since will never used.

Name='Saco'; lstr=length(Name);
River.Name(1,1:lstr)=Name;
River.Xpos(1)=1;
River.Ypos(1)=52;
River.dir (1)=1;
River.num (1)=1;

Name='Kennebec-Androscoggin'; lstr=length(Name);
River.Name(2,1:lstr)=Name;
River.Xpos(2)=31;
River.Ypos(2)=74;
River.dir (2)=1;
River.num (2)=2;

Name='Penobscot'; lstr=length(Name);
River.Name(3,1:lstr)=Name;
River.Xpos(3)=66;
River.Ypos(3)=78;
River.dir (3)=1;
River.num (3)=3;

Name='St. Johns'; lstr=length(Name);
River.Name(4,1:lstr)=Name;
River.Xpos(4)=131;
River.Ypos(4)=78;
River.dir (4)=1;
River.num (4)=4;

Nrivers=length(River.dir);

%-----------------------------------------------------------------------
%  Read in river data.
%-----------------------------------------------------------------------

load(Rname);
clear met*

%-----------------------------------------------------------------------
%  Fill river data into structure array.
%-----------------------------------------------------------------------
%
%  The nondimensional river mass transport vertical shape profile MUST
%  add to UNITY, sum(River.vshape(i,:))=1.

River.time=Tstart+runoff(:,1)./24;
Nrec=length(River.time);

for i=1:Nrivers,
  River.trans(i,:)=runoff(:,i+1);
  River.vshape(i,1:N)=1/N;
end,

temp=runoff(:,Nrivers+2);
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
